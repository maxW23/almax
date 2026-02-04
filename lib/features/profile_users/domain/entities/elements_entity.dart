import 'dart:convert';
import 'package:hive/hive.dart';

part 'elements_entity.g.dart'; // This will be generated

@HiveType(typeId: 0)
class ElementEntity {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? userId;

  @HiveField(2)
  final String? elementName;

  @HiveField(3)
  final dynamic date;

  @HiveField(4)
  final String? createdAt;

  @HiveField(5)
  final String? updatedAt;

  @HiveField(6)
  final bool? buy;

  @HiveField(7)
  final String? elamentId;

  @HiveField(8)
  final String? type;

  @HiveField(9)
  String? imgElement;

  @HiveField(10)
  String? linkPath;

  @HiveField(11)
  final String? giftCount;

  @HiveField(12)
  final String? price;

  @HiveField(13)
  final bool isSale;

  @HiveField(14)
  final num? timer;

  @HiveField(15)
  final dynamic vip;
  @HiveField(16)
  String? linkPathLocal;
  @HiveField(17)
  String? still;

  @HiveField(18)
  String? imgElementLocal;

  @HiveField(19)
  final String? userName;
  @HiveField(20)
  final String? giftPoints;
  ElementEntity({
    this.id,
    this.linkPathLocal,
    this.userId,
    this.elementName,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.buy,
    this.elamentId,
    this.type,
    this.imgElement,
    this.linkPath,
    this.price,
    this.isSale = true,
    this.timer,
    this.vip,
    this.giftCount,
    this.imgElementLocal,
    this.still,
    this.giftPoints,
    this.userName,
  });

  // Normalize URLs: encode spaces, support //host, host-only, and relative paths
  static String? _normalizeUrl(String? raw) {
    if (raw == null) return null;
    var t = raw.trim();
    if (t.isEmpty) return null;
    if (t.contains(' ')) t = t.replaceAll(' ', '%20');
    if (t.startsWith('//')) return 'https:$t';
    if (t.startsWith('lklklive.com')) return 'https://$t';
    if (t.startsWith('/')) return 'https://lklklive.com$t';
    return t;
  }

  factory ElementEntity.fromJson(Map<String, dynamic> json) {
    return ElementEntity(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'] ?? ''),
      userId: json['user_id']?.toString(),
      elementName: json['elament'] ?? json['Element_Name'] ?? json['element'],
      price: json['price']?.toString(),
      date: json['date'],
      createdAt: json['created_At']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      type: json['type']?.toString(),
      buy: (json['buy']?.toString() == 'yes') ||
          (json['active']?.toString() == 'yes'),
      imgElement: _normalizeUrl(json['img'] ?? json['Image']),
      linkPath: _normalizeUrl((json['link'] ?? json['Link_Path'])?.toString()),
      elamentId: json['elament_id'] ??
          json['element_id'] ??
          json['elament']?.toString(),
      giftCount: json['gift_count']?.toString(),
      still: json['still']?.toString(),
      vip: json['vip'],
      isSale: json['isSale'] ?? true,
      userName: json['userName']?.toString(),
      giftPoints: json['giftPoints']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'elament': elementName,
      'date': date,
      'created_At': createdAt,
      'updated_at': updatedAt,
      'buy': buy,
      'elament_id': elamentId,
      'type': type,
      'img': imgElement,
      'imgLocal': imgElementLocal,
      'link': linkPath,
      'price': price,
      'isSale': isSale,
      'timer': timer,
      'vip': vip,
      'gift_count': giftCount,
      'still': still,
      'linkLocal': linkPathLocal,
      'userName': userName,
      'giftPoints': giftPoints
    };
  }

// Inside ElementEntity class add:
  factory ElementEntity.gift({
    required String userId,
    required String userName,
    required String giftId,
    required int giftCount,
    int giftPoints = 1,
  }) {
    final now = DateTime.now();
    return ElementEntity(
      userId: userId,
      userName: userName,
      elamentId: giftId,
      giftCount: giftCount.toString(),
      giftPoints: giftPoints.toString(),
      date: now,
      createdAt: now.toString(),
      updatedAt: now.toString(),
      buy: true,
      isSale: false,
      type: "gift",
    );
  }
  List<ElementEntity> parseGiftElementsData(List<dynamic> jsonList) {
    return jsonList.map((json) => ElementEntity.fromJson(json)).toList();
  }

  ElementEntity markAsDownloaded(String localPath) {
    return ElementEntity(
      id: id,
      userId: userId,
      elementName: elementName,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
      buy: buy,
      elamentId: elamentId,
      type: type,
      imgElement: imgElement,
      linkPath: linkPath,
      giftCount: giftCount,
      price: price,
      isSale: isSale,
      timer: timer,
      vip: vip,
      imgElementLocal: imgElementLocal,
      linkPathLocal: localPath,
      still: still,
      userName: userName,
      giftPoints: giftPoints,
    );
  }

  String toJson() => json.encode(toMap());
}
