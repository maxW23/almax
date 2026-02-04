import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/foreground_service_manager.dart';

import '../../../live_audio_room_manager.dart';
import 'defines.dart';

class AudioRoomOverlayPageWidget extends StatefulWidget {
  final AudioRoomOverlayData overlayData;
  final GlobalKey<NavigatorState> navigatorKey;

  const AudioRoomOverlayPageWidget({
    super.key,
    required this.navigatorKey,
    required this.overlayData,
  });

  @override
  State<AudioRoomOverlayPageWidget> createState() =>
      _AudioRoomOverlayPageWidgetState();
}

class _AudioRoomOverlayPageWidgetState
    extends State<AudioRoomOverlayPageWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          // Background Circle with Image
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 60, // جعل الارتفاع والعرض متساويين لضمان شكل دائري مثالي
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey,
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.overlayData.roomImg,
                  // حجم كاش محسن لصور الأوفرلاي (عادة 60×60)
                  memCacheWidth: 120,
                  memCacheHeight: 120,
                  maxWidthDiskCache: 120,
                  maxHeightDiskCache: 120,
                  placeholder: (context, url) => Container(
                    color: AppColors.grey,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.grey,
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                audioRoomOverlayController.hide();
                ZegoLiveAudioRoomManager().logoutRoom();
                await ForegroundServiceManager.stopService(context);
              },
              child: Container(
                width: 24, // تصغير حجم الزر قليلاً
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black.withValues(alpha: 0.7),
                  border: Border.all(
                    color: AppColors.white,
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    FontAwesomeIcons.powerOff,
                    color: AppColors.white,
                    size: 12, // تصغير حجم الأيقونة
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// back 123
// ZegoSeatItemView(
//   onPressed: () {
//     audioRoomOverlayController.restore(
//       widget.navigatorKey.currentState!.context,
//     );
//   },

//   /// default show host only
//   seatIndex: 0,
// ),
