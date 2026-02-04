import 'dart:async';
import 'package:lklk/features/room/domain/entities/luck_bag_entity.dart';

class BagSession {
  final String bagID;
  final String ownerID;
  final String? who;
  final String? how;
  final int? displayEndAtMs;
  final int createdAt;
  final int maxUsers;
  final LuckBagEntity? bag;
  final List<String> collectedUsers;
  Timer? timer;
  bool isProcessing;

  BagSession({
    required this.bagID,
    required this.ownerID,
    required this.who,
    required this.how,
    this.displayEndAtMs,
    required this.createdAt,
    required this.maxUsers,
    this.bag,
    required this.collectedUsers,
    this.timer,
    this.isProcessing = false,
  });
  void dispose() {
    timer?.cancel();
    timer = null;
  }
}
