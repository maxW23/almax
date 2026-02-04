part of 'diamond_cubit.dart';

@immutable
abstract class DiamondState {}

class DiamondInitial extends DiamondState {}

class BuyDiamondEvent extends DiamondState {
  final int diamondAmount;

  BuyDiamondEvent(this.diamondAmount);
}

class DiamondLoading extends DiamondState {}

class DiamondPurchased extends DiamondState {}

class DiamondFailed extends DiamondState {
  final String errorMessage;

  DiamondFailed(this.errorMessage);
}
