import 'package:flutter/material.dart';
import 'package:lklk/features/auth/presentation/view/widget/auth_container.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class AnimatedAuthBody extends StatefulWidget {
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final bool enabled;

  const AnimatedAuthBody(
      {super.key,
      required this.userCubit,
      required this.roomCubit,
      required this.enabled});

  @override
  State<AnimatedAuthBody> createState() => _AnimatedAuthBodyState();
}

class _AnimatedAuthBodyState extends State<AnimatedAuthBody>
    with TickerProviderStateMixin {
  late AnimationController _fadeSlideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeSlideController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _fadeSlideController, curve: Curves.easeOut));

    _fadeSlideController.forward();
  }

  @override
  void dispose() {
    _fadeSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AuthContainer(
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
          enabled: widget.enabled,
        ),
      ),
    );
  }
}
