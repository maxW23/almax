// ignore_for_file: deprecated_member_use

import 'package:lklk/core/utils/logger.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/utils/functions/image_helper.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/widgets/microphone_room_page.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/flages_countrys.dart';
import 'package:lklk/features/room/presentation/views/widgets/item_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/password_input_dialog.dart';
import 'package:lklk/features/room/presentation/views/widgets/rename_room_dialog.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_settings_appbar.dart';
import 'package:lklk/features/room/presentation/views/widgets/show_users_bottom_sheet.dart';
import 'package:lklk/features/room/presentation/views/widgets/view_profile.dart';
import 'package:lklk/zego_sdk_manager.dart';

class RoomSettingsPage extends StatefulWidget {
  const RoomSettingsPage({
    super.key,
    required this.room,
    required this.roomCubit,
    this.users,
    this.bannedUsers,
    required this.userCubit,
    required this.isAdmin,
    required this.onSend,
    required this.adminUsers, // Add isAdmin parameter
  });

  final RoomEntity room;
  final RoomCubit roomCubit;
  final List<UserEntity>? users;
  final List<UserEntity>? bannedUsers;
  final List<UserEntity>? adminUsers;

  final UserCubit userCubit;
  final bool isAdmin; // Boolean to check if the user is an admin
  final void Function(ZIMMessage) onSend;
  @override
  State<RoomSettingsPage> createState() => _RoomSettingsPageState();
}

class _RoomSettingsPageState extends State<RoomSettingsPage> {
  String selectedLanguage = 'en';
  @override
  void initState() {
    super.initState();
    // Load current language from cubit
    final languageCubit = context.read<LanguageCubit>();
    selectedLanguage = languageCubit.state.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    log("lan $selectedLanguage");
    const categoryTitleStyle =
        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500);
    // const disabledColor =
    //     Colors.grey; // Grayed out color for non-clickable items

