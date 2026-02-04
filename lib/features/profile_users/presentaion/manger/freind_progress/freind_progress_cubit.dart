import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:meta/meta.dart';

part 'freind_progress_state.dart';

class FreindProgressCubit extends Cubit<FreindProgressState> {
  FreindProgressCubit() : super(FreindProgressInitial());

  /// Safely emit a state only if this Cubit is not closed
  void _safeEmit(FreindProgressState state) {
    if (isClosed) return;
    emit(state);
  }

  /// حذف صديق أو طلب صداقة
  Future<void> deleteFriendOrFriendRequest(String friendShipId) async {
    try {
      final response =
          await ApiService().post('/user/friend/delete/$friendShipId');

      if (response.statusCode == 200) {
        // Normalize plain-text or JSON-encoded string responses without throwing
        String responseText;
        final data = response.data;
        if (data is String) {
          var s = data.trim();
          // Try to decode JSON string like "done" safely, fallback to raw string
          try {
            final decoded = jsonDecode(s);
            if (decoded is String) {
              s = decoded.trim();
            }
          } catch (_) {}
          responseText = s;
        } else {
          responseText = data.toString().trim();
        }

        if (responseText == 'done') {
          _safeEmit(FreindProgressSuccessDelete());
        } else if (responseText.toLowerCase() == 'you are not friend') {
          // Emit exactly as the server responded
          _safeEmit(FreindProgressError('you are not friend'));
        } else if (responseText.toLowerCase() == 'something went wrong') {
          _safeEmit(FreindProgressError('Something went wrong'));
        } else {
          // Pass through server text if available; otherwise generic
          _safeEmit(FreindProgressError(
              responseText.isEmpty ? 'Unexpected response' : responseText));
        }
      } else {
        _safeEmit(FreindProgressError('${response.statusMessage}'));
      }
    } catch (e) {
      _safeEmit(FreindProgressError('$e'));
    }
  }

  /// إرسال طلب صداقة
  Future<void> addFriend(String friendId) async {
    try {
      final response = await ApiService().post('/user/add_friend/$friendId');

      if (response.statusCode == 200) {
        // Normalize plain-text or JSON-encoded string responses without throwing
        String responseText;
        final data = response.data;
        if (data is String) {
          var s = data.trim();
          // Try to decode JSON string like "done" safely, fallback to raw string
          try {
            final decoded = jsonDecode(s);
            if (decoded is String) {
              s = decoded.trim();
            }
          } catch (_) {}
          responseText = s;
        } else {
          responseText = data.toString().trim();
        }

        if (responseText.toLowerCase() == 'done') {
          _safeEmit(FreindProgressSuccessSend());
        } else if (responseText.toLowerCase() == 'waiting accepting' ||
            responseText.toLowerCase() == 'wating accepting' ||
            responseText.toLowerCase() == 'friend request sent' ||
            responseText.toLowerCase().contains('friend request sent') ||
            (responseText.toLowerCase().contains('waiting') &&
                responseText.toLowerCase().contains('accept'))) {
          // تم الإرسال وبانتظار القبول
          _safeEmit(FreindProgressWaitingAccepting());
        } else if (responseText.toLowerCase() == 'you are already friend' ||
            responseText.toLowerCase().contains('already friend')) {
          // بالفعل صديقان
          _safeEmit(FreindProgressAlreadyFriend());
        } else {
          // Pass through server text if available; otherwise generic
          _safeEmit(FreindProgressError(
              responseText.isEmpty ? 'Something went wrong' : responseText));
        }
      } else {
        _safeEmit(FreindProgressError(
            'Failed to send friend request: ${response.statusMessage}'));
      }
    } catch (e) {
      _safeEmit(FreindProgressError('Failed to send friend request: $e'));
    }
  }

  /// إرسال طلب صداقة بدون إصدار حالات لإعادة البناء، تُعيد نصاً موحداً للحالة
  /// القيم المتوقعة: 'done' | 'waiting_accepting' | 'already_friend' | 'error:<reason>'
  Future<String> addFriendStatus(String friendId) async {
    try {
      final response = await ApiService().post('/user/add_friend/$friendId');
      if (response.statusCode == 200) {
        String responseText;
        final data = response.data;
        if (data is String) {
          var s = data.trim();
          try {
            final decoded = jsonDecode(s);
            if (decoded is String) {
              s = decoded.trim();
            }
          } catch (_) {}
          responseText = s;
        } else {
          responseText = data.toString().trim();
        }

        final lower = responseText.toLowerCase();
        if (lower == 'done') return 'done';
        if (lower == 'waiting accepting' || lower == 'wating accepting' ||
            lower == 'friend request sent' ||
            lower.contains('friend request sent') ||
            (lower.contains('waiting') && lower.contains('accept'))) {
          return 'waiting_accepting';
        }
        if (lower == 'you are already friend' || lower.contains('already friend')) {
          return 'already_friend';
        }
        return 'error:${responseText.isEmpty ? 'unknown' : responseText}';
      } else {
        return 'error:${response.statusMessage}';
      }
    } catch (e) {
      return 'error:$e';
    }
  }

  /// قبول طلب صداقة
  Future<void> acceptFriendRequest(String friendId) async {
    try {
      final response = await ApiService().post('/user/accept/$friendId');

      if (response.statusCode == 200) {
        // Normalize plain-text or JSON-encoded string responses without throwing
        String responseText;
        final data = response.data;
        if (data is String) {
          var s = data.trim();
          try {
            final decoded = jsonDecode(s);
            if (decoded is String) {
              s = decoded.trim();
            }
          } catch (_) {}
          responseText = s;
        } else {
          responseText = data.toString().trim();
        }

        if (responseText.toLowerCase() == 'accepting') {
          _safeEmit(FreindProgressFriendRequestAccepted());
        } else {
          _safeEmit(FreindProgressError(
              responseText.isEmpty ? 'Something went wrong' : responseText));
        }
      } else {
        _safeEmit(FreindProgressError(
            'Failed to accept friend request: ${response.statusMessage}'));
      }
    } catch (e) {
      _safeEmit(FreindProgressError('Failed to accept friend request: $e'));
    }
  }
}
