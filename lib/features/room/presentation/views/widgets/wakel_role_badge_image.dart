import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';
import 'package:lklk/core/player/svga_custom_player.dart';

/// Unified Wakel badge widget for all user types
/// Supports: superadmin, admin, sec_admin, mini_admin, mini, charge, user
class WakelRoleBadgeImage extends StatelessWidget {
  const WakelRoleBadgeImage({
    super.key,
    required this.type,
    this.size = LevelRowSize.normal,
    this.useSvga = true,
  });

  final String? type;
  final LevelRowSize size;
  final bool useSvga;

  @override
  Widget build(BuildContext context) {
    final double height = size == LevelRowSize.small ? 20.h : 20.h;
    final double width = size == LevelRowSize.small ? 48.w : 60.w;
    final double borderRadius = size == LevelRowSize.small ? 4.r : 4.r;

    final t = (type ?? 'user').toLowerCase();

    if (useSvga) {
      // SVGA assets mapping
      final String? svgaPath;
      switch (t) {
        case 'mini':
          svgaPath = 'assets/badges/user_badges/host_agent.svga';
          break;
        case 'mini_admin':
          svgaPath = 'assets/badges/user_badges/agency_manger.svga';
          break;
        case 'charge':
          svgaPath = 'assets/badges/user_badges/shipping_agent.svga';
          // svgaPath = 'assets/badges/user_badges/host_agent.svga';
          break;

        case 'superadmin':
          svgaPath = 'assets/badges/user_badges/super_admin.svga';
          break;
        // case 'user':
        //   svgaPath = 'assets/badges/user_badges/host.svga';
        //   break;

        default:
          return const SizedBox.shrink();
      }
      // Use CustomSVGAWidget with small size and no repeat to reduce cost
      return CustomSVGAWidget(
        height: height,
        width: width,
        pathOfSvgaFile: svgaPath,
        isRepeat: true,
        fit: BoxFit.fill,
        clearsAfterStop: false,
        allowDrawingOverflow: false,
        isPadding: false,
        preferredSize: Size(width, height),
      );
    } else {
      // Static asset images mapping (no network URLs)
      final String assetPath;
      switch (t) {
        case 'mini':
          assetPath = 'assets/badges/user_badges/host.png';
          break;
        case 'charge':
          assetPath = 'assets/badges/user_badges/host_agent.png';
          break;
        case 'superadmin':
          assetPath = 'assets/badges/user_badges/super_admin.png';
          break;
        case 'admin':
          assetPath = 'assets/badges/user_badges/agency_manger.png';
          break;
        case 'sec_admin':
          assetPath = 'assets/badges/user_badges/host_agent.png';
          break;
        case 'mini_admin':
          assetPath = 'assets/badges/user_badges/shipping_agent.png';
          break;
        case 'user':
        default:
          assetPath = 'assets/badges/user_badges/host.png';
          break;
      }
      return _AssetRoundedImage(
        assetPath: assetPath,
        height: height,
        width: width,
        borderRadius: borderRadius,
      );
    }
  }
}

class _AssetRoundedImage extends StatelessWidget {
  const _AssetRoundedImage({
    required this.assetPath,
    required this.height,
    required this.width,
    required this.borderRadius,
  });

  final String assetPath;
  final double height;
  final double width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetPath,
        height: height,
        width: width,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
