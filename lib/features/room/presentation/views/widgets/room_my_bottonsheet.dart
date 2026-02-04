import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/custom_text_button_icon.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_settings_body_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:lklk/zego_sdk_manager.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import '../../../domain/entities/room_entity.dart';

class RoomInfoBottomSheet extends StatefulWidget {
  const RoomInfoBottomSheet({
    super.key,
    required this.room,
    required this.roomCubit,
    this.users,
    this.bannedUsers,
    required this.userCubit,
    required this.onSend,
    this.adminUsers,
  });

  final RoomEntity room;
  final RoomCubit roomCubit;
  final List<UserEntity>? users;
  final List<UserEntity>? adminUsers;
  final List<UserEntity>? bannedUsers;
  final UserCubit userCubit;
  final void Function(ZIMMessage) onSend;

  @override
  State<RoomInfoBottomSheet> createState() => _RoomInfoBottomSheetState();
}

class _RoomInfoBottomSheetState extends State<RoomInfoBottomSheet> {
  late bool isRoomOwner;
  late bool isAdmin;
  late UserEntity currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.userCubit.user!;
    _updateUserStatus();
    _loadRoomOwnerProfile();
  }

  @override
  void didUpdateWidget(covariant RoomInfoBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.room != widget.room ||
        oldWidget.users != widget.users ||
        oldWidget.userCubit != widget.userCubit) {
      _updateUserStatus();
      _loadRoomOwnerProfile();
    }
  }

  void _updateUserStatus() {
    isRoomOwner = (currentUser.iduser == widget.room.owner);
    isAdmin =
        currentUser.adminRoomIds?.contains(widget.room.id.toString()) ?? false;
  }

  void _loadRoomOwnerProfile() {
    if (widget.room.owner.isNotEmpty && widget.room.owner != "null") {
      widget.userCubit.getUserProfileById(widget.room.owner);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomCubitState>(
      builder: (context, state) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: DefaultTabController(
            animationDuration: const Duration(milliseconds: 200),
            length: 2,
            initialIndex: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                // gradient: LinearGradient(
                //   colors: [AppColors.white, AppColors.white],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height * .55,
              child: Column(
                children: [
                  // مقبض السحب الأنيق
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
                  // تبويبات لتقسيم المعلومات
                  TabBar(
                    indicator: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.black,
                          width: 3,
                        ),
                      ),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: <Widget>[
                      Tab(icon: AutoSizeText(S.of(context).roomInfo)),
                      Tab(icon: AutoSizeText(S.of(context).member)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        // تبويب معلومات الغرفة
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RoomInfoWidget(
                                room: widget.room,
                                isRoomOwner: isRoomOwner,
                                isAdmin: isAdmin,
                                roomCubit: widget.roomCubit,
                                bannedUsers: widget.bannedUsers,
                                users: widget.users,
                                userCubit: widget.userCubit,
                                onSend: widget.onSend,
                                adminUsers: widget.adminUsers,
                              ),
                              const SizedBox(height: 20),
                              BlocConsumer<UserCubit, UserCubitState>(
                                listener: (context, state) {},
                                builder: (context, state) {
                                  if (state.userOther != null) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.graywhite
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: UserWidgetTitle(
                                        user: state.userOther!,
                                        userCubit: widget.userCubit,
                                        isRoomTypeUser: false,
                                      ),
                                    );
                                  } else if (state.status.isError) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      SnackbarHelper.showMessage(context,
                                          'UserCubitError: ${state.message}');
                                      SnackbarHelper.showMessage(context,
                                          'UserCubitError:User: ${state.userOther}');
                                    });
                                    if (widget.room.owner.isNotEmpty &&
                                        widget.room.owner != "null") {
                                      widget.userCubit.getUserProfileById(
                                          widget.room.owner);
                                    }
                                    return const SizedBox();
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      S.of(context).announcement,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AutoSizeText(
                                      widget.room.helloText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        // تبويب قائمة الأعضاء
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: widget.users?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: UserWidgetTitle(
                                  user: widget.users![index],
                                  userCubit: widget.userCubit,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RoomInfoWidget extends StatefulWidget {
  const RoomInfoWidget({
    super.key,
    required this.room,
    required this.isRoomOwner,
    required this.isAdmin,
    required this.roomCubit,
    required this.bannedUsers,
    required this.users,
    required this.userCubit,
    required this.onSend,
    required this.adminUsers,
  });

  final RoomEntity room;
  final bool isRoomOwner;
  final bool isAdmin;
  final RoomCubit roomCubit;
  final List<UserEntity>? bannedUsers;
  final List<UserEntity>? adminUsers;

  final List<UserEntity>? users;
  final UserCubit userCubit;
  final void Function(ZIMMessage) onSend;
  @override
  State<RoomInfoWidget> createState() => _RoomInfoWidgetState();
}

class _RoomInfoWidgetState extends State<RoomInfoWidget> {
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    final languageCubit = context.read<LanguageCubit>();
    selectedLanguage = languageCubit.state.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: getTextDirection(selectedLanguage),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            widget.room.img,
            // حجم كاش محسن لصور الغرفة في CircleAvatar (عادة 40×40)
            maxWidth: 80,
            maxHeight: 80,
          ),
        ),
        title: AutoSizeText(
          widget.room.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: AutoSizeText(
          'ID: ${widget.room.id}',
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        trailing: widget.isRoomOwner || widget.isAdmin
            ? CustomTextButtonIcon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomSettingsPage(
                        room: widget.room,
                        roomCubit: widget.roomCubit,
                        bannedUsers: widget.bannedUsers,
                        users: widget.users,
                        userCubit: widget.userCubit,
                        isAdmin: widget.isAdmin && widget.isRoomOwner == false,
                        onSend: widget.onSend,
                        adminUsers: widget.adminUsers,
                      ),
                    ),
                  );
                },
                buttonHeight: 35,
                iconHeight: 15,
                iconpadding: const EdgeInsets.all(4),
                icon: FontAwesomeIcons.solidPenToSquare,
                sizeIcon: 9,
                text: S.of(context).settings,
              )
            : null,
      ),
    );
  }
}

