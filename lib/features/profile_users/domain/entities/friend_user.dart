// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:lklk/features/auth/domain/entities/user_entity.dart';

class FriendUser {
  final int id;
  final String senderId;
  final String receiverId;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String stringId;
  final UserEntity friendUser;
  FriendUser({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.stringId,
    required this.friendUser,
  });

  FriendUser copyWith({
    int? id,
    String? senderId,
    String? receiverId,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? stringId,
    UserEntity? friendUser,
  }) {
    return FriendUser(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stringId: stringId ?? this.stringId,
      friendUser: friendUser ?? this.friendUser,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'stringId': stringId,
      'friendUser': friendUser.toMap(),
    };
  }

  factory FriendUser.fromMap(Map<String, dynamic> map) {
    return FriendUser(
      id: map['id'] as int,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      type: map['type'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      stringId: map['stringId'] as String,
      friendUser: UserEntity.fromMap(map['friendUser'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  // factory FriendUser.fromJson(String source) => FriendUser.fromMap(json.decode(source) as Map<String, dynamic>);
  factory FriendUser.fromJson(Map<String, dynamic> json) {
    return FriendUser(
      id: json['id'] as int,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      stringId: json['stringid'] as String,
      friendUser:
          UserEntity.fromJson(json['user_sent'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'FriendUser(id: $id, senderId: $senderId, receiverId: $receiverId, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, stringId: $stringId, friendUser: $friendUser)';
  }

  @override
  bool operator ==(covariant FriendUser other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.stringId == stringId &&
        other.friendUser == friendUser;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        stringId.hashCode ^
        friendUser.hashCode;
  }
}
