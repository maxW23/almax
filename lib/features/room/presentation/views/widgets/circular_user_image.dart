import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/custom_fading_widget.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/core/widgets/circular_gradient_box_decoration.dart';

class CircularUserImage extends StatefulWidget {
  final String? imagePath;
  final bool isEmpty;
  final double? radius;
  final Widget? child;
  final bool isSquare; // new: choose between circular (default) and square
  final double? cornerRadius; // new: square corner radius
  final String? frameOverlayAsset; // new: optional overlay frame asset
  final BoxFit? frameOverlayAssetFit; // new: optional overlay frame fit
  final double?
      innerPadding; // new: optional extra padding to inset avatar (useful when overlay frame covers edges)
  const CircularUserImage({
    super.key,
    required this.imagePath,
    this.isEmpty = false,
    this.radius = 20,
    this.child,
    this.isSquare = false,
    this.cornerRadius = 6,
    this.frameOverlayAsset,
    this.innerPadding,
    this.frameOverlayAssetFit = BoxFit.fill,
  });

  @override
  State<CircularUserImage> createState() => _CircularUserImageState();
}

class _CircularUserImageState extends State<CircularUserImage> {
  late String? _imagePath;

  @override
  void initState() {
    super.initState();
    updateImagePath(widget.imagePath);
  }

  @override
  void didUpdateWidget(CircularUserImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath) {
      updateImagePath(widget.imagePath);
    }
  }

  void updateImagePath(String? path) {
    final normalized = path?.trim();
    if (normalized == null ||
        normalized.isEmpty ||
        normalized.toLowerCase() == 'null') {
      _imagePath = null;
    } else if (normalized.startsWith('file://')) {
      final parts = normalized.split('/');
      final name = parts.isNotEmpty ? parts.last : '';
      _imagePath = name.isNotEmpty
          ? 'https://lklklive.com/imguser/$name'
          : AssetsData.userTestNetwork;
    } else if (normalized.contains('https://lh3.googleusercontent.com')) {
      // Upgrade Google avatar size hint to a higher resolution (e.g., s512)
      String upgraded = normalized
          .replaceAll(RegExp(r'/s\d+-c'), '/s512-c')
          .replaceAll(RegExp(r'=s\d+-c'), '=s512-c')
          .replaceAll(RegExp(r'=s\d+'), '=s512');
      _imagePath = upgraded;
    } else if (normalized.contains('https://lklklive.com') ||
        normalized.contains('http://lklklive.com')) {
      _imagePath = normalized; //
    } else if (normalized.contains('https://') ||
        normalized.contains('http://')) {
      _imagePath = normalized; //
    } else if (normalized.contains('assets')) {
      _imagePath = normalized;
    } else {
      _imagePath = 'https://lklklive.com/imguser/$normalized';
    }
    // Debug: log the final resolved image path
    assert(() {
      // ignore: avoid_print
      // AppLogger.debug(
      //     '[CircularUserImage] Resolved image URL: ${_imagePath ?? 'null'}');
      return true;
    }());
  }

  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetSize = (widget.radius ?? 20) * 2;
    // Use 2.0x DPR to fetch a sharper bitmap and clamp to safe bounds
    const double scale = 2.0;
    final double scaledW = targetSize * dpr * scale;
    final double scaledH = targetSize * dpr * scale;
    final int memW = (scaledW.isFinite && scaledW > 0)
        ? scaledW.clamp(64, 1024).round()
        : (targetSize * dpr).round();
    final int memH = (scaledH.isFinite && scaledH > 0)
        ? scaledH.clamp(64, 1024).round()
        : (targetSize * dpr).round();
    // If a frame overlay is provided, inset the avatar slightly so the frame fully covers edges.
    // Also allow caller to provide additional inner padding via `innerPadding`.
    final double frameInset = (widget.frameOverlayAsset != null ? 2.0 : 0.0) +
        (widget.innerPadding ?? 0.0);
    return widget.isEmpty
        ? (widget.isSquare
            ? Container(
                width: targetSize,
                height: targetSize,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(widget.cornerRadius ?? 6),
                ),
              )
            : CircleAvatar(
                radius: widget.radius!,
                backgroundColor: AppColors.transparent,
                child: Container(
                  decoration:
                      CircularGradientBoxDecoration.circularGradient(0.3),
                  child: IconButton(
                    color: AppColors.whiteWithOpacity5,
                    icon: const FaIcon(FontAwesomeIcons.microphone),
                    onPressed: () {
                      AppLogger.debug("Pressed");
                    },
                  ),
                ),
              ))
        : SizedBox(
            width: targetSize,
            height: targetSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Avatar image clipped to shape
                widget.isSquare
                    ? Padding(
                        padding: EdgeInsets.all(frameInset),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              (widget.cornerRadius ?? 6).toDouble()),
                          child: CachedNetworkImage(
                            imageUrl: _imagePath ?? AssetsData.userTestNetwork,
                            cacheKey: _imagePath,
                            memCacheWidth: memW,
                            memCacheHeight: memH,
                            maxWidthDiskCache: memW,
                            maxHeightDiskCache: memH,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            imageBuilder: (context, provider) => Image(
                              image: provider,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                              gaplessPlayback: true,
                              width: targetSize - frameInset * 2,
                              height: targetSize - frameInset * 2,
                            ),
                            placeholder: (context, url) => CustomFadingWidget(
                              child: Container(
                                color: AppColors.grey,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.grey,
                              child: CachedNetworkImage(
                                imageUrl: AssetsData.userTestNetwork,
                                memCacheWidth: memW,
                                memCacheHeight: memH,
                                maxWidthDiskCache: memW,
                                maxHeightDiskCache: memH,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(frameInset),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _imagePath ?? AssetsData.userTestNetwork,
                            cacheKey: _imagePath,
                            memCacheWidth: memW,
                            memCacheHeight: memH,
                            maxWidthDiskCache: memW,
                            maxHeightDiskCache: memH,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            imageBuilder: (context, provider) => Image(
                              image: provider,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                              gaplessPlayback: true,
                              width: targetSize - frameInset * 2,
                              height: targetSize - frameInset * 2,
                            ),
                            placeholder: (context, url) => CustomFadingWidget(
                              child: Container(
                                color: AppColors.grey,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.grey,
                              child: CachedNetworkImage(
                                imageUrl: AssetsData.userTestNetwork,
                                memCacheWidth: memW,
                                memCacheHeight: memH,
                                maxWidthDiskCache: memW,
                                maxHeightDiskCache: memH,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                // Optional frame overlay
                if (widget.frameOverlayAsset != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Image.asset(
                        widget.frameOverlayAsset!,
                        fit: widget.frameOverlayAssetFit,
                      ),
                    ),
                  ),
                if (widget.child != null) Positioned.fill(child: widget.child!),
              ],
            ),
          );
  }
}
