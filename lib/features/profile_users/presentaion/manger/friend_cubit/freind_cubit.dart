import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:lklk/core/utils/json_isolate.dart';

import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/domain/entities/friend_user.dart';
import 'package:lklk/features/profile_users/domain/entities/friendship_entity.dart';
import 'package:meta/meta.dart';

import '../../../../../core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'freind_state.dart';

class FreindCubit extends Cubit<FreindState> {
  FreindCubit() : super(FreindInitial());

  // In-memory mirrors and storage keys
  List<FriendUser>? _cachedFriends;
  List<UserEntity>? _cachedVisitors;
  static const String _friendsKey = 'cachedFriends';
  static const String _visitorsKey = 'cachedVisitors';

  Future<List<FriendUser>?> _loadCachedFriends() async {
    if (_cachedFriends != null) return _cachedFriends;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_friendsKey);
      if (raw == null || raw.isEmpty) return null;
      final List<dynamic> decoded = await compute<String, List<dynamic>>(decodeJsonToListIsolate, raw);
      _cachedFriends = decoded
          .whereType<Map<String, dynamic>>()
          .map((m) => FriendUser.fromMap(m))
          .toList();
      return _cachedFriends;
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheFriends(List<FriendUser> friends) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = friends.map((f) => f.toMap()).toList();
      await prefs.setString(_friendsKey, await compute<dynamic, String>(encodeJsonIsolate, list));
      _cachedFriends = friends;
    } catch (_) {}
  }

  Future<List<UserEntity>?> _loadCachedVisitors() async {
    if (_cachedVisitors != null) return _cachedVisitors;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_visitorsKey);
      if (raw == null || raw.isEmpty) return null;
      final List<dynamic> decoded = await compute<String, List<dynamic>>(decodeJsonToListIsolate, raw);
      _cachedVisitors = decoded
          .whereType<Map<String, dynamic>>()
          .map((m) => UserEntity.fromMap(m))
          .toList();
      return _cachedVisitors;
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheVisitors(List<UserEntity> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = users.map((u) => u.toMap()).toList();
      await prefs.setString(_visitorsKey, await compute<dynamic, String>(encodeJsonIsolate, list));
      _cachedVisitors = users;
    } catch (_) {}
  }

  Future<void> getWaitingFriendRequestsList() async {
    emit(FreindLoadingList());

    try {
      final response =
          await ApiService().get('/user/friend/list/waiting/accept');

      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final Map<String, dynamic> responseData = raw is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
            : Map<String, dynamic>.from(raw as Map);

        log("getWaitingFriendRequestsList $responseData");
        final List<dynamic> waitingRequestsData = responseData['user'];

        final List<FriendshipEntity> waitingRequests = waitingRequestsData
            .map<FriendshipEntity>(
                (requestData) => FriendshipEntity.fromJson(requestData))
            .toList();
        emit(FreindWaitingFriendRequestsLoaded(waitingRequests));
      } else {
        emit(FreindError(
            'Failed to fetch waiting friend requests list: ${response.statusMessage}'));
      }
    } catch (e) {
      emit(FreindError('Failed to fetch waiting friend requests list: $e'));
    }
  }

  Future<void> getListOfVisitorProfiles() async {
    // 1) Show cached visitors instantly if available
    List<UserEntity>? cached;
    try {
      cached = await _loadCachedVisitors();
      if (cached != null && cached.isNotEmpty) {
        emit(FreindVisitorProfilesLoaded(cached));
      } else {
        emit(FreindLoadingList());
      }
    } catch (_) {
      emit(FreindLoadingList());
    }

    final bool hadCache = cached != null && cached.isNotEmpty;

    // 2) Fetch fresh from API and update cache/state
    try {
      final response = await ApiService().get('/user/profile/visitor/list');

      if (response.statusCode == 200) {
        final dynamic rawVip = response.data;
        if (rawVip is String && rawVip.contains("you have to be vip 2 and up to see you visitor")) {
          if (!hadCache) {
            emit(FreindRequiresVip(requiredVipLevel: 2, feature: "رؤية الزوار"));
          }
          return;
        }
        final dynamic raw = response.data;
        final Map<String, dynamic> responseData = raw is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
            : Map<String, dynamic>.from(raw as Map);

        // VIP requirement string from backend
        if (responseData is String &&
            responseData.toString()
                .contains('you have to be vip 2 and up to see you visitor')) {
          if (!hadCache) {
            emit(FreindRequiresVip(requiredVipLevel: 2, feature: 'رؤية الزوار'));
          }
          return;
        }

        final List<dynamic> visitorData = responseData['profile_visitor'] ?? [];
        if (visitorData.isEmpty) {
          emit(FreindEmpty());
        } else {
          final List<UserEntity> visitorProfiles = List<UserEntity>.from(
            visitorData.reversed
                .map((visitorJson) => UserEntity.fromJson(visitorJson)),
          );
          await _cacheVisitors(visitorProfiles);
          emit(FreindVisitorProfilesLoaded(visitorProfiles));
        }
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        if (!hadCache) {
          emit(FreindRequiresVip(requiredVipLevel: 2, feature: 'رؤية الزوار'));
        }
      } else {
        emit(FreindError(
            'Failed to fetch visitor profiles: ${response.statusMessage}'));
      }
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('vip') || errorMessage.contains('403')) {
        if (!hadCache) {
          emit(FreindRequiresVip(requiredVipLevel: 2, feature: 'رؤية الزوار'));
        }
      } else {
        emit(FreindError('Failed to fetch visitor profiles: $e'));
      }
    }
  }

  Future<void> getFriendsList() async {
    // 1) Show cached friends instantly if available
    try {
      final cached = await _loadCachedFriends();
      if (cached != null && cached.isNotEmpty) {
        emit(FreindFriendsListLoaded(cached));
      } else {
        emit(FreindLoadingList());
      }
    } catch (_) {
      emit(FreindLoadingList());
    }

    // 2) Fetch fresh friends and update cache/state
    try {
      final response = await ApiService().get('/user/friend/list');

      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final Map<String, dynamic> responseData = raw is String
            ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, raw)
            : Map<String, dynamic>.from(raw as Map);
        final List<dynamic> friendsData = responseData['user'];
        for (var friend in friendsData) {
          log("friend.runtimeType ${friend.runtimeType.toString()}");
        }
        final List<FriendUser> friends = friendsData
            .map((friendData) => FriendUser.fromJson(friendData))
            .toList();

        await _cacheFriends(friends);
        emit(FreindFriendsListLoaded(friends));
      } else {
        emit(FreindError(
            'Failed to fetch friends list: ${response.statusMessage}'));
      }
    } catch (e) {
      emit(FreindError('Failed to fetch friends list: $e'));
    }
  }
}
