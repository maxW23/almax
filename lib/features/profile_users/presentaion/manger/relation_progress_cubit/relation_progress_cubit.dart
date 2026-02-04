import 'dart:convert';

import 'package:lklk/core/services/api_service.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

part 'relation_progress_state.dart';

class RelationProgressCubit extends Cubit<RelationProgressState> {
  RelationProgressCubit() : super(RelationProgressInitial());

  /// إرسال طلب علاقة
  Future<void> sendRelationRequest(String userId) async {
    emit(RelationProgressLoading());

    try {
      final response = await ApiService().post('/user/relation/add/$userId');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.data);
        if (responseBody == "realation request has been sent") {
          emit(RelationProgressRelationRequestSent());
        } else if (responseBody ==
            "you have relation request to accept you cant send befor delete the last realation request") {
          emit(RelationProgressRelationRequestSentRecently());
        } else {
          emit(RelationProgressError('Unexpected response: $responseBody'));
        }
      } else {
        emit(RelationProgressError(
            'Failed to send relation request: ${response.statusMessage}'));
      }
    } catch (e) {
      emit(RelationProgressError('Failed to send relation request: $e'));
    }
  }

  /// حذف طلب علاقة
  Future<void> deleteRelationRequest(String requestId) async {
    emit(RelationProgressLoading());

    try {
      final response =
          await ApiService().post('/user/relation/delete/$requestId');

      if (response.statusCode == 200) {
        emit(RelationProgressRelationRequestDeleted());
      } else {
        emit(RelationProgressError(
            'Failed to delete relation request: ${response.statusMessage}'));
      }
    } catch (e) {
      emit(RelationProgressError('Failed to delete relation request: $e'));
    }
  }

  /// قبول طلب علاقة
  Future<void> acceptRelationRequest(String requestId) async {
    emit(RelationProgressLoading());

    try {
      final response =
          await ApiService().post('/user/relation/accept/$requestId');

      if (response.statusCode == 200) {
        emit(RelationProgressRelationRequestAccepted());
      } else {
        emit(RelationProgressError(
            'Failed to accept relation request: ${response.statusMessage}'));
      }
    } catch (e) {
      emit(RelationProgressError('Failed to accept relation request: $e'));
    }
  }
}
