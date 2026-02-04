part of 'money_bag_top_bar_cubit.dart';

abstract class MoneyBagTopBarState extends Equatable {
  const MoneyBagTopBarState();

  @override
  List<Object> get props => [];
}

class MoneyBagTopBarInitial extends MoneyBagTopBarState {}

class MoneyBagTopBarShow extends MoneyBagTopBarState implements HasMessage {
  @override
  final TopBarMessageEntity message;
  final dynamic timestamp;
  const MoneyBagTopBarShow(this.message, this.timestamp);

  @override
  List<Object> get props => [message, timestamp];
}
