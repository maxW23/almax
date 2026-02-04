abstract class BuyItemState {}

class BuyItemInitial extends BuyItemState {}

class BuyItemLoading extends BuyItemState {}

class BuyItemSuccess extends BuyItemState {}

class BuyItemError extends BuyItemState {
  final String error;
  BuyItemError(this.error);
}
