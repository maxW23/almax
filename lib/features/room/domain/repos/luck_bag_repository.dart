// repositories/luck_bag_repository.dart
import 'package:lklk/features/room/domain/entities/luck_bag_entity.dart';

abstract class LuckBagRepository {
  Future<String> getBagResult(LuckBagEntity luckBag);
  Future<String> purchaseBag(LuckBagEntity luckBag);
  Future<String> sendUltraMessage(int roomID, String message);
}
