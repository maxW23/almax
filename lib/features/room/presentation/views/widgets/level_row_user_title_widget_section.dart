import 'package:flutter/material.dart';

import 'package:lklk/core/utils/logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/level_image.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_image_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/new_type_image.dart';
import 'package:lklk/features/room/presentation/views/widgets/wakel_role_badge_image.dart';

// Enum لتحديد حجم الواجهة
enum LevelRowSize {
  normal, // الحجم العادي
  small, // الحجم الصغير
}

class LevelRowUserTitleWidgetSection extends StatefulWidget {
  const LevelRowUserTitleWidgetSection({
    super.key,
    required this.user,
    this.isRoomTypeUser = false,
    this.isWakel = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
    required this.roomID,
    this.size = LevelRowSize.normal, // إضافة خاصية الحجم
    this.useSvgaWakelBadge = true,
  });

  final bool isRoomTypeUser;
  final bool isWakel;
  final UserEntity user;
  final MainAxisAlignment mainAxisAlignment;
  final String roomID;
  final LevelRowSize size; // خاصية الحجم الجديدة
  final bool useSvgaWakelBadge; // التحكم في عرض SVGA أو صورة ثابتة

  @override
  State<LevelRowUserTitleWidgetSection> createState() =>
      _LevelRowUserTitleWidgetSectionState();
}

