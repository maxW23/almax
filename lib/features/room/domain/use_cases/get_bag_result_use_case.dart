// use_cases/get_bag_result_use_case.dart
import 'package:lklk/features/room/domain/entities/luck_bag_entity.dart';
import 'package:lklk/features/room/domain/repos/luck_bag_repository.dart';

class GetBagResultUseCase {
  final LuckBagRepository repository;

  GetBagResultUseCase(this.repository);

  Future<String> execute(LuckBagEntity luckBag) {
    return repository.getBagResult(luckBag);
  }
}

// use_cases/purchase_bag_use_case.dart
class PurchaseBagUseCase {
  final LuckBagRepository repository;

  PurchaseBagUseCase(this.repository);

  Future<String> execute(LuckBagEntity luckBag) {
    return repository.purchaseBag(luckBag);
  }
}

// use_cases/send_ultra_message_use_case.dart
class SendUltraMessageUseCase {
  final LuckBagRepository repository;

  SendUltraMessageUseCase(this.repository);

  Future<String> execute(int roomID, String message) {
    return repository.sendUltraMessage(roomID, message);
  }
}

// use_cases/complete_purchase_flow_use_case.dart
class CompletePurchaseFlowUseCase {
  final GetBagResultUseCase getBagResultUseCase;
  final PurchaseBagUseCase purchaseBagUseCase;

  CompletePurchaseFlowUseCase({
    required this.getBagResultUseCase,
    required this.purchaseBagUseCase,
  });

  Future<void> execute(LuckBagEntity luckBag) async {
    await getBagResultUseCase.execute(luckBag);
    await purchaseBagUseCase.execute(luckBag);
  }
}