///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
// if (state is RoomCubitRoomUpdated) {
//   return
//   Padding(
//     padding: MediaQuery.of(context).viewInsets,
//     child: DefaultTabController(
//       length: 2,
//       initialIndex: 0,
//       child: SizedBox(
//         height: MediaQuery.of(context).size.height * .7,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const TabBar(
//               labelColor: AppColors.primary,
//               tabs: <Widget>[
//                 Tab(
//                   icon: AutoSizeText('Room Info'),
//                 ),
//                 Tab(
//                   icon: AutoSizeText('Member'),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: <Widget>[
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ListTile(
//                         leading: const CircleAvatar(
//                           backgroundImage: NetworkImage(
//                               AssetsData.userTest),
//                         ),
//                         title: AutoSizeText(state.room.name),
//                         subtitle: AutoSizeText('Room ID: ${room.id}'),
//                         trailing: isRoomOwner
//                             ? CustomTextButtonIcon(
//                                 onPressed: () {
//                                   Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             RoomSettingsPage(
//                                           room: room,
//                                           roomCubit: roomCubit,
//                                         ),
//                                       ));
//                                 },
//                                 // GoRouter.of(context)
//                                 //     .go(AppRouter.kRoomSettingsPage),
//                                 buttonHeight: 35,
//                                 iconHeight: 15,
//                                 iconpadding: const EdgeInsets.all(4),
//                                 icon: FontAwesomeIcons.solidEdit,
//                                 sizeIcon: 9,
//                                 text: 'Settings')
//                             : null,
//                       ),
//                       Container(
//                         margin:
//                             const EdgeInsets.symmetric(horizontal: 16),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withValues(alpha: .6),
//                           borderRadius: const BorderRadius.all(
//                               Radius.circular(16)),
//                         ),
//                         child: const UserWidgetTitle(
//                             // room: room,
//                             ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.symmetric(horizontal: 20),
//                         child: Column(
//                           children: [
//                             const AutoSizeText(
//                               'Announcement',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 4.0,
//                             ),
//                             AutoSizeText(
//                               room.helloText,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w400,
//                                   color: AppColors.gray),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Spacer(),
//                       Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.spaceEvenly,
//                         children: [
//                           TextButton.icon(
//                             onPressed: () ,
//                             icon: const Icon(FontAwesomeIcons.heart),
//                             label: const AutoSizeText('Followed'),
//                           ),
//                           TextButton.icon(
//                             onPressed: () ,
//                             icon: const Icon(FontAwesomeIcons.user),
//                             label: const AutoSizeText('Review'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const Column(
//                     children: [
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: NetworkImage(
//                               AssetsData.userTest),
//                         ),
//                         title: AutoSizeText('Admin Name'),
//                         subtitle: AutoSizeText('Level: 2 | Rank: 5'),
//                         trailing: Icon(Icons.person_2),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// } else {
//   return Padding(
//     padding: MediaQuery.of(context).viewInsets,
//     child: DefaultTabController(
//       length: 2,
//       initialIndex: 0,
//       child: SizedBox(
//         height: MediaQuery.of(context).size.height * .7,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const TabBar(
//               labelColor: AppColors.primary,
//               tabs: <Widget>[
//                 Tab(
//                   icon: AutoSizeText('Room Info'),
//                 ),
//                 Tab(
//                   icon: AutoSizeText('Member'),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: <Widget>[
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ListTile(
//                         leading: const CircleAvatar(
//                           backgroundImage: NetworkImage(
//                               AssetsData.userTest),
//                         ),
//                         title: AutoSizeText(room.name),
//                         subtitle: AutoSizeText('Room ID: ${room.id}'),
//                         trailing: isRoomOwner
//                             ? CustomTextButtonIcon(
//                                 onPressed: () {
//                                   Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             RoomSettingsPage(
//                                           room: room,
//                                           roomCubit: roomCubit,
//                                         ),
//                                       ));
//                                 },
//                                 // GoRouter.of(context)
//                                 //     .go(AppRouter.kRoomSettingsPage),
//                                 buttonHeight: 35,
//                                 iconHeight: 15,
//                                 iconpadding: const EdgeInsets.all(4),
//                                 icon: FontAwesomeIcons.solidEdit,
//                                 sizeIcon: 9,
//                                 text: 'Settings')
//                             : null,
//                       ),
//                       Container(
//                         margin:
//                             const EdgeInsets.symmetric(horizontal: 16),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withValues(alpha: .6),
//                           borderRadius: const BorderRadius.all(
//                               Radius.circular(16)),
//                         ),
//                         child: const UserWidgetTitle(
//                             // room: room,
//                             ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.symmetric(horizontal: 20),
//                         child: Column(
//                           children: [
//                             const AutoSizeText(
//                               'Announcement',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 4.0,
//                             ),
//                             AutoSizeText(
//                               room.helloText,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w400,
//                                   color: AppColors.gray),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Spacer(),
//                       Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.spaceEvenly,
//                         children: [
//                           TextButton.icon(
//                             onPressed: () ,
//                             icon: const Icon(FontAwesomeIcons.heart),
//                             label: const AutoSizeText('Followed'),
//                           ),
//                           TextButton.icon(
//                             onPressed: () ,
//                             icon: const Icon(FontAwesomeIcons.user),
//                             label: const AutoSizeText('Review'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const Column(
//                     children: [
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: NetworkImage(
//                               AssetsData.userTest),
//                         ),
//                         title: AutoSizeText('Admin Name'),
//                         subtitle: AutoSizeText('Level: 2 | Rank: 5'),
//                         trailing: Icon(Icons.star),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }  // Row(
//   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   children: [
//     TextButton.icon(
//       onPressed: () {},
//       icon: const Icon(FontAwesomeIcons.heart),
//       label: const AutoSizeText('Followed'),
//     ),
//     TextButton.icon(
//       onPressed: () {},
//       icon: const Icon(FontAwesomeIcons.user),
//       label: const AutoSizeText('Review'),
//     ),
//   ],
// ),
