// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:lklk/features/auth/domain/entities/user_entity.dart';

class FriendshipEntity {
  final int id;
  final String senderId;
  final String receiverId;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String stringId;
  final UserEntity userSent;
  FriendshipEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.stringId,
    required this.userSent,
  });

  FriendshipEntity copyWith({
    int? id,
    String? senderId,
    String? receiverId,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? stringId,
    UserEntity? userSent,
  }) {
    return FriendshipEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stringId: stringId ?? this.stringId,
      userSent: userSent ?? this.userSent,
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
      'userSent': userSent.toMap(),
    };
  }

  factory FriendshipEntity.fromMap(Map<String, dynamic> map) {
    return FriendshipEntity(
      id: map['id'] as int,
      senderId: map['senderId'].toString(),
      receiverId: map['receiverId'].toString(),
      type: map['type'].toString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      stringId: map['stringId'].toString(),
      userSent: UserEntity.fromMap(map['userSent'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  // factory FriendshipEntity.fromJson(String source) => FriendshipEntity.fromMap(json.decode(source) as Map<String, dynamic>);
  factory FriendshipEntity.fromJson(Map<String, dynamic> json) {
    return FriendshipEntity(
      id: json['id'] as int,
      senderId: json['sender_id'].toString(),
      receiverId: json['receiver_id'].toString(),
      type: json['type'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      stringId: json['stringid'].toString(),
      userSent: UserEntity.fromJson(json['user_sent'] as Map<String, dynamic>),
    );
  }
  @override
  String toString() {
    return 'FriendshipEntity(id: $id, senderId: $senderId, receiverId: $receiverId, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, stringId: $stringId, userSent: $userSent)';
  }

  @override
  bool operator ==(covariant FriendshipEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.stringId == stringId &&
        other.userSent == userSent;
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
        userSent.hashCode;
  }
}
