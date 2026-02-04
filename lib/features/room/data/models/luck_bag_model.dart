// data/models/luck_bag_model.dart
import 'package:lklk/features/room/domain/entities/luck_bag_entity.dart';

class LuckBagModel {
  final String? roomID;
  final String? who;
  final String? how;
  final String? user;
  final String? message;
  final String? id;

  LuckBagModel({
    this.roomID,
    this.who,
    this.how,
    this.user,
    this.message,
    this.id,
  });

  factory LuckBagModel.fromEntity(LuckBagEntity entity) {
    return LuckBagModel(
      roomID: entity.roomID,
      who: entity.who,
      how: entity.how,
      user: entity.user,
      message: entity.message,
      id: entity.id,
    );
  }

  LuckBagEntity toEntity() {
    return LuckBagEntity(
        roomID: roomID,
        who: who,
        how: how,
        user: user,
        message: message,
        id: id);
  }
}
