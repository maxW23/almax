// ignore: file_names

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/slide_view/timer_counter_acc.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
// ignore: file_names
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/top_contributors_text.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_v_i_p_bottom_sheet_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:lklk/zego_sdk_manager.dart';

class TopUserBottomSheet extends StatefulWidget {
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final void Function(ZIMMessage) onSend;
  final List<UserEntity>? users;
  final bool isAdd;
  final int? roomId;
  final IconData? icon;
  final Function(int, String, String)? onUserAction;
  final Function()? onUpdateUI;
  const TopUserBottomSheet({
    super.key,
    required this.userCubit,
    required this.users,
    this.isAdd = false,
    this.roomId,
    this.icon,
    this.onUserAction,
    this.onUpdateUI,
    required this.roomCubit,
    required this.onSend,
  });

  @override
  State<TopUserBottomSheet> createState() => _TopUserBottomSheetState();

  // Static method to show the bottom sheet
  static Future<void> showBasicModalBottomSheet(
    BuildContext context,
    UserCubit userCubit,
    RoomCubit roomCubit,
    void Function(ZIMMessage) onSend,
    List<UserEntity>? users, {
    bool isAdd = false,
    int? roomId,
    IconData? icon,
    Function(int, String, String)? onUserAction,
    Function()? onUpdateUI,
  }) async {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return TopUserBottomSheet(
          userCubit: userCubit,
          roomCubit: roomCubit,
          users: users,
          isAdd: isAdd,
          roomId: roomId,
          icon: icon,
          onUserAction: onUserAction,
          onUpdateUI: onUpdateUI,
          onSend: onSend,
        );
      },
    );
  }
}

class _TopUserBottomSheetState extends State<TopUserBottomSheet> {
  String _selectedLanguage = 'en';
  @override
  void initState() {
    super.initState();
    final languageCubit = context.read<LanguageCubit>();
    _selectedLanguage = languageCubit.state.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: getTextDirection(_selectedLanguage),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const TopContributorsText(),
            const Center(
              child: TimerCounterAcc(
                color: AppColors.goldenhad1,
                shadowColor: AppColors.whiteGrey,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.users?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final user = widget.users![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 0, left: 6),
                    child: Row(
                      children: [
                        if (index == 0)
                          Image.asset(
                            AssetsData.cup1,
                            height: 30,
                            width: 40,
                            fit: BoxFit.cover,
                          )
                        else if (index == 1)
                          Image.asset(
                            AssetsData.cup2,
                            height: 30,
                            width: 40,
                            fit: BoxFit.cover,
                          )
                        else if (index == 2)
                          Image.asset(
                            AssetsData.cup3,
                            height: 30,
                            width: 40,
                            fit: BoxFit.cover,
                          )
                        else
                          SizedBox(
                            height: 30,
                            width: 40,
                            child: AutoSizeText(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        Expanded(
                          child: UserWidgetTitle(
                            contentPadding: const EdgeInsets.only(right: 4),
                            user: user,
                            userCubit: widget.userCubit,
                            icon: widget.icon,
                            isAdd: widget.isAdd,
                            roomId: widget.roomId,
                            onUserAction: widget.onUserAction,
                            isIcon: true,
                            isRoomTypeUser: false,
                            isWakel: false,
                            trailing: null,
                            paddingImageOnly: 13,
                            onTap: () {
                              UserVIPBottomSheetWidget
                                  .showBasicModalBottomSheet(
                                context,
                                user,
                                widget.roomCubit,
                                widget.roomId.toString(),
                                widget.onSend,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 51,
                          child: GradientText(
                            "${user.giftCount ?? 1}",
                            // textDirectionBool: true,
                            gradient: const LinearGradient(colors: [
                              AppColors.goldenhad1,
                              AppColors.brownshad1,
                              AppColors.brownshad2,
                              AppColors.goldenhad2,
                            ]),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // AutoSizeText('${user.giftCount ?? 0}',
                        //     style: const TextStyle(
                        //       fontSize: 16,
                        //       color: AppColors.goldenhad1,
                        //       fontWeight: FontWeight.w500,
                        //     )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
