import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class VipTab extends StatefulWidget {
  const VipTab({super.key, required this.user});
  final UserEntity user;

  @override
  State<VipTab> createState() => _VipTabState();
}

class _VipTabState extends State<VipTab> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;
  List<int> _ownedVips = const [];
  int? _selectedVip;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _fetchOwnedVips();
  }

  Future<void> _fetchOwnedVips() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.get('/my/vip');
      final data = res.data;
      dynamic parsed;
      if (data is String) {
        parsed = data.isNotEmpty ? jsonDecode(data) : null;
      } else {
        parsed = data;
      }
      List<int> vips = [];
      if (parsed is Map<String, dynamic>) {
        final anyList = parsed['vips'] ??
            parsed['data'] ??
            parsed['vip'] ??
            parsed['items'];
        if (anyList is List) {
          vips = anyList
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .where((v) => v > 0)
              .toList();
        }
      } else if (parsed is List) {
        vips = parsed
            .map((e) => int.tryParse(e.toString()) ?? 0)
            .where((v) => v > 0)
            .toList();
      }
      vips.sort();
      setState(() {
        _ownedVips = vips;
        if (_ownedVips.isNotEmpty) _selectedVip = _ownedVips.first;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _applyVip() async {
    if (_selectedVip == null) return;
    setState(() => _applying = true);
    try {
      await _api.post('/use/vip', data: {"vip": _selectedVip});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تفعيل VIP ${_selectedVip} بنجاح')),
      );
      // Refresh myprofile to reflect new VIP immediately
      try {
        await context.read<UserCubit>().getProfileUser('vip_use', fast: true);
      } catch (_) {
        // ignore refresh errors silently
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التفعيل: $e')),
      );
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.golden),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('حدث خطأ أثناء جلب الـ VIP'),
            const SizedBox(height: 8),
            Text(_error!,
                style: const TextStyle(
                    color: const Color(0xFFFF0000), fontSize: 12)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchOwnedVips,
              child: const Text('إعادة المحاولة'),
            )
          ],
        ),
      );
    }
    if (_ownedVips.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.verified_outlined, size: 48, color: AppColors.golden),
            SizedBox(height: 12),
            Text('لا تملك أي VIP حالياً'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: _ownedVips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final vip = _ownedVips[index];
              final selected = vip == _selectedVip;
              final previewUser = widget.user.copyWith(vip: vip.toString());

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedVip = vip),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            selected ? AppColors.golden : Colors.grey.shade300,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: UserWidgetTitle(
                      user: previewUser,
                      userCubit: null,
                      isID: true,
                      isIcon: false,
                      isWakel: true,
                      isRoomTypeUser: true,
                      trailing: Radio<int>(
                        value: vip,
                        groupValue: _selectedVip,
                        fillColor: MaterialStateProperty.resolveWith(
                          (states) => AppColors.golden,
                        ),
                        activeColor: AppColors.golden,
                        onChanged: (v) => setState(() => _selectedVip = v),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.golden,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed:
                    (_selectedVip == null || _applying) ? null : _applyVip,
                child: _applying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('استخدام'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
