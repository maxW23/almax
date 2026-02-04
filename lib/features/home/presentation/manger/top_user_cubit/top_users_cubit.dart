import 'package:flutter/foundation.dart';
import 'package:lklk/core/utils/json_isolate.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/domain/entities/relation_entity.dart';

part 'top_users_state.dart';

class TopUsersCubit extends Cubit<TopUsersState> {
  TopUsersCubit() : super(TopUsersInitial());

  // Prevent emitting after close
  void _safeEmit(TopUsersState state) {
    if (isClosed) return;
    emit(state);
  }

  // Simple in-memory cache for users per API code (13=daily, 14=weekly, 15=monthly)
  final Map<int, List<UserEntity>> _cacheUsers = {};
  final Map<int, DateTime> _cacheAt = {};
  final Duration cacheTTL = const Duration(minutes: 2);

  bool _isFresh(int code) {
    final t = _cacheAt[code];
    if (t == null) return false;
    return DateTime.now().difference(t) < cacheTTL;
  }

  Future<void> fetchTopUsersCached(int code,
      {bool forceRefresh = false}) async {
    final hasCached = _cacheUsers.containsKey(code);
    final fresh = _isFresh(code);

    // Immediately emit cached data if present and not forcing refresh
    if (hasCached && (!forceRefresh || fresh)) {
      _safeEmit(TopUsersLoaded(_cacheUsers[code]!));
      if (fresh) return; // No need to refresh if cache is fresh
    } else {
      // If no cache, show loading while fetching
      _safeEmit(TopUsersLoading());
    }

    try {
      // تحديد الـ endpoint بناءً على الكود
      // code = 1 يعني API الغرف (toproom1)
      final String endpoint = code == 1 ? '/toproom$code' : '/top/$code';

      final response = await sl<ApiService>().get(endpoint);
      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final List<dynamic> data = raw is String
            ? await compute<String, List<dynamic>>(decodeJsonToListIsolate, raw)
            : List<dynamic>.from(raw as List);
        // We only cache normal top users lists (not relation call code 8)
        final users =
            data.map((userJson) => UserEntity.fromJson(userJson)).toList();
        _cacheUsers[code] = users;
        _cacheAt[code] = DateTime.now();
        _safeEmit(TopUsersLoaded(users));
      } else {
        // On error but we have old cache, keep showing cache
        if (hasCached) {
          _safeEmit(TopUsersLoaded(_cacheUsers[code]!));
        } else {
          _safeEmit(const TopUsersError("Failed to fetch top users"));
        }
      }
    } catch (e) {
      if (hasCached) {
        _safeEmit(TopUsersLoaded(_cacheUsers[code]!));
      } else {
        _safeEmit(TopUsersError(e.toString()));
      }
    }
  }

  /// جلب توب الوكالات بنية حقول مختلفة (wakel_id, wakel_name, wakel_pic, total_diamonds)
  Future<void> wakalaTop(int id) async {
    _safeEmit(TopUsersLoading());
    try {
      final response = await sl<ApiService>().get('/top/$id');
      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final List<dynamic> data = raw is String
            ? await compute<String, List<dynamic>>(decodeJsonToListIsolate, raw)
            : List<dynamic>.from(raw as List);

        String _fullPicUrl(String raw) {
          final filename = (raw).toString().trim();
          if (filename.isEmpty || filename == 'null') return '';
          if (filename.startsWith('http')) return filename;
          if (filename.startsWith('file://')) {
            final parts = filename.split('/');
            final name = parts.isNotEmpty ? parts.last : filename;
            return 'https://lklklive.com/imguser/$name';
          }
          if (filename.startsWith('/img/') ||
              filename.startsWith('img/') ||
              filename.startsWith('/imguser/') ||
              filename.startsWith('imguser/')) {
            final cleaned = filename.replaceFirst(RegExp(r'^/'), '');
            return 'https://lklklive.com/$cleaned';
          }
          return 'https://lklklive.com/imguser/$filename';
        }

        final users = data.map((e) {
          final map = e as Map<String, dynamic>;
          final iduser = map['wakel_id']?.toString() ?? '';
          final name = map['wakel_name']?.toString() ?? '';
          final pic = map['wakel_pic']?.toString() ?? '';
          final diamondsStr = map['total_diamonds']?.toString();
          // Some wakala endpoints may also include weekly/monthly points per agency/user
          final totalSpent = map['total_spent']?.toString();
          return UserEntity(
            iduser: iduser.isEmpty ? '0' : iduser,
            name: name,
            img: _fullPicUrl(pic),
            mon: diamondsStr, // عرضها كنص كما تأتي من API (مثل 2.2M)
            totalSpent: totalSpent,
          );
        }).toList();

        _safeEmit(TopUsersLoaded(users));
      } else {
        _safeEmit(const TopUsersError('Failed to fetch wakala top'));
      }
    } catch (e) {
      _safeEmit(TopUsersError(e.toString()));
    }
  }

  Future<void> fetchTopUsers(int numberOfCubitTopUsers) async {
    _safeEmit(TopUsersLoading());
    try {
      final response = await sl<ApiService>().get(
        '/top/$numberOfCubitTopUsers',
      );
      // log("/top/$numberOfCubitTopUsers response----- $response");
      // log("/top/$numberOfCubitTopUsers data----- ${response.data}");
      // log("/top/$numberOfCubitTopUsers statusCode----- ${response.statusCode}");
      // log("/top/$numberOfCubitTopUsers statusMessage----- ${response.statusMessage}");
      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final List<dynamic> data = raw is String
            ? await compute<String, List<dynamic>>(decodeJsonToListIsolate, raw)
            : List<dynamic>.from(raw as List);
        if (numberOfCubitTopUsers != 8) {
          final users =
              data.map((userJson) => UserEntity.fromJson(userJson)).toList();
          _safeEmit(TopUsersLoaded(users));
        } else {
          final users =
              data.map((userJson) => UserRelation.fromJson(userJson)).toList();
          _safeEmit(TopUserRelationUsersLoaded(users));
        }
      } else {
        _safeEmit(const TopUsersError("Failed to fetch top users"));
      }
    } catch (e) {
      _safeEmit(TopUsersError(e.toString()));
    }
  }

  // ===== Method جديدة للتعامل مع response الصور (array of strings) =====

  // Cache منفصل للصور
  final Map<String, List<String>> _cacheImages = {};
  final Map<String, DateTime> _cacheImagesAt = {};

  /// التحقق من صلاحية cache الصور
  bool _isImagesCacheFresh(String endpoint) {
    final t = _cacheImagesAt[endpoint];
    if (t == null) return false;
    return DateTime.now().difference(t) < cacheTTL;
  }

  /// جلب الصور من API
  /// يستخدم للـ endpoints التي ترجع array of strings فقط
  /// مثل: /toproom1, /top/44, /top/55, /top/88
  Future<void> fetchTopImages(String endpoint,
      {bool forceRefresh = false}) async {
    final hasCached = _cacheImages.containsKey(endpoint);
    final fresh = _isImagesCacheFresh(endpoint);

    // عرض البيانات المخزنة فوراً إن وجدت
    if (hasCached && (!forceRefresh || fresh)) {
      _safeEmit(TopImagesLoaded(_cacheImages[endpoint]!));
      if (fresh) return; // لا حاجة للتحديث إذا كان الـ cache حديثاً
    } else {
      // إذا لم يكن هناك cache، نعرض حالة التحميل
      _safeEmit(TopImagesLoading());
    }

    try {
      final response = await ApiService().get(endpoint);
      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final List<dynamic> data = raw is String
            ? await compute<String, List<dynamic>>(decodeJsonToListIsolate, raw)
            : List<dynamic>.from(raw as List);

        // تحويل القائمة إلى List<String> مع اختيار base URL الصحيح
        final bool isRoomEndpoint = endpoint.contains('toproom');
        // العلاقات تُعامل كصور مستخدمين (imguser)
        final String base = isRoomEndpoint
            ? 'https://lklklive.com/img/' // صور الغرف
            : 'https://lklklive.com/imguser/'; // صور المستخدمين (يشمل /top/88)

        final List<String> imageUrls = data
            .map((item) => item.toString())
            .where((url) => url.isNotEmpty && url != 'null')
            .map((raw) {
          final filename = raw.trim();
          // إذا كان يبدأ بـ http أعده كما هو
          if (filename.startsWith('http')) return filename;
          // إذا كان يبدأ بـ file:// خذ اسم الملف فقط
          if (filename.startsWith('file://')) {
            final parts = filename.split('/');
            final name = parts.isNotEmpty ? parts.last : filename;
            return '$base$name';
          }
          // إذا جاء بمسار نسبي يبدأ بـ img أو imguser، حوّله إلى URL كامل
          if (filename.startsWith('/img/') ||
              filename.startsWith('img/') ||
              filename.startsWith('/imguser/') ||
              filename.startsWith('imguser/')) {
            final cleaned = filename.replaceFirst(RegExp(r'^/'), '');
            return 'https://lklklive.com/$cleaned';
          }
          // الحالة الافتراضية: أضف base المناسب
          return '$base$filename';
        }).toList();

        // حفظ في الـ cache
        _cacheImages[endpoint] = imageUrls;
        _cacheImagesAt[endpoint] = DateTime.now();

        _safeEmit(TopImagesLoaded(imageUrls));
      } else {
        // في حالة الخطأ ولكن لدينا cache قديم، نبقي على الـ cache
        if (hasCached) {
          _safeEmit(TopImagesLoaded(_cacheImages[endpoint]!));
        } else {
          _safeEmit(const TopImagesError("Failed to fetch top images"));
        }
      }
    } catch (e) {
      if (hasCached) {
        _safeEmit(TopImagesLoaded(_cacheImages[endpoint]!));
      } else {
        _safeEmit(TopImagesError(e.toString()));
      }
    }
  }
}
