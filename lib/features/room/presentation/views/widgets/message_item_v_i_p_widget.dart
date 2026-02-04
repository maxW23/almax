import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_message_info.dart';

class MessageItemVIPWidget extends StatelessWidget {
  // final Message message;
  final Color? colorContainer;
  final Color colorBorder;
  final double paddingValue;
  final String imagePath;
  final String text;
  final String vip, img, userName;
  final RoomCubit roomCubit;
  final String roomID, userId;
  static const double _topImageSize = 32;
  static const double _messageRightMargin = 20;
  static const double _messageTextPadding = 2;
  static const double _containerWidthDivider = 2;

  const MessageItemVIPWidget({
    super.key,
    // required this.message,
    this.colorContainer,
    this.colorBorder = AppColors.transparent,
    required this.paddingValue,
    required this.imagePath,
    required this.text,
    required this.vip,
    required this.img,
    required this.userName,
    required this.roomCubit,
    required this.roomID,
    required this.userId,
  });

  VipMessageItemAssets? _getVipAsset() {
    switch (vip) {
      case '1':
        return VipMessageItemAssets(
          levelImage: AssetsData.vipLevel1,
          shieldImage: AssetsData.vip1SvgaSheildSVGA,
          topLeft: AssetsData.vipChatTL1,
          topRight: AssetsData.vipChatTR1,
          bottomLeft: AssetsData.vipChatBL1,
          bottomRight: AssetsData.vipChatBR1,
        );
      case '2':
        return VipMessageItemAssets(
          levelImage: AssetsData.vipLevel2,
          shieldImage: AssetsData.vip2SvgaSheildSVGA,
          topLeft: AssetsData.vipChatTL2,
          topRight: AssetsData.vipChatTR2,
          bottomLeft: AssetsData.vipChatBL2,
          bottomRight: AssetsData.vipChatBR2,
        );
      case '3':
        return VipMessageItemAssets(
          levelImage: AssetsData.vipLevel3,
          shieldImage: AssetsData.vip3SvgaSheildSVGA,
          topLeft: AssetsData.vipChatTL3,
          topRight: AssetsData.vipChatTR3,
          bottomLeft: AssetsData.vipChatBL3,
          bottomRight: AssetsData.vipChatBR3,
        );
      case '4':
        return VipMessageItemAssets(
          levelImage: AssetsData.vipLevel4,
          shieldImage: AssetsData.vip4SvgaSheildSVGA,
          topLeft: AssetsData.vipChatTL4,
          topRight: AssetsData.vipChatTR4,
          bottomLeft: AssetsData.vipChatBL4,
          bottomRight: AssetsData.vipChatBR4,
        );
      case '5':
        return VipMessageItemAssets(
          levelImage: AssetsData.vipLevel5,
          shieldImage: AssetsData.vip5SvgaSheildSVGA,
          topLeft: AssetsData.vipChatTL5,
          topRight: AssetsData.vipChatTR5,
          bottomLeft: AssetsData.vipChatBL5,
          bottomRight: AssetsData.vipChatBR5,
        );

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final vipImages = _getVipImages();
    final screenWidth = MediaQuery.of(context).size.width;
    final VipMessageItemAssets? vipAsset = _getVipAsset();

    return Align(
      alignment: Alignment.topRight,
      child: Column(
        children: [
          UserMessageInfo(
            img: img,
            userName: userName,
          ),
          if (roomCubit.state.usersZego != null)
            roomCubit.state.usersZego!.firstWhereOrNullExtention(
                        (element) => element.iduser == userId) !=
                    null
                ? Row(
                    children: [
                      Spacer(),
                      LevelRowUserTitleWidgetSection(
                        size: LevelRowSize.small,
                        isRoomTypeUser: true,
                        isWakel: true,
                        user: roomCubit.state.usersZego!
                            .where((element) => element.iduser == userId)
                            .first,
                        roomID: roomID,
                      ),
                      SizedBox(
                        width: 45.w,
                      )
                    ],
                  )
                : SizedBox(),
          SizedBox(
            height: 14.h,
          ),
          Align(
            alignment: Alignment.topRight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: screenWidth / _containerWidthDivider,
                  constraints: BoxConstraints(
                      maxWidth: screenWidth / _containerWidthDivider),
                  margin: const EdgeInsets.only(right: 24, left: 8, bottom: 20),
                  padding: EdgeInsets.all(paddingValue),
                  decoration: BoxDecoration(
                    color: colorContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colorBorder, width: 2),
                  ),
                  child: Column(
                    textDirection: TextDirection.rtl,
                    // _isRTLText ? TextDirection.rtl : TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // const SizedBox(height: _infoSpacing),
                      _buildMessageContent(),
                    ],
                  ),
                ),
                // Positioned(
                //   top: 0,
                //   left: 3,
                //   child: Image.asset(
                //     imagePath,
                //     height: _topImageSize,
                //     width: _topImageSize,
                //     fit: BoxFit.cover,
                //   ),
                // ),

                if (vipAsset?.topLeft != null)
                  Positioned(
                    top: -10,
                    left: -5,
                    child: Image.asset(
                      vipAsset!.topLeft,
                      height: _topImageSize,
                      width: _topImageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (vipAsset?.topRight != null)
                  Positioned(
                    top: -15,
                    right: 14,
                    child: Image.asset(
                      vipAsset!.topRight,
                      height: _topImageSize * 1.5,
                      width: _topImageSize * 1.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (vipAsset?.bottomLeft != null)
                  Positioned(
                    bottom: 8,
                    left: -8,
                    child: Image.asset(
                      vipAsset!.bottomLeft,
                      height: _topImageSize * 1.3,
                      width: _topImageSize * 1.3,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (vipAsset?.bottomRight != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Image.asset(
                      vipAsset!.bottomRight,
                      height: _topImageSize * 1.3,
                      width: _topImageSize * 1.3,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (vipAsset?.levelImage != null)
                  Positioned(
                    bottom: 1,
                    right: 25,
                    child: Image.asset(
                      vipAsset!.levelImage,
                      height:
                          _topImageSize * 1.2, // حجم أكبر قليلاً للصور العادية
                      width: _topImageSize * 1.2,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(right: _messageRightMargin),
      padding: const EdgeInsets.symmetric(
        vertical: _messageTextPadding,
        horizontal: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: AutoSizeText(
          text,
          textDirection: TextDirection.rtl,
          //  _isRTLText ? TextDirection.rtl : TextDirection.ltr,
          style: TextStyle(
            fontSize: 15, // حجم أكبر قليلاً للوضوح
            fontWeight: FontWeight.w400, // سماكة متوسطة أفضل للقراءة
            color: AppColors.white,
            fontFamily: 'Roboto', // خط احترافي (تأكد من إضافته في pubspec.yaml)
            height: 1.4, // زيادة تباعد الأسطر
            letterSpacing: 0.2, // تباعد أحرف دقيق
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 2,
                offset: Offset(0.5, 0.5),
              ),
            ], // ظل خفيف لتحسين التباين
          ),
          minFontSize: 12, // حد أدنى لحجم الخط
        ),
      ),
    );
  }
}

class VipMessageItemAssets {
  final String topRight;
  final String topLeft;
  final String bottomRight;
  final String bottomLeft;
  final String shieldImage;
  final String levelImage;

  VipMessageItemAssets(
      {required this.topRight,
      required this.topLeft,
      required this.bottomRight,
      required this.bottomLeft,
      required this.shieldImage,
      required this.levelImage});
}
