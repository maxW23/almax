import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/image_user_section_with_fram.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/svga_badges_row_widget.dart';
import 'package:lklk/zego_sdk_manager.dart';
import 'background_v_i_p_bottom_sheet.dart';
import 'buttons_section_botton_sheet_v_i_p.dart';
import 'i_d_section_user_widget.dart';

class UserVIPBottomSheetWidget extends StatefulWidget {
  const UserVIPBottomSheetWidget({
    super.key,
    required this.user,
    required this.roomId,
    required this.roomCubit,
    required this.onSend,
  });

  final UserEntity user;
  final RoomCubit roomCubit;
  final String roomId;
  final void Function(ZIMMessage) onSend;

  @override
  State<UserVIPBottomSheetWidget> createState() =>
      _UserVIPBottomSheetWidgetState();

  static Future<void> showBasicModalBottomSheet(
    BuildContext context,
    UserEntity user,
    RoomCubit roomCubit,
    String roomId,
    void Function(ZIMMessage) onSend,
  ) async {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      context: context,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: BlocProvider.of<UserCubit>(context),
          child: UserVIPBottomSheetWidget(
            user: user,
            roomCubit: roomCubit,
            roomId: roomId,
            onSend: onSend,
          ),
        );
      },
    );
  }
}

class _UserVIPBottomSheetWidgetState extends State<UserVIPBottomSheetWidget> {
  UserEntity? currentUser;
  bool isLoading = true;
  StreamSubscription<UserCubitState>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userCubit = context.read<UserCubit>();
      final currentState = userCubit.state;

      if (currentState.user != null) {
        log('Loaded current user from cubit state: ${currentState.user}');
        setState(() {
          currentUser = currentState.user;
          isLoading = false;
        });
        return;
      }

      _userSubscription = userCubit.stream.listen((state) {
        if (state.user != null && mounted) {
          log('Loaded current user from cubit stream: ${state.user}');
          setState(() {
            currentUser = state.user;
            isLoading = false;
          });
          _userSubscription?.cancel();
        }
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && isLoading) {
          _userSubscription?.cancel();
          setState(() {
            isLoading = false;
          });
          log('Timeout loading user from cubit');
        }
      });
    } catch (e) {
      log('Error loading current user from cubit: $e');
      _userSubscription?.cancel();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return BlocBuilder<UserCubit, UserCubitState>(
      builder: (context, userState) {
        // تحديث المستخدم الحالي من الـ Bloc مباشرة
        if (userState.user != null && currentUser != userState.user) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                currentUser = userState.user;
                isLoading = false;
              });
            }
          });
        }

        // اختر المستخدم الفعلي من roomCubit.state.usersZego (يحمل بيانات ZIM بما فيها شارات SVGA)
        UserEntity effectiveUser = widget.user;
        final usersZego = widget.roomCubit.state.usersZego;
        if (usersZego != null) {
          for (final u in usersZego) {
            if (u.iduser == widget.user.iduser) {
              effectiveUser = u;
              break;
            }
          }
        }

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          height: height / 2,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              BackgroundVIPBottomSheet(vip: effectiveUser.vip ?? "0"),
              Positioned(
                top: 140.h,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 2 - 140.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.h),
                      GradientText(
                        effectiveUser.name!,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.black,
                            AppColors.black,
                          ],
                        ),
                        style: Styles.textStyle20
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 35.h,
                        child: IDSectionUserWidget(
                          currentUser: effectiveUser,
                          isCopyIcon: false,
                          isFileIcon: false,
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LevelRowUserTitleWidgetSection(
                        roomID: widget.roomId,
                        isRoomTypeUser: false,
                        isWakel: true,
                        user: effectiveUser,
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      SizedBox(height: 6),
                      Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.r),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                          
                              children: [
                                UserSvgaBadgesRow(
                                  user: effectiveUser,
                                  size: LevelRowSize.normal,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  centerContent: true,
                                ),
                              ],
                            ),
                          ),
                      Spacer(),
                      ButtonsSectionBottonSheetVIP(
                        isME: currentUser?.iduser == widget.user.iduser,
                        roomId: widget.roomId,
                        roomCubit: widget.roomCubit,
                        onSend: widget.onSend,
                        user: widget.user,
                      ),
                      SizedBox(
                        height: 12,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox.shrink(),
              Positioned(
                top: effectiveUser.vip == '0' ? 0 : 40,
                child: ImageUserSectionWithFram(
                  height: 80,
                  width: 80,
                  radius: 22.r,
                  img: effectiveUser.img,
                  linkPath: SvgaUtils.getValidFilePath(
                          effectiveUser.elementFrame?.elamentId?.toString()) ??
                      effectiveUser.elementFrame?.linkPathLocal ??
                      effectiveUser.elementFrame?.linkPath,
                  isImage: true,
                  onTap: () {},
                  padding: 0,
                  paddingImageOnly: 5.r,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SizedBox loading() {
    return SizedBox(
        width: 70.w,
        height: 70.h,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.black,
          ),
        ));
  }
}
