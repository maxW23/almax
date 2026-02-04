// gift_entity.dart
class GiftEntity {
  final String userId;
  final String userName;
  final String giftId;
  final String giftType;
  final int giftCount;
  final int giftPoints;
  final int timestamp;
  final int timer;
  final String? imgGift;
  final String? imgUser;
  final String? giftReciversName;
  final String? link;

  GiftEntity({
    required this.userId,
    required this.userName,
    required this.giftId,
    required this.giftType,
    required this.giftCount,
    required this.giftPoints,
    required this.timestamp,
    required this.timer,
    this.imgGift,
    this.imgUser,
    this.giftReciversName,
    this.link,
  });

  static String? _normalizeUrl(String? raw) {
    if (raw == null) return null;
    var t = raw.trim();
    if (t.isEmpty) return null;
    // encode only spaces to avoid double-encoding existing % sequences
    if (t.contains(' ')) t = t.replaceAll(' ', '%20');
    if (t.startsWith('//')) return 'https:$t';
    if (t.startsWith('lklklive.com')) return 'https://$t';
    if (t.startsWith('/')) return 'https://lklklive.com$t';
    return t;
  }

  factory GiftEntity.fromMap(Map<String, dynamic> map) {
    // Normalize possible timestamp keys
    final dynamic tsRaw = map['timestamp'] ?? map['createdAt'] ?? map['created_at'] ?? map['created'] ?? '';
    int ts = int.tryParse(tsRaw.toString()) ?? 0;
    // Ensure milliseconds resolution if server sent seconds
    if (ts > 0 && ts < 1000000000000) {
      ts = ts * 1000;
    }

    return GiftEntity(
      userId: map['user_id']?.toString() ?? '',
      userName: map['user_name']?.toString() ?? '',
      giftId: map['gift_id']?.toString() ?? '',
      giftType: (map['gift_type'] ?? map['Type'])?.toString() ?? '',
      giftCount: int.tryParse(map['gift_count']?.toString() ?? '') ?? 1,
      giftPoints: int.tryParse(map['gift_points']?.toString() ?? '') ?? 0,
      timestamp: ts,
      timer: int.tryParse(map['timer']?.toString() ?? '') ?? 4,
      imgGift: _normalizeUrl((map['img_gift'] ?? map['Image'])?.toString()),
      imgUser: _normalizeUrl(map['img_user']?.toString()),
      giftReciversName: map['gift_recivers_name']?.toString(),
      link: _normalizeUrl((map['link'] ?? map['Link_Path'])?.toString()),
    );
  }
  Map<String, dynamic> toJson() => toMap();
  @override
  String toString() {
    return 'GiftEntity{userId: $userId, userName: $userName, giftId: $giftId, giftType: $giftType, giftCount: $giftCount, giftPoints: $giftPoints, timestamp: $timestamp, timer: $timer, imgGift: $imgGift, imgUser: $imgUser, giftReciversName: $giftReciversName, link: $link}';
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'gift_id': giftId,
      'gift_type': giftType,
      'gift_count': giftCount,
      'gift_points': giftPoints,
      'timestamp': timestamp,
      'timer': timer,
      'img_gift': imgGift,
      'img_user': imgUser,
      'gift_recivers_name': giftReciversName,
      'link': link
    };
  }
}
