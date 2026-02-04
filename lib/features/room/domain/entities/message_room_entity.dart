// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// message.dart
class Message {
  final int id;
  final String userName;
  final String roomId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? img;
  final String? level;
  final String isOwmer;
  final String? giftSender;
  final String? giftReciver;
  final String? giftsMany;
  final String? vip;
  final String? reciverId;
  final String? giftLink;
  final String? giftImg;
  final String? pass;
  final int? timer;
  Message(
      {required this.id,
      required this.userName,
      required this.roomId,
      required this.userId,
      required this.text,
      required this.createdAt,
      required this.updatedAt,
      this.level,
      required this.isOwmer,
      this.img,
      this.giftReciver,
      this.giftSender,
      this.giftsMany,
      this.vip,
      this.reciverId,
      this.pass,
      this.giftImg,
      this.giftLink,
      this.timer});

  Message copyWith({
    int? id,
    String? userName,
    String? roomId,
    String? userId,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? img,
    String? level,
    String? isOwmer,
    String? giftSender,
    String? giftReciver,
    String? giftsMany,
    String? vip,
    String? reciverId,
    String? giftImg,
    String? giftLink,
    String? pass,
    int? timer,
  }) {
    return Message(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      img: img ?? this.img,
      level: level ?? this.level,
      isOwmer: isOwmer ?? this.isOwmer,
      giftReciver: giftReciver ?? this.giftReciver,
      giftSender: giftSender ?? this.giftSender,
      giftsMany: giftsMany ?? this.giftsMany,
      vip: vip ?? this.vip,
      reciverId: reciverId ?? this.reciverId,
      giftLink: reciverId ?? this.giftLink,
      giftImg: reciverId ?? this.giftImg,
      pass: pass ?? this.pass,
      timer: timer ?? this.timer,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userName': userName,
      'roomId': roomId,
      'userId': userId,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'img': img,
      'level': level,
      'isOwmer': isOwmer,
      'giftReciver': giftReciver,
      'giftSender': giftSender,
      'giftsMany': giftsMany,
      'vip': vip,
      'reciverId': reciverId,
      'timer': timer,
      'pass': pass,
      'giftLink': giftLink,
      'giftImg': giftImg,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
        id: map['id'] as int,
        userName: map['userName'].toString(),
        roomId: map['roomId'].toString(),
        userId: map['userId'].toString(),
        text: (map['text'] ?? map['massage']).toString(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
        img: map['img'] is String
            ? map['img'].toString()
            : (map['img'] != null ? map['img']['url'].toString() : null),
        level: map['level'].toString(),
        isOwmer: map['isOwmer'].toString(),
        giftReciver: map['giftReciver'].toString(),
        giftSender: map['giftSender'].toString(),
        giftsMany: map['giftsMany'].toString(),
        vip: map['vip'].toString(),
        reciverId: map['reciver_id'].toString(),
        giftLink: map['gift_link'].toString(),
        giftImg: map['gift_img'].toString(),
        pass: map['pass'].toString(),
        timer: map["timer"] as int);
  }

  String toJson() => json.encode(toMap());

  // factory Message.fromJson(String source) => Message.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      userName: json['user_name'],
      roomId: json['room_id'],
      userId: json['user_id'],
      text: (json['massage'] ?? json['text']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      img: json['img'],
      level: json['level'],
      isOwmer: json['admin'],
      giftReciver: json['gift_reciver'],
      giftSender: json['gift_sender'],
      giftsMany: json['gifts_many'],
      vip: json['vip'],
      reciverId: json['reciver_id'],
      giftLink: json['gift_link'],
      giftImg: json['gift_img'],
      pass: json['pass'],
      timer: json["timer"] != null
          ? int.tryParse(json["timer"].toString())
          : null, // تحويل null إلى قيمة افتراضية 0
    );
  }
  @override
  String toString() {
    return 'Message(id: $id, userName: $userName, roomId: $roomId, userId: $userId, text: $text, createdAt: $createdAt, updatedAt: $updatedAt, img: $img, level: $level, isOwmer: $isOwmer, giftReciver: $giftReciver, giftSender: $giftSender ,giftsMany: $giftsMany.vip:$vip, reciverId: $reciverId, timer: $timer, giftLink:$giftLink , giftImg:$giftImg ,pass:$pass )';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userName == userName &&
        other.roomId == roomId &&
        other.userId == userId &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.img == img &&
        other.level == level &&
        other.isOwmer == isOwmer &&
        other.giftReciver == giftReciver &&
        other.giftSender == giftSender &&
        other.giftsMany == giftsMany &&
        other.reciverId == reciverId &&
        other.timer == timer &&
        other.giftImg == giftImg &&
        other.giftLink == giftLink &&
        other.pass == pass &&
        other.vip == vip;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userName.hashCode ^
        roomId.hashCode ^
        userId.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        img.hashCode ^
        level.hashCode ^
        isOwmer.hashCode ^
        giftReciver.hashCode ^
        giftSender.hashCode ^
        giftsMany.hashCode ^
        reciverId.hashCode ^
        timer.hashCode ^
        giftLink.hashCode ^
        giftImg.hashCode ^
        pass.hashCode ^
        vip.hashCode;
  }
}
