import 'package:lklk/core/utils/logger.dart';

class HomeMessageEntity {
  final int id;
  final String? senderId;
  final String receiverId;
  final String message;
  final String? type;
  final String createdAt;
  final String updatedAt;
  final String sender;
  final String? otherImg;
  final String? gender;
  final String user;
  final String idString;
  final String? userImg;
  final String? other;
  final String? howManyTime;

  HomeMessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    required this.otherImg,
    required this.gender,
    required this.user,
    required this.idString,
    required this.other,
    this.userImg,
    this.howManyTime,
  });

  factory HomeMessageEntity.fromJson(Map<String, dynamic> json) {
    // Log the JSON object for debugging purposes
    log('HomeMessageEntity fromJson: $json');

    return HomeMessageEntity(
      id: json['id'] ?? 0,
      senderId: json['sender_id'].toString(),
      receiverId: json['receiver_id'].toString(),
      message: json['masssage'].toString(),
      type: json['type'].toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      sender: json['sender'].toString(),
      otherImg: json['otherimg'].toString(),
      gender: json['gender'].toString(),
      user: json['user'],
      idString: json['idstring'].toString(),
      userImg: json['userimg'].toString(),
      other: json['other'].toString(),
      howManyTime: json['how_many_time'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'gender': gender,
      'receiverId': receiverId,
      'masssage': message,
      'type': type,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sender': sender,
      'otherimg': otherImg,
      'user': user,
      'idstring': idString,
      'userimg': userImg,
      'other': other,
      'howManyTime': howManyTime,
    };
  }
}
