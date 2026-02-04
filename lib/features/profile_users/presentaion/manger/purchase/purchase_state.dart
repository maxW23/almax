part of 'purchase_cubit.dart';

abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object?> get props => [];
}

class PurchaseInitial extends PurchaseState {
  const PurchaseInitial();
}

class PurchaseLoading extends PurchaseState {
  const PurchaseLoading();
}

class PurchaseReady extends PurchaseState {
  const PurchaseReady();
}

class PurchasePending extends PurchaseState {
  final String productId;
  final int coinAmount;

  const PurchasePending(this.productId, this.coinAmount);

  @override
  List<Object?> get props => [productId, coinAmount];
}

class PurchaseVerifying extends PurchaseState {
  final String productId;
  final int coinAmount;

  const PurchaseVerifying(this.productId, this.coinAmount);

  @override
  List<Object?> get props => [productId, coinAmount];
}

class PurchaseSuccess extends PurchaseState {
  final String productId;
  final int coinAmount;
  final String? serverMessage;
  final String? debugInfo;

  const PurchaseSuccess(this.productId, this.coinAmount,
      {this.serverMessage, this.debugInfo});

  @override
  List<Object?> get props => [productId, coinAmount, serverMessage, debugInfo];
}

class PurchaseError extends PurchaseState {
  final String message;

  const PurchaseError(this.message);

  @override
  List<Object?> get props => [message];
}

class PurchaseCanceled extends PurchaseState {
  const PurchaseCanceled();
}
