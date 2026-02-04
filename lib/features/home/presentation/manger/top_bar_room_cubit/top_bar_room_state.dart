part of 'top_bar_room_cubit.dart';

abstract class TopBarRoomState extends Equatable {
  const TopBarRoomState();

  @override
  List<Object> get props => [];
}

class TopBarRoomInitial extends TopBarRoomState {}

class TopBarShow extends TopBarRoomState implements HasMessage {
  @override
  final TopBarMessageEntity message;
  final dynamic timestamp;
  const TopBarShow(this.message, this.timestamp);

  @override
  List<Object> get props => [message, timestamp];
}
