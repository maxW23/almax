import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/core/services/background_download_service.dart';
import 'package:lklk/core/services/download_manger.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/room/domain/entities/gift_entity.dart';
import 'package:lklk/zego_sdk_manager.dart';
import '../../../../../core/utils/bloc_status.dart';
part 'gifts_state.dart';

class GiftCubit extends Cubit<GiftState> {
  GiftCubit() : super(GiftState.initial()) {
    DownloadService.instance.updates.listen(_onTaskStatus);
  }
  final DownloadManager _downloadManager = DownloadManager();

  void _onTaskStatus(TaskStatusUpdate u) {
    final id = u.task.metaData;
    if (u.status == TaskStatus.complete) {
      log("Gift $id downloaded");
      // emit(state.copyWith(message: 'Gift $id downloaded', status: Status.success));
    }
    if (u.exception != null) {
      final ex = u.exception!;
      log('Failed task ${u.task.metaData} due to ${ex.runtimeType} (${ex.toString()})');
    } else if ((u.status == TaskStatus.failed ||
        u.status == TaskStatus.canceled)) {
      log("Permanent failure or canceled for $id – no retry no downloaded");
      // لا تستدعي FileDownloader().enqueue(u.task);
    }
  }

  Future<void> fetchGiftsElements({bool download = true}) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final box = Hive.box<List>('giftCacheBox');
      final cached = box.get('giftListCached');
      if (cached != null) {
        emit(state.copyWith(
            elements: cached.cast<ElementEntity>(), status: Status.success));
      }

      final response = await ApiService().get('/room/gift/list');
      final parsedData = jsonDecode(response.data);
      if (response.statusCode == 200) {
        final elements = (parsedData as List<dynamic>)
            .map((e) => ElementEntity.fromJson(e))
            .toList();

        emit(state.copyWith(elements: elements, status: Status.success));
        await box.put('giftListCached', elements);

        final shouldDownload = download && !kDebugMode;
        if (shouldDownload) {
          await _downloadManager.enqueueSubset(
            elements,
          );
        }
      } else {
        emit(state.copyWith(
            status: Status.fail, error: 'Failed to fetch gifts'));
      }
    } catch (e) {
      log('Error fetching gifts: $e');
      emit(state.copyWith(status: Status.fail, error: e.toString()));
    }
  }

  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  Future<String> sendGift(
    String giftId,
    String roomId,
    String selectedUsersString,
    int giftsMany,
    GiftsShowCubit giftsShowCubit,
    void Function(ZIMMessage) onSend,
    String selectedUsersStringName,
  ) async {
    // حالة التحميل
    emit(state.copyWith(status: Status.loading, isSending: true));

    try {
      // التحقق من المدخلات
      if (roomId.isEmpty || giftId.isEmpty) {
        final errorMessage =
            roomId.isEmpty ? 'Room ID is empty' : 'Gift ID is empty';
        emit(state.copyWith(
          error: errorMessage,
          status: Status.fail,
          isSending: false,
        ));
        return errorMessage;
      }

      final UserEntity? user = await AuthService.getUserFromSharedPreferences();
      final String userId = user?.iduser ?? "null_user";
      final String userName = user?.name ?? "null_username";
      final String userImg = user?.img ?? "";
      final startTime = DateTime.now();

      try {
        final response = await ApiService().post(
          '/gift/new/$giftId?room_id=$roomId&selected_users=$selectedUsersString&gifts_many=$giftsMany',
        );

        final responseData =
            response.data is String ? jsonDecode(response.data) : response.data;
        log('responseData $responseData');

        if (response.statusCode == 200 && responseData['status'] == 'done') {
          try {
            final List<String> recipients = selectedUsersString.isNotEmpty
                ? selectedUsersString.split('ـ')
                : [];

            if (recipients.isEmpty) {
              log('Warning: No recipients specified for gift animation');
            }
          } catch (e, stackTrace) {
            log('Error in recipients: $e', stackTrace: stackTrace);
          }

          // إنشاء GiftEntity
          final giftEntity = GiftEntity(
              userId: userId,
              userName: userName,
              giftId: giftId,
              giftType: responseData['gift_type'],
              giftCount: giftsMany,
              giftPoints: responseData['gift_point'],
              timestamp: DateTime.now().millisecondsSinceEpoch,
              timer: int.parse(responseData['timer'] ?? "6"),
              imgGift: responseData['img_gift'],
              imgUser: userImg,
              link: responseData['link'],
              giftReciversName: selectedUsersStringName);

          final Map<String, dynamic> giftMessage = {
            "Message": {
              "operationType": 20001,
              "operatorID": "system-000000",
              "targetID": selectedUsersString.split('ـ'),
              "targetName": selectedUsersStringName.split('ـ'),
              "SenderUnaware": 0,
              "data": {
                "gifts": [giftEntity.toMap()], // استخدام toMap()
              }
            },
          };

          final String jsonMessage = jsonEncode(giftMessage);
          final customMessage = ZIMBarrageMessage(
            message: jsonMessage,
          );
          onSend(customMessage);
          final config = ZIMMessageSendConfig()
            ..priority = ZIMMessagePriority.high;

          try {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              giftsShowCubit.showGiftAnimation(
                giftEntity,
                giftMessage['Message']['targetID']?.cast<String>() ?? [],
              );
            });

            await ZIM.getInstance()!.sendMessage(
                  customMessage,
                  roomId,
                  ZIMConversationType.room,
                  config,
                );

            final duration = DateTime.now().difference(startTime);
            log('تم إرسال الهدية بنجاح في ${duration.inMilliseconds}ms');

            emit(state.copyWith(
              message: 'Gift sent successfully',
              status: Status.success,
              isSending: false,
              gift: giftMessage,
            ));
            return 'Gift sent successfully';
          } on ZIMError catch (e) {
            final errorMsg = 'Error sending gift notification: ${e.message}';
            emit(state.copyWith(
              error: errorMsg,
              status: Status.fail,
              isSending: false,
            ));
            return errorMsg;
          }
        } else {
          final errorMsg =
              responseData['status'] == 'you dont have enough coins'
                  ? 'You don\'t have enough coins'
                  : 'Failed to send gift: ${responseData['status']}';

          emit(state.copyWith(
            error: errorMsg,
            status: Status.fail,
            isSending: false,
          ));
          return errorMsg;
        }
      } catch (e, stackTrace) {
        log('Error in gift sending process', error: e, stackTrace: stackTrace);
        final errorMsg = 'Error sending gift: ${e.toString()}';
        emit(state.copyWith(
          error: errorMsg,
          status: Status.fail,
          isSending: false,
        ));
        return errorMsg;
      }
    } catch (e, stackTrace) {
      log('Unexpected error in sendGift', error: e, stackTrace: stackTrace);
      final errorMsg = 'Unexpected error: ${e.toString()}';
      emit(state.copyWith(
        error: errorMsg,
        status: Status.fail,
        isSending: false,
      ));
      return errorMsg;
    }
  }
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////

////////////////////////////////////////////////////
////////////////////////////////////////////////////
////////////////////////////////////////////////////
////////////////////////////////////////////////////
////////////////////////////////////////////////////
}
