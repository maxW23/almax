import 'package:lklk/core/utils/logger.dart';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:lklk/core/utils/json_isolate.dart';
import 'package:lklk/core/services/background_download_service.dart';
import 'package:lklk/core/services/download_manger.dart';
import '../../../../../core/services/api_service.dart';
import 'fetch_elements_cubit_state.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

class FetchElementsCubit extends Cubit<FetchElementsCubitState> {
  FetchElementsCubit() : super(FetchElementsCubitState.initial()) {
    DownloadService.instance.updates.listen(_onTaskStatus);
  }
  final DownloadManager _downloadManager = DownloadManager();

  void _onTaskStatus(TaskStatusUpdate u) {
    final id = u.task.metaData;
    if (u.status == TaskStatus.complete) {
      // emit(state.copyWith(message: 'Element $id downloaded', status: Status.success));
      log("Element $id downloaded");
    } else if ((u.status == TaskStatus.failed ||
        u.status == TaskStatus.canceled)) {
      log("Permanent failure or canceled for $id – no retry no downloaded");
      // لا تستدعي FileDownloader().enqueue(u.task);
    }
  }

  Future<void> fetchStoreElements({bool download = true}) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final response = await ApiService().get('/store/list');
      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final List<dynamic> data = raw is String
            ? await compute<String, List<dynamic>>(decodeJsonToListIsolate, raw)
            : List<dynamic>.from(raw as List);
        final elements = data.map((e) => ElementEntity.fromJson(e)).toList();

        emit(state.copyWith(elements: elements, status: Status.success));

        final shouldDownload = download && !kDebugMode;
        if (shouldDownload) {
          await _downloadManager.enqueueSubset(
            elements,
          );
        }
      } else {
        emit(state.copyWith(
            status: Status.error, error: 'Failed fetching elements'));
      }
    } catch (e) {
      log('Error fetch store elements: $e');
      emit(state.copyWith(status: Status.error, error: e.toString()));
    }
  }

////////////////////
////////////////////
////////////////////
////////////////////
////////////////////
////////////////////
  Future<void> fetchMyElements() async {
    try {
      final response = await ApiService().get('/my/elament');
      final dynamic body = response.data;
      final dynamic parsedData = body is String
          ? await compute<String, dynamic>(decodeJsonDynamicIsolate, body)
          : body;

      log("stooooooooor fetchMyElements $parsedData");
      if (response.statusCode == 200) {
        // Case 1: API replied with a simple string indicating no room
        if (parsedData is String) {
          final s = parsedData.toString();
          final isNoRoom = s.contains('no room') ||
              s.contains('dont have room') ||
              s.contains('you dont have room') ||
              s.contains('لا تملك غرفة') ||
              s.contains('ليس لديك غرفة') ||
              s.contains('لا يوجد غرفة');
          if (isNoRoom) {
            emit(state.copyWith(
              myElements: const [],
              status: Status.success,
              message: 'no_room',
            ));
            return;
          }
        }

        // Case 2: Map with message
        if (parsedData is Map<String, dynamic>) {
          if (parsedData['message'] is String) {
            final s = (parsedData['message'] as String);
            final isNoRoom = s.contains('no room') ||
                s.contains('dont have room') ||
                s.contains('you dont have room') ||
                s.contains('لا تملك غرفة') ||
                s.contains('ليس لديك غرفة') ||
                s.contains('لا يوجد غرفة');
            if (isNoRoom) {
              emit(state.copyWith(
                myElements: const [],
                status: Status.success,
                message: 'no_room',
              ));
              return;
            }
          }

          // Normal case: elements list under 'elament'
          if (parsedData['elament'] is List) {
            final List<dynamic> data = parsedData['elament'];
            final myElements =
                data.map((e) => ElementEntity.fromJson(e)).toList();
            emit(state.copyWith(
                myElements: myElements, status: Status.success, message: null));
            return;
          }
        }

        // Fallback: unknown shape
        emit(state.copyWith(
            myElements: const [],
            status: Status.success,
            message: null));
      } else {
        emit(state.copyWith(
            error: 'Failed to load elements', status: Status.error));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error: $e', status: Status.error));
    }
  }

  Future<String> useElement(int elementId) async {
    try {
      final response = await ApiService().get('/my/elament/use/$elementId');
      final raw = response.data;
      log("stooooooooor useElement $raw");

      if (response.statusCode == 200) {
        emit(state.copyWith(status: Status.success));
        return 'Use Element Success';
      } else {
        emit(state.copyWith(
            error: 'Failed to use element', status: Status.error));
        return 'Failed to use element';
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error: $e', status: Status.error));
      return 'Use Element Error';
    }
  }

  Future<String> disableElement(int elementId) async {
    try {
      final response = await ApiService().get('/my/elament/disabel/$elementId');
      final raw = response.data;
      log("stooooooooor disableElement $raw");

      if (response.statusCode == 200) {
        emit(state.copyWith(status: Status.success));
        return 'Disable Element Success';
      } else {
        emit(state.copyWith(
            error: 'Failed to disable element', status: Status.error));
        return 'Disable Element Error';
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error: $e', status: Status.error));
      return 'Disable Element Error';
    }
  }
}
