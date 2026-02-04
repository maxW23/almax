import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/room/presentation/views/widgets/media_player/player_assets.dart';
import 'package:lklk/features/room/presentation/manger/player/playlist_cubit.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

/// BottomSheet لعرض أغاني الجهاز مع تحديد متعدد وإضافتها إلى قائمة التشغيل
class DeviceSongsBottomSheet extends StatefulWidget {
  const DeviceSongsBottomSheet({super.key});

  @override
  State<DeviceSongsBottomSheet> createState() => _DeviceSongsBottomSheetState();
}

class _DeviceSongsBottomSheetState extends State<DeviceSongsBottomSheet> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = const [];
  final Set<int> _selected = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // طلب صلاحية الوصول إلى الوسائط
      if (Platform.isAndroid) {
        // استخدم آلية الإذن المضمنة في OnAudioQuery لتغطية READ_MEDIA_AUDIO/READ_EXTERNAL_STORAGE
        bool granted = await _audioQuery.permissionsStatus();
        if (!granted) granted = await _audioQuery.permissionsRequest();
        if (!granted) {
          setState(() => _error =
              'يرجى منح صلاحية الوصول إلى ملفات الصوت لعرض أغاني الجهاز.');
          return;
        }
      }
      if (Platform.isIOS) {
        // على iOS نستخدم mediaLibrary من permission_handler
        final status = await Permission.mediaLibrary.request();
        if (!status.isGranted) {
          setState(() => _error = 'يرجى منح صلاحية الوصول إلى مكتبة الموسيقى.');
          return;
        }
      }

      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );
      setState(() {
        _songs = songs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر قراءة أغاني الجهاز: $e';
        _loading = false;
      });
    }
  }

  void _toggle(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _addSelected() async {
    if (_selected.isEmpty) return;
    final playlist = context.read<PlaylistCubit>();
    final List<String> addedPaths = [];

    for (final s in _songs.where((e) => _selected.contains(e.id))) {
      final path = s.data; // قد يكون مسار حقيقي أو content uri
      try {
        if (path.startsWith('/')) {
          // مسار ملف مباشر
          final newPath = await playlist.copyToAppDir(path, fileName: s.title);
          addedPaths.add(newPath);
        } else if ((s.uri ?? '').startsWith('file://')) {
          final p = Uri.parse(s.uri!).toFilePath();
          final newPath = await playlist.copyToAppDir(p, fileName: s.title);
          addedPaths.add(newPath);
        } else {
          // لا يمكن النسخ من content uri مباشرة بدون SAF، نتجاهلها مؤقتاً
        }
      } catch (_) {}
    }

    if (addedPaths.isNotEmpty) {
      await playlist.addPaths(addedPaths);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.playerGradientTop,
            AppColors.playerGradientBottom,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 580,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    Image.asset(
                      PlayerAssets.musicListPng,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: AutoSizeText(
                        'أغاني الجهاز',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => setState(() {
                        if (_selected.length == _songs.length) {
                          _selected.clear();
                        } else {
                          _selected
                            ..clear()
                            ..addAll(_songs.map((e) => e.id));
                        }
                      }),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          gradient: const SweepGradient(colors: [
                            Color(0xff0E3408),
                            Color(0xff296D12),
                            Color(0xff0E3408),
                            Color(0xff296D12),
                            Color(0xff0E3408),
                            Color(0xff296D12),
                          ]),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.select_all_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text('تحديد الكل',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Text(_error!,
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _songs.length,
                            itemBuilder: (ctx, i) {
                              final s = _songs[i];
                              final selected = _selected.contains(s.id);
                              return Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 4.h, horizontal: 8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.glassFill,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.glassBorder, width: 1),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.music_note,
                                      color: Colors.white70),
                                  title: Text(
                                    s.title,
                                    style: const TextStyle(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    s.artist ?? '',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                  trailing: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _toggle(s.id),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      reverseDuration:
                                          const Duration(milliseconds: 140),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: selected
                                          ? Image.asset(
                                              PlayerAssets.tickCirclePng,
                                              key: const ValueKey('selected'),
                                              width: 22,
                                              height: 22,
                                            )
                                          : Image.asset(
                                              PlayerAssets.plusPng,
                                              key: const ValueKey('unselected'),
                                              width: 22,
                                              height: 22,
                                            ),
                                    ),
                                  ),
                                  onTap: () => _toggle(s.id),
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _addSelected,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          gradient: const SweepGradient(colors: [
                            Color(0xff0E3408),
                            Color(0xff296D12),
                            Color(0xff0E3408),
                            Color(0xff296D12),
                            Color(0xff0E3408),
                            Color(0xff296D12),
                          ]),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Text('إضافة المحدد',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
