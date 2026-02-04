import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/animations/heart.dart';
import 'package:lklk/core/animations/heart_artery_animation.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/relation_progress_cubit/relation_progress_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/core/animations/glow_animated.dart';
import 'dart:ui' as ui;
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class RelationshipRow extends StatefulWidget {
  const RelationshipRow({
    super.key,
    required this.userCubit,
    required this.user,
    this.isProfile = false,
    required this.roomCubit,
  });

  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final UserEntity user;
  final bool isProfile;

  @override
  State<RelationshipRow> createState() => _RelationshipRowState();
}

class _RelationshipRowState extends State<RelationshipRow> {
  @override
  void initState() {
    super.initState();
    _loadUserProfileIfNeeded();
  }

  @override
  void didUpdateWidget(RelationshipRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.idrelation != widget.user.idrelation) {
      _loadUserProfileIfNeeded();
    }
  }

  void _loadUserProfileIfNeeded() {
    if (widget.isProfile &&
        widget.user.idrelation != null &&
        widget.user.idrelation!.isNotEmpty &&
        widget.user.idrelation != "null") {
      widget.userCubit.getUserProfileById(widget.user.idrelation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelationProgressCubit>(
      lazy: true,
      create: (context) => RelationProgressCubit(),
      child: Container(
        decoration: const BoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 80.h,
              child: Stack(
                children: [
                  Positioned(
                    right: 50.w,
                    bottom: 0,
                    top: 0,
                    child: SizedBox(
                      width: 170.w,
                      height: 40.h,
                      child: HeartArteryAnimation(),
                    ),
                  ),
                  Positioned(
                    left: 50.w,
                    bottom: 0,
                    top: 0,
                    child: SizedBox(
                      width: 170.w,
                      height: 40.h,
                      child: HeartArteryAnimation(),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    top: 0,
                    right: 190.w,
                    child: GlowAnimated(
                      child: CircularUserImage(
                        imagePath: widget.user.img,
                        isEmpty: false,
                        radius: 30.r,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    left: 190.w,
                    child: GlowAnimated(
                        child: widget.isProfile
                            ? Builder(builder: (context) {
                                return BlocProvider<RelationProgressCubit>(
                                  create: (context) => RelationProgressCubit(),
                                  child: GestureDetector(
                                    onTap: () {
                                      final relationCubit = BlocProvider.of<
                                          RelationProgressCubit>(context);
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            log("user.,,idrelation ${widget.user.idrelation}");
                                            log("user.,,imgrelation ${widget.user.imgrelation}");
                                            return CustomDialog(
                                              title: 'title',
                                              content: 'content',
                                              imagePath:
                                                  widget.user.imgrelation,
                                              onButton1Pressed: () {
                                                BlocConsumer<UserCubit,
                                                    UserCubitState>(
                                                  listener: (context, state) {},
                                                  builder: (context, state) {
                                                    if (state
                                                        .status.isLoadedById) {
                                                      return OtherUserProfile(
                                                        user: state.userOther!,
                                                        entryList: state
                                                            .entryListOther,
                                                        frameList: state
                                                            .frameListOther,
                                                        giftList:
                                                            state.giftListOther,
                                                        userCubit:
                                                            widget.userCubit,
                                                        friendStatus:
                                                            state.freindOther,
                                                        friendNumber: state
                                                            .friendNumberOther!,
                                                        visitorNumber: state
                                                            .visitorNumberOther!,
                                                        roomCubit:
                                                            widget.roomCubit,
                                                      );
                                                    } else if (state
                                                        .status.isError) {
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        SnackbarHelper.showMessage(
                                                            context,
                                                            'UserCubitError: ${state.message}');
                                                      });
                                                      SnackbarHelper.showMessage(
                                                          context,
                                                          'UserCubitError:User: ${state.userOther}');
                                                      if (widget.user
                                                              .idrelation !=
                                                          null) {
                                                        widget.userCubit
                                                            .getUserProfileById(
                                                                widget.user
                                                                    .idrelation!);
                                                      }
                                                      return const SizedBox();
                                                    } else {
                                                      return const SizedBox();
                                                    }
                                                  },
                                                );
                                              
                                              },
                                              onButton2Pressed: () async {
                                                await relationCubit
                                                    .deleteRelationRequest(
                                                        widget
                                                            .user.idrelation!);
                                                widget.userCubit.getProfileUser(
                                                    "RelationshipRow");
                                              },
                                              onButton3Pressed: () {},
                                            );
                                          });
                                    },
                                    child: CircularUserImage(
                                      imagePath: widget.user.imgrelation,
                                      isEmpty: false,
                                      radius: 30.r,
                                    ),
                                  ),
                                );
                              })
                            : CircularUserImage(
                                imagePath: widget.user.imgrelation,
                                isEmpty: false,
                                radius: 30.r,
                              )),
                  ),
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    left: 0,
                    child: HeartbeatAnimation(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onButton1Pressed;
  final VoidCallback onButton2Pressed;
  final VoidCallback onButton3Pressed;
  final String? imagePath;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.imagePath,
    required this.onButton1Pressed,
    required this.onButton2Pressed,
    required this.onButton3Pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .95, end: 1),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: (value.clamp(.95, 1) - .90) * 10, // quick fade-in
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: .92),
                        Colors.white.withValues(alpha: .86),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .55),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.close_rounded,
                                  size: 20, color: Colors.black54),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      CircularUserImage(
                        imagePath: imagePath,
                        isEmpty: false,
                        radius: 34,
                      ),
                      const SizedBox(height: 12),
                      if (title.isNotEmpty)
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          content,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withValues(alpha: .7),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionChipButton(
                            icon: FontAwesomeIcons.portrait,
                            label: 'زيارة البروفايل',
                            color: AppColors.primary,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onButton1Pressed();
                            },
                          ),
                          _ActionChipButton(
                            icon: FontAwesomeIcons.heartBroken,
                            label: 'إلغاء الارتباط',
                            color: AppColors.danger,
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              onButton2Pressed();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: .12),
                color.withValues(alpha: .22),
              ],
            ),
            border: Border.all(color: color.withValues(alpha: .35), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
