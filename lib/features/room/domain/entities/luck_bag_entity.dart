// entities/luck_bag_entity.dart
class LuckBagEntity {
  final String? id;
  final String? roomID;
  final String? who;
  final String? how;
  final String? user;
  final String? message;
  final int? createdAt;
  final String? ownerID;
  final int? maxUsers;
  LuckBagEntity(
      {this.id,
      this.ownerID,
      this.roomID,
      this.who,
      this.how,
      this.user,
      this.message,
      this.createdAt,
      this.maxUsers});

  // إضافة دالة copyWith يدوياً
  LuckBagEntity copyWith({
    String? id,
    String? roomID,
    String? who,
    String? how,
    String? user,
    String? message,
    int? createdAt,
    String? ownerID,
    int? maxUsers,
  }) {
    return LuckBagEntity(
        id: id ?? this.id,
        roomID: roomID ?? this.roomID,
        who: who ?? this.who,
        how: how ?? this.how,
        user: user ?? this.user,
        message: message ?? this.message,
        createdAt: createdAt ?? this.createdAt,
        ownerID: ownerID ?? this.ownerID,
        maxUsers: maxUsers ?? this.maxUsers);
  }
}
