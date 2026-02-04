import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/foundation.dart';

/// محسّن الشبكة للتعامل مع الغرف عالية الكثافة
/// يدير تجميع الطلبات وتحسين استهلاك البيانات
class NetworkOptimizer {
  static final NetworkOptimizer _instance = NetworkOptimizer._internal();
  factory NetworkOptimizer() => _instance;
  NetworkOptimizer._internal();

  // تجميع الطلبات لتقليل عدد استدعاءات الشبكة
  final Map<String, Timer> _batchTimers = {};
  final Map<String, List<Function>> _batchedRequests = {};

  // تخزين مؤقت للبيانات المتكررة
  final Map<String, dynamic> _dataCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // إعدادات التحسين
  static const Duration _batchDelay = Duration(milliseconds: 100);
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const int _maxCacheSize = 1000;

  /// تجميع طلبات تحديث المستخدمين
  void batchUserUpdate(String userId, Function updateFunction) {
    final batchKey = 'user_updates';

    // إضافة الطلب إلى المجموعة
    _batchedRequests[batchKey] ??= [];
    _batchedRequests[batchKey]!.add(updateFunction);

    // إلغاء المؤقت السابق وإنشاء جديد
    _batchTimers[batchKey]?.cancel();
    _batchTimers[batchKey] = Timer(_batchDelay, () {
      _executeBatchedRequests(batchKey);
    });
  }

  /// تجميع طلبات تحديث الرسائل
  void batchMessageUpdate(String roomId, Function updateFunction) {
    final batchKey = 'message_updates_$roomId';

    _batchedRequests[batchKey] ??= [];
    _batchedRequests[batchKey]!.add(updateFunction);

    _batchTimers[batchKey]?.cancel();
    _batchTimers[batchKey] = Timer(_batchDelay, () {
      _executeBatchedRequests(batchKey);
    });
  }

  /// تجميع طلبات تحديث الصوت
  void batchAudioUpdate(String streamId, Function updateFunction) {
    final batchKey = 'audio_updates';

    _batchedRequests[batchKey] ??= [];
    _batchedRequests[batchKey]!.add(updateFunction);

    _batchTimers[batchKey]?.cancel();
    _batchTimers[batchKey] = Timer(const Duration(milliseconds: 50), () {
      _executeBatchedRequests(batchKey);
    });
  }

  /// تنفيذ الطلبات المجمعة
  void _executeBatchedRequests(String batchKey) {
    final requests = _batchedRequests[batchKey];
    if (requests == null || requests.isEmpty) return;

    try {
      if (kDebugMode) {
        log('[NetworkOptimizer] Executing ${requests.length} batched requests for $batchKey');
      }

      // تنفيذ جميع الطلبات في المجموعة
      for (final request in requests) {
        try {
          request();
        } catch (e) {
          if (kDebugMode) {
            log('[NetworkOptimizer] Error executing batched request: $e');
          }
        }
      }
    } finally {
      // تنظيف المجموعة
      _batchedRequests[batchKey]?.clear();
      _batchTimers[batchKey]?.cancel();
      _batchTimers.remove(batchKey);
    }
  }

  /// تخزين البيانات في الكاش
  void cacheData(String key, dynamic data) {
    // تنظيف الكاش إذا وصل للحد الأقصى
    if (_dataCache.length >= _maxCacheSize) {
      _cleanupOldCache();
    }

    _dataCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// استرجاع البيانات من الكاش
  T? getCachedData<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    // التحقق من انتهاء صلاحية الكاش
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      _dataCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _dataCache[key] as T?;
  }

  /// تنظيف الكاش القديم
  void _cleanupOldCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheExpiry) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _dataCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    // إذا لم يكن هناك كاش منتهي الصلاحية، احذف الأقدم
    if (_dataCache.length >= _maxCacheSize && expiredKeys.isEmpty) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _dataCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }

    if (kDebugMode && expiredKeys.isNotEmpty) {
      log('[NetworkOptimizer] Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }

  /// تحسين طلبات الصور
  String optimizeImageUrl(String originalUrl, {int? width, int? height}) {
    // إضافة معاملات تحسين الصورة إذا كان الرابط يدعم ذلك
    if (originalUrl.contains('cloudinary') || originalUrl.contains('imgix')) {
      final separator = originalUrl.contains('?') ? '&' : '?';
      final params = <String>[];

      if (width != null) params.add('w=$width');
      if (height != null) params.add('h=$height');
      params.add('q=auto'); // جودة تلقائية
      params.add('f=auto'); // تنسيق تلقائي

      return '$originalUrl$separator${params.join('&')}';
    }

    return originalUrl;
  }

  /// تحسين طلبات البيانات المتكررة
  Future<T> optimizedRequest<T>(
    String cacheKey,
    Future<T> Function() requestFunction, {
    Duration? customCacheExpiry,
  }) async {
    // محاولة الحصول على البيانات من الكاش أولاً
    final cachedData = getCachedData<T>(cacheKey);
    if (cachedData != null) {
      if (kDebugMode) {
        log('[NetworkOptimizer] Cache hit for $cacheKey');
      }
      return cachedData;
    }

    // تنفيذ الطلب وتخزين النتيجة
    try {
      final result = await requestFunction();
      cacheData(cacheKey, result);

      if (kDebugMode) {
        log('[NetworkOptimizer] Cache miss for $cacheKey, data cached');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        log('[NetworkOptimizer] Request failed for $cacheKey: $e');
      }
      rethrow;
    }
  }

  /// تنظيف الموارد
  void dispose() {
    // إلغاء جميع المؤقتات
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();

    // تنظيف البيانات المجمعة
    _batchedRequests.clear();

    // تنظيف الكاش
    _dataCache.clear();
    _cacheTimestamps.clear();

    if (kDebugMode) {
      log('[NetworkOptimizer] Resources disposed');
    }
  }

  /// الحصول على إحصائيات الأداء
  Map<String, dynamic> getStats() {
    return {
      'activeBatches': _batchTimers.length,
      'cacheSize': _dataCache.length,
      'maxCacheSize': _maxCacheSize,
      'batchDelay': _batchDelay.inMilliseconds,
      'cacheExpiry': _cacheExpiry.inMinutes,
    };
  }

  /// مسح الكاش يدوياً
  void clearCache() {
    _dataCache.clear();
    _cacheTimestamps.clear();

    if (kDebugMode) {
      log('[NetworkOptimizer] Cache cleared manually');
    }
  }
}
