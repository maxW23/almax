import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lklk/core/utils/json_isolate.dart';
import 'package:lklk/core/utils/logger.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/log_print_list_space.dart';
import 'package:lklk/features/home/domain/entities/avatar_data_zego.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/core/config/app_config.dart';
import 'package:lklk/core/cache/room_details_cache_manager.dart';
import 'package:lklk/live_audio_room_manager.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../room/domain/entities/room_entity.dart';
part 'room_cubit_state.dart';

class RoomCubit extends Cubit<RoomCubitState> {
  final ApiService _apiService = ApiService();
  RoomEntity? _roomCubit;

  RoomCubit() : super(RoomCubitState(status: RoomCubitStatus.initial));
  RoomEntity? get roomCubit => _roomCubit;

  bool isActive = true;
  void stopProcess() {
    isActive = false;
  }

  // Public helper to merge a profile user into the in-memory Zego users list
  void mergeUserProfileIntoZego(UserEntity profile) {
    final existing = state.usersZego ?? [];
    if (existing.isEmpty) return;
    final int idx = existing.indexWhere((u) => u.iduser == profile.iduser);
    if (idx == -1) return;
    final merged = _mergeUserEntityBadges(existing[idx], profile);
    if (identical(merged, existing[idx])) return;
    final updated = [...existing];
    updated[idx] = merged;
    emit(state.copyWith(usersZego: updated, status: RoomCubitStatus.zegoUsersUpdated));
  }

  bool _isEmptyStr(String? s) {
    if (s == null) return true;
    final t = s.trim();
    return t.isEmpty || t == 'null';
  }

  // Merge non-empty badge/frame fields from profile into base without overwriting existing non-empty values
  UserEntity _mergeUserEntityBadges(UserEntity base, UserEntity profile) {
    // Frame merge: if base.elementFrame missing or empty elamentId, take from profile
    final String? baseFrameId = base.elementFrame?.elamentId;
    final String? profFrameId = profile.elementFrame?.elamentId;
    final elementFrame = (_isEmptyStr(baseFrameId) && !_isEmptyStr(profFrameId))
        ? profile.elementFrame
        : base.elementFrame;

    String? choose(String? a, String? b) => _isEmptyStr(a) && !_isEmptyStr(b) ? b : a;

    return base.copyWith(
      elementFrame: elementFrame,
      ws1: choose(base.ws1, profile.ws1),
      ws2: choose(base.ws2, profile.ws2),
      ws3: choose(base.ws3, profile.ws3),
      ws4: choose(base.ws4, profile.ws4),
      ws5: choose(base.ws5, profile.ws5),
      ic1: choose(base.ic1, profile.ic1),
      ic2: choose(base.ic2, profile.ic2),
      ic3: choose(base.ic3, profile.ic3),
      ic4: choose(base.ic4, profile.ic4),
      ic5: choose(base.ic5, profile.ic5),
      ic6: choose(base.ic6, profile.ic6),
      ic7: choose(base.ic7, profile.ic7),
      ic8: choose(base.ic8, profile.ic8),
      ic9: choose(base.ic9, profile.ic9),
      ic10: choose(base.ic10, profile.ic10),
      ic11: choose(base.ic11, profile.ic11),
      ic12: choose(base.ic12, profile.ic12),
      ic13: choose(base.ic13, profile.ic13),
      ic14: choose(base.ic14, profile.ic14),
      ic15: choose(base.ic15, profile.ic15),
    );
  }

  void activeProcess() {
    isActive = true;
  }

  // void setBannedUsersRoom(List<UserEntity> bannedUsersRoom) {
  //   _bannedUsersRoom = bannedUsersRoom;
  //   emit(state);
  // }

  // void setTopUsersRoom(List<UserEntity> topUsersRoom) {
  //   _topUsersRoom = topUsersRoom;
  //   emit(state);
  // }

  // void setUsersRoom(List<UserEntity> usersRoom) {
  //   _usersRoom = usersRoom;
  //   emit(state);
  // }

  set room(RoomEntity? room) {
    _roomCubit = room;
    emit(state);
  }

