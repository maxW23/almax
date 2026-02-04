import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';

class AvatarData {
  static const String separator = ',*,';
  // زِد العدد لاحتواء frameLink و entryLink كحقول اختيارية جديدة في نهاية السلسلة
  static const int expectedPartsCount = 15; // image, frameId, vip, entryID, entryTimer, totalSocre, level1, level2, newlevel3, ownerIds, adminRoomIds, svgaSquareUrls, svgaRectUrls, frameLink, entryLink

  final String? imageUrl;
  final String? frameId;
  // رابط إطار SVGA المباشر (اختياري)، لتسهيل العرض بدون الحاجة لتحميل مسبق محلي
  final String? frameLink;
  // رابط دخول SVGA المباشر (اختياري) لتسهيل عرض دخول المستخدم
  final String? entryLink;
  final String? vipLevel;
  final String? entryID;
  final String? entryTimer;
  final String? totalSocre;
  final String? level1;
  final String? level2;
  final String? newlevel3;
  final List<String>? ownerIds;
  final List<String>? adminRoomIds;
  // روابط SVGA الاختيارية
  final List<String>? svgaSquareUrls; // ws*
  final List<String>? svgaRectUrls; // ic*

  AvatarData({
    this.imageUrl,
    this.frameId,
    this.frameLink,
    this.entryLink,
    this.vipLevel,
    this.entryID,
    this.entryTimer,
    this.totalSocre,
    this.level1,
    this.level2,
    this.newlevel3,
    ///////////////
    this.ownerIds,
    this.adminRoomIds,
    this.svgaSquareUrls,
    this.svgaRectUrls,
  });

  String toEncodedString() => [
        imageUrl ?? 'null',
        frameId ?? 'null',
        vipLevel ?? 'null',
        entryID ?? 'null',
        entryTimer ?? 'null',
        totalSocre ?? 'null',
        level1 ?? 'null',
        level2 ?? 'null',
        newlevel3 ?? 'null',

        //////////////////////////
        jsonEncode(ownerIds ?? []),
        jsonEncode(adminRoomIds ?? []),
        // SVGA lists appended at the end for backward compatibility
        jsonEncode(svgaSquareUrls ?? []),
        jsonEncode(svgaRectUrls ?? []),
        // New optional: frameLink at the very end (backward compatible)
        frameLink ?? 'null',
        // New optional: entryLink at the very end (backward compatible)
        entryLink ?? 'null',
      ].join(separator);

  factory AvatarData.fromEncodedString(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      // AppLogger.debug('AvatarData: encoded string is null or empty');
      return AvatarData();
    }

    // AppLogger.debug('AvatarData: parsing encoded string: $encoded');

    // إذا كان encoded مجرد اسم ملف (مثل "1756829907.jpg") بدون فواصل
    if (!encoded.contains(AvatarData.separator) &&
        encoded.contains('.') &&
        encoded.length < 100) {
      // AppLogger.debug(
      // 'AvatarData: detected simple filename, creating minimal AvatarData');
      return AvatarData(imageUrl: encoded);
    }

    try {
      final parts = encoded.split(AvatarData.separator);

      // Backward-compatible parsing: handle legacy (<14 parts), mid (==14 parts), and new (>=15 parts)
      if (parts.length < 14) {
        return AvatarData(
          imageUrl: _parsePart(parts, 0),
          frameId: _parsePart(parts, 1),
          vipLevel: _parsePart(parts, 2),
          entryID: _parsePart(parts, 3),
          entryTimer: _parsePart(parts, 4),
          totalSocre: _parsePart(parts, 5),
          level1: _parsePart(parts, 6),
          level2: _parsePart(parts, 7),
          newlevel3: parts.length > 8 ? _parsePart(parts, 8) : null,
          ownerIds: parts.length > 9 ? _parseListPart(parts, 9) : [],
          adminRoomIds: parts.length > 10 ? _parseListPart(parts, 10) : [],
          svgaSquareUrls: parts.length > 11 ? _parseListPart(parts, 11) : [],
          svgaRectUrls: parts.length > 12 ? _parseListPart(parts, 12) : [],
          frameLink: null,
          entryLink: null,
        );
      }

      return AvatarData(
        imageUrl: _parsePart(parts, 0),
        frameId: _parsePart(parts, 1),
        vipLevel: _parsePart(parts, 2),
        entryID: _parsePart(parts, 3),
        entryTimer: _parsePart(parts, 4),
        totalSocre: _parsePart(parts, 5),
        level1: _parsePart(parts, 6),
        level2: _parsePart(parts, 7),
        newlevel3: _parsePart(parts, 8),
        ownerIds: _parseListPart(parts, 9),
        adminRoomIds: _parseListPart(parts, 10),
        svgaSquareUrls: _parseListPart(parts, 11),
        svgaRectUrls: _parseListPart(parts, 12),
        frameLink: _parsePart(parts, 13),
        entryLink: parts.length > 14 ? _parsePart(parts, 14) : null,
      );
    } catch (e) {
      AppLogger.debug('Error decoding AvatarData: $e, encoded: $encoded');
      return AvatarData();
    }
  }
  static String? _parsePart(List<String> parts, int index) {
    return (parts.length > index && parts[index] != 'null')
        ? parts[index]
        : null;
  }

  static List<String>? _parseListPart(List<String> parts, int index) {
    if (parts.length <= index || parts[index] == 'null') return null;
    try {
      final decoded = jsonDecode(parts[index]) as List;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      AppLogger.debug('Error parsing list at index $index: ${parts[index]}');
      return null;
    }
  }

  @override
  String toString() => 'AvatarData('
      'imageUrl: $imageUrl, '
      'frameId: $frameId, '
      'frameLink: $frameLink, '
      'entryLink: $entryLink, '
      'vipLevel: $vipLevel, '
      'entryID: $entryID, '
      'entryTimer: $entryTimer, '
      'totalSocre: $totalSocre, '
      'level1: $level1, '
      'level2: $level2, '
      'level3: $newlevel3, '
      'ownerIds: $ownerIds, '
      'adminRoomIds: $adminRoomIds, '
      'svgaSquareUrls: $svgaSquareUrls, '
      'svgaRectUrls: $svgaRectUrls)';
}
