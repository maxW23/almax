import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/animations/lines_animation.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/core/widgets/overlay/defines.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/password_input_dialog.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:x_overlay/x_overlay.dart';

class TopSixRoomsWidget extends StatelessWidget {
  const TopSixRoomsWidget({
    super.key,
    required this.rooms,
    required this.roomCubit,
    required this.userCubit,
  });

  final List<RoomEntity> rooms;
  final RoomCubit roomCubit;
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) return const SizedBox.shrink();
    final big = rooms.isNotEmpty ? rooms[0] : null;
    final small =
        rooms.length > 1 ? rooms.sublist(1).take(5).toList() : <RoomEntity>[];

    // Sizes
    const double spacing = 10;
    const double bigHeight = 240;
    const double smallHeight = 115;
    final double cardRadius = 15;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big card
            if (big != null)
              Expanded(
                flex: 2,
                child: RepaintBoundary(
                  child: _RoomTrendCard(
                  room: big,
                  height: bigHeight,
                  radius: cardRadius,
                  isBig: true,
                  onTap: () => _openRoom(context, big),
                  // Frame for rank, #1
                  frameAsset:
                      'assets/images/rooms/rooms_frames/fram_top_room_1.png',
                  contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
            const SizedBox(width: spacing),
            // Right two small stacked
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  if (small.isNotEmpty)
                    RepaintBoundary(
                      child: _RoomTrendCard(
                      room: small[0],
                      height: smallHeight,
                      radius: cardRadius,
                      onTap: () => _openRoom(context, small[0]),
                      // Frame for rank #2
                      frameAsset:
                          'assets/images/rooms/rooms_frames/fram_top_room_2.png',
                      contentPadding: const EdgeInsets.all(8),
                      ),
                    ),
                  SizedBox(height: spacing),
                  if (small.length > 1)
                    RepaintBoundary(
                      child: _RoomTrendCard(
                      room: small[1],
                      height: smallHeight,
                      radius: cardRadius,
                      onTap: () => _openRoom(context, small[1]),
                      // Frame for rank #3
                      frameAsset:
                          'assets/images/rooms/rooms_frames/fram_top_room_3.png',
                      contentPadding: const EdgeInsets.all(8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: spacing),
        // Bottom row of three
        Row(
          children: [
            for (int i = 2; i < 5; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 4 ? spacing : 0),
                  child: (small.length > i)
                      ? RepaintBoundary(
                          child: _RoomTrendCard(
                          room: small[i],
                          height: smallHeight,
                          radius: cardRadius,
                          onTap: () => _openRoom(context, small[i]),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _openRoom(BuildContext context, RoomEntity room) async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      SnackbarHelper.showMessage(
        context,
        S.of(context).microphonePermissionIsRequired,
      );
      return;
    }

    if (XOverlayPageState.overlaying ==
        audioRoomOverlayController.pageStateNotifier.value) {
      audioRoomOverlayController.restore(context, withSafeArea: false);
      return;
    }

    String? pass;
    if (room.pass != null) {
      pass = await showDialog<String>(
        context: context,
        builder: (context) => const PasswordSetupDialog(),
      );
      if (pass != room.pass || pass == null) {
        SnackbarHelper.showMessage(
          context,
          S.of(context).thePasswordIsWrong,
        );
        return;
      }
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => RoomViewBloc(
          roomId: room.id,
          pass: pass,
          roomCubit: roomCubit,
          userCubit: userCubit,
          backgroundImage: room.background,
          isForce: true,
          // initialRoom: room,
        ),
      ),
    );
  }
}

class _RoomTrendCard extends StatelessWidget {
  const _RoomTrendCard({
    required this.room,
    required this.height,
    required this.radius,
    required this.onTap,
    this.isBig = false,
    this.frameAsset,
    this.contentPadding,
  });

  final RoomEntity room;
  final double height;
  final double radius;
  final bool isBig;
  final VoidCallback onTap;
  final String? frameAsset;
  final EdgeInsets? contentPadding;

  Color _parseCoverColor(String? c) {
    if (c == null || c.isEmpty) return AppColors.primary;
    final lower = c.toLowerCase();
    // Common names
    switch (lower) {
      case 'blue':
        return const Color(0xFF3F51B5);
      case 'red':
        return const Color(0xFFE91E63);
      case 'pink':
        return const Color(0xFFE91E63);
      case 'purple':
        return const Color(0xFF9C27B0);
    }
    // Hex formats: #RRGGBB or #AARRGGBB
    String hex = lower.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = room.img.startsWith('http')
        ? room.img
        : 'https://lklklive.com/img/${room.img}';
    // Use color1 (fallback to color2) as the base color for overlays
    final cover = _parseCoverColor(room.color1 ?? room.color2);
    // Auto padding when a decorative frame is used, so content stays inside the frame
    final EdgeInsets effectivePadding = frameAsset != null
        ? (isBig ? const EdgeInsets.all(10) : const EdgeInsets.all(3))
        : (contentPadding ?? EdgeInsets.zero);
    final EdgeInsets effectiveImagePadding = frameAsset != null
        ? (isBig ? const EdgeInsets.all(10) : const EdgeInsets.all(3))
        : (contentPadding ?? EdgeInsets.zero);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(8),
              ),
              child: Stack(
                children: [
                  // Background image
                  imageRoom(imgUrl, padding: effectiveImagePadding),
                  // Overlay content wrapped with auto padding if frame exists
                  Padding(
                    padding: effectivePadding,
                    child: Stack(
                      children: [
                        // Top row with chat type and flag (hidden when frame overlay is present)
                        if (frameAsset == null)
                          Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                _buildTypeChip(context, cover, room.word ?? ""),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: _buildFlag(),
                                ),
                              ],
                            ),
                          ),
                        // Bottom gradient with user count
                        userCountRoom(cover),
                        // Room name at the bottom
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: nameRoom(),
                        ),
                      ],
                    ),
                  ),
                 // Frame ,overlay on top (non-interactive)
                  if (frameAsset != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Image.asset(
                          frameAsset!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Positioned imageRoom(String imgUrl, {EdgeInsets? padding}) {
    return Positioned.fill(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dpr = MediaQuery.of(context).devicePixelRatio;
            final double cw = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;
            final double ch = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 200;
            final int memW = (cw * dpr).clamp(256, 1280).round();
            final int memH = (ch * dpr).clamp(256, 1280).round();
            return CachedNetworkImage(
              imageUrl: imgUrl,
              fit: BoxFit.cover,
              memCacheWidth: memW,
              memCacheHeight: memH,
              maxWidthDiskCache: memW,
              maxHeightDiskCache: memH,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (c, u) => const SizedBox(),
              errorWidget: (c, u, e) => const SizedBox(),
            );
          },
        ),
      ),
    );
  }

  AutoSizeText nameRoom() {
    return AutoSizeText(
      room.name,
      maxLines: 1,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }

  Positioned userCountRoom(Color cover) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 29,
        width: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.0),
              // cover.withOpacity(0.85),
              cover.withOpacity(0.85),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 18,
              child: const AnimatedLinesWidget(isWhite: true),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              room.fire ?? '200',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag() {
    return CountryFlag.fromCountryCode(
      room.country,
      height: 18,
      width: 26,
      shape: const RoundedRectangle(3),
    );
  }

  Widget _buildTypeChip(BuildContext context, Color cover, String roomType) {
    // Normalize backend value (Arabic/English) to canonical key
    String _normalizeWord(String? value) {
      final v = (value ?? '').trim().toLowerCase();
      switch (v) {
        case 'دردشة':
          return 'chat';
        case 'موسيقى':
          return 'music';
        case 'مسابقات':
          return 'contest';
        case 'ألعاب':
        case 'العاب':
          return 'games';
        case 'أنشطة':
        case 'انشطة':
          return 'activity';
        case 'chat':
          return 'chat';
        case 'music':
          return 'music';
        case 'contest':
        case 'contests':
          return 'contest';
        case 'games':
        case 'game':
          return 'games';
        case 'activity':
        case 'activities':
          return 'activity';
        case 'party':
          return 'party';
        case 'radio':
          return 'radio';
      }
      return 'chat';
    }

    String _localizedLabel(BuildContext context, String? value) {
      final isArabic = Directionality.of(context) == TextDirection.rtl ||
          Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
      final w = _normalizeWord(value);
      if (isArabic) {
        switch (w) {
          case 'radio':
            return 'راديو';
          case 'party':
            return 'حفلة';
          case 'music':
            return 'موسيقى';
          case 'contest':
            return 'مسابقات';
          case 'games':
            return 'ألعاب';
          case 'activity':
            return 'أنشطة';
          case 'chat':
          default:
            return 'دردشة';
        }
      } else {
        switch (w) {
          case 'radio':
            return 'Radio';
          case 'party':
            return 'Party';
          case 'music':
            return 'Music';
          case 'contest':
            return 'Contests';
          case 'games':
            return 'Games';
          case 'activity':
            return 'Activities';
          case 'chat':
          default:
            return 'Chat';
        }
      }
    }

    final label = _localizedLabel(context, roomType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cover,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
