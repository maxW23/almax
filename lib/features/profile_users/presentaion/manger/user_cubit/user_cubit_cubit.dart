import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lklk/core/utils/json_isolate.dart';
import 'package:lklk/core/utils/logger.dart';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lklk/core/services/auth_result.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/core/services/seat_user.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/auth/domain/use_cases/google_signin_use_case.dart';
import 'package:lklk/features/home/domain/entities/avatar_data_zego.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/domain/entities/friendship_entity.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/splash/domain/entities/app_version.dart';
import 'package:lklk/zego_sdk_manager.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lklk/core/realtime/notification_realtime_service.dart';
part 'user_cubit_state.dart';

class UserCubit extends Cubit<UserCubitState> {
  final GoogleSignInUseCase _googleSignInUseCase;
  final AuthApiClient _authApiClient;

  UserCubit(this._googleSignInUseCase, this._authApiClient)
      : super(const UserCubitState());

  UserEntity? _user;
  String? _token;
  bool _isRefreshingMinimal =
      false; // guard against concurrent background refreshes
  bool _isRefreshingWalletOnly = false; // coalesce wallet-only refreshes
  // Sequence token to ensure only the most recent edit applies
  int _editSeq = 0;

  UserEntity? get user => _user;
  String? get token => _token;

  void _setUser(UserEntity user) {
    _user = user;
    // Keep realtime filters aligned with the currently authenticated user
    try {
      NotificationRealtimeService.instance
          .updateCurrentUserIds(iduser: user.iduser, id: user.id);
    } catch (_) {}
  }

  void _setToken(String token) {
    _token = token;
  }

  Future<AppVersionInfo?> getVertionNumber() async {
    try {
      final response = await ApiService().get('/version');

      if (response.statusCode == 200 && response.data != null) {
        log("Raw Response: ${response.data}");

        // نحول النص إلى Map (استخدام isolate لتفادي حجب الـ UI)
        final dynamic raw = response.data;
        final Map<String, dynamic> jsonData = raw is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
            : Map<String, dynamic>.from(raw as Map);

        final versionInfo = AppVersionInfo.fromJson(jsonData);

        log("numb: ${versionInfo.numb}");
        log("version: ${versionInfo.version}");
        log("message: ${versionInfo.response}");

        return versionInfo;
      }
    } catch (e) {
      log("getVertionNumber catch: $e");
    }
    return null;
  }

  // Minimal background refresh: fetch user only and update state quickly
  Future<void> _refreshProfileMinimal({bool skipZego = true}) async {
    if (_isRefreshingMinimal) return;
    _isRefreshingMinimal = true;
    try {
      final response = await ApiService().get('/user/myprofile');
      final dynamic raw = response.data;
      final Map<String, dynamic> parsedData = raw is String
          ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
          : Map<String, dynamic>.from(raw as Map);
      var serverUser = UserEntity.fromJson(parsedData['user']);

      // Merge with current state to avoid reverting optimistic UI for non-lucky flows
      final current = state.user;
      if (current != null) {
        final int? serverWallet = serverUser.wallet;
        final int? currentWallet = current.wallet;
        final num? serverDiamond = serverUser.diamond;
        final num? currentDiamond = current.diamond;

        final int? mergedWallet =
            (serverWallet != null && currentWallet != null)
                ? (serverWallet < currentWallet ? serverWallet : currentWallet)
                : serverWallet ?? currentWallet;
        final num? mergedDiamond = (serverDiamond != null &&
                currentDiamond != null)
            ? (serverDiamond < currentDiamond ? serverDiamond : currentDiamond)
            : serverDiamond ?? currentDiamond;

        serverUser = serverUser.copyWith(
          wallet: mergedWallet,
          diamond: mergedDiamond,
        );
      }

      // Resolve ONLY active entry from response (active == 'yes'). If none, do not propagate inactive entries.
      String? activeEntryId;
      String? activeEntryLink;
      String? activeEntryTimer;
      try {
        final entriesRaw = parsedData['entry'];
        if (entriesRaw is List && entriesRaw.isNotEmpty) {
          for (final e in entriesRaw) {
            if (e is Map) {
              final m = Map<String, dynamic>.from(e as Map);
              final isActive = m['active']?.toString().toLowerCase() == 'yes';
              if (isActive) {
                final id = (m['elament_id'] ?? m['element_id'] ?? m['elament'])?.toString();
                final ln = (m['link'] ?? m['Link_Path'])?.toString();
                if (id != null && id.trim().isNotEmpty && id.trim().toLowerCase() != 'null') {
                  activeEntryId = id.trim();
                }
                if (ln != null && ln.trim().isNotEmpty && ln.trim().toLowerCase() != 'null') {
                  activeEntryLink = ln.trim();
                }
                final t = m['timer'] ?? m['date1'];
                if (t != null) activeEntryTimer = t.toString();
                break;
              }
            }
          }
        }
      } catch (_) {}

      // Reflect active entry into local model; if none active, clear to nulls
      serverUser = serverUser.copyWith(
        entryID: activeEntryId, // becomes null if no active
        entrylink: activeEntryLink, // becomes null if no active
        entryTimer: activeEntryTimer, // becomes null if no active
      );

      // Optionally update Zego if not skipping (rare case)
      if (!skipZego) {
        final avatarData = AvatarData(
          imageUrl: serverUser.img,
          frameId: serverUser.elementFrame?.elamentId,
          frameLink: serverUser.elementFrame?.linkPath,
          vipLevel: serverUser.vip,
          // Pass only active entry values (null when no active)
          entryID: activeEntryId,
          entryTimer: activeEntryTimer,
          entryLink: activeEntryLink,
          ownerIds: serverUser.ownerIds,
          adminRoomIds: serverUser.adminRoomIds,
          totalSocre: serverUser.totalSocre,
          level1: serverUser.level1,
          level2: serverUser.level2,
          newlevel3: serverUser.newlevel3,
          svgaSquareUrls: [
            serverUser.ws1,
            serverUser.ws2,
            serverUser.ws3,
            serverUser.ws4,
            serverUser.ws5,
          ]
              .where((s) => s != null && s!.trim().isNotEmpty && s!.trim() != 'null')
              .map((e) => e!.trim())
              .toList(),
          svgaRectUrls: [
            serverUser.ic1,
            serverUser.ic2,
            serverUser.ic3,
            serverUser.ic4,
            serverUser.ic5,
            serverUser.ic6,
            serverUser.ic7,
            serverUser.ic8,
            serverUser.ic9,
            serverUser.ic10,
            serverUser.ic11,
            serverUser.ic12,
            serverUser.ic13,
            serverUser.ic14,
            serverUser.ic15,
          ]
              .where((s) => s != null && s!.trim().isNotEmpty && s!.trim() != 'null')
              .map((e) => e!.trim())
              .toList(),
        );
        final encoded = avatarData.toEncodedString();
        // Keep avatarUrl as an actual image URL/path only (avoid encoded composite)
        await ZEGOSDKManager().zimService.updateUserAvatarUrl(serverUser.img ?? '');
        // Also publish rich metadata into extendedData to avoid avatarUrl length/charset limits
        try {
          await ZEGOSDKManager().zimService.updateUserExtendedData(encoded);
        } catch (_) {}
        final String nameToSet = serverUser.name ?? '';
        if (nameToSet.isNotEmpty) {
          await ZEGOSDKManager().zimService.updateUserName(nameToSet);
        }
      }

      _setUser(serverUser);
      await AuthService.saveUserToSharedPreferences(serverUser);
      emit(state.copyWith(
        user: serverUser,
        status: UserCubitStatus.loadedProfile,
      ));
    } catch (_) {
      // ignore errors in background refresh
    } finally {
      _isRefreshingMinimal = false;
    }
  }

