import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:lklk/core/utils/json_isolate.dart';

/// Caches per-room details (RoomEntity + key lists) with LRU of last 3 rooms
class RoomDetailsCacheManager {
  static const String _logTag = 'RoomDetailsCache';
  static const String _cacheKey = 'room_details_cache_v1';
  static const String _orderKey = 'room_details_order_v1';
  static const int _maxRooms = 3;

  RoomDetailsCacheManager._internal();
  static final RoomDetailsCacheManager instance = RoomDetailsCacheManager._internal();

  Future<void> cacheRoomDetails({
    required RoomEntity room,
    List<UserEntity>? usersServer,
    List<UserEntity>? admins,
    List<UserEntity>? banned,
    List<UserEntity>? top,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load existing map and order
      final rawMap = prefs.getString(_cacheKey);
      final rawOrder = prefs.getString(_orderKey);
      final Map<String, dynamic> cache = rawMap != null
          ? await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, rawMap)
          : <String, dynamic>{};
      List<String> order = rawOrder != null
          ? List<String>.from(
              await compute<String, List<dynamic>>(decodeJsonToListIsolate, rawOrder),
            )
          : <String>[];

      final String roomId = room.id.toString();

      // Serialize RoomEntity with underscore keys for fromJson()
      final r = room.toMap();
      final Map<String, dynamic> roomJson = {
        'id': r['id'],
        'name': r['name'],
        'background': r['background'],
        'img': r['img'],
        'country': r['country'],
        'hello_text': r['helloText'],
        'microphone_number': r['microphoneNumber'],
        'owner': r['owner'],
        'type': r['type'],
        'pass': r['pass'],
        'coin': r['coin'],
        'fire': r['fire'],
        'topvalues': r['topvalues'],
        'isFavourite': r['isFavourite'],
        'ic': r['ic'],
        'back': r['back'],
        'frame': r['frame'],
        'color1': r['color1'],
        'color2': r['color2'],
        'word': r['word'],
      };

      // Users lists (store via toMap -> restore via fromMap)
      List<Map<String, dynamic>> _encodeUsers(List<UserEntity>? list) =>
          (list ?? const <UserEntity>[]) .map((u) => u.toMap()).toList();

      final entry = {
        'room': roomJson,
        'users': _encodeUsers(usersServer),
        'admins': _encodeUsers(admins),
        'banned': _encodeUsers(banned),
        'top': _encodeUsers(top),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Update cache map
      cache[roomId] = entry;

      // Update LRU order: move to front
      order.remove(roomId);
      order.insert(0, roomId);

      // Trim to max size
      while (order.length > _maxRooms) {
        final removedId = order.removeLast();
        cache.remove(removedId);
      }
      final cacheJson =
          await compute<dynamic, String>(encodeJsonIsolate, cache);
      final orderJson =
          await compute<dynamic, String>(encodeJsonIsolate, order);
      await prefs.setString(_cacheKey, cacheJson);
      await prefs.setString(_orderKey, orderJson);
      dev.log('💾 Cached room $roomId (order: ${order.join(',')})', name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to cache state: $e', name: _logTag);
    }
  }

  Future<RoomDetails?> getCachedDetails(int roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawMap = prefs.getString(_cacheKey);
      if (rawMap == null) return null;

      final Map<String, dynamic> cache =
          await compute<String, Map<String, dynamic>>(decodeJsonToMapIsolate, rawMap);
      final entry = cache[roomId.toString()];
      if (entry == null) return null;

      final Map<String, dynamic> r = Map<String, dynamic>.from(entry['room'] as Map);
      final room = RoomEntity.fromJson(r);

      List<UserEntity> _decodeUsers(dynamic list) {
        if (list is List) {
          return list
              .map((e) => UserEntity.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        return <UserEntity>[];
      }

      final users = _decodeUsers(entry['users']);
      final admins = _decodeUsers(entry['admins']);
      final banned = _decodeUsers(entry['banned']);
      final top = _decodeUsers(entry['top']);

      return RoomDetails(
        room: room,
        users: users,
        admins: admins,
        banned: banned,
        top: top,
      );
    } catch (e) {
      dev.log('❌ Failed to read cached state for $roomId: $e', name: _logTag);
      return null;
    }
  }

  /// For testing or emergencies
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_orderKey);
      dev.log('🗑️ Cleared room details cache', name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to clear room details cache: $e', name: _logTag);
    }
  }
}

class RoomDetails {
  final RoomEntity room;
  final List<UserEntity> users;
  final List<UserEntity> admins;
  final List<UserEntity> banned;
  final List<UserEntity> top;

  const RoomDetails({
    required this.room,
    required this.users,
    required this.admins,
    required this.banned,
    required this.top,
  });
}
