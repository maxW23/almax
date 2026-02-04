import 'dart:convert';

import 'package:lklk/features/auth/domain/entities/user_entity.dart';

class UserRelation {
  final int id;
  final String user1;
  final String user2;
  final String type;
  final String createdAt;
  final String updatedAt;
  final String? level;
  final String? user1Name;
  final String? user1Img;
  final String? user2Name;
  final String? user2Img;
  final UserEntity? user;

  UserRelation({
    required this.id,
    required this.user1,
    required this.user2,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.level,
    this.user1Name,
    this.user1Img,
    this.user2Name,
    this.user2Img,
    this.user,
  });

  UserRelation copyWith({
    int? id,
    String? user1,
    String? user2,
    String? type,
    String? createdAt,
    String? updatedAt,
    UserEntity? user,
    String? level,
    String? user1Img,
    String? user1Name,
    String? user2Img,
    String? user2Name,
  }) {
    return UserRelation(
      id: id ?? this.id,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      level: level ?? this.level,
      user1Img: user1Img ?? this.user1Img,
      user1Name: user1Name ?? this.user1Name,
      user2Img: user2Img ?? this.user2Img,
      user2Name: user2Name ?? this.user2Name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user1': user1,
      'user2': user2,
      'type': type,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'level': level,
      'user1_name': user1Name,
      'user1_img': user1Img,
      'user2_name': user2Name,
      'user2_img': user2Img,
      'user': user?.toMap(),
    };
  }

  factory UserRelation.fromMap(Map<String, dynamic> map) {
    return UserRelation(
      id: map['id'] as int,
      user1: map['user1'].toString(),
      user2: map['user2'].toString(),
      type: map['type'].toString(),
      createdAt: map['createdAt'].toString(),
      updatedAt: map['updatedAt'].toString(),
      level: map['level'].toString(),
      user1Name: map['user1_name'].toString(),
      user1Img: map['user1_img'].toString(),
      user2Name: map['user2_name'].toString(),
      user2Img: map['user2_img'].toString(),
      user: map['user'] != null
          ? UserEntity.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRelation.fromJson(Map<String, dynamic> json) {
    return UserRelation(
      id: json['id'],
      user1: json['user1'],
      user2: json['user2'],
      type: json['type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      level: json['level'],
      user1Name: json['user1_name'],
      user1Img: json['user1_img'],
      user2Name: json['user2_name'],
      user2Img: json['user2_img'],
      user: json['user'] != null ? UserEntity.fromJson(json['user']) : null,
    );
  }

  @override
  String toString() {
    return 'UserRelation(id: $id, user1: $user1, user2: $user2, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, level: $level, user1Name: $user1Name, user1Img: $user1Img, user2Name: $user2Name, user2Img: $user2Img, user: $user)';
  }

  @override
  bool operator ==(covariant UserRelation other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user1 == user1 &&
        other.user2 == user2 &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.level == level &&
        other.user1Name == user1Name &&
        other.user1Img == user1Img &&
        other.user2Name == user2Name &&
        other.user2Img == user2Img &&
        other.user == user;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user1.hashCode ^
        user2.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        level.hashCode ^
        user1Name.hashCode ^
        user1Img.hashCode ^
        user2Name.hashCode ^
        user2Img.hashCode ^
        user.hashCode;
  }
}

// class UserRelation {
//   final int id;
//   final String user1;
//   final String user2;
//   final String type;
//   final String createdAt;
//   final String updatedAt;
//   final String? level;
//   final String? user1_name;
//   final String? user1_img;
//   final String? user2_name;
//   final String? user2_img;
//   final UserEntity? user;
//   UserRelation({
//     required this.id,
//     required this.user1,
//     required this.user2,
//     required this.type,
//     required this.createdAt,
//     required this.updatedAt,
//     this.user,
//     this.level,
//     this.user1_img,
//     this.user1_name,
//     this.user2_img,
//     this.user2_name,
//   });

//   UserRelation copyWith({
//     int? id,
//     String? user1,
//     String? user2,
//     String? type,
//     String? createdAt,
//     String? updatedAt,
//     UserEntity? user,
//     String? level,
//     String? user1_img,
//     String? user1_name,
//     String? user2_img,
//     String? user2_name,
//   }) {
//     return UserRelation(
//       id: id ?? this.id,
//       user1: user1 ?? this.user1,
//       user2: user2 ?? this.user2,
//       type: type ?? this.type,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       user: user ?? this.user,
//       level: level ?? this.level,
//       user1_img: user1_img ?? this.user1_img,
//       user1_name: user1_name?? this .user1_name,
//       user2_img: user2_img ?? this.user2_img,
//       user2_name: user2_name ?? this.user2_name,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'id': id,
//       'user1': user1,
//       'user2': user2,
//       'type': type,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//       'user': user?.toMap(),
//       'level':level,
//       'user1_img':user1_img,
//       'user1_name':user1_name,
//       'user2_img':user2_img,
//       'user2_name':user2_name,
//     };
//   }

//   factory UserRelation.fromMap(Map<String, dynamic> map) {
//     return UserRelation(
//       id: map['id'] as int,
//       user1: map['user1'] .toString(),
//       user2: map['user2'] .toString(),
//       type: map['type'] .toString(),
//       createdAt: map['createdAt'] .toString(),
//       updatedAt: map['updatedAt'] .toString(),
//       user: map['user'] != null
//           ? UserEntity.fromMap(map['user'] as Map<String, dynamic>)
//           : null,
//       level: map['level'] .toString(),
//       user1_img: map['user1_img'] .toString(),
//       user1_name: map['user1_name'] .toString(),
//       user2_img: map['user2_img'] .toString(),
//       user2_name: map['user2_name'] .toString(),

//     );
//   }

//   String toJson() => json.encode(toMap());

//   // factory UserRelation.fromJson(String source) => UserRelation.fromMap(json.decode(source) as Map<String, dynamic>);
//   factory UserRelation.fromJson(Map<String, dynamic> json) {
//     return UserRelation(
//       id: json['id'],
//       user1: json['user1'],
//       user2: json['user2'],
//       type: json['type'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       user: UserEntity.fromJson(json['user']) as UserEntity?,
//       level: json['level'] ,
//       user1_img: json['user1_img'] ,
//       user1_name: json['user1_name'] ,
//       user2_img: json['user2_img'] ,
//       user2_name: json['user2_name'] ,
//     );
//   }
//   @override
//   String toString() {
//     return 'UserRelation(id: $id, user1: $user1, user2: $user2, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, user: $user , level :$level , user1_img:$user1_img)';
//   }

//   @override
//   bool operator ==(covariant UserRelation other) {
//     if (identical(this, other)) return true;

//     return other.id == id &&
//         other.user1 == user1 &&
//         other.user2 == user2 &&
//         other.type == type &&
//         other.createdAt == createdAt &&
//         other.updatedAt == updatedAt &&
//         other.user == user;
//   }

//   @override
//   int get hashCode {
//     return id.hashCode ^
//         user1.hashCode ^
//         user2.hashCode ^
//         type.hashCode ^
//         createdAt.hashCode ^
//         updatedAt.hashCode ^
//         user.hashCode;
//   }
// }