  // Fetch only wallet/diamond from server and update state quickly.
  // Skips any Zego updates and heavy processing.
  Future<void> refreshWalletOnly() async {
    if (_isRefreshingWalletOnly) return;
    _isRefreshingWalletOnly = true;
    try {
      final response = await ApiService().get('/user/myprofile');
      final dynamic raw = response.data;
      final Map<String, dynamic> parsedData = raw is String
          ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
          : Map<String, dynamic>.from(raw as Map);
      final userMap = parsedData['user'] as Map<String, dynamic>;

      final dynamic walletRaw = userMap['wallet'];
      final int? serverWallet =
          walletRaw == null ? null : int.tryParse(walletRaw.toString());

      final dynamic diamondRaw = userMap['diamond'];
      final num? serverDiamond =
          diamondRaw == null ? null : num.tryParse(diamondRaw.toString());

      final current = state.user ?? _user;
      if (current != null) {
        final updated = current.copyWith(
          wallet: serverWallet ?? current.wallet,
          diamond: serverDiamond ?? current.diamond,
        );
        _setUser(updated);
        await AuthService.saveUserToSharedPreferences(updated);
        emit(state.copyWith(
          user: updated,
          status: UserCubitStatus.loadedProfile,
        ));
      }
    } catch (_) {
      // ignore errors in lightweight refresh
    } finally {
      _isRefreshingWalletOnly = false;
    }
  }

  Future<void> signIn(
    RoomCubit roomCubit,
    BuildContext context, {
    String? email,
    String? password,
    bool isGoogle = true,
  }) async {
    emit(state.copyWith(status: UserCubitStatus.loading));

    try {
      UserEntity? signedUser;

      if (isGoogle) {
        signedUser = await _tryGoogleSignIn(context);
        if (signedUser == null) return;
      }

      final authResult = await (isGoogle
          ? _authApiClient.authenticateUserGoogle(
              signedUser!, roomCubit, context)
          : _authApiClient.authenticateUser(
              roomCubit, context, email!, password!));

      if (authResult == null ||
          authResult.token == null ||
          authResult.user == null ||
          authResult.isBanned) {
        // استخرج رسالة الخطأ لو موجودة و اعرضها
        final errorMsg = authResult?.errorMessage ?? 'فشل في المصادقة.';
        emit(state.copyWith(status: UserCubitStatus.error, message: errorMsg));
        return;
      }

      _setToken(authResult.token!);
      _setUser(authResult.user!);

      await AuthService.saveUserToSharedPreferences(authResult.user!);
      SeatPreferences.initializeSeatState();
      SeatPreferences.setSeatTaken(false);
      user!.isMicOnNotifier.value = false;

      emit(state.copyWith(
        status: UserCubitStatus.authenticated,
        user: authResult.user,
        token: authResult.token,
      ));
    } catch (error) {
      _handleError(error, context, retry: () {
        signIn(roomCubit, context,
            email: email, password: password, isGoogle: isGoogle);
      });
    }
  }

  Future<UserEntity?> _tryGoogleSignIn(BuildContext context) async {
    try {
      final userGoogle = await _googleSignInUseCase.signIn();
      if (userGoogle?.iduser == null && userGoogle?.email == null) {
        emit(state.copyWith(
            status: UserCubitStatus.error, message: 'فشل تسجيل الدخول بجوجل.'));
        return null;
      }
      return userGoogle;
    } catch (e) {
      String errMsg = 'فشل في المصادقة مع جوجل';
      if (e is PlatformException) {
        // Example: PlatformException(network_error, ApiException: 7: , ...)
        final code = e.code.toString();
        final msg = (e.message ?? '').toString();
        log('Google Sign-In Error: $code - $msg');
        if (code.toLowerCase().contains('network') ||
            msg.toLowerCase().contains('apiexception: 7') ||
            msg.contains(' 7:')) {
          errMsg = 'تعذر الاتصال بخدمات Google (network_error: 7). تحقق من الإنترنت وحدّث خدمات Google Play ثم أعد المحاولة.';
        } else if (code.toLowerCase().contains('sign_in_canceled')) {
          errMsg = 'تم إلغاء تسجيل الدخول.';
        } else {
          errMsg = 'خطأ في Google Sign-In: $code';
        }
      } else {
        log('Google Sign-In Unexpected Error: $e');
      }
      SnackbarHelper.showMessage(context, errMsg);
      emit(state.copyWith(status: UserCubitStatus.error, message: errMsg));
      return null;
    }
  }

