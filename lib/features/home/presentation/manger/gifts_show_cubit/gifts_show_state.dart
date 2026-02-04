// gifts_show_state.dart
part of 'gifts_show_cubit.dart';

abstract class GiftsShowState extends Equatable {
  const GiftsShowState();
  @override
  List<Object> get props => [];
}

class GiftsShowInitial extends GiftsShowState {}

class GiftShow extends GiftsShowState {
  final GiftEntity giftEntity;
  final List<String> usersID;

  const GiftShow(this.giftEntity, this.usersID);

  @override
  List<Object> get props => [giftEntity, usersID];
}