class _LevelRowUserTitleWidgetSectionState
    extends State<LevelRowUserTitleWidgetSection> {
  String typeUser = 'user'; // Default value

  @override
  void initState() {
    super.initState();

    // log("5555roomID ${widget.roomID} -- ${widget.user.ownerIds} -- ${widget.user.adminRoomIds}");
    // log("55555User -- ${widget.user}");
    if (widget.user.ownerIds?.contains(widget.roomID) ?? false) {
      log("owner ${widget.user.ownerIds?.contains(widget.roomID)} -- ${widget.roomID}");
      typeUser = "owner";
    } else if (widget.user.adminRoomIds?.contains(widget.roomID) ?? false) {
      log("admin ${widget.user.adminRoomIds?.contains(widget.roomID)} -- ${widget.roomID}");
      typeUser = "admin";
    }
  }

  int _parseLevel(dynamic levelValue) {
    if (levelValue == null) return 0;
    final String raw = levelValue.toString().trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') return 0;

    final String s = raw.toLowerCase();
    // Handle suffixed numbers like 331.1K or 10M
    double? numVal;
    if (s.endsWith('k')) {
      numVal = double.tryParse(s.substring(0, s.length - 1));
      if (numVal != null) return (numVal * 1000).round();
    } else if (s.endsWith('m')) {
      numVal = double.tryParse(s.substring(0, s.length - 1));
      if (numVal != null) return (numVal * 1000000).round();
    }

    // Try plain int, then double
    final int? asInt = int.tryParse(s);
    if (asInt != null) return asInt;
    final double? asDouble = double.tryParse(s);
    if (asDouble != null) return asDouble.round();
    return 0;
  }

  // يحسب newlevel3 من خبرة level3 (كل 126000 = مستوى خبرة واحد)
  int _computeNewLevel3({String? providedNewLevel3, String? xpLevel3}) {
    // إذا كان الحقل موجودًا من الـ API نثق به
    final String providedStr = (providedNewLevel3 ?? '').trim();
    final int? providedInt = int.tryParse(providedStr);
    if (providedInt != null) return providedInt;
    final double? providedDouble = double.tryParse(providedStr);
    if (providedDouble != null) return providedDouble.floor();

    // خلاف ذلك نحسبه من نقاط الخبرة في level3
    final int xp = _parseLevel(xpLevel3);
    if (xp <= 0) return 0;
    final int lvl = xp ~/ 126000; // قسمة صحيحة (أرضي)
    return lvl;
  }

  String? _getVipAsset() {
    switch (widget.user.vip) {
      case '1':
        return AssetsData.vipLevel1;
      case '2':
        return AssetsData.vipLevel2;
      case '3':
        return AssetsData.vipLevel3;
      case '4':
        return AssetsData.vipLevel4;
      case '5':
        return AssetsData.vipLevel5;
      default:
        return null;
    }
  }

  // دالة مساعدة لتحديد الأبعاد بناءً على الحجم المحدد
  double _getSizeValue(double normalValue, double smallValue) {
    return widget.size == LevelRowSize.small ? smallValue : normalValue;
  }

  // تم الاستغناء عن _buildLevelInfo والاكتفاء باستخدام LevelImageWidget للمستوى الثالث

  @override
  Widget build(BuildContext context) {
    final int level1 = _parseLevel(widget.user.level1);
    final int level2 = _parseLevel(widget.user.level2);
    // newlevel3 قد لا يأتي من /top، لذا نحسبه من level3 (الخبرة)
    final int level3 = _computeNewLevel3(
      providedNewLevel3: widget.user.newlevel3,
      xpLevel3: widget.user.level3,
    );
    final String? vipAsset = _getVipAsset();

    // تحديد الأبعاد بناءً على الحجم المحدد
    final double spacing = _getSizeValue(1.w, 0.5.w);
    final double adminImageHeight = _getSizeValue(16.h, 12.h);
    final double adminImageWidth = _getSizeValue(50.w, 40.w);

    return SizedBox(
      height: 25.h,
      child: Directionality(
        textDirection: TextDirection.ltr, // Force LTR for consistent icon order
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // if (widget.user.newType != null)
              //   NewTypeImage(widget: widget, size: widget.size),
              if (widget.isWakel) ...[
                WakelRoleBadgeImage(
                  type: widget.user.type,
                  size: widget.size,
                  useSvga: widget.useSvgaWakelBadge,
                ),
                SizedBox(width: widget.user.newType != null ? spacing : 0),
              ],
              if (typeUser == 'admin') ...[
                Image.asset(
                  AssetsData.adminRoom,
                  height: adminImageHeight,
                  width: adminImageWidth,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: spacing),
              ] else if (typeUser == 'owner') ...[
                Image.asset(
                  AssetsData.ownerRoom,
                  height: adminImageHeight,
                  width: adminImageWidth,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: spacing),
              ],
              if (vipAsset != null) ...[
                Image.asset(
                  vipAsset,
                  height: _getSizeValue(20.h, 16.h),
                  width: _getSizeValue(36.w, 36.w),
                  fit: BoxFit.fill,
                ),
                SizedBox(width: spacing),
              ],
              LevelImageWidget(
                level: level1,
                isPrimary: true,
                imageProviderResolver: determineImage,
                displayValue: widget.user.level1?.toString() ?? '0',
                size: widget.size,
              ),
              SizedBox(width: spacing),
              LevelImageWidget(
                level: level2,
                isPrimary: false,
                imageProviderResolver: determineImage,
                displayValue: widget.user.level2?.toString() ?? '0',
                size: widget.size,
              ),
              SizedBox(width: spacing),
              LevelImageWidget(
                level: level3,
                isPrimary: false,
                imageProviderResolver: (lvl, isPrimary) {
                  final int v = (lvl <= 0) ? 1 : lvl;
                  if (v <= 20) return 'assets/badges/diamond_badges/1.png';
                  if (v <= 40) return 'assets/badges/diamond_badges/2.png';
                  if (v <= 80) return 'assets/badges/diamond_badges/3.png';
                  if (v <= 160) return 'assets/badges/diamond_badges/4.png';
                  if (v <= 320) return 'assets/badges/diamond_badges/5.png';
                  return 'assets/badges/diamond_badges/6.png';
                },
                // نعرض قيمة مستوى الخبرة المحسوبة (وليس نقاط الخبرة الخام)
                displayValue: level3.toString(),
                size: widget.size,
              ),
              // SizedBox(width: spacing),
            ],
          ),
        ),
      ),
    );
  }
}
