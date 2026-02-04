import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_v_i_p_bottom_sheet_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/zego_sdk_manager.dart';

class UsersBottomSheet extends StatefulWidget {
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final bool isAdd;
  final int? roomId;
  final IconData? icon;
  final Function(int, String, String)? onUserAction;
  final Function()? onUpdateUI;
  final void Function(ZIMMessage) onSend;
  const UsersBottomSheet({
    super.key,
    required this.userCubit,
    required this.roomCubit,
    this.isAdd = false,
    this.roomId,
    this.icon,
    this.onUserAction,
    this.onUpdateUI,
    required this.onSend,
  });

  static void showBasicModalBottomSheet(
    BuildContext context,
    void Function(ZIMMessage) onSend, {
    required UserCubit userCubit,
    required RoomCubit roomCubit,
    required int roomId,
    List<UserEntity>? users,
    bool isAdd = false,
    IconData? icon,
    Function(int, String, String)? onUserAction,
    Function()? onUpdateUI,
  }) {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return UsersBottomSheet(
          userCubit: userCubit,
          onSend: onSend,
          roomCubit: roomCubit,
          isAdd: isAdd,
          roomId: roomId,
          icon: icon,
          onUserAction: onUserAction,
          onUpdateUI: onUpdateUI,
        );
      },
    );
  }

  @override
  State<UsersBottomSheet> createState() => _UsersBottomSheetState();
}

class _UsersBottomSheetState extends State<UsersBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<RoomCubit>(context).updatedfetchRoomById(
          widget.roomId.toString(), "initState UsersBottomSheet");
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomCubit, RoomCubitState>(
      listener: (BuildContext context, RoomCubitState state) {},
      builder: (context, state) {
        List<UserEntity> users = state.usersZego ?? [];
        final List<UserEntity> admins = state.adminsListUsers ?? [];

        if (state.status.isZegoUsersUpdated) {
          users = state.usersZego ?? [];
        }
        // احصل على المستخدمين والمدراء من الـ state الحالي
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: AppColors.white,
            // خلفية متدرجة تضيف حيوية للمظهر
            // gradient: LinearGradient(
            //   colors: [AppColors.secondColorDark, AppColors.secondColor],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
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
              // عنوان مرِح للتطبيق
              AutoSizeText(
                S.of(context).users,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: AppColors.primaryDark,
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: AppColors.primaryDark,
                        indicator: const UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: AppColors.primaryDark,
                            width: 3,
                          ),
                        ),
                        tabs: [
                          Tab(text: 'Online (${users.length})'),
                          Tab(text: '${S.of(context).admin} (${admins.length})'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _UsersListTab(
                              users: users,
                              userCubit: widget.userCubit,
                              roomCubit: widget.roomCubit,
                              roomId: widget.roomId,
                              isAdd: widget.isAdd,
                              icon: widget.icon,
                              onUserAction: widget.onUserAction,
                              onSend: widget.onSend,
                            ),
                            _UsersListTab(
                              users: admins,
                              userCubit: widget.userCubit,
                              roomCubit: widget.roomCubit,
                              roomId: widget.roomId,
                              isAdd: widget.isAdd,
                              icon: widget.icon,
                              onUserAction: widget.onUserAction,
                              onSend: widget.onSend,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UsersListTab extends StatefulWidget {
  final List<UserEntity> users;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final bool isAdd;
  final int? roomId;
  final IconData? icon;
  final Function(int, String, String)? onUserAction;
  final void Function(ZIMMessage) onSend;

  const _UsersListTab({
    required this.users,
    required this.userCubit,
    required this.roomCubit,
    required this.roomId,
    required this.onSend,
    this.isAdd = false,
    this.icon,
    this.onUserAction,
    super.key,
  });

  @override
  State<_UsersListTab> createState() => _UsersListTabState();
}

class _UsersListTabState extends State<_UsersListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final users = widget.users;
    if (users.isEmpty) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.35,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        final user = users[index];
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
            onTap: () {
              UserVIPBottomSheetWidget.showBasicModalBottomSheet(
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
    );
  }
}