  //
  Future<void> fetchRoomById(int roomId, String? pass,
      {bool isUpdate = false}) async {
    try {
      // تحديد نقطة النهاية
      final endpoint = '/room/$roomId?pass=$pass';

      // استخدام دالة get من ApiService دون الحاجة لإرسال التوكن يدويًا
      final response = await _apiService.get(
        endpoint,
        retries: AppConfig.maxRetryAttempts,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
      );
      final data = response.data;
      // log("response room  $parsedData");

      if (response.statusCode == 200) {
        if (data == 'محظور من دخول الغرفة') {
          // emit(RoomCubitBan('محظور من دخول الغرفة'));
          emit(state.copyWith(
              errorMessage: 'محظور من دخول الغرفة',
              status: RoomCubitStatus.userBanned));
        }
        if (data == 'You are banned from entering this room') {
          // التعامل مع حالة الحاجة إلى كلمة مرور
          // emit(RoomCubitBan('You are banned from entering this room'));
          emit(state.copyWith(
              errorMessage: 'You are banned from entering this room',
              status: RoomCubitStatus.userBanned));
        } else {
          if (data == 'you need password to enter') {
            // التعامل مع حالة الحاجة إلى كلمة مرور
          }
          final Map<String, dynamic> parsedData = data is String
              ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, data as String)
              : Map<String, dynamic>.from(data as Map);
          // log("fetchRoomById $responseData");//You are banned from entering this room
          final roomData = parsedData['room'];
          final List<dynamic> usersData = parsedData['users'];
          final List<dynamic> bannedUsersData = parsedData['banned_user'];
          final List<dynamic> topUsersData = parsedData['top'];
          final List<dynamic> adminData = parsedData['admin'] ?? [];
          log("fetchRoomById adminData : $adminData");
          final room = RoomEntity.fromJson(roomData);
          final List<UserEntity> users = usersData
              .map((userData) => UserEntity.fromJson(userData))
              .toList();

          final List<UserEntity> admins = adminData
              .map((userData) => UserEntity.fromJson(userData))
              .toList();
          log("fetchRoomById admins : $admins");

          logUserIdsAndNames("fetchRoomById usersusersusers", users);
          final userAuth = await AuthService.getUserFromSharedPreferences();

          final UserEntity? user = usersData
              .map((userData) => UserEntity.fromJson(userData))
              .firstWhereOrNull2((user) => user.id == userAuth?.id);

          final List<UserEntity> bannedUsers = bannedUsersData
              .map((userData) => UserEntity.fromJson(userData))
              .toList();

          final List<UserEntity> topUsers = topUsersData
              .map((userData) => UserEntity.fromJson(userData))
              .toList();
          bool isBan = false;
          if (user != null) {
            isBan = bannedUsersData
                .map((e) => UserEntity.fromJson(e))
                .any((element) => user.iduser == element.iduser);
          }

          if (isBan == true) {
            emit(state.copyWith(
                errorMessage: 'You are banned from entering this room ',
                status: RoomCubitStatus.userBanned));
          }
          // Set the room property
          this.room = room;

          // setBannedUsersRoom(bannedUsers);
          // setUsersRoom(users);
          // setTopUsersRoom(topUsers);
          // emit(RoomCubitRoomLoaded(room, users, bannedUsers, topUsers));
          log("\n\n\nRoom Cubit fetchRoomById users $users -- admin $admins -- ban $bannedUsers -- top $topUsers");

          emit(state.copyWith(
              room: room,
              bannedUsers: bannedUsers,
              topUsers: topUsers,
              user: user,
              usersServer: users,
              adminsListUsers: admins,
              status: RoomCubitStatus.roomLoaded));
          // Cache last rooms (LRU up to 3) for instant restore and to avoid leaking wrong data
          try {
            await RoomDetailsCacheManager.instance.cacheRoomDetails(
              room: room,
              usersServer: users,
              admins: admins,
              banned: bannedUsers,
              top: topUsers,
            );
          } catch (_) {}
        }
      } else {
        // emit(RoomCubitRoomError('Failed to load room details'));
        emit(state.copyWith(
            errorMessage: 'Failed to load room details',
            status: RoomCubitStatus.roomError));
      }
    } on DioException catch (e) {
      final msg = ApiService.formatDioError(e);
      emit(
          state.copyWith(errorMessage: msg, status: RoomCubitStatus.roomError));
    } on SocketException catch (e) {
      emit(state.copyWith(
          errorMessage:
              'انقطع الاتصال، يرجى التحقق من الإنترنت والمحاولة لاحقًا.',
          status: RoomCubitStatus.roomError));
    } catch (e) {
      emit(state.copyWith(
          errorMessage: 'حدث خطأ أثناء جلب بيانات الغرفة: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  Future<RoomEntity?> createRoom() async {
    try {
      const endpoint = '/make/room';

      // Send the request using ApiService
      final response = await _apiService.post(endpoint);

      if (response.statusCode == 200) {
        final rawCreate = response.data;
        final Map<String, dynamic> parsedData = rawCreate is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, rawCreate as String)
            : Map<String, dynamic>.from(rawCreate as Map);

        final responseData = parsedData;
        log(responseData.toString());

        // Extract the room data from the response
        final roomData = responseData['room'] as Map<String, dynamic>;
        final room = RoomEntity.fromMap(roomData);
        _roomCubit = room;

        // Update state with the created room
        emit(state.copyWith(status: RoomCubitStatus.roomCreated));
        emit(state.copyWith(room: room, status: RoomCubitStatus.roomLoaded));
        return room;
      } else {
        emit(state.copyWith(
            errorMessage: 'Failed to create room: ${response.statusMessage}',
            status: RoomCubitStatus.roomError));
      }
    } catch (e) {
      emit(state.copyWith(
          errorMessage: 'Failed to create room: $e',
          status: RoomCubitStatus.roomError));
    }

    return null;
  }

//
  Future<void> _updateRoom(int roomId, Map<String, dynamic> data) async {
    try {
      final endpoint = '/edit/room/$roomId';

      // استخدام دالة post من ApiService لإرسال البيانات
      final response = await _apiService.post(
        endpoint,
        data: data,
      );

      if (response.statusCode == 200) {
        final rawUpd = response.data;
        final Map<String, dynamic> responseData = rawUpd is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, rawUpd as String)
            : Map<String, dynamic>.from(rawUpd as Map);

        final RoomEntity updatedRoom = RoomEntity.fromMap(responseData['room']);
        _roomCubit = updatedRoom;

        // emit(RoomCubitRoomUpdated(updatedRoom));
        emit(state.copyWith(
            room: updatedRoom, status: RoomCubitStatus.roomUpdated));

        // إعادة جلب البيانات الكاملة للتأكد من التحديث (بدون تأخير لتحديث فوري)
        Future.delayed(const Duration(milliseconds: 200), () {
          refreshRoomData(roomId);
        });
      } else {
        // emit(RoomCubitRoomError(
        // 'Failed to update room: ${response.statusMessage}'));
        emit(state.copyWith(
            errorMessage: 'Failed to update room: ${response.statusMessage}',
            status: RoomCubitStatus.roomError));
      }
    } catch (e) {
      // emit(RoomCubitRoomError('Failed to update room: $e'));
      emit(state.copyWith(
          errorMessage: 'Failed to update room: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  /// إعادة جلب بيانات الغرفة المحدثة من الخادم
  Future<void> refreshRoomData(int roomId) async {
    try {
      log('🔄 Refreshing room data for room $roomId');

      // جلب البيانات المحدثة بدون كلمة مرور (للتحديث فقط)
      await fetchRoomById(roomId, null, isUpdate: true);

      log('✅ Room data refreshed successfully');
    } catch (e) {
      log('❌ Error refreshing room data: $e');
    }
  }

  Future<void> editRoomName(int roomId, String name) async {
    await _updateRoom(roomId, {'name': name});
  }

  Future<void> editMicrophoneNumber(int roomId, String microphoneNumber) async {
    await _updateRoom(roomId, {'microphone_number': microphoneNumber});
  }

  Future<void> editCountry(int roomId, String country) async {
    await _updateRoom(roomId, {'country': country});
  }

  Future<void> editHelloText(int roomId, String helloText) async {
    await _updateRoom(roomId, {'hello_text': helloText});
  }

  Future<void> editRoomType(int roomId, int basic) async {
    try {
      final endpoint = '/room/type/$roomId?basic=$basic';
      final response = await _apiService.post(endpoint);

      if (response.statusCode == 200) {
        // Some endpoints return plain strings like 'done'
        emit(state.copyWith(status: RoomCubitStatus.roomUpdated));
        await refreshRoomData(roomId);
      } else {
        emit(state.copyWith(
          errorMessage: 'Failed to update room type: ${response.statusMessage}',
          status: RoomCubitStatus.roomError,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update room type: $e',
        status: RoomCubitStatus.roomError,
      ));
    }
  }

  /// تحديث بيانات الغرفة فوراً بدون انتظار
  void updateRoomDataImmediately(RoomEntity updatedRoom) {
    _roomCubit = updatedRoom;
    emit(
        state.copyWith(room: updatedRoom, status: RoomCubitStatus.roomUpdated));
    log('🔄 Room data updated immediately: ${updatedRoom.name}');
    // Update cache with the immediate change as well
    try {
      RoomDetailsCacheManager.instance.cacheRoomDetails(
        room: updatedRoom,
        usersServer: state.usersServer,
        admins: state.adminsListUsers,
        banned: state.bannedUsers,
        top: state.topUsers,
      );
    } catch (_) {}
  }

  /// إعادة تعيين حالة التحديث
  void resetUpdateStatus() {
    if (state.status == RoomCubitStatus.roomUpdated) {
      emit(state.copyWith(status: RoomCubitStatus.roomLoaded));
    }
  }

  // Future<void> editImageRoom(int roomId, XFile image) async {
  //   await _updateRoom(roomId, {'img': image});
  // }

  Future<void> editPassRoom(int roomId, String pass) async {
    try {
      final endpoint = '/privet/room/$roomId';
      final data = {'pass': pass};

      // استخدام دالة post من ApiService لإرسال البيانات
      final response = await _apiService.post(endpoint, data: data);

      if (response.statusCode == 200) {
        // emit(RoomCubitPassUpdated());
        emit(state.copyWith(status: RoomCubitStatus.passUpdated));
      } else {
        // emit(RoomCubitRoomError(
        // 'Failed to password room: ${response.statusMessage}'));
        emit(state.copyWith(
            errorMessage: 'Failed to password room: ${response.statusMessage}',
            status: RoomCubitStatus.roomError));
      }
    } catch (e) {
      // emit(RoomCubitRoomError('Failed to password room: $e'));
      emit(state.copyWith(
          errorMessage: 'Failed to password room: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  Future<void> editOpenPrivetRoom(int roomId) async {
    try {
      final endpoint = '/remove/privet/room/$roomId';

      // إرسال الطلب باستخدام ApiService
      final response = await _apiService.post(endpoint);

      if (response.statusCode == 200) {
        // emit(RoomCubitPassUpdated());
        emit(state.copyWith(status: RoomCubitStatus.passUpdated));
      } else {
        // emit(RoomCubitRoomError(
        // 'Failed to update room visibility: ${response.statusMessage}'));
        emit(state.copyWith(
            errorMessage:
                'Failed to update room visibility: ${response.statusMessage}',
            status: RoomCubitStatus.roomError));
      }
    } catch (e) {
      // emit(RoomCubitRoomError('Failed to update room visibility: $e'));
      emit(state.copyWith(
          errorMessage: 'Failed to update room visibility: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  Future<void> editImageRoom(int roomId, File image, String type) async {
    try {
      final endpoint = '/edit/room/$roomId';
      // final headers = {
      //   'Authorization':
      //       'Bearer ${await AuthService.getTokenFromSharedPreferences()}'
      // };

      // final formData = FormData.fromMap({
      //   type: await MultipartFile.fromFile(image.path),
      // });

      // استخدام ApiService لإرسال الملف
      final response = await _apiService.uploadFile(
        endpoint,
        file: image, fieldName: type,
        //  headers: headers,
      );

      if (response.statusCode == 200) {
        final rawImg = response.data;
        final Map<String, dynamic> responseData = rawImg is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, rawImg as String)
            : Map<String, dynamic>.from(rawImg as Map);
        final RoomEntity updatedRoom = RoomEntity.fromMap(responseData['room']);
        room = updatedRoom;
        // emit(RoomCubitRoomUpdated(updatedRoom));
        emit(state.copyWith(
            room: updatedRoom, status: RoomCubitStatus.roomUpdated));
      } else {
        // emit(RoomCubitRoomError(
        // 'Failed to update room image: ${response.statusMessage}'));
        emit(state.copyWith(
            errorMessage:
                'Failed to update room image: ${response.statusMessage}',
            status: RoomCubitStatus.roomError));
      }
    } catch (e) {
      // emit(RoomCubitRoomError('Failed to update room image: $e'));
      emit(state.copyWith(
          errorMessage: 'Failed to update room image: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  Future<void> banUserFromRoom(int roomId, String userId, String how) async {
    // final String? token = await AuthService.getTokenFromSharedPreferences();

    try {
      emit(state.copyWith(status: RoomCubitStatus.banLoading));

      final endpoint = '/ban/user/room/$roomId?userid=$userId&value=$how';

      // إرسال الطلب باستخدام ApiService
      final response = await _apiService.post(endpoint);

      if (response.statusCode == 200) {
        final dynamic rawBan = response.data;
        final Map<String, dynamic> responseData = rawBan is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, rawBan)
            : Map<String, dynamic>.from(rawBan as Map);

        // التحقق من إذا تم حظر المستخدم بنجاح
        if (responseData.containsKey('system') &&
            responseData['system'] == 'user has been baned') {
          emit(state.copyWith(errorMessage: "user has been baned"));
          ZegoLiveAudioRoomManager().kickOutRoom(userId);
        } else {
          // emit(RoomCubitRoomError('Failed to ban user from room'));
          emit(state.copyWith(
              errorMessage: 'Failed to ban user from room',
              status: RoomCubitStatus.roomError));
        }
      } else {
        // emit(RoomCubitRoomError(
        // 'Failed to ban user from room: ${response.statusMessage}'));
        emit(state.copyWith(
            errorMessage:
                'Failed to ban user from room: ${response.statusMessage}',
            status: RoomCubitStatus.roomError));
      }
    } on SocketException catch (e) {
      // emit(RoomCubitRoomError('Connection to the server was reset: $e'));
      emit(state.copyWith(
          errorMessage: 'Connection to the server was reset: $e',
          status: RoomCubitStatus.roomError));
    } catch (e) {
      // emit(RoomCubitRoomError('Failed to ban user from room: $e'));
      emit(state.copyWith(
          errorMessage: 'Failed to ban user from room: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  Future<void> removeBanFromUser(int roomId, String userId) async {
    try {
      emit(state.copyWith(status: RoomCubitStatus.banLoading));
      final endpoint = '/remove/user/ban/room/$roomId?userid=$userId';

      // إرسال الطلب باستخدام ApiService
      final response = await _apiService.post(endpoint);

      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final Map<String, dynamic> responseData = raw is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
            : Map<String, dynamic>.from(raw as Map);

        // التحقق من إذا تم إزالة الحظر بنجاح
        if (responseData.containsKey('system') &&
            responseData['system'] == 'done') {
          // تحديث قائمة المستخدمين المحظورين وإصدار الحالة الجديدة
          // final updatedBannedUsers = _bannedUsersRoom!
          //     .where((user) => user.iduser! != userId)
          //     .toList();
          // setBannedUsersRoom(updatedBannedUsers);

          // emit(RoomCubitBanRemoved());
          emit(state.copyWith(status: RoomCubitStatus.banRemoved));
        } else {
          // emit(RoomCubitRoomError('Failed to remove ban from user'));
          emit(state.copyWith(
              errorMessage: 'Failed to remove ban from user',
              status: RoomCubitStatus.roomError));
        }
      } else {
        // emit(RoomCubitRoomError(
        // 'Failed to remove ban from user: ${response.statusMessage}'));
        emit(state.copyWith(
            errorMessage:
                'Failed to remove ban from user: ${response.statusMessage}',
            status: RoomCubitStatus.roomError));
      }
    } on SocketException catch (e) {
      // emit(RoomCubitRoomError('Connection to the server was reset: $e'));
      emit(state.copyWith(
          errorMessage: 'Failed to update room: $e',
          status: RoomCubitStatus.roomError));
    } catch (e) {
      // emit(RoomCubitRoomError('Failed to remove ban from user: $e'));
      emit(state.copyWith(
          errorMessage: 'Failed to remove ban from user: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  Future<void> addAdminToRoom(int roomId, String userId) async {
    try {
      emit(state.copyWith(status: RoomCubitStatus.adminLoading));
      final endpoint = '/add/admin/room/$roomId?user_id=$userId';

      // إرسال الطلب باستخدام ApiService
      final response = await _apiService.post(endpoint);

      if (response.statusCode == 200) {
        final responseData = (response.data).trim();

        if (responseData == 'done') {
          // emit(RoomCubitUserUpdate());
          emit(state.copyWith(status: RoomCubitStatus.userUpdated));
        } else if (responseData == 'user is already admin') {
          // emit(RoomCubitRoomError('User is already admin'));
          emit(state.copyWith(
              errorMessage: 'User is already admin',
              status: RoomCubitStatus.roomError));
        } else {
          // emit(RoomCubitRoomError(
          // 'Failed to add admin to room: Unexpected response'));
          emit(state.copyWith(
              errorMessage: 'Failed to add admin to room: Unexpected response',
              status: RoomCubitStatus.roomError));
        }
      } else {
        // emit(RoomCubitRoomError(
        // 'Failed to add admin to room: ${response.statusMessage}'));
        emit(state.copyWith(
            errorMessage:
                'Failed to add admin to room: ${response.statusMessage}',
            status: RoomCubitStatus.roomError));
      }
    } catch (e) {
      // emit(RoomCubitRoomError('Failed to add admin to room: $e'));
      emit(state.copyWith(
          errorMessage: 'Failed to add admin to room: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  Future<void> removeAdminFromRoom(int roomId, String userId) async {
    try {
      emit(state.copyWith(status: RoomCubitStatus.adminLoading));

      final endpoint = '/remove/admin/room/$roomId?user_id=$userId';

      // استخدام دالة post من ApiService لإرسال الطلب
      final response = await _apiService.post(endpoint);

      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        String responseData;
        if (raw is String) {
          final String s = raw.trim();
          // إذا كانت الاستجابة على شكل JSON string مثل "done" قم بفكها في isolate
          if (s.startsWith('"') || s.startsWith('{') || s.startsWith('[')) {
            final dynamic decoded = await compute<String, dynamic>(decodeJsonDynamicIsolate, s);
            responseData = decoded.toString().trim();
          } else {
            responseData = s;
          }
        } else {
          responseData = raw.toString().trim();
        }

        if (responseData == 'user is removed admin') {
          // التعامل مع حالة نجاح إزالة المدير
        } else if (responseData == 'user is not admin') {
          // emit(RoomCubitRoomError('user is not admin'));
          emit(state.copyWith(
              errorMessage: 'user is not admin',
              status: RoomCubitStatus.roomError));
        } else {
          // التعامل مع استجابة غير متوقعة
          // emit(RoomCubitRoomError(
          // 'Failed to remove admin from room: Unexpected response'));
          emit(state.copyWith(
              errorMessage:
                  'Failed to remove admin from room: Unexpected response',
              status: RoomCubitStatus.roomError));
        }
      } else {
        // emit(RoomCubitRoomError(
        // 'Failed to remove admin from room: ${response.statusMessage}'));
        emit(state.copyWith(
            errorMessage:
                'Failed to remove admin from room: ${response.statusMessage}',
            status: RoomCubitStatus.roomError));
      }
    } catch (e) {
      // emit(RoomCubitRoomError('Failed to remove admin from room: $e'));
      emit(state.copyWith(
          errorMessage: 'Failed to remove admin from room: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  //////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////
  Future<void> updatedfetchRoomById(String roomId, String where, {String? pass}) async {
    try {
      // استخدم نفس نقطة النهاية الكاملة مثل fetchRoomById لضمان رجوع users/admin/banned/top
      final endpoint = '/room/$roomId?pass=$pass';
      // استخدام دالة get من ApiService لإرسال الطلب
      final response = await _apiService.get(
        endpoint,
        retries: AppConfig.maxRetryAttempts,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
      );

      if (response.statusCode == 200) {
        if (response.data == 'محظور من دخول الغرفة') {
          emit(state.copyWith(
              status: RoomCubitStatus.userBanned,
              errorMessage: 'محظور من دخول الغرفة'));
        } else {
          final Map<String, dynamic> responseData = response.data is String
              ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, response.data as String)
              : Map<String, dynamic>.from(response.data as Map);

          // if (response.data == 'you need password to enter') {
          //   // التعامل مع حالة "تحتاج إلى كلمة مرور للدخول"
          // }

          final roomData = responseData['room'];

          // مسار سريع عند التتبع: ما زلنا نجلب admin لضمان صلاحيات صحيحة، ونتجنب users/banned/top الثقيلة
          if (where == 'track') {
            final room = RoomEntity.fromJson(roomData);
            final List<dynamic> adminData = responseData['admin'] ?? [];
            final List<UserEntity> admins = adminData
                .map((userData) => UserEntity.fromJson(userData))
                .toList();
            this.room = room;
            emit(state.copyWith(
              room: room,
              bannedUsers: const <UserEntity>[],
              topUsers: const <UserEntity>[],
              user: state.user,
              usersServer: const <UserEntity>[],
              adminsListUsers: admins,
              status: RoomCubitStatus.roomLoaded,
            ));
            return;
          }

          final List<dynamic> usersData = responseData['users'];
          final List<dynamic> bannedUsersData = responseData['banned_user'];
          final List<dynamic> topUsersData = responseData['top'];

          final room = RoomEntity.fromJson(roomData);

          final List<UserEntity> users = usersData
              .map((userData) => UserEntity.fromJson(userData))
              .toList();

          final List<UserEntity> bannedUsers = bannedUsersData
              .map((userData) => UserEntity.fromJson(userData))
              .toList();
          final List<UserEntity> topUsers = topUsersData
              .map((usersData) => UserEntity.fromJson(usersData))
              .toList();
          // setBannedUsersRoom(bannedUsers);
          // setUsersRoom(users);
          // setTopUsersRoom(topUsers);
          logUserIdsAndNames("updatedfetchRoomById usersusersusers", users);
          final List<dynamic> adminData = responseData['admin'] ?? [];
          final List<UserEntity> admins = adminData
              .map((userData) => UserEntity.fromJson(userData))
              .toList();
          this.room = room;
          final userAuth = await AuthService.getUserFromSharedPreferences();

          final UserEntity? user = usersData
              .map((userData) => UserEntity.fromJson(userData))
              .firstWhereOrNull2((user) => user.id == userAuth?.id);
          bool isBan = false;
          if (user != null) {
            isBan = bannedUsersData
                .map((e) => UserEntity.fromJson(e))
                .any((element) => user.iduser == element.iduser);
          }
          if (isBan == true) {
            emit(state.copyWith(
                errorMessage: 'You are banned from entering this room ',
                status: RoomCubitStatus.userBanned));
          }
          // log("\n\n\nRoom Cubit updatedfetchRoomById users $users -- admin $admins -- ban $bannedUsers -- top $topUsers");

          emit(state.copyWith(
              room: room,
              bannedUsers: bannedUsers,
              topUsers: topUsers,
              user: user,
              usersServer: users,
              adminsListUsers: admins,
              status: RoomCubitStatus.roomLoaded));
          // Cache last rooms (LRU up to 3)
          try {
            await RoomDetailsCacheManager.instance.cacheRoomDetails(
              room: room,
              usersServer: users,
              admins: admins,
              banned: bannedUsers,
              top: topUsers,
            );
          } catch (_) {}
          // emit(RoomCubitRoomLoaded(room, users, bannedUsers, topUsers));
        }
      } else {
        // emit(RoomCubitRoomError('Failed to load room details'));
        emit(state.copyWith(
            errorMessage: 'Failed to load room details',
            status: RoomCubitStatus.roomError));
      }
    } on DioException catch (e) {
      final msg = ApiService.formatDioError(e);
      emit(
          state.copyWith(errorMessage: msg, status: RoomCubitStatus.roomError));
    } catch (e) {
      emit(state.copyWith(
          errorMessage: 'حدث خطأ أثناء جلب بيانات الغرفة: $e',
          status: RoomCubitStatus.roomError));
    }
  }

  void backInitial() {
    emit(state.copyWith(
      status: RoomCubitStatus.initial,
      bannedUsers: [],
      room: null,
      topUsers: [],
      user: null,
      usersServer: [],
      usersZego: [],
    ));
  }

  /// إرجاع رقم غرفة المستخدم إن وجد بسرعة بدون أي تغييرات على الحالة
  Future<int?> getUserRoomIdIfAny(String iduser) async {
    try {
      final response = await _apiService.get(
        '/user/roomin/$iduser',
        retries: 1,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        if (raw is int) return raw;

        if (raw is String) {
          final trimmed = raw.trim();
          final lower = trimmed.toLowerCase();
          if (lower.contains('not in room')) return null;
          if (lower.contains('same')) return null;

          final asInt = int.tryParse(trimmed);
          if (asInt != null) return asInt;

          try {
            final parsed = jsonDecode(trimmed);
            if (parsed is int) return parsed;
          } catch (_) {}
          return null;
        }

        try {
          final parsed = raw is String ? jsonDecode(raw) : raw;
          if (parsed is int) return parsed;
          if (parsed is Map && parsed['room'] != null) {
            final r = parsed['room'];
            if (r is Map && r['id'] != null) {
              return int.tryParse(r['id'].toString());
            }
          }
        } catch (_) {
          return null;
        }
      }
    } catch (_) {
      // ignore errors for a quick check
    }

    return null;
  }

  Future<RoomEntity> trackUserRoom(String iduser) async {
    try {
      final response = await ApiService().get('/user/roomin/$iduser');
      log("track :: ${response.data}");

      if (response.statusCode == 200) {
        final rawData = response.data;
        if (rawData is String) {
          final trimmed = rawData.trim();
          final lower = trimmed.toLowerCase();
          if (lower.contains('not in room')) {
            emit(state.copyWith(
                errorMessage: 'not in room', status: RoomCubitStatus.noRoom));
            throw Exception('not in room');
          }
          if (lower.contains('same')) {
            // emit(state.copyWith(status: RoomCubitStatus.sameRoomDetected));
            throw Exception("User is already in the same room");
          }
          // If API returns numeric room id as plain text, handle it directly
          final numericId = int.tryParse(trimmed);
          if (numericId != null) {
            // Use the endpoint that returns full room details without password
            await updatedfetchRoomById(numericId.toString(), 'track');
            if (state.status == RoomCubitStatus.userBanned) {
              throw Exception("User is banned");
            }
            if (_roomCubit != null) {
              return _roomCubit!;
            }
            throw Exception("Room not found");
          }
        }
        // If API returns numeric as JSON number (e.g., jsonDecode("10000") => 10000)
        if (rawData is int) {
          await updatedfetchRoomById(rawData.toString(), 'track');
          if (state.status == RoomCubitStatus.userBanned) {
            throw Exception("User is banned");
          }
          if (_roomCubit != null) {
            return _roomCubit!;
          }
          throw Exception("Room not found");
        }
        final parsedData = rawData is String ? jsonDecode(rawData) : rawData;
        if (parsedData is int) {
          await updatedfetchRoomById(parsedData.toString(), 'track');
          if (state.status == RoomCubitStatus.userBanned) {
            throw Exception("User is banned");
          }
          if (_roomCubit != null) {
            return _roomCubit!;
          }
          throw Exception("Room not found");
        }
        final responseData = parsedData;

        final roomData = responseData['room'];
        final List<dynamic> usersData = responseData['users'];
        final List<dynamic> bannedUsersData = responseData['banned_user'];
        final List<dynamic> topUsersData = responseData['top'];
        final List<dynamic> adminData = responseData['admin'] ?? [];

        final room = RoomEntity.fromJson(roomData);
        final List<UserEntity> users =
            usersData.map((e) => UserEntity.fromJson(e)).toList();
        final List<UserEntity> admins =
            adminData.map((e) => UserEntity.fromJson(e)).toList();
        final List<UserEntity> bannedUsers =
            bannedUsersData.map((e) => UserEntity.fromJson(e)).toList();
        final List<UserEntity> topUsers =
            topUsersData.map((e) => UserEntity.fromJson(e)).toList();

        final userAuth = await AuthService.getUserFromSharedPreferences();
        final UserEntity? user =
            users.firstWhereOrNull2((u) => u.id == userAuth?.id);

        if (user != null && bannedUsers.any((b) => b.iduser == user.iduser)) {
          emit(state.copyWith(
              errorMessage: 'You are banned from entering this room',
              status: RoomCubitStatus.userBanned));
          throw Exception("User is banned");
        }

        emit(state.copyWith(
            room: room,
            user: user,
            bannedUsers: bannedUsers,
            topUsers: topUsers,
            usersServer: users,
            adminsListUsers: admins,
            status: RoomCubitStatus.roomLoaded));

        return room; // Return the RoomEntity directly
      }
      throw Exception("Failed to fetch room data: ${response.statusCode}");
    } catch (e) {
      final msg = e.toString();
      // Known control-flow cases: don't override state to roomError
      if (msg.contains('not in room') ||
          msg.contains('already in the same room') ||
          msg.contains('User is banned')) {
        rethrow;
      }
      emit(state.copyWith(
          errorMessage: "track User Room error: $msg",
          status: RoomCubitStatus.roomError));
      throw Exception("Failed to track room: $msg");
    }
  }

  Future<void> addFavoraiteRoom(int id) async {
    try {
      emit(state.copyWith(status: RoomCubitStatus.favoriteLoading));
      final response = await ApiService().get('/user/room/add/$id');
      if (response.statusCode == 200) {
        // final parsedData = jsonDecode(response.data);
        log("addFavoraiteRoom:${response.data}");
        emit(state.copyWith(status: RoomCubitStatus.success));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: "addFavoraiteRoom $e"));
    }
  }

  Future<void> fetchOnlineUsersFromRoom(String roomId) async {
    log('[fetchOnlineUsersFromRoom] Called with roomId: $roomId');

    try {
      List<ZIMUserInfo> allMembers = [];
      String? nextFlag;
      int pageCount = 0;
      int totalMembers = 0;

      do {
        pageCount++;
        ZIMRoomMemberQueryConfig config = ZIMRoomMemberQueryConfig()
          ..count = 100
          ..nextFlag = nextFlag ?? "1";

        log('[ZIM] Querying page $pageCount with nextFlag: ${nextFlag ?? "initial"}');
        final result =
            await ZIM.getInstance()!.queryRoomMemberList(roomId, config);

        log('[ZIM] Page $pageCount fetched: ${result.memberList.length} members');
        log('[ZIM] Next flag: ${result.nextFlag}');

        allMembers.addAll(result.memberList);
        totalMembers += result.memberList.length;
        nextFlag = result.nextFlag;
      } while (nextFlag.isNotEmpty);

      log('[ZIM] Total members fetched: $totalMembers across $pageCount pages');

      if (totalMembers == 0) {
        log('[WARNING] Room $roomId has no members');
        emit(state.copyWith(usersZego: []));
        return;
      }

      List<UserEntity> onlineZegoUsers = allMembers.map((zimUser) {
        log('--- Processing user ${zimUser.userID} ---');

        AvatarData avatarData;
        try {
          avatarData = AvatarData.fromEncodedString(zimUser.userAvatarUrl);
        } catch (e) {
          log('[AvatarData] Error decoding avatar for user ${zimUser.userID}: $e');
          avatarData = AvatarData(); // default fallback
        }

        // ZIM now carries displayed level in level3; use it directly
        // final String? _newLevel3 = avatarData.newlevel3;

        return UserEntity(
          iduser: zimUser.userID,
          id: zimUser.userID,
          name: zimUser.userName,
          img: avatarData.imageUrl ?? '',
          vip: avatarData.vipLevel,
          totalSocre: avatarData.totalSocre,
          ownerIds: avatarData.ownerIds,
          adminRoomIds: avatarData.adminRoomIds,
          level1: avatarData.level1,
          level2: avatarData.level2,
          newlevel3: avatarData.newlevel3,
          elementFrame: ElementEntity(
            elamentId: avatarData.frameId ?? '',
          ),
          // SVGA badges mapped from AvatarData lists
          ws1: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.isNotEmpty)
              ? avatarData.svgaSquareUrls![0]
              : null,
          ws2: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 1)
              ? avatarData.svgaSquareUrls![1]
              : null,
          ws3: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 2)
              ? avatarData.svgaSquareUrls![2]
              : null,
          ws4: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 3)
              ? avatarData.svgaSquareUrls![3]
              : null,
          ws5: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 4)
              ? avatarData.svgaSquareUrls![4]
              : null,
          ic1: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.isNotEmpty)
              ? avatarData.svgaRectUrls![0]
              : null,
          ic2: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 1)
              ? avatarData.svgaRectUrls![1]
              : null,
          ic3: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 2)
              ? avatarData.svgaRectUrls![2]
              : null,
          ic4: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 3)
              ? avatarData.svgaRectUrls![3]
              : null,
          ic5: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 4)
              ? avatarData.svgaRectUrls![4]
              : null,
          ic6: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 5)
              ? avatarData.svgaRectUrls![5]
              : null,
          ic7: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 6)
              ? avatarData.svgaRectUrls![6]
              : null,
          ic8: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 7)
              ? avatarData.svgaRectUrls![7]
              : null,
          ic9: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 8)
              ? avatarData.svgaRectUrls![8]
              : null,
          ic10: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 9)
              ? avatarData.svgaRectUrls![9]
              : null,
          ic11: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 10)
              ? avatarData.svgaRectUrls![10]
              : null,
          ic12: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 11)
              ? avatarData.svgaRectUrls![11]
              : null,
          ic13: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 12)
              ? avatarData.svgaRectUrls![12]
              : null,
          ic14: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 13)
              ? avatarData.svgaRectUrls![13]
              : null,
          ic15: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 14)
              ? avatarData.svgaRectUrls![14]
              : null,
        );
      }).toList();

      // Merge current profile (from SharedPreferences) into own Zego user to avoid missing badges/frame
      try {
        final UserEntity? me = await AuthService.getUserFromSharedPreferences();
        if (me != null) {
          onlineZegoUsers = onlineZegoUsers
              .map((u) => u.iduser == me.iduser ? _mergeUserEntityBadges(u, me) : u)
              .toList();
        }
      } catch (_) {}

      log('[Users] Successfully parsed ${onlineZegoUsers.length} users');
      emit(state.copyWith(
          usersZego: onlineZegoUsers,
          status: RoomCubitStatus.zegoUsersUpdated));
      log('[State] Users updated in RoomCubit');

      // بعد التهيئة الأولية، حدث بيانات جميع المستخدمين من الخادم لتفضيل extendedData (يتضمن شارات كاملة)
      try {
        final ids = allMembers.map((m) => m.userID).toList();
        // لا تنتظر؛ دع التحديث يحدث في الخلفية
        _refreshMultipleUsers(ids);
      } catch (_) {}
    } catch (e, stack) {
      log('[ERROR] fetchOnlineUsersFromRoom: $e');
      log('[STACKTRACE] $stack');
      // Consider emitting an error state here if needed
    }
  }

  void addUser(UserEntity user) {
    final existing = state.usersZego ?? [];
    if (existing.any((u) => u.iduser == user.iduser)) return;
    emit(state.copyWith(usersZego: [...existing, user]));
  }

  void removeUserById(String id) {
    final existing = state.usersZego ?? [];
    emit(state.copyWith(
        usersZego: existing.where((u) => u.iduser != id).toList()));
  }

  /////////////////////////////////////////////////////
  ///
  Future<void> refreshUserData(String userId) async {
    log('[refreshUserData] Refreshing data for user: $userId');

    try {
      // استخدام ZIMUserInfoQueryConfig بدلاً من ZIMUsersInfoQueryConfig
      final config = ZIMUserInfoQueryConfig()..isQueryFromServer = true;

      // استعلام بيانات المستخدم المحدد من الخادم
      final result = await ZIM.getInstance()!.queryUsersInfo([userId], config);

      if (result.userList.isNotEmpty) {
        final userInfo = result.userList.first;
        log('[refreshUserData] Successfully fetched updated data for user: $userId');

        // تحديث البيانات في القائمة المحلية مع تفضيل extendedData الغني إن توفّر
        _updateUserInListFromFullInfo(userInfo);
      } else {
        log('[WARNING] User $userId not found in server query');
      }
    } catch (e, stack) {
      log('[ERROR] Failed to refresh user data for $userId: $e');
      log('[STACKTRACE] $stack');
    }
  }

// دالة مساعدة لتحويل ZIMUserInfo إلى UserEntity
  UserEntity _convertZimUserToEntity(ZIMUserInfo zimUser) {
    AvatarData avatarData;
    try {
      avatarData = AvatarData.fromEncodedString(zimUser.userAvatarUrl);
    } catch (e) {
      log('[AvatarData] Error decoding avatar for user ${zimUser.userID}: $e');
      avatarData = AvatarData(); // default fallback
    }

    return UserEntity(
      iduser: zimUser.userID,
      id: zimUser.userID,
      name: zimUser.userName,
      img: avatarData.imageUrl ?? '',
      vip: avatarData.vipLevel,
      totalSocre: avatarData.totalSocre,
      ownerIds: avatarData.ownerIds,
      adminRoomIds: avatarData.adminRoomIds,
      level1: avatarData.level1,
      level2: avatarData.level2,
      newlevel3: avatarData.newlevel3,
      elementFrame: ElementEntity(
        elamentId: avatarData.frameId ?? '',
        linkPath: avatarData.frameLink,
      ),
      // Map SVGA badge URLs if provided
      ws1: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.isNotEmpty)
          ? avatarData.svgaSquareUrls![0]
          : null,
      ws2: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 1)
          ? avatarData.svgaSquareUrls![1]
          : null,
      ws3: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 2)
          ? avatarData.svgaSquareUrls![2]
          : null,
      ws4: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 3)
          ? avatarData.svgaSquareUrls![3]
          : null,
      ws5: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 4)
          ? avatarData.svgaSquareUrls![4]
          : null,
      ic1: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.isNotEmpty)
          ? avatarData.svgaRectUrls![0]
          : null,
      ic2: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 1)
          ? avatarData.svgaRectUrls![1]
          : null,
      ic3: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 2)
          ? avatarData.svgaRectUrls![2]
          : null,
      ic4: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 3)
          ? avatarData.svgaRectUrls![3]
          : null,
      ic5: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 4)
          ? avatarData.svgaRectUrls![4]
          : null,
      ic6: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 5)
          ? avatarData.svgaRectUrls![5]
          : null,
      ic7: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 6)
          ? avatarData.svgaRectUrls![6]
          : null,
      ic8: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 7)
          ? avatarData.svgaRectUrls![7]
          : null,
      ic9: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 8)
          ? avatarData.svgaRectUrls![8]
          : null,
      ic10: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 9)
          ? avatarData.svgaRectUrls![9]
          : null,
      ic11: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 10)
          ? avatarData.svgaRectUrls![10]
          : null,
      ic12: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 11)
          ? avatarData.svgaRectUrls![11]
          : null,
      ic13: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 12)
          ? avatarData.svgaRectUrls![12]
          : null,
      ic14: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 13)
          ? avatarData.svgaRectUrls![13]
          : null,
      ic15: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 14)
          ? avatarData.svgaRectUrls![14]
          : null,
    );
  }

  // تحويل ZIMUserFullInfo إلى UserEntity مع تفضيل extendedData إن كانت متاحة
  UserEntity _convertZimFullInfoToEntity(ZIMUserFullInfo full) {
    AvatarData avatarData;
    try {
      final String source = full.extendedData.isNotEmpty
          ? full.extendedData
          : full.userAvatarUrl;
      avatarData = AvatarData.fromEncodedString(source);
    } catch (e) {
      log('[AvatarData] Error decoding FULL avatar for user ${full.baseInfo.userID}: $e');
      avatarData = AvatarData();
    }

    return UserEntity(
      iduser: full.baseInfo.userID,
      id: full.baseInfo.userID,
      name: full.baseInfo.userName,
      img: avatarData.imageUrl ?? '',
      vip: avatarData.vipLevel,
      totalSocre: avatarData.totalSocre,
      ownerIds: avatarData.ownerIds,
      adminRoomIds: avatarData.adminRoomIds,
      level1: avatarData.level1,
      level2: avatarData.level2,
      newlevel3: avatarData.newlevel3,
      elementFrame: ElementEntity(
        elamentId: avatarData.frameId ?? '',
        linkPath: avatarData.frameLink,
      ),
      // Map SVGA badge URLs if provided
      ws1: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.isNotEmpty)
          ? avatarData.svgaSquareUrls![0]
          : null,
      ws2: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 1)
          ? avatarData.svgaSquareUrls![1]
          : null,
      ws3: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 2)
          ? avatarData.svgaSquareUrls![2]
          : null,
      ws4: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 3)
          ? avatarData.svgaSquareUrls![3]
          : null,
      ws5: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 4)
          ? avatarData.svgaSquareUrls![4]
          : null,
      ic1: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.isNotEmpty)
          ? avatarData.svgaRectUrls![0]
          : null,
      ic2: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 1)
          ? avatarData.svgaRectUrls![1]
          : null,
      ic3: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 2)
          ? avatarData.svgaRectUrls![2]
          : null,
      ic4: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 3)
          ? avatarData.svgaRectUrls![3]
          : null,
      ic5: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 4)
          ? avatarData.svgaRectUrls![4]
          : null,
      ic6: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 5)
          ? avatarData.svgaRectUrls![5]
          : null,
      ic7: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 6)
          ? avatarData.svgaRectUrls![6]
          : null,
      ic8: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 7)
          ? avatarData.svgaRectUrls![7]
          : null,
      ic9: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 8)
          ? avatarData.svgaRectUrls![8]
          : null,
      ic10: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 9)
          ? avatarData.svgaRectUrls![9]
          : null,
      ic11: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 10)
          ? avatarData.svgaRectUrls![10]
          : null,
      ic12: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 11)
          ? avatarData.svgaRectUrls![11]
          : null,
      ic13: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 12)
          ? avatarData.svgaRectUrls![12]
          : null,
      ic14: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 13)
          ? avatarData.svgaRectUrls![13]
          : null,
      ic15: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 14)
          ? avatarData.svgaRectUrls![14]
          : null,
    );
  }

  void _updateUserInListFromFullInfo(ZIMUserFullInfo full) {
    final currentUsers = state.usersZego ?? [];
    final exists = currentUsers.any((u) => u.iduser == full.baseInfo.userID);
    final fresh = _convertZimFullInfoToEntity(full);
    if (exists) {
      final updatedUsers = currentUsers.map((u) {
        if (u.iduser == full.baseInfo.userID) {
          // دمج مع الحفاظ على القيم غير الفارغة الموجودة مسبقاً
          return _mergeUserEntityBadges(fresh, u);
        }
        return u;
      }).toList();
      emit(state.copyWith(usersZego: updatedUsers, status: RoomCubitStatus.zegoUsersUpdated));
    } else {
      emit(state.copyWith(usersZego: [...currentUsers, fresh], status: RoomCubitStatus.zegoUsersUpdated));
    }
  }

  Future<void> refreshAllUsersInRoom(String roomId) async {
    log('[refreshAllUsersInRoom] Refreshing all users in room: $roomId');

    try {
      // أولاً: جلب جميع أعضاء الغرفة الحاليين
      List<ZIMUserInfo> allMembers = [];
      String? nextFlag;
      int pageCount = 0;

      do {
        pageCount++;
        ZIMRoomMemberQueryConfig config = ZIMRoomMemberQueryConfig()
          ..count = 100
          ..nextFlag = nextFlag ?? "1";

        log('[ZIM] Querying page $pageCount for room members');
        final result =
            await ZIM.getInstance()!.queryRoomMemberList(roomId, config);

        allMembers.addAll(result.memberList);
        nextFlag = result.nextFlag;
      } while (nextFlag.isNotEmpty);

      log('[ZIM] Total members found: ${allMembers.length}');

      if (allMembers.isEmpty) {
        log('[WARNING] Room $roomId has no members');
        emit(state.copyWith(usersZego: []));
        return;
      }

      // ثانياً: استخلاص IDs جميع المستخدمين
      final List<String> userIds =
          allMembers.map((user) => user.userID).toList();

      // ثالثاً: تحديث بيانات جميع المستخدمين من الخادم
      await _refreshMultipleUsers(userIds);
    } catch (e, stack) {
      log('[ERROR] refreshAllUsersInRoom: $e');
      log('[STACKTRACE] $stack');
      // يمكنك إعادة محاولة الجلب أو التعامل مع الخطأ
    }
  }

  Future<void> _refreshMultipleUsers(List<String> userIds) async {
    if (userIds.isEmpty) return;

    log('[refreshMultipleUsers] Refreshing data for ${userIds.length} users');

    try {
      // تقسيم المستخدمين إلى مجموعات (للتجنب حدود ZIM)
      const batchSize = 10; // الحد الأقصى المسموح به في الاستعلام الواحد
      for (int i = 0; i < userIds.length; i += batchSize) {
        final batch = userIds.sublist(
            i, i + batchSize > userIds.length ? userIds.length : i + batchSize);

        log('[refreshMultipleUsers] Processing batch: ${batch.length} users');

        final config = ZIMUserInfoQueryConfig()..isQueryFromServer = true;
        final result = await ZIM.getInstance()!.queryUsersInfo(batch, config);

        // تحديث كل مستخدم في الدفعة باستخدام extendedData إن توفّر
        for (var userInfo in result.userList) {
          _updateUserInListFromFullInfo(userInfo);
        }

        // إضافة تأخير صغير بين الدفعات لتجنب rate limiting
        if (i + batchSize < userIds.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      log('[SUCCESS] Updated all users successfully');
    } catch (e, stack) {
      log('[ERROR] Failed to refresh multiple users: $e');
      log('[STACKTRACE] $stack');
    }
  }

  // _updateUserInList removed; we now enrich users via _updateUserInListFromFullInfo
}

extension SafeFirstWhere<T> on Iterable<T> {
  T? firstWhereOrNullExtention(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