  void _handleError(Object error, BuildContext context, {VoidCallback? retry}) {
    String errorMessage = 'حدث خطأ غير متوقع';
    if (error is DioException) {
      errorMessage = error.message ?? error.toString();
      if (_isNetworkError(error) && retry != null) {
        retry();
        return;
      }
    }
    SnackbarHelper.showMessage(context, errorMessage);
    emit(state.copyWith(status: UserCubitStatus.error, message: errorMessage));
  }

  bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.error is SocketException;
  }

  void optimisticDiamondUpdate(num diamonds) {
    if (state.user != null) {
      emit(state.copyWith(
        status: UserCubitStatus.loadedProfile,
        user: state.user!
            .copyWith(diamond: (state.user!.diamond ?? 0) - diamonds),
      ));
    }
  }

  void revertDiamondUpdate(num diamonds) {
    if (state.user != null) {
      emit(state.copyWith(
        status: UserCubitStatus.loadedProfile,
        user: state.user!
            .copyWith(diamond: (state.user!.diamond ?? 0) + diamonds),
      ));
    }
  }

  // Immediate wallet deduction after confirmed actions (e.g., successful gift purchase)
  void optimisticWalletDeduct(int amount) {
    if (state.user != null) {
      final current = state.user!.wallet ?? 0;
      final updated = state.user!.copyWith(wallet: current - amount);
      _setUser(updated);
      emit(state.copyWith(
        status: UserCubitStatus.loadedProfile,
        user: updated,
      ));
    }
  }

  void revertWalletDeduct(int amount) {
    if (state.user != null) {
      final current = state.user!.wallet ?? 0;
      final updated = state.user!.copyWith(wallet: current + amount);
      _setUser(updated);
      emit(state.copyWith(
        status: UserCubitStatus.loadedProfile,
        user: updated,
      ));
    }
  }
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
  /// 2
  ///done

  Box? profileBox;
  Box? userBox;
  Box? giftBox;
  Box? frameBox;
  Box? entryBox;

  int? friendNumberCached;
  int? visitorNumberCached;
  int? friendRequestCached;
  int? relationRequestCached;

  List<ElementEntity>? giftListCached;
  List<ElementEntity>? entryListCached;
  List<ElementEntity>? frameListCached;

  UserEntity? userCached;

  UserProfileCubit() {
    _initializeHiveBoxes();
  }

  void _initializeHiveBoxes() {
    //log('Initializing Hive boxes...');
    try {
      profileBox = Hive.box('cachedProfileElementsData');
      userBox = Hive.box('userCacheBox');
      giftBox = Hive.box('giftCacheBox');
      frameBox = Hive.box('frameCacheBox');
      entryBox = Hive.box('entryCacheBox');
      //log('Hive boxes initialized successfully.');
    } catch (e) {
      //log('Error initializing Hive boxes: $e');
    }
  }

  Future<UserEntity?> getProfileUser(String where,
      {bool isProfileState = false, bool fast = false}) async {
    // log("getProfileUsergetProfileUsergetProfileUser $where");
    //log('getProfileUser called with isProfileState = $isProfileState');
    if (fast) {
      // Immediate return from current state (includes any optimistic updates)
      final cached = state.user ?? _user;
      if (cached != null) {
        // Keep local mirror in sync only if changed
        if (!identical(_user, cached)) _setUser(cached);
        // Avoid redundant emit if same instance/value
        if (state.user != cached) {
          emit(state.copyWith(
              status: UserCubitStatus.loadedProfile, user: cached));
        }
      }
      // Background refresh (minimal, skip heavy operations)
      unawaited(_refreshProfileMinimal(skipZego: true));
      return cached;
    }

    emit(state.copyWith(status: UserCubitStatus.loading));
    //log('State set to loading.');
    await _loadCachedData();
    //log('Cached data loaded. userCached: ${userCached != null}');
    if (userCached != null) {
      //log('Emitting loaded state with cached data.');
      _emitLoadedState();
    }

    try {
      //log('Fetching profile data from API...');
      final response = await ApiService().get('/user/myprofile');
      log('getProfileUser Response received: ${response.data}');
      final dynamic raw = response.data;
      final Map<String, dynamic> parsedData = raw is String
          ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
          : Map<String, dynamic>.from(raw as Map);

      if (kDebugMode) {
        log('myprofile: type=${response.data.runtimeType} status=${response.statusCode}');
        if (parsedData['gift'] is List) {
          log('Gift Count: ${(parsedData['gift'] as List).length}');
        }
        if (parsedData['entry'] is List) {
          log('Entry Count: ${(parsedData['entry'] as List).length}');
        }
        if (parsedData['frame'] is List) {
          log('Frame Count: ${(parsedData['frame'] as List).length}');
        }
      }

      // استلام القيم من السيرفر
      final friendNumber = parsedData['friend_number'];
      final visitorNumber = parsedData['visitor_number'];
      final friendRequest = parsedData['friend_request'];
      final relationRequest = parsedData['relation_request'];
      //log('Parsed response data: friendNumber=$friendNumber, visitorNumber=$visitorNumber, friendRequest=$friendRequest, relationRequest=$relationRequest');

      // عرض القيم المستلمة في السجلات
      //log("Response Friend number: $friendNumber");
      //log("Response Visitor number: $visitorNumber");
      //log("Response Friend request: $friendRequest");
      //log("Response Relation request: $relationRequest");

      // log("f*ss000 Raw owner: ${parsedData['owner']}, Raw admin: ${parsedData['room_admin']}");
      var user = UserEntity.fromJson(parsedData['user']);
      // room من نفس ريسبونس myprofile
      RoomEntity? myRoom;
      try {
        final roomJson = parsedData['room'];
        if (roomJson != null) {
          myRoom = RoomEntity.fromJson(
            roomJson is String
                ? await compute<String, Map<String, dynamic>>(
                    decodeJsonToMapIsolate, roomJson)
                : Map<String, dynamic>.from(roomJson as Map),
          );
        }
      } catch (_) {
        // ignore malformed room
      }
      final giftList = (parsedData['gift'] as List)
          .map((gift) => ElementEntity.fromJson(gift))
          .toList();
      final entryList = (parsedData['entry'] as List)
          .map((entry) => ElementEntity.fromJson(entry))
          .toList();
      final frameList = (parsedData['frame'] as List)
          .map((frame) => ElementEntity.fromJson(frame))
          .toList();
      // log("f*ss000 Parsed ownerIds: ${user.ownerIds}, adminRoomIds: ${user.adminRoomIds}");

      //log('Data transformed successfully.');
      _updateCachedData(
        user: user,
        giftList: giftList,
        entryList: entryList,
        frameList: frameList,
        friendNumber: friendNumber,
        visitorNumber: visitorNumber,
        friendRequest: friendRequest,
        relationRequest: relationRequest,
      );
      //log('Cached data updated.');
      // Determine active entry (active == 'yes') from raw response
      String? activeEntryId;
      String? activeEntryLink;
      String? activeEntryTimer;
      try {
        final entriesRaw = parsedData['entry'];
        if (entriesRaw is List && entriesRaw.isNotEmpty) {
          for (final e in entriesRaw) {
            if (e is Map) {
              final m = Map<String, dynamic>.from(e as Map);
              final isActive = m['active']?.toString().toLowerCase() == 'yes';
              if (isActive) {
                final id = (m['elament_id'] ?? m['element_id'] ?? m['elament'])?.toString();
                final ln = (m['link'] ?? m['Link_Path'])?.toString();
                if (id != null && id.trim().isNotEmpty && id.trim().toLowerCase() != 'null') {
                  activeEntryId = id.trim();
                }
                if (ln != null && ln.trim().isNotEmpty && ln.trim().toLowerCase() != 'null') {
                  activeEntryLink = ln.trim();
                }
                final t = m['timer'] ?? m['date1'];
                if (t != null) activeEntryTimer = t.toString();
                break;
              }
            }
          }
        }
      } catch (_) {}

      // Update user model: if no active entry, force clear to null
      user = user.copyWith(
        entryID: activeEntryId,
        entrylink: activeEntryLink,
        entryTimer: activeEntryTimer, // null when no active entry
      );

      final avatarData = AvatarData(
        imageUrl: user.img,
        frameId: user.elementFrame?.elamentId,
        frameLink: user.elementFrame?.linkPath,
        vipLevel: user.vip,
        // Pass only active entry values (null when no active)
        entryID: activeEntryId,
        entryTimer: activeEntryTimer,
        entryLink: activeEntryLink,
        ownerIds: user.ownerIds,
        adminRoomIds: user.adminRoomIds,
        totalSocre: user.totalSocre,
        level1: user.level1,
        level2: user.level2,
        newlevel3: user.newlevel3,
        svgaSquareUrls: [
          user.ws1,
          user.ws2,
          user.ws3,
          user.ws4,
          user.ws5,
        ]
            .where((s) => s != null && s!.trim().isNotEmpty && s!.trim() != 'null')
            .map((e) => e!.trim())
            .toList(),
        svgaRectUrls: [
          user.ic1,
          user.ic2,
          user.ic3,
          user.ic4,
          user.ic5,
          user.ic6,
          user.ic7,
          user.ic8,
          user.ic9,
          user.ic10,
          user.ic11,
          user.ic12,
          user.ic13,
          user.ic14,
          user.ic15,
        ]
            .where((s) => s != null && s!.trim().isNotEmpty && s!.trim() != 'null')
            .map((e) => e!.trim())
            .toList(),
      );
      final bool skipZego = where == 'giftsbsheet';
      if (!skipZego) {
        final encoded = avatarData.toEncodedString();
        final ZIMUserAvatarUrlUpdatedResult zimUserAvatarUrlUpdatedResult =
            await ZEGOSDKManager()
                .zimService
                .updateUserAvatarUrl(user.img ?? '');
        try {
          await ZEGOSDKManager().zimService.updateUserExtendedData(encoded);
        } catch (_) {}
        final ZIMUserNameUpdatedResult zimUserNameUpdatedResult =
            await ZEGOSDKManager().zimService.updateUserName(user.name!);
        log("zimUserAvatarUrlUpdatedResult $zimUserAvatarUrlUpdatedResult ---- zimUserNameUpdatedResult $zimUserNameUpdatedResult  ");
      }
      _setUser(user);
      await AuthService.saveUserToSharedPreferences(user);
      emit(state.copyWith(
        user: user,
        status: UserCubitStatus.loadedProfile,
        giftList: giftList,
        entryList: entryList,
        frameList: frameList,
        friendNumber: friendNumber,
        visitorNumber: visitorNumber,
        friendRequest: friendRequest,
        relationRequest: relationRequest,
        myRoom: myRoom,
      ));
      //log('State updated and emitted.');
      //log("---- Updated state: Friend Number: ${state.friendNumber}, Visitor Number: ${state.visitorNumber}");

      await _cacheDataToHive();
      //log('Data cached to Hive successfully.');
    } catch (error) {
      //log('Error fetching profile data: $error');
      emit(state.copyWith(status: UserCubitStatus.error));
    }
    return null;
  }

  Future<void> _loadCachedData() async {
    friendNumberCached =
        profileBox?.get('friendNumberCached') ?? state.friendNumber ?? 0;
    //log('friendNumberCached loaded: $friendNumberCached');
    visitorNumberCached =
        profileBox?.get('visitorNumberCached') ?? state.visitorNumber ?? 0;
    //log('visitorNumberCached loaded: $visitorNumberCached');

    friendRequestCached =
        profileBox?.get('friendRequestCached') ?? state.friendRequest ?? 0;
    //log('friendRequestCached loaded: $friendRequestCached');

    relationRequestCached =
        profileBox?.get('relationRequestCached') ?? state.relationRequest ?? 0;
    //log('relationRequestCached loaded: $relationRequestCached');

    final userCachedData = userBox?.get('userCached');
    if (userCachedData != null) {
      userCached = UserEntity.fromJson(userCachedData);
    }
    giftListCached = _loadListFromHive(giftBox, 'giftListCached');
    //log('giftListCached loaded: ${giftListCached?.length} items.');
    frameListCached = _loadListFromHive(frameBox, 'frameListCached');
    //log('frameListCached loaded: ${frameListCached?.length} items.');
    entryListCached = _loadListFromHive(entryBox, 'entryListCached');
    //log('entryListCached loaded: ${entryListCached?.length} items.');
  }

  List<ElementEntity>? _loadListFromHive(Box? box, String key) {
    final cachedData = box?.get(key);
    if (cachedData != null) {
      return (cachedData as List)
          .map((e) => ElementEntity.fromJson(e))
          .toList();
    }
    return null;
  }

  Future<void> _cacheDataToHive() async {
    //log('Caching data to Hive...');
    if (friendNumberCached != null) {
      await profileBox?.put('friendNumberCached', friendNumberCached);
      //log('Cached friendNumber: $friendNumberCached');
    }
    if (visitorNumberCached != null) {
      await profileBox?.put('visitorNumberCached', visitorNumberCached);
      //log('Cached visitorNumber: $visitorNumberCached');
    }
    if (friendRequestCached != null) {
      await profileBox?.put('friendRequestCached', friendRequestCached);
      //log('Cached friendRequest: $friendRequestCached');
    }
    if (relationRequestCached != null) {
      await profileBox?.put('relationRequestCached', relationRequestCached);
      //log('Cached relationRequest: $relationRequestCached');
    }

    if (userCached != null) {
      await userBox?.put('userCached', userCached!.toJson());
      //log('Cached userCached: ${userCached?.iduser}');
    }

    if (giftListCached != null) {
      await giftBox?.put('giftListCached', _convertListToJson(giftListCached));
      //log('Cached giftListCached: ${giftListCached?.length} items.');
    }
    if (frameListCached != null) {
      await frameBox?.put(
          'frameListCached', _convertListToJson(frameListCached));
      //log('Cached frameListCached: ${frameListCached?.length} items.');
    }
    if (entryListCached != null) {
      await entryBox?.put(
          'entryListCached', _convertListToJson(entryListCached));
      //log('Cached entryListCached: ${entryListCached?.length} items.');
    }
  }

  List<String>? _convertListToJson(List<ElementEntity>? list) {
    return list?.map((e) => e.toJson()).toList();
  }

  void _emitLoadedState() {
    emit(state.copyWith(
      status: UserCubitStatus.loadedProfileCached,
      user: userCached,
      giftList: giftListCached,
      entryList: entryListCached,
      frameList: frameListCached,
      friendRequest: friendRequestCached,
      visitorNumber: visitorNumberCached,
      relationRequest: relationRequestCached,
      friendNumber: friendNumberCached,
    ));
  }

  void _updateCachedData({
    required UserEntity user,
    required List<ElementEntity> giftList,
    required List<ElementEntity> entryList,
    required List<ElementEntity> frameList,
    required int? friendNumber,
    required int? visitorNumber,
    required int? friendRequest,
    required int? relationRequest,
  }) {
    userCached = user;
    giftListCached = giftList;
    entryListCached = entryList;
    frameListCached = frameList;
    friendNumberCached = friendNumber ?? 0;
    visitorNumberCached = visitorNumber ?? 0;
    friendRequestCached = friendRequest ?? 0;
    relationRequestCached = relationRequest ?? 0;
  }
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

  Future<void> searchUserByIdOrName({String? id, String? name}) async {
    emit(state.copyWith(status: UserCubitStatus.loading));

    try {
      final endpoint =
          id != null ? '/user/search?id=$id' : '/user/search?name=$name';
      final response = await ApiService().get(endpoint);
      final dynamic raw = response.data;
      final Map<String, dynamic> parsedData = raw is String
          ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
          : Map<String, dynamic>.from(raw as Map);

      if (response.statusCode == 200) {
        final users = (parsedData['user'] as List)
            .map((userData) => UserEntity.fromJson(userData))
            .toList();

        emit(state.copyWith(
          status: UserCubitStatus.searchingSuccess,
          users: users,
        ));
      } else {
        emit(state.copyWith(
          status: UserCubitStatus.error,
          message: 'Failed to search user: ${response.statusMessage}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: UserCubitStatus.error,
        message: 'Error: $e',
      ));
    }
  }

/////////////////////////////////////////////////////////////////////////
  /// 4
  /// done

  Future<void> editUserProfile({
    String? gender,
    String? name,
    String? statuse,
    String? profileState,
    String? birth,
    File? image,
  }) async {
    // Bump sequence: any earlier edits become stale
    final int op = ++_editSeq;
    // Optimistic update for instant UI feedback
    UserEntity? prev = state.user ?? _user;
    if (prev != null) {
      final optimistic = prev.copyWith(
        gender: gender ?? prev.gender,
        name: name ?? prev.name,
        profile_state: profileState ?? prev.profile_state,
        birth: birth ?? prev.birth,
      );
      _setUser(optimistic);
      emit(state.copyWith(status: UserCubitStatus.loadedProfile, user: optimistic));
    }

    try {
      // إعداد الحقول الإضافية
      final Map<String, String> fields = {};
      if (gender != null) fields['gender'] = gender;
      if (name != null) fields['name'] = name;
      if (statuse != null) fields['statuse'] = statuse;
      if (profileState != null) fields['profile_state'] = profileState;
      if (birth != null) fields['birth'] = birth;

// If fields should only contain String values, you can do additional checks
      // final Map<String, String> safeFields =
      //     fields.map((key, value) => MapEntry(key, value.toString()));

      // التحقق من وجود صورة وتنفيذ منطق إضافي
      if (image != null) {
        log("Uploading user profile image...");
        final response = await ApiService().uploadFile(
          '/user/edit',
          file: image,
          fieldName: 'img',
          // headers: safeFields,
        );

        if (response.statusCode == 200) {
          final dynamic raw = response.data;
          final Map<String, dynamic> responseData = raw is String
              ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
              : Map<String, dynamic>.from(raw as Map);

          final user = UserEntity.fromJson(responseData['user']);
          //log("User updated successfully: $user");
          // استدعاء وظائف تحديث أخرى
          final avatarData = AvatarData(
            imageUrl: user.img,
            frameId: user.elementFrame?.elamentId,
            frameLink: user.elementFrame?.linkPath,
            vipLevel: user.vip,
            entryID: user.entryID,
            
            entryTimer: user.entryTimer,
            entryLink: user.entrylink,
            ownerIds: user.ownerIds,
            adminRoomIds: user.adminRoomIds,
            totalSocre: user.totalSocre,
            level1: user.level1,
            level2: user.level2,
            newlevel3: user.newlevel3,
            svgaSquareUrls: [
              user.ws1,
              user.ws2,
              user.ws3,
              user.ws4,
              user.ws5,
            ]
                .where((s) => s != null && s!.trim().isNotEmpty && s!.trim() != 'null')
                .map((e) => e!.trim())
                .toList(),
            svgaRectUrls: [
              user.ic1,
              user.ic2,
              user.ic3,
              user.ic4,
              user.ic5,
              user.ic6,
              user.ic7,
              user.ic8,
              user.ic9,
              user.ic10,
              user.ic11,
              user.ic12,
              user.ic13,
              user.ic14,
              user.ic15,
            ]
                .where((s) => s != null && s!.trim().isNotEmpty && s!.trim() != 'null')
                .map((e) => e!.trim())
                .toList(),
          );
          final encoded = avatarData.toEncodedString();
          final ZIMUserAvatarUrlUpdatedResult zimUserAvatarUrlUpdatedResult =
              await ZEGOSDKManager()
                  .zimService
                  .updateUserAvatarUrl(user.img ?? '');
          try {
            await ZEGOSDKManager().zimService.updateUserExtendedData(encoded);
          } catch (_) {}
          final ZIMUserNameUpdatedResult zimUserNameUpdatedResult =
              await ZEGOSDKManager().zimService.updateUserName(user.name!);
          log("zimUserAvatarUrlUpdatedResult $zimUserAvatarUrlUpdatedResult ---- zimUserNameUpdatedResult $zimUserNameUpdatedResult  ");

          // Ignore stale responses
          if (op != _editSeq) return;

          _setUser(user);
          await AuthService.saveUserToSharedPreferences(user);

          // تحديث الحالة
          emit(state.copyWith(
            status: UserCubitStatus.loaded,
            user: user,
          ));
        } else {
          // Only handle error if this is still the latest op
          if (op == _editSeq) {
            emit(state.copyWith(
              status: UserCubitStatus.error,
              message: 'Failed to edit user profile: ${response.statusMessage}',
            ));
            // Revert optimistic update on error
            if (prev != null) {
              _setUser(prev);
              emit(state.copyWith(status: UserCubitStatus.loadedProfile, user: prev));
            }
          }
        }
      } else {
        // منطق في حالة عدم وجود صورة
        //log("Updating user profile without image...");
        final response = await ApiService().post('/user/edit', data: fields);

        if (response.statusCode == 200) {
          final dynamic raw = response.data;
          final Map<String, dynamic> responseData = raw is String
              ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
              : Map<String, dynamic>.from(raw as Map);
          final user = UserEntity.fromJson(responseData['user']);
          //log("User updated successfully: $user");

          // Ignore stale responses
          if (op != _editSeq) return;

          _setUser(user);
          await AuthService.saveUserToSharedPreferences(user);

          emit(state.copyWith(
            status: UserCubitStatus.loaded,
            user: user,
          ));
        } else {
          if (op == _editSeq) {
            emit(state.copyWith(
              status: UserCubitStatus.error,
              message: 'Failed to edit user profile: ${response.statusMessage}',
            ));
            // Revert optimistic update on error
            if (prev != null) {
              _setUser(prev);
              emit(state.copyWith(status: UserCubitStatus.loadedProfile, user: prev));
            }
          }
        }
      }
    } catch (e) {
      if (op == _editSeq) {
        emit(state.copyWith(
          status: UserCubitStatus.error,
          message: 'Failed to edit user profile: $e',
        ));
        //log("Error editing user profile: $e");
        // Revert optimistic update on error
        if (prev != null) {
          _setUser(prev);
          emit(state.copyWith(status: UserCubitStatus.loadedProfile, user: prev));
        }
      }
    }
  }

/////////////////////////////////////////////////////////////////////////
  /// 5
  Future<void> editUserCountry(String country) async {
    // Bump sequence: only the last country edit should win
    final int op = ++_editSeq;
    // Optimistic update for instant feedback
    final prev = state.user ?? _user;
    if (prev != null) {
      final optimistic = prev.copyWith(country: country);
      _setUser(optimistic);
      emit(state.copyWith(status: UserCubitStatus.loadedProfile, user: optimistic));
    }

    try {

      final response = await ApiService().get('/edit/country?country=$country');
      log("editUserCountry $country ${response.statusCode}");

      if (response.statusCode == 200) {
        dynamic responseData;
        try {
          responseData = response.data is String
              ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, response.data)
              : Map<String, dynamic>.from(response.data as Map);
        } catch (e) {
          log("JSON decode error: ${e.toString()}");
          emit(state.copyWith(
            status: UserCubitStatus.error,
            message: 'Invalid response format.',
          ));
          return;
        }

        log("editUserCountry responseData: $responseData");

        if (responseData is Map<String, dynamic>) {
          final String message = responseData['message']?.toString() ??
              'Country updated successfully';
          log("editUserCountry message: $message");

          if (op == _editSeq) {
            // Keep current optimistic user and just update status/message
            emit(state.copyWith(status: UserCubitStatus.loaded, message: message));
            // Trigger a minimal background refresh to sync any other fields
            unawaited(_refreshProfileMinimal(skipZego: true));
          }
        } else {
          log("Unexpected data format: $responseData");
          if (op == _editSeq) {
            emit(state.copyWith(
              status: UserCubitStatus.error,
              message: 'Unexpected response format.',
            ));
            if (prev != null) {
              _setUser(prev);
              emit(state.copyWith(status: UserCubitStatus.loadedProfile, user: prev));
            }
          }
        }
      } else {
        if (op == _editSeq) {
          emit(state.copyWith(
            status: UserCubitStatus.error,
            message: 'Failed to update country: ${response.statusMessage}',
          ));
          if (prev != null) {
            _setUser(prev);
            emit(state.copyWith(status: UserCubitStatus.loadedProfile, user: prev));
          }
        }
      }
    } catch (e) {
      log("editUserCountry error for \\$country: ${e.toString()}");

      if (op == _editSeq) {
        emit(state.copyWith(
          status: UserCubitStatus.error,
          message: 'Failed to update country: ${e.toString()}',
        ));
        if (prev != null) {
          _setUser(prev);
          emit(state.copyWith(status: UserCubitStatus.loadedProfile, user: prev));
        }
      }
    }
  }

