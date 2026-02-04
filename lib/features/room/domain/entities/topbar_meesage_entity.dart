class TopBarMessageEntity {
  final String? id;
  final String? userName;
  final String? userId;
  final String? roomId;
  final String? message;
  final String? giftSender;
  final String? giftReciver;
  final String? giftImg;
  final String? img;
  final String? giftSenderImg;
  final String? giftId;
  final int? timer;
  final String? vip;
  final String? pass;
  final String? level;
  final String? type;
  final String? sender;
  final String? reciver;
  final dynamic giftsMany;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TopBarMessageEntity({
    this.id,
    this.userName,
    this.userId,
    this.roomId,
    this.message,
    this.timer,
    this.giftSender,
    this.giftReciver,
    this.giftImg,
    this.img,
    this.giftSenderImg,
    this.giftId,
    this.vip,
    this.pass,
    this.giftsMany,
    this.level,
    this.type,
    this.sender,
    this.reciver,
    this.createdAt,
    this.updatedAt,
  });

  factory TopBarMessageEntity.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(String? s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    return TopBarMessageEntity(
      id: map[r'$id'],
      userName: map['gift_sender'],
      userId: map['sender'],
      roomId: map['room_id'],
      message: map['message'],
      giftSender: map['gift_sender'],
      giftReciver: map['gift_reciver'],
      reciver: map['reciver'],
      giftImg: map['gift_img'],
      img: map['img'],
      giftSenderImg: map['gift_sender_img'],
      giftId: map['gift_id']?.toString(),
      timer: int.tryParse(map['timer']?.toString() ?? '') ?? 4,
      vip: map['vip'],
      pass: map['Lpass'],
      level: map['level'],
      type: map['type'],
      sender: map['sender'],
      giftsMany: map['gifts_many'],
      createdAt: parseDate(map[r'$createdAt']),
      updatedAt: parseDate(map[r'$updatedAt']),
    );
  }

  @override
  String toString() {
    return 'TopBarMessageEntity(\n'
        '  id: $id,\n'
        '  userName: $userName,\n'
        '  userId: $userId,\n'
        '  roomId: $roomId,\n'
        '  message: $message,\n'
        '  giftSender: $giftSender,\n'
        '  giftReciver: $giftReciver,\n'
        '  giftImg: $giftImg,\n'
        '  img: $img,\n'
        '  giftSenderImg: $giftSenderImg,\n'
        '  giftId: $giftId,\n'
        '  timer: $timer,\n'
        '  vip: $vip,\n'
        '  pass: $pass,\n'
        '  level: $level,\n'
        '  type: $type,\n'
        '  sender: $sender,\n'
        '  reciver: $reciver,\n'
        '  giftsMany: $giftsMany,\n'
        '  createdAt: $createdAt,\n'
        '  updatedAt: $updatedAt,\n'
        ')';
  }

  // يمكنك أيضاً إضافة دالة toMap إذا كنت تريدها
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'userId': userId,
      'roomId': roomId,
      'message': message,
      'giftSender': giftSender,
      'giftReciver': giftReciver,
      'giftImg': giftImg,
      'img': img,
      'giftSenderImg': giftSenderImg,
      'giftId': giftId,
      'timer': timer,
      'vip': vip,
      'pass': pass,
      'level': level,
      'type': type,
      'sender': sender,
      'reciver': reciver,
      'giftsMany': giftsMany,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
