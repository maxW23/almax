class MessagePrivate {
  final int id;
  final String senderId;
  final String receiverId;
  final String message;
  final String createdAt;
  final String updatedAt;

  MessagePrivate({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessagePrivate.fromJson(Map<String, dynamic> json) {
    return MessagePrivate(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['masssage'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
