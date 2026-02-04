// ignore: file_names
import 'package:lklk/core/utils/logger.dart' as log;
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/animations/animated_list_builder.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_v_i_p_bottom_sheet_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:lklk/zego_sdk_manager.dart';

class ShowUsersBottomsheet extends StatefulWidget {
  const ShowUsersBottomsheet({
    super.key,
    required this.userCubit,
    required this.users,
    this.isAdd = false,
    this.roomId,
    this.icon,
    this.onUserAction,
    required this.type,
    required this.roomCubit,
    required this.onSend,
  });
  final RoomCubit roomCubit;
  final UserCubit userCubit;
  final List<UserEntity>? users;
  final bool isAdd;
  final int? roomId;
  final IconData? icon;
  final Function(int, String, String how)? onUserAction;
  final String type;
  final void Function(ZIMMessage) onSend;
  static Future<void> showBasicModalBottomSheet(
    BuildContext context,
    UserCubit userCubit,
    RoomCubit roomCubit,
    String type,
    void Function(ZIMMessage) onSend,
    List<UserEntity>? users, {
    bool isAdd = false,
    int? roomId,
    IconData? icon,
    Function(int, String, String how)? onUserAction,
  }) async {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (_, scrollController) {
            return ShowUsersBottomsheet(
              userCubit: userCubit,
              users: users,
              isAdd: isAdd,
              roomId: roomId,
              icon: icon,
              onUserAction: onUserAction,
              type: type,
              roomCubit: roomCubit,
              onSend: onSend,
            );
          },
        );
      },
    );
  }

  @override
  State<ShowUsersBottomsheet> createState() => _ShowUsersBottomsheetState();
}

class _ShowUsersBottomsheetState extends State<ShowUsersBottomsheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.roomId != null) {
        widget.roomCubit.refreshRoomData(widget.roomId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return BlocBuilder<RoomCubit, RoomCubitState>(
      bloc: widget.roomCubit,
      builder: (context, state) {
        List<UserEntity>? users = widget.users; // القائمة الابتدائية
        if (state.status.isRoomLoaded || state.status.isSuccess) {
          log.log("state.usersZego ${state.usersZego}");
          log.log("usersBaned ${state.bannedUsers}");
          switch (widget.type) {
            case 'add user to Admin List':
              users = state.usersZego!
                  .where((user) =>
                      !(user.ownerIds?.contains(widget.roomId.toString()) ??
                          false) &&
                      !(user.adminRoomIds?.contains(widget.roomId.toString()) ??
                          false))
                  .toList();
              break;
            case 'Room Admin':
              users = state.adminsListUsers?.toList();
              break;
            case "Room Block List":
              users = state.bannedUsers?.toList();
              break;
            case 'Block User':
              users = state.usersZego!
                  .where((user) =>
                      int.parse(user.vip ?? '0') <= 5 &&
                      !(user.ownerIds?.contains(widget.roomId.toString()) ??
                          false) &&
                      !(state.bannedUsers!.any(
                          (bannedUser) => bannedUser.iduser == user.iduser)))
                  .toList();
              break;
            default:
          }
        }
        if (users == null || users.isEmpty) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                )
              ],
            ),
            height: height * 0.45,
            child: const Center(
              child: AutoSizeText(
                'لا يوجد مستخدمين',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -5),
              )
            ],
          ),
          height: height * 0.45,
          child: Column(
            children: [
              // مقبض السحب في الأعلى
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // عنوان مرِح
              const AutoSizeText(
                'المستخدمين',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // قائمة المستخدمين
              Expanded(
                child: AnimatedListBuilder(
                  items: users,
                  itemBuilder: (context, index) {
                    final user = users![index];
                    return Padding(
                      padding: index != 0
                          ? const EdgeInsets.only(top: 35)
                          : const EdgeInsets.only(top: 20),
                      child: UserWidgetTitle(
                        user: user,
                        userCubit: widget.userCubit,
                        icon: widget.icon,
                        isAdd: widget.isAdd,
                        roomId: widget.roomId,
                        onUserAction: widget.onUserAction,
                        isIcon: true,
                        typeOfIconRoomSettings: widget.type,
                        isLevel:
                            widget.type == "Room Block List" ? false : true,
                        onTap: widget.type == "Room Block List"
                            ? () {}
                            : () {
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////
// طريقة عرض بديلة: قائمة المستخدمين بشكل مبسط
void showUsersBottomSheet(
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
}) {
  showModalBottomSheet(
    barrierColor: Colors.transparent,
    backgroundColor: AppColors.black,
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: ListView.builder(
            itemCount: users?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              final user = users![index];
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: UserWidgetTitle(
                  user: user,
                  userCubit: userCubit,
                  icon: icon,
                  isAdd: isAdd,
                  roomId: roomId,
                  onUserAction: onUserAction,
                  isIcon: true,
                  onTap: () {
                    UserVIPBottomSheetWidget.showBasicModalBottomSheet(
                        context, user, roomCubit, roomId.toString(), onSend);
                  },
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
