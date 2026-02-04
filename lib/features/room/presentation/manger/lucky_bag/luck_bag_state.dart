part of 'luck_bag_cubit.dart';

// presentation/states/luck_bag_state.dart
enum BagStatus { initial, loading, purchasing, sendingMessage, success, error }

class LuckBagState extends Equatable {
  final BagStatus status;
  final String? resultMessage;
  final String? purchaseMessage;
  final String? ultraMessage;
  final String? error;
  final String? currentOperation;
  final int activeBagsCount;
  @override
  List<Object?> get props => [
        status,
        resultMessage,
        purchaseMessage,
        ultraMessage,
        error,
        currentOperation,
        activeBagsCount,
      ];

  const LuckBagState({
    this.status = BagStatus.initial,
    this.resultMessage,
    this.purchaseMessage,
    this.ultraMessage,
    this.error,
    this.currentOperation,
    this.activeBagsCount = 0,
  });

  LuckBagState copyWith({
    BagStatus? status,
    String? resultMessage,
    String? purchaseMessage,
    String? ultraMessage,
    String? error,
    String? currentOperation,
    int? activeBagsCount,
  }) {
    return LuckBagState(
      status: status ?? this.status,
      resultMessage: resultMessage ?? this.resultMessage,
      purchaseMessage: purchaseMessage ?? this.purchaseMessage,
      ultraMessage: ultraMessage ?? this.ultraMessage,
      error: error ?? this.error,
      currentOperation: currentOperation ?? this.currentOperation,
      activeBagsCount: activeBagsCount ?? this.activeBagsCount,
    );
  }

  factory LuckBagState.initial() {
    return const LuckBagState(
      status: BagStatus.initial,
      activeBagsCount: 0,
    );
  }

  bool get isLoading => status == BagStatus.loading;
  bool get isPurchasing => status == BagStatus.purchasing;
  bool get isSendingMessage => status == BagStatus.sendingMessage;
  bool get isSuccess => status == BagStatus.success;
  bool get isError => status == BagStatus.error;
}
