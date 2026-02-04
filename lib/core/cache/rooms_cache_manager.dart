import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'dart:developer' as dev;

/// مدير كاش الغرف المحسن
class RoomsCacheManager {
  static const String _logTag = 'RoomsCacheManager';
  static const String _roomsKey = 'cached_rooms';
  static const String _lastUpdateKey = 'rooms_last_update';
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  static RoomsCacheManager? _instance;
  static RoomsCacheManager get instance =>
      _instance ??= RoomsCacheManager._internal();

  RoomsCacheManager._internal();

  /// حفظ الغرف في الكاش
  Future<void> cacheRooms(List<RoomEntity> rooms) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // تحويل الغرف إلى صيغة متوافقة مع fromJson
      final roomsJson = rooms.map((room) {
        final map = room.toMap();
        // تأكد من أن المفاتيح بالصيغة الصحيحة
        return {
          'id': map['id'],
          'name': map['name'],
          'background': map['background'],
          'img': map['img'],
          'country': map['country'],
          'hello_text':
              map['helloText'], // استخدم underscore للتوافق مع fromJson
          'microphone_number':
              map['microphoneNumber'], // استخدم underscore للتوافق مع fromJson
          'owner': map['owner'],
          'type': map['type'],
          'pass': map['pass'],
          'coin': map['coin'],
          'fire': map['fire'],
          'topvalues': map['topvalues'],
          'isFavourite': map['isFavourite'],
        };
      }).toList();

      final roomsData = jsonEncode(roomsJson);

      await prefs.setString(_roomsKey, roomsData);
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);

      dev.log('💾 Cached ${rooms.length} rooms successfully', name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to cache rooms: $e', name: _logTag);
    }
  }

  Future<List<RoomEntity>?> getCachedRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsData = prefs.getString(_roomsKey);
      final lastUpdate = prefs.getInt(_lastUpdateKey);

      if (roomsData == null || lastUpdate == null) {
        dev.log('📭 No cached rooms found', name: _logTag);
        return null;
      }

      // فحص صلاحية الكاش
      final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdate;
      if (cacheAge > _cacheValidDuration.inMilliseconds) {
        dev.log(
            '⏰ Cache expired, age: ${Duration(milliseconds: cacheAge).inMinutes} minutes',
            name: _logTag);
        // مسح الكاش المنتهي الصلاحية
        await clearCache();
        return null;
      }

      // محاولة فك تشفير البيانات مع معالجة أفضل للأخطاء
      dynamic decodedData;
      try {
        decodedData = jsonDecode(roomsData);
      } catch (e) {
        dev.log('❌ Invalid JSON format in cache, clearing cache: $e',
            name: _logTag);
        await clearCache();
        return null;
      }

      // التأكد من أن البيانات في صيغة قائمة
      if (decodedData is! List) {
        dev.log('❌ Cache data is not a list, clearing cache', name: _logTag);
        await clearCache();
        return null;
      }

      final List<RoomEntity> rooms = [];
      for (final item in decodedData) {
        try {
          if (item is Map<String, dynamic>) {
            // البيانات محفوظة بالصيغة الصحيحة مسبقاً، استخدمها مباشرة
            rooms.add(RoomEntity.fromJson(item));
          } else {
            dev.log('⚠️ Skipping invalid room data: $item', name: _logTag);
          }
        } catch (e) {
          dev.log('⚠️ Failed to parse room: $e', name: _logTag);
          continue;
        }
      }

      if (rooms.isEmpty) {
        dev.log('📭 No valid rooms found in cache', name: _logTag);
        await clearCache();
        return null;
      }

      dev.log('📦 Retrieved ${rooms.length} cached rooms', name: _logTag);
      return rooms;
    } catch (e) {
      dev.log('❌ Failed to get cached rooms: $e', name: _logTag);
      // مسح الكاش في حالة حدوث خطأ
      try {
        await clearCache();
      } catch (clearError) {
        dev.log('❌ Failed to clear corrupted cache: $clearError',
            name: _logTag);
      }
      return null;
    }
  }

  /// فحص صلاحية الكاش
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey);

      if (lastUpdate == null) return false;

      final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdate;
      return cacheAge <= _cacheValidDuration.inMilliseconds;
    } catch (e) {
      return false;
    }
  }

  /// مسح الكاش
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_roomsKey);
      await prefs.remove(_lastUpdateKey);
      dev.log('🗑️ Cache cleared', name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to clear cache: $e', name: _logTag);
    }
  }

  /// تحديث غرفة واحدة في الكاش
  Future<void> updateRoomInCache(RoomEntity updatedRoom) async {
    try {
      final cachedRooms = await getCachedRooms();
      if (cachedRooms == null) return;

      final index = cachedRooms.indexWhere((room) => room.id == updatedRoom.id);
      if (index != -1) {
        cachedRooms[index] = updatedRoom;
        await cacheRooms(cachedRooms);
        dev.log('🔄 Updated room ${updatedRoom.id} in cache', name: _logTag);
      }
    } catch (e) {
      dev.log('❌ Failed to update room in cache: $e', name: _logTag);
    }
  }
}
