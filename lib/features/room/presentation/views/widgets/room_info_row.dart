import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/manger/room_exit_service.dart';
import 'package:lklk/features/room/presentation/views/widgets/top_user_bottom_sheet.dart';
import 'package:lklk/features/room/presentation/views/widgets/users_bottomsheet.dart';
import 'package:lklk/features/room/presentation/views/widgets/users_room_section.dart';
import 'package:lklk/zego_sdk_manager.dart';

class RoomInfoRow extends StatefulWidget {
  final RoomEntity room;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final void Function(ZIMMessage) onSend;
  const RoomInfoRow({
    super.key,
    required this.room,
    required this.userCubit,
    required this.roomCubit,
    required this.onSend,
  });

  @override
  State<RoomInfoRow> createState() => _RoomInfoRowState();
}

class _RoomInfoRowState extends State<RoomInfoRow> {
  // Inline SVG assets (provided by designer)
  final String _topRoomUsersSvg =
      '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M7.43439 1.92188L9.05158 5.16094L11.2125 1.92188H7.43439ZM12.7875 1.92188L14.9485 5.16094L16.5656 1.92188H12.7875ZM12 2.26031L9.78752 5.57812H14.2125L12 2.26031ZM6.66096 2.26688L3.90096 5.57812H8.31564L6.66096 2.26688ZM17.3391 2.26688L15.6844 5.57812H20.1L17.3391 2.26688ZM3.78846 6.42188L9.22502 14.5781H11.6719L8.70002 6.42188H3.78846ZM9.60471 6.42188L12 13.0172L14.3953 6.42188H9.60471ZM15.3 6.42188L12.3281 14.5781H14.775L20.2125 6.42188H15.3ZM9.42189 15.4219V17.5781H14.5781V15.4219H9.42189ZM6.24377 18.4219L3.72705 22.8281H20.2735L17.7563 18.4219H8.57814H6.24377ZM7.50002 20.5781H16.5V21.4219H7.50002V20.5781Z" fill="url(#paint0_linear_6673_19340)"/>
<defs>
<linearGradient id="paint0_linear_6673_19340" x1="3.72705" y1="12.2841" x2="20.2735" y2="12.2841" gradientUnits="userSpaceOnUse">
<stop stop-color="#AB7800"/>
<stop offset="0.151042" stop-color="#FBE5AE"/>
<stop offset="0.322917" stop-color="#F1D6A2"/>
<stop offset="0.489583" stop-color="#FAECD2"/>
<stop offset="0.666667" stop-color="#E6D1AE"/>
<stop offset="0.84375" stop-color="#CBAD7F"/>
<stop offset="1" stop-color="#B9955F"/>
</linearGradient>
</defs>
</svg>''';

  final String _usersIconSvg =
      '''<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
<g opacity="0.8">
<path d="M1.16663 12.834C1.16663 11.5963 1.65829 10.4093 2.53346 9.53415C3.40863 8.65898 4.59562 8.16732 5.83329 8.16732C7.07097 8.16732 8.25796 8.65898 9.13313 9.53415C10.0083 10.4093 10.5 11.5963 10.5 12.834H1.16663ZM5.83329 7.58398C3.89954 7.58398 2.33329 6.01773 2.33329 4.08398C2.33329 2.15023 3.89954 0.583984 5.83329 0.583984C7.76704 0.583984 9.33329 2.15023 9.33329 4.08398C9.33329 6.01773 7.76704 7.58398 5.83329 7.58398ZM10.1284 8.88657C11.0207 9.1159 11.8179 9.62089 12.4065 10.3296C12.9951 11.0384 13.3451 11.9148 13.4067 12.834H11.6666C11.6666 11.3115 11.0833 9.92548 10.1284 8.88657ZM8.94829 7.5589C9.43712 7.12168 9.82805 6.5861 10.0955 5.98725C10.3629 5.38841 10.5007 4.73982 10.5 4.08398C10.5012 3.28684 10.2973 2.50278 9.90788 1.80723C10.5686 1.93999 11.1629 2.29745 11.5899 2.81885C12.0169 3.34025 12.2501 3.99341 12.25 4.66732C12.2501 5.08292 12.1614 5.49376 11.9899 5.87229C11.8183 6.25083 11.5678 6.58832 11.2551 6.86213C10.9425 7.13595 10.5749 7.33978 10.177 7.45995C9.77919 7.58012 9.36025 7.61385 8.94829 7.5589Z" fill="white"/>
</g>
</svg>''';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: BlocConsumer<RoomCubit, RoomCubitState>(
        listener: (context, state) {
          if (state.status.isUserBanned) {
            banUserFromRoomMethod(context);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // top users CUP icon (SVG)
                _buildInfoWidgetSvg(
                    _topRoomUsersSvg, widget.room.topvalues ?? "0", () {
                  TopUserBottomSheet.showBasicModalBottomSheet(
                    context,
                    widget.userCubit,
                    widget.roomCubit,
                    widget.onSend,
                    state.topUsers ?? [],
                  );
                }),

                const Spacer(),
                // the Live Users in Room
                UsersRoomSection(
                  roomId: widget.room.id,
                  onTap: () {
                    log("5state $state ---- users ${state.usersZego} ");
                    UsersBottomSheet.showBasicModalBottomSheet(
                      context,
                      widget.onSend,
                      userCubit: widget.userCubit,
                      roomCubit: widget.roomCubit,
                      roomId: widget.room.id,
                      users: state.usersZego ?? [],
                    );
                  },
                ),
               
                _buildInfoWidgetSvgIcon(
                    _usersIconSvg, state.usersZego?.length ?? 0, () {
                  UsersBottomSheet.showBasicModalBottomSheet(
                    context,
                    widget.onSend,
                    userCubit: widget.userCubit,
                    roomCubit: widget.roomCubit,
                    roomId: widget.room.id,
                    users: state.usersZego ?? [],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  void banUserFromRoomMethod(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log("RoomInfoRow HomeView RoomViewBloc state.status.isUserBanned ");

      await RoomExitService.exitRoom(
          context: context,
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
          delayDuration: Duration(milliseconds: 1000));
    });
  }

  Widget _buildInfoWidgetSvg(
    String svgString,
    String value,
    void Function()? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // decoration: BoxDecoration(
        //   color: AppColors.whiteWithOpacity25,
        //   borderRadius: BorderRadius.circular(20),
        // ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            // Render inline SVG
            SvgPicture.string(
              svgString,
              height: 26,
              width: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 5),
            AutoSizeText(value.toString(),
                style: const TextStyle(
                  color: AppColors.whiteIcon,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoWidgetSvgIcon(
    String svgString,
    int value,
    void Function()? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            SvgPicture.string(
              svgString,
              height: 20,
              width: 20,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            AutoSizeText(value.toString(),
                style: const TextStyle(
                  color: AppColors.whiteIcon,
                )),
          ],
        ),
      ),
    );
  }
}
