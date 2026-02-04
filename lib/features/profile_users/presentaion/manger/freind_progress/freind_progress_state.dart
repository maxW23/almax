part of 'freind_progress_cubit.dart';

@immutable
abstract class FreindProgressState {}

class FreindProgressInitial extends FreindProgressState {}

class FreindProgressError extends FreindProgressState {
  final String message;

  FreindProgressError(this.message);
}

// class FreindProgressLoading extends FreindProgressState

class FreindProgressSuccessDelete extends FreindProgressState {}

class FreindProgressSuccessSend extends FreindProgressState {}

/// تم إرسال الطلب وهو بانتظار القبول
class FreindProgressWaitingAccepting extends FreindProgressState {}

/// المستخدمان صديقان بالفعل
class FreindProgressAlreadyFriend extends FreindProgressState {}

class FreindProgressFriendRequestAccepted extends FreindProgressState {}
