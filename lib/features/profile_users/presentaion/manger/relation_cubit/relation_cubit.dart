import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/domain/entities/relation_entity.dart';
import 'package:meta/meta.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:lklk/core/utils/json_isolate.dart';

part 'relation_state.dart';

class RelationCubit extends Cubit<RelationState> {
  RelationCubit() : super(RelationInitial());

  Future<void> getReceivedRelationRequests() async {
    try {
      final response = await ApiService().get('/user/relation/recive/list');
      log("RelationCubit getReceivedRelationRequests ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, response.data as String)
            : Map<String, dynamic>.from(response.data as Map);
        final List<dynamic> relationData = responseData['relation'];

        final List<UserRelation> relationRequests = relationData
            .map((relationJson) => UserRelation.fromJson(relationJson))
            .toList();

        emit(RelationReceivedRelationRequestsLoaded(relationRequests));
      } else {
        emit(RelationError(
            'Failed to fetch received relation requests: ${response.statusMessage}'));
      }
    } catch (e) {
      emit(RelationError('Failed to fetch received relation requests: $e'));
    }
  }

  Future<void> getSentRelationRequests(String token) async {
    try {
      final response = await ApiService().get('/user/relation/send');
      log("RelationCubit getSentRelationRequests ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, response.data as String)
            : Map<String, dynamic>.from(response.data as Map);
        final relationData = responseData['relation'];
        final relationWith = responseData['relation_with'];

        if (relationData != null && relationWith != null) {
          final relation = UserRelation.fromJson(relationData);
          final user = UserEntity.fromJson(relationWith);
          emit(RelationSentRelationRequestsLoaded(relation, user));
        } else {
          emit(RelationError('No sent relation requests found'));
        }
      } else {
        emit(RelationError(
            'Failed to fetch sent relation requests: ${response.statusMessage}'));
      }
    } catch (e) {
      emit(RelationError('Failed to fetch sent relation requests: $e'));
    }
  }
}
