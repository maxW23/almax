import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/room/presentation/manger/is_active_gifts_cubit/is_active_gifts_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShowHideTopBarSwitch extends StatefulWidget {
  const ShowHideTopBarSwitch({super.key});

  @override
  State<ShowHideTopBarSwitch> createState() => _ShowHideTopBarSwitchState();
}

class _ShowHideTopBarSwitchState extends State<ShowHideTopBarSwitch> {
  final IsActiveTopBarManager _topBarManager = IsActiveTopBarManager();
  late bool _isActiveTopBar;

  @override
  void initState() {
    super.initState();
    _isActiveTopBar = _topBarManager.isActiveTopBarNotifier.value;
    _topBarManager.isActiveTopBarNotifier.addListener(_onValueChanged);
  }

  void _onValueChanged() {
    setState(() {
      _isActiveTopBar = _topBarManager.isActiveTopBarNotifier.value;
    });
  }

  @override
  void dispose() {
    _topBarManager.isActiveTopBarNotifier.removeListener(_onValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SvgPicture.asset(
              'assets/icons/room_btn/topbar_icon.svg',
              key: ValueKey<bool>(_isActiveTopBar),
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 10),
          AutoSizeText(
            S.of(context).showTopBar,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Switch(
            value: _isActiveTopBar,
            activeColor: Colors.white,
            activeTrackColor: Colors.white38,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
            onChanged: (value) async {
              await _topBarManager.setIsActiveTopBar(value);
            },
          )
        ],
      ),
    );
  }
}