    return BlocConsumer<RoomCubit, RoomCubitState>(
      listener: (context, stateRoomCubit) {},
      builder: (context, stateRoomCubit) {
        return Directionality(
          textDirection: getTextDirection(selectedLanguage),
          child: Scaffold(
            appBar: const RoomSettingsAppbar(),
            body: ListView(
              children: [
                // Profile view
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 40.0, horizontal: 20.0),
                  child: ViewProfileRoom(
                    onTap: widget.isAdmin
                        ? null
                        : () async {
                            // Disable for admins
                            File? file = await ImageHelper.pickImage(
                              targetHeight: 400,
                              targetWidth: 400,
                              isCrop: true,
                            );
                            if (file == null) {
                              // Show snackbar
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: AutoSizeText(
                                      'الصورة كبيرة جدًا ولا يمكن تحميلها'),
                                ),
                              );
                            }
                            if (file != null) {
                              await widget.roomCubit
                                  .editImageRoom(widget.room.id, file, 'img');
                              messenger.showSnackBar(
                                SnackBar(
                                    content:
                                        Text('${s.waitforcheckyouimage} ')),
                              );
                            }
                          },
                    urlRoomImage: widget.room.img,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: AutoSizeText(S.of(context).roomInfo, style: categoryTitleStyle),
                ),
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).roomName,
                  svgAsset: 'assets/icons/room_settings/room_title_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () async {
                          // Disable for admins
                          String? newName = await showDialog<String>(
                            context: context,
                            builder: (context) => const RenameNameDialog(),
                          );
                          if (newName != null) {
                            await widget.roomCubit
                                .editRoomName(widget.room.id, newName);
                          }
                        },
                  // Apply gray color if disabled
                ),
                // Room Image
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: selectedLanguage == 'ar' ? 'صورة الغرفة' : 'Room Image',
                  svgAsset: 'assets/icons/room_settings/room_image_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () async {
                          File? file = await ImageHelper.pickImage(
                            targetHeight: 400,
                            targetWidth: 400,
                            isCrop: true,
                          );
                          if (file == null) {
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: AutoSizeText('الصورة كبيرة جدًا ولا يمكن تحميلها')),
                            );
                          }
                          if (file != null) {
                            await widget.roomCubit
                                .editImageRoom(widget.room.id, file, 'img');
                            messenger.showSnackBar(
                              SnackBar(content: Text('${s.waitforcheckyouimage} ')),
                            );
                          }
                        },
                ),
                // Room Wallpaper
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).roomWallpaper,
                  svgAsset: 'assets/icons/room_settings/room_image_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () async {
                          File? file = await ImageHelper.pickImage(
                            quality: 80,
                            isScreenfull: true,
                            screenWidth: MediaQuery.of(context).size.width.toInt(),
                            screenHeight: MediaQuery.of(context).size.height.toInt(),
                            isCrop: true,
                          );
                          if (file == null) {
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: AutoSizeText('الصورة كبيرة جدًا ولا يمكن تحميلها')),
                            );
                          }
                          if (file != null) {
                            await widget.roomCubit
                                .editImageRoom(widget.room.id, file, 'background');
                          }
                          messenger.showSnackBar(
                            SnackBar(content: Text('${s.waitforcheckyouimage} ')),
                          );
                        },
                ),
                // Room Flag
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).country,
                  svgAsset: 'assets/icons/room_settings/room_flag_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () async {
                          String? newName = await showDialog<String>(
                            context: context,
                            builder: (context) => const CountryFlagPicker(),
                          );
                          if (newName != null) {
                            widget.roomCubit.editCountry(widget.room.id, newName);
                          }
                        },
                ),
                // ===== General Settings =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: AutoSizeText(S.of(context).settings, style: categoryTitleStyle),
                ),
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).roomAnnouncement,
                  svgAsset: 'assets/icons/room_settings/room_bio_announcement_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () async {
                          // Disable for admins
                          String? newName = await showDialog<String>(
                            context: context,
                            builder: (context) => const RenameNameDialog(),
                          );
                          if (newName != null) {
                            await widget.roomCubit
                                .editHelloText(widget.room.id, newName);
                          }
                        },
                  // Apply gray color if disabled
                ),
                // (country moved to Room Information)
                // Room type selector
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: selectedLanguage == 'ar' ? 'تصنيف الروم' : 'Room Type',
                  svgAsset: 'assets/icons/room_settings/room_type_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () async {
                          await _showRoomTypeBottomSheet(context);
                        },
                ),
                // (open room moved to Privacy Settings under Lock)
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).microphones,
                  svgAsset: 'assets/icons/room_settings/microphones_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MicophoneRoomPage(
                                room: widget.room,
                                roomCubit: widget.roomCubit,
                              ),
                            ),
                          );
                        },
                ),
                // (duplicate room wallpaper removed; already in Room Information)

                // ===== Admin Settings =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: AutoSizeText(S.of(context).admin, style: categoryTitleStyle),
                ),
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).roomAdmin,
                  svgAsset: 'assets/icons/room_settings/admin_list_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () {
                          ShowUsersBottomsheet.showBasicModalBottomSheet(
                            context,
                            widget.userCubit,
                            widget.roomCubit,
                            'Room Admin',
                            widget.onSend,
                            widget.adminUsers,
                            roomId: widget.room.id,
                            isAdd: true,
                            icon: FontAwesomeIcons.arrowRotateLeft,
                            onUserAction: (roomId, userId, how) async {
                              log('removeAdminFromRoom $roomId -- $userId');

                              await widget.roomCubit
                                  .removeAdminFromRoom(roomId, userId);
                              widget.roomCubit.refreshRoomData(widget.room.id);
                            },
                          );
                        },
                ),

                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).addUserToAdminList,
                  svgAsset: 'assets/icons/room_settings/admin_list_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () {
                          List<UserEntity>? users =
                              (stateRoomCubit.usersServer ?? widget.users ?? [])
                                  .where((user) => user.type == 'user')
                                  .toList();
                          ShowUsersBottomsheet.showBasicModalBottomSheet(
                            context,
                            widget.userCubit,
                            widget.roomCubit,
                            'add user to Admin List',
                            widget.onSend,
                            users,
                            roomId: widget.room.id,
                            isAdd: true,
                            icon: FontAwesomeIcons.circlePlus,
                            onUserAction: (roomId, userId, how) async {
                              // log('addAdminToRoom $roomId -- $userId');
                              await widget.roomCubit
                                  .addAdminToRoom(roomId, userId);
                              widget.roomCubit.refreshRoomData(widget.room.id);
                              widget.roomCubit.refreshUserData(userId);
                            },
                          );
                        },
                ),
                // ===== Privacy =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: AutoSizeText(S.of(context).block, style: categoryTitleStyle),
                ),
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).roomLock,
                  svgAsset: 'assets/icons/room_settings/room_lock.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () async {
                          if (int.parse(widget.userCubit.user!.vip!) >= 1) {
                            String? pass = await showDialog<String>(
                              context: context,
                              builder: (context) => const PasswordSetupDialog(),
                            );
                            if (pass != null) {
                              widget.roomCubit.editPassRoom(widget.room.id, pass);
                            }
                          } else {
                            messenger.showSnackBar(
                              SnackBar(content: Text(s.yVIP1UPLockRoom)),
                            );
                          }
                        },
                ),
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).roomOpen,
                  svgAsset: 'assets/icons/room_settings/room_lock.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: widget.isAdmin
                      ? null
                      : () async {
                          await widget.roomCubit.editOpenPrivetRoom(widget.room.id);
                          messenger.showSnackBar(
                            SnackBar(content: Text(s.theRoomOpened)),
                          );
                        },
                ),
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).roomBlockList,
                  svgAsset: 'assets/icons/room_settings/block_list_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: () async {
                    // Always enabled for admins
                    List<UserEntity>? bannedUsersRoom =
                        (stateRoomCubit.bannedUsers ??
                            widget.bannedUsers ??
                            []);
                    ShowUsersBottomsheet.showBasicModalBottomSheet(
                      context,
                      widget.userCubit,
                      widget.roomCubit,
                      "Room Block List",
                      widget.onSend,
                      bannedUsersRoom,
                      roomId: widget.room.id,
                      icon: FontAwesomeIcons.arrowRotateLeft,
                      isAdd: true,
                      onUserAction: (roomId, userId, how) async {
                        await widget.roomCubit
                            .removeBanFromUser(roomId, userId);
                        widget.roomCubit.refreshRoomData(widget.room.id);
                      },
                    );
                  },
                ),
                ItemWidget(
                  selectedLanguage: selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).blockUser,
                  svgAsset: 'assets/icons/room_settings/block_list_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: () async {
                    // Always enabled for admins
                    List<UserEntity>? users =
                        (stateRoomCubit.usersServer ?? widget.users ?? [])
                            .where((user) =>
                                int.parse(user.vip!) < 4 &&
                                user.type != 'owner' &&
                                user.banned == "no" &&
                                !(stateRoomCubit.bannedUsers ??
                                        widget.bannedUsers ??
                                        [])
                                    .any((bannedUser) =>
                                        bannedUser.iduser == user.iduser))
                            .toList();
                    ShowUsersBottomsheet.showBasicModalBottomSheet(
                      context,
                      widget.userCubit,
                      widget.roomCubit,
                      "Block User",
                      widget.onSend,
                      users,
                      roomId: widget.room.id,
                      isAdd: true,
                      icon: FontAwesomeIcons.circlePlus,
                      onUserAction: (roomId, userId, how) async {
                        await widget.roomCubit
                            .banUserFromRoom(roomId, userId, how);
                        widget.roomCubit.refreshRoomData(widget.room.id);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helpers inside state
extension on _RoomSettingsPageState {
  int _detectCurrentRoomType(RoomEntity room) {
    // Prefer numeric type if available
    final t = room.type;
    final n = int.tryParse((t ?? '').trim());
    if (n != null && n >= 1 && n <= 5) return n;

    final w = (room.word ?? '').toLowerCase();
    if (w.contains('دردشة') || w.contains('chat')) return 1;
    if (w.contains('موسي') || w.contains('music')) return 2;
    if (w.contains('مساب') || w.contains('contest') || w.contains('radio')) return 3;
    if (w.contains('العاب') || w.contains('ألعاب') || w.contains('game')) return 4;
    if (w.contains('انشط') || w.contains('أنشط') || w.contains('activity')) return 5;
    return 1;
  }

  Future<void> _showRoomTypeBottomSheet(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final int current = _detectCurrentRoomType(widget.room);

    final options = [
      {
        'n': 1,
        'ar': 'دردشة',
        'en': 'Chat',
        'icon': 'assets/icons/rooms_icons/chat.svg',
      },
      {
        'n': 2,
        'ar': 'موسيقى',
        'en': 'Music',
        'icon': 'assets/icons/rooms_icons/music.svg',
      },
      {
        'n': 3,
        'ar': 'مسابقات',
        'en': 'Contests',
        'icon': 'assets/icons/rooms_icons/radio.svg',
      },
      {
        'n': 4,
        'ar': 'العاب',
        'en': 'Games',
        'icon': 'assets/icons/rooms_icons/party.svg',
      },
      {
        'n': 5,
        'ar': 'انشطة',
        'en': 'Activities',
        'icon': 'assets/icons/rooms_icons/activity.svg',
      },
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        final tt = theme.textTheme;
        Color borderFor(bool selected) =>
            selected ? cs.primary : cs.outlineVariant.withOpacity(0.6);
        List<Color> gradientFor(int n) {
          switch (n) {
            case 1:
              return const [Color(0xFF4facfe), Color(0xFF00f2fe)];
            case 2:
              return const [Color(0xFFf5576c), Color(0xFFf093fb)];
            case 3:
              return const [Color(0xFF43e97b), Color(0xFF38f9d7)];
            case 4:
              return const [Color(0xFFfa709a), Color(0xFFfee140)];
            case 5:
            default:
              return const [Color(0xFFa18cd1), Color(0xFFfbc2eb)];
          }
        }
        return Directionality(
          textDirection: getTextDirection(selectedLanguage),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Grab handle
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(FontAwesomeIcons.layerGroup,
                            size: 18, color: cs.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedLanguage == 'ar'
                                  ? 'اختر تصنيف الروم'
                                  : 'Choose Room Type',
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedLanguage == 'ar'
                                  ? 'اختر ما يناسب طبيعة الغرفة، يمكنك تغييره لاحقاً'
                                  : 'Pick what fits your room vibe, you can change it anytime',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        splashRadius: 22,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Grid of playful cards
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: options.map<Widget>((opt) {
                      final int n = opt['n'] as int;
                      final bool isSelected = n == current;
                      final colors = gradientFor(n);
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          Feedback.forTap(ctx);
                          Navigator.of(ctx).pop();
                          await widget.roomCubit
                              .editRoomType(widget.room.id, n);
                          messenger.showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(selectedLanguage == 'ar'
                                  ? 'تم تحديث تصنيف الروم'
                                  : 'Room type updated'),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: 108,
                          height: 120,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: colors,
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : cs.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: borderFor(isSelected),
                              width: isSelected ? 1.6 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: colors.first.withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color:
                                          cs.shadow.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : cs.onSurface.withOpacity(0.06),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    opt['icon'] as String,
                                    width: 24,
                                    height: 24,
                                    colorFilter: ColorFilter.mode(
                                      isSelected ? Colors.white : cs.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedLanguage == 'ar'
                                    ? opt['ar'] as String
                                    : opt['en'] as String,
                                textAlign: TextAlign.center,
                                style: tt.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : cs.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