/////////////////////////////////////////////////////////////////////////
  /// 10
  /// done
  Future<void> getUserProfileById(String userId) async {
    final List<String> executionSteps = []; // لتخزين خطوات التنفيذ

    try {
      executionSteps.add('1. Starting getUserProfileById for user: $userId');
      emit(state.copyWith(
        userOther: null,
        status: UserCubitStatus.loading,
      ));
      executionSteps.add('2. Emitted loading state');

      executionSteps.add('3. Making API request to /user/profile/$userId');
      final response = await ApiService().get('/user/profile/$userId');
      executionSteps.add(
          '4. Received API response with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        executionSteps
            .add('5. Processing successful response for user: $userId');
        final dynamic raw = response.data;
        final Map<String, dynamic> responseData = raw is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
            : Map<String, dynamic>.from(raw as Map);
        executionSteps.add(
            '6. Response data processed (type: ${responseData.runtimeType})');

        final userData = responseData['user'];
        executionSteps.add('7. Extracted user data: ${userData.toString()}');
        final userOther = UserEntity.fromJson(userData);
        executionSteps.add('8. Created UserEntity from JSON');

        // optional room in profile/id response
        RoomEntity? otherRoom;
        try {
          final roomJson = responseData['room'];
          if (roomJson != null) {
            otherRoom = RoomEntity.fromJson(
              roomJson is String
                  ? await compute<String, Map<String, dynamic>>(
                      decodeJsonToMapIsolate, roomJson)
                  : Map<String, dynamic>.from(roomJson as Map),
            );
          }
        } catch (_) {
          // ignore malformed room
        }

        final int friendNumber = responseData['friend_number'] ?? 0;
        final int visitorNumber = responseData['visitor_number'] ?? 0;
        final String freind = responseData['friend'] ?? '';
        executionSteps.add(
            '9. Extracted metadata - friendNumber: $friendNumber, visitorNumber: $visitorNumber, freind: $freind');

        final List<ElementEntity> giftList = responseData['gifts'] != null
            ? (responseData['gifts'] as List)
                .map((gift) => ElementEntity.fromJson(gift))
                .toList()
            : [];
        executionSteps
            .add('10. Processed gift list with ${giftList.length} items');

        final List<ElementEntity> entryList = responseData['entry'] != null
            ? (responseData['entry'] is Map
                ? (responseData['entry'] as Map)
                    .values
                    .map((entry) => ElementEntity.fromJson(entry))
                    .toList()
                : (responseData['entry'] as List)
                    .map((entry) => ElementEntity.fromJson(entry))
                    .toList())
            : [];
        executionSteps
            .add('11. Processed entry list with ${entryList.length} items');

        final List<ElementEntity> frameList = responseData['frame'] != null
            ? (responseData['frame'] is Map
                ? (responseData['frame'] as Map)
                    .values
                    .map((frame) => ElementEntity.fromJson(frame))
                    .toList()
                : (responseData['frame'] as List)
                    .map((frame) => ElementEntity.fromJson(frame))
                    .toList())
            : [];
        executionSteps
            .add('12. Processed frame list with ${frameList.length} items');

        emit(state.copyWith(
          status: UserCubitStatus.loadedById,
          userOther: userOther,
          friendNumberOther: friendNumber,
          visitorNumberOther: visitorNumber,
          freindOther: freind,
          entryListOther: entryList,
          frameListOther: frameList,
          giftListOther: giftList,
          otherRoom: otherRoom,
        ));
        executionSteps.add('13. Emitted loaded state with user data');

        if (responseData['status'] == 'you are friend') {
          emit(state.copyWith(status: UserCubitStatus.youAreFriend));
          executionSteps.add('14. Emitted youAreFriend status');
        } else if (responseData['status'] == 'you are not friend') {
          emit(state.copyWith(
            status: UserCubitStatus.error,
            message: "You are not friend",
          ));
          executionSteps.add('15. Emitted not friend error status');
        }
      } else {
        executionSteps.add(
            '16. API request failed with status code: ${response.statusCode}');
        final errorMessage =
            'Failed to fetch user profile: ${response.statusMessage}';

        // طباعة الخطأ والخطوات السابقة
        log('\n⚠️ ERROR DETAILS ⚠️');
        log('🔴 Primary Error: $errorMessage');
        log('\n🔍 Execution Steps:');
        for (var step in executionSteps) {
          log(step);
        }
        log('\n📄 Full Response: ${response.data}');

        emit(state.copyWith(
          status: UserCubitStatus.error,
          message: 'User Cubit: $errorMessage',
        ));
      }
    } catch (e, stackTrace) {
      executionSteps.add('17. Exception caught in getUserProfileById: $e');
      executionSteps.add('18. Stack trace: $stackTrace');

      // طباعة الخطأ والخطوات السابقة
      log('\n⚠️ ERROR DETAILS ⚠️');
      log('🔴 Primary Error: $e');
      log('\n🔍 Execution Steps:');
      for (var step in executionSteps) {
        log(step);
      }

      emit(state.copyWith(
        status: UserCubitStatus.error,
        message: 'User Cubit: Failed to fetch user profile: $e',
      ));
    }
    executionSteps.add('19. Completed getUserProfileById execution');
  }

  Future<void> deleteAccount() async {
    try {
      // استدعاء واجهة API للحذف
      final response = await ApiService().get('/delete/myprofile');

      // تسجيل الاستجابة
      log("/delete/myprofile - Response: ${response.data}");

      // التحقق من نجاح العملية بناءً على نوع البيانات وحالة الاستجابة
      if (response.statusCode == 200) {
        if (response.data is String) {
          log("/delete/myprofile -  ${response.data}");
          emit(state.copyWith(
            status: UserCubitStatus.deleteAccount,
            message: response.data, // استخدام النص كرسالة نجاح
          ));
        } else {
          log("/delete/myprofile - ${response.data.runtimeType}");
          emit(state.copyWith(
            status: UserCubitStatus.error,
            message: 'Unexpected response format.',
          ));
        }
      } else {
        log("/delete/myprofile - Failed to delete account: ${response.data}");
        emit(state.copyWith(
          status: UserCubitStatus.error,
          message: response.data?.toString() ?? 'Failed to delete account.',
        ));
      }
    } catch (e) {
      // التعامل مع الأخطاء
      if (e is DioException) {
        log("/delete/myprofile - DioError: ${e.message}");
        emit(state.copyWith(
          status: UserCubitStatus.error,
          message: e.response?.data?.toString() ?? 'An error occurred.',
        ));
      } else {
        log("/delete/myprofile - Unknown error: $e");
        emit(state.copyWith(
          status: UserCubitStatus.error,
          message: 'An unexpected error occurred.',
        ));
      }
    }
  }

  Future<void> ads() async {
    try {
      final ip = await getUserIP();
      log("adsadsads ip -- $ip");
      final response = await ApiService().get("/add/ads?ip=$ip");
      log("adsadsads  --  ${response.data}");

      if (response.statusCode == 200) {
        log("userCubit adsadsads response.data ${response.data}");
      } else {
        log("userCubit adsadsads is response.statusCode=${response.statusCode}");
      }
    } catch (e) {
      log("userCubit adsadsads is catch $e");
    }
  }

  Future<String> myAdsNumber() async {
    try {
      log("myAdsNumber adsadsads -- ");

      final response = await ApiService().get("/my/ads");
      log("myAdsNumber  adsadsads d--  ${response.data}");

      if (response.statusCode == 200) {
        log("myAdsNumber userCubit adsadsads response.data ${response.data}");
        return response.data.toString();
      } else {
        log("myAdsNumber userCubit adsadsads is response.statusCode=${response.statusCode}");
        return "error ${response.statusCode.toString()}";
      }
    } catch (e) {
      log("myAdsNumber userCubit adsadsads is catch $e");

      return "error ${e.toString()}";
    }
  }

  Future<String> getUserIP() async {
    final response =
        await http.get(Uri.parse('https://api.ipify.org?format=json'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = await compute<String, Map<String, dynamic>>(
          decodeJsonToMapIsolate, response.body);
      return (data['ip'] ?? '').toString();
    } else {
      throw Exception('Failed to get IP');
    }
  }

  /// دالة عامة لطباعة أي response بصيغة جميلة ومنسقة
  /// استخدمها لأي endpoint تريد فحص بياناته
  void printResponsePretty({
    required String endpoint,
    required dynamic responseData,
    required int statusCode,
  }) {
    try {
      Map<String, dynamic>? parsedData;
      if (responseData is Map) {
        parsedData = Map<String, dynamic>.from(responseData as Map);
      } else {
        log('Endpoint: $endpoint status=$statusCode (non-Map response: ${responseData.runtimeType})');
        return;
      }

      log('\n╔════════════════════════════════════════════════════════════╗');
      log('║                 📊 API RESPONSE DEBUG 📊                  ║');
      log('╠════════════════════════════════════════════════════════════╣');
      log('║ Endpoint: $endpoint');
      log('║ Status Code: $statusCode');
      log('╠════════════════════════════════════════════════════════════╣');
      log('║ FULL RESPONSE: (keys only)');
      log('╠════════════════════════════════════════════════════════════╣');

      log('╠════════════════════════════════════════════════════════════╣');
      log('║ ALL KEYS IN RESPONSE:');
      parsedData.forEach((key, value) {
        final valueType = value.runtimeType;
        final valuePreview = value is List
            ? 'List[${value.length}]'
            : value is Map
                ? 'Map[${(value as Map).length}]'
                : value.toString().length > 50
                    ? '${value.toString().substring(0, 50)}...'
                    : value.toString();
        log('║   • $key ($valueType): $valuePreview');
      });

      log('╚════════════════════════════════════════════════════════════╝\n');
    } catch (e) {
      log('Error printing response: $e');
    }
  }
}

// أضف هذا في ملف مستقل مثل user_entity_extensions.dart
extension UserEntityExtensions on UserEntity {
  UserEntity fromOwnAvatarData() {
    return UserEntity.fromAvatarData(
      avatarUrlNotifier.value ?? '',
      userId: iduser.toString(),
      userName: name ?? '',
      streamID: streamID,
      viewID: viewID,
    );
  }
}
