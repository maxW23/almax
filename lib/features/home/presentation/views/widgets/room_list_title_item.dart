import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/animations/lines_animation.dart';
import 'package:lklk/features/home/presentation/views/widgets/room_item_widget_titles_container.dart';

class RoomListTitleItem extends StatelessWidget {
  const RoomListTitleItem({
    super.key,
    required this.widget,
  });

  final RoomItemWidgetTitlesContainer widget;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    final Color c1 = _parseColor(room.color1) ?? const Color(0xFF8E2DE2);
    final Color c2 = _parseColor(room.color2) ?? const Color(0xFF4A00E0);

    final bool hasBack = room.back != null && room.back!.isNotEmpty;
    final BorderRadius cardRadius = isRTL
        ? const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(70),
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(8),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(70),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(8),
          );

    final EdgeInsets margin = isRTL
        ? const EdgeInsets.only(right: 30)
        : const EdgeInsets.only(left: 30);

    final Widget bg = hasBack
        ? Container(
            height: 100.h,
            margin: margin,
            decoration: BoxDecoration(
              borderRadius: cardRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: cardRadius,
              clipBehavior: Clip.antiAlias,
              child: SizedBox.expand(
                child: _imageAny(room.back, fit: BoxFit.cover),
              ),
            ),
          )
        : Container(
            height: 100.h,
            margin: margin,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c1, c2]),
              borderRadius: cardRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          );

    return Stack(
      children: [
        bg,
        Container(
          height: 100.h,
          // margin: margin,
          decoration: BoxDecoration(
            borderRadius: cardRadius,
          ),
          child: SizedBox(
            height: 100.h,
            child: ClipRRect(
              borderRadius: cardRadius,
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Content
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    child: Directionality(
                      textDirection:
                          isRTL ? TextDirection.rtl : TextDirection.ltr,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _AvatarWithOverlays(
                            img: room.img,
                            frame: room.frame,
                            back: room.back,
                          ),
                          SizedBox(width: 10.w),
                          // Titles
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  room.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    CountryFlag.fromCountryCode(
                                      room.country,
                                      height: 16.h,
                                      width: 22.w,
                                      shape: RoundedRectangle(3.r),
                                    ),
                                    SizedBox(width: 6.w),
                                    AutoSizeText(
                                      'ID: ${room.id}',
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Right column: type icon+label and fire counter
                          SizedBox(
                            width: 72.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _TypeIconAndText(
                                  word: room.word,
                                  ic: room.ic,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        height: 17,
                                        child: Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: const AnimatedLinesWidget(
                                              isWhite: false),
                                        )),
                                    SizedBox(width: 6.w),
                                    AutoSizeText(
                                      room.fire ?? '1',
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
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
            ),
          ),
        ),
      ],
    );
  }
}

Widget _imageAny(String? src, {BoxFit fit = BoxFit.cover}) {
  if (src == null || src.isEmpty) return const SizedBox();
  final bool isSvg = src.toLowerCase().endsWith('.svg');
  final bool isNetwork = src.startsWith('http');
  if (isSvg) {
    return isNetwork
        ? SvgPicture.network(
            src,
            fit: fit,
            placeholderBuilder: (_) => const SizedBox(),
          )
        : SvgPicture.asset(src, fit: fit);
  }
  if (isNetwork) {
    // Compute optimal cache dimensions based on the layout constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final double cw = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final double ch = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 100; // fallback for list item background height
        // Double quality: request 2x pixel density with safe clamps
        final int memW = (cw * dpr * 2).clamp(256, 2048).round();
        final int memH = (ch * dpr * 2).clamp(256, 2048).round();
        return CachedNetworkImage(
          imageUrl: src,
          fit: fit,
          memCacheWidth: memW,
          memCacheHeight: memH,
          maxWidthDiskCache: memW,
          maxHeightDiskCache: memH,
          imageBuilder: (context, provider) => Image(
            image: provider,
            fit: fit,
            filterQuality: FilterQuality.high,
          ),
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          errorWidget: (c, u, e) => const SizedBox(),
        );
      },
    );
  }
  return Image.asset(src, fit: fit);
}

class _AvatarWithOverlays extends StatelessWidget {
  const _AvatarWithOverlays({
    required this.img,
    required this.frame,
    required this.back,
  });

  final String? img;
  final String? frame;
  final String? back;

  String _normalizeImg(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    return 'https://lklklive.com/img/$value';
  }

