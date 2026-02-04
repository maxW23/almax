import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/animations/lines_animation.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/chat/presentation/views/chat_private_page.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/freind_progress/freind_progress_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class OtherProfileHeaderActions extends StatelessWidget {
  const OtherProfileHeaderActions({
    super.key,
    required this.user,
    required this.userCubit,
    required this.roomCubit,
    this.friendStatus,
    required this.onEnterRoom,
    this.showTrack = false,
  });

  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final String? friendStatus;
  final VoidCallback onEnterRoom;
  final bool showTrack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FreindProgressCubit(),
      // Use a Builder to obtain a context that is a descendant of BlocProvider
      child: Builder(
        builder: (innerContext) {
          return Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _circleSvg(
                  innerContext,
                  assetPath: 'assets/images/my_profile_icon/message_icon.svg',
                  size: 40,
                  backgroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      innerContext,
                      MaterialPageRoute(
                        builder: (context) => ChatPrivatePageBloc(
                          roomCubit: roomCubit,
                          userCubit: userCubit,
                          userId: user.iduser,
                          userImg: user.img,
                          userName: user.name ?? '-',
                          userImgcurrent:
                              userCubit.user?.img ?? AssetsData.userTestNetwork,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                _circleSvg(
                  innerContext,
                  assetPath:
                      'assets/images/my_profile_icon/add_frinds_icon.svg',
                  size: 40,
                  backgroundColor: AppColors.successColor.withOpacity(0.12),
                  onTap: () async {
                    final cubit = innerContext.read<FreindProgressCubit>();
                    final fid = user.iduser;
                    // if (friendStatus == null ||
                    //     friendStatus!.isEmpty ||
                    //     friendStatus == 'not_friend') {
                    //   await cubit.addFriend(fid);
                    // } else if (user.stringid != null && user.stringid!.isNotEmpty) {
                    //   await cubit.deleteFriendOrFriendRequest(user.stringid!);
                    // }
                    final messenger =
                        ScaffoldMessenger.of(innerContext)..hideCurrentSnackBar();
                    final status = await cubit.addFriendStatus(fid);
                    switch (status) {
                      case 'done':
                        messenger.showSnackBar(const SnackBar(
                          content: Text('تم ارسال طلب صداقة بنجاح'),
                          behavior: SnackBarBehavior.floating,
                        ));
                        break;
                      case 'waiting_accepting':
                        messenger.showSnackBar(const SnackBar(
                          content: Text('تم الارسال'),
                          behavior: SnackBarBehavior.floating,
                        ));
                        break;
                      case 'already_friend':
                        messenger.showSnackBar(const SnackBar(
                          content: Text('أنتما صديقان بالفعل'),
                          behavior: SnackBarBehavior.floating,
                        ));
                        break;
                      default:
                        final msg = status.startsWith('error:')
                            ? status.substring(6)
                            : status;
                        messenger.showSnackBar(SnackBar(
                          content: Text(msg),
                          behavior: SnackBarBehavior.floating,
                        ));
                    }
                  },
                ),
                if (showTrack) ...[
                  const SizedBox(width: 4),
                  _circleSvg(
                    innerContext,
                    assetPath:
                        'assets/images/my_profile_icon/home_icon_purple.svg',
                    size: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    onTap: onEnterRoom,
                  ),
                  const SizedBox(width: 2),
                  Center(
                    child: SizedBox(
                      height: 18,
                      child: const AnimatedLinesWidget(
                        isWhite: false,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _circleSvg(
    BuildContext context, {
    required String assetPath,
    Color? backgroundColor,
    double size = 36,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          assetPath,
          width: size * 0.58,
          height: size * 0.58,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