  Widget _imageFrom(String? src, {BoxFit fit = BoxFit.cover}) {
    if (src == null || src.isEmpty) return const SizedBox();
    final bool isSvg = src.toLowerCase().endsWith('.svg');
    final bool isNetwork = src.startsWith('http');
    if (isSvg) {
      return isNetwork
          ? SvgPicture.network(
              src,
              fit: fit,
              placeholderBuilder: (_) => const SizedBox(),
            )
          : SvgPicture.asset(src, fit: fit);
    }
    if (isNetwork) {
      // Use constraints to size cache exactly to avatar/frame box
      return LayoutBuilder(
        builder: (context, constraints) {
          final dpr = MediaQuery.of(context).devicePixelRatio;
          final double cw = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 72.0;
          final double ch = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 72.0;
          // Double quality for frame overlays
          final int memW = (cw * dpr * 2).clamp(128, 1024).round();
          final int memH = (ch * dpr * 2).clamp(128, 1024).round();
          return CachedNetworkImage(
            imageUrl: src,
            fit: fit,
            memCacheWidth: memW,
            memCacheHeight: memH,
            maxWidthDiskCache: memW,
            maxHeightDiskCache: memH,
            imageBuilder: (context, provider) => Image(
              image: provider,
              fit: fit,
              filterQuality: FilterQuality.high,
            ),
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
          );
        },
      );
    }
    return Image.asset(src, fit: fit);
  }

  @override
  Widget build(BuildContext context) {
    final double size = 72.h;
    final String base = _normalizeImg(img);
    final BorderRadius avatarRadius = BorderRadius.circular(19.r);
    return ClipRRect(
      borderRadius: avatarRadius,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Base layer to ensure corners look consistent and no background shows
            const Positioned.fill(child: ColoredBox(color: Colors.white)),
            // Avatar
            Positioned.fill(
              child: Builder(
                builder: (context) {
                  final dpr = MediaQuery.of(context).devicePixelRatio;
                  // Double quality for avatar bitmap
                  final int memW = (size * dpr * 2).clamp(128, 1024).round();
                  final int memH = (size * dpr * 2).clamp(128, 1024).round();
                  return CachedNetworkImage(
                    imageUrl: base,
                    fit: BoxFit.cover,
                    memCacheWidth: memW,
                    memCacheHeight: memH,
                    maxWidthDiskCache: memW,
                    maxHeightDiskCache: memH,
                    imageBuilder: (context, provider) => Image(
                      image: provider,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                  );
                },
              ),
            ),

            // Frame overlay
            if (frame != null && frame!.isNotEmpty)
              Positioned.fill(child: _imageFrom(frame, fit: BoxFit.fill)),
          ],
        ),
      ),
    );
  }
}

class _TypeIconAndText extends StatelessWidget {
  const _TypeIconAndText({
    required this.word,
    required this.ic,
  });

  final String? word;
  final String? ic;

  // Normalize incoming backend value (Arabic or English) to a canonical key.
  // Supported keys: chat, music, contest, games, activity, party, radio
  String _normalizeWord(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    switch (v) {
      // Arabic inputs
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

      // English inputs
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

  String _getIconPath() {
    final w = _normalizeWord(word);
    switch (w) {
      case 'radio':
        return 'assets/icons/rooms_icons/radio.svg';
      case 'party':
        return 'assets/icons/rooms_icons/party.svg';
      case 'music':
        return 'assets/icons/rooms_icons/music.svg';
      case 'contest':
        // contest icon asset doesn't exist; use radio.svg as per settings sheet mapping
        return 'assets/icons/rooms_icons/radio.svg';
      case 'games':
        // games icon asset doesn't exist; use party.svg as per settings sheet mapping
        return 'assets/icons/rooms_icons/party.svg';
      case 'activity':
        return 'assets/icons/rooms_icons/activity.svg';
      case 'chat':
      default:
        return 'assets/icons/rooms_icons/chat.svg';
    }
  }

  Widget _iconWidget() {
    if (ic != null && ic!.isNotEmpty) {
      final String src = ic!;
      final bool isSvg = src.toLowerCase().endsWith('.svg');
      final bool isNetwork = src.startsWith('http');

      if (isSvg) {
        return isNetwork
            ? SvgPicture.network(
                src,
                width: 22,
                height: 22,
                placeholderBuilder: (_) =>
                    const SizedBox(width: 22, height: 22),
              )
            : SvgPicture.asset(src, width: 22, height: 22);
      }
      return isNetwork
          ? CachedNetworkImage(imageUrl: src, width: 22, height: 22)
          : Image.asset(src, width: 22, height: 22);
    }

    return SvgPicture.asset(
      _getIconPath(),
      width: 22,
      height: 22,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }

  String _label(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl ||
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final w = _normalizeWord(word);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconWidget(),
        const SizedBox(height: 4),
        Text(
          _label(context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

Color? _parseColor(String? src) {
  if (src == null || src.isEmpty) return null;
  final s = src.trim().toLowerCase();
  switch (s) {
    case 'blue':
      return const Color(0xFF2196F3);
    case 'red':
      return const Color(0xFFE91E63);
    case 'pink':
      return const Color(0xFFE91E63);
    case 'purple':
      return const Color(0xFF9C27B0);
    case 'green':
      return const Color(0xFF4CAF50);
    case 'orange':
      return const Color(0xFFFF9800);
  }
  String hex = s.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  try {
    return Color(int.parse(hex, radix: 16));
  } catch (_) {
    return null;
  }
}
