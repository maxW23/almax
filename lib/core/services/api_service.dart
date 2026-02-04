import 'dart:async';
import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';
import 'dart:io';
import 'dart:math' as math;

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/core/config/app_config.dart';

/// خدمة ApiService المحسنة:
/// - تستخدم Dio مع إعدادات متقدمة للـ BaseOptions.
/// - تدعم إعادة المحاولة باستخدام Exponential Backoff مع طباعة تفاصيل المحاولات.
/// - تراقب حالة الاتصال وتعيد محاولة الطلبات الفاشلة عند استعادة الاتصال.
/// - تطبع تفاصيل الطلبات لكل خطوة لتسهيل تتبع الأخطاء وتحليلها.
class ApiService {
  final Dio _dio;

  /// قائمة الطلبات التي فشلت وتنتظر إعادة المحاولة.
  final List<Future Function()> _failedRequests = [];

  /// خريطة لتتبع وقت آخر طلب لكل endpoint لتفعيل خاصية الـ debounce.
  final Map<String, DateTime> _lastRequestTimes = {};

  /// تفعيل خاصية تأخير الطلبات لمنع التكرار.
  final bool enableRequestDebounce;
  final Duration requestDebounceDuration;

  /// مسارات يجب إيقاف الطباعة لها (عمليات الدفع)
  static const List<String> _suppressLogMarkers = <String>[
    '/transaction/google',
    'transaction/google',
    '/iap/verify',
    'iap/verify',
  ];

  ApiService({
    this.enableRequestDebounce = false,
    this.requestDebounceDuration = const Duration(seconds: 5),
  }) : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.connectionTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          sendTimeout: AppConfig.receiveTimeout,
          responseType: ResponseType.plain,
        )) {
    _initializeInterceptors();
    // _listenForConnectionChanges();
    // Debug-only workaround: bypass TLS verification for our API hosts on Android.
    // This addresses HandshakeException: CERTIFICATE_VERIFY_FAILED on some older devices
    // where the server's intermediate CA may not be recognized. DO NOT enable in release.
    // try {
    //   if (Platform.isAndroid) {
    //     final adapter = _dio.httpClientAdapter as IOHttpClientAdapter;
    //     adapter.onHttpClientCreate = (HttpClient client) {
    //       client.badCertificateCallback = (
    //         X509Certificate cert,
    //         String host,
    //         int port,
    //       ) {
    //         final isOurHost = host == 'lklklive.com' || host == 'api.lklklive.com';
    //         return kDebugMode && isOurHost;
    //       };
    //       return client;
    //     };
    //   }
    // } catch (_) {
    //   // Ignore adapter cast issues on non-IO platforms
    // }
    log("ApiService: تم تهيئة الخدمة بنجاح.");
  }

  /// Public helper to format Dio errors into user-friendly messages
  static String formatDioError(DioException error) {
    // Mirror logic from _handleError (kept for uploadFile) but exposed publicly
    if (error.error is SocketException) {
      return 'انقطع الاتصال، يرجى التحقق من الإنترنت والمحاولة لاحقًا.';
    }
    if (error.response != null) {
      final data = error.response?.data;
      final msg = _extractMessageSync(data);
      if (msg != null) return msg;

      if (error.response?.statusCode == 500) {
        return 'خطأ في الخادم، يرجى المحاولة لاحقًا.';
      }
      if (error.response?.statusCode == 429) {
        return 'تم تجاوز معدل الطلبات، يرجى الانتظار والمحاولة لاحقًا.';
      }
      if (error.response?.statusCode == 403) {
        return 'تم رفض الطلب بواسطة السيرفر (403). قد يكون السبب استخدام VPN أو حظر عنوان IP';
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة الاتصال بالخادم، يرجى المحاولة مجددًا.';
    } else if (error.type == DioExceptionType.unknown &&
        error.error is SocketException) {
      return 'فشل الاتصال، يرجى المحاولة مرة أخرى.';
    }
    return 'حدث خطأ غير متوقع';
  }

  /// دالة GET مع دعم الـ debounce وإعادة المحاولة.
  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters,
      int retries = 3,
      Duration? connectTimeout,
      Duration? receiveTimeout,
      CancelToken? cancelToken}) async {
    final bool suppress = _shouldSuppressLogsFor(endpoint);
    final key = _generateRequestKey(endpoint, queryParameters);
    if (enableRequestDebounce &&
        _shouldDelayRequest(key, requestDebounceDuration)) {
      if (!suppress) {
        log("GET: تأجيل الطلب للـ endpoint: $endpoint لمدة ${requestDebounceDuration.inSeconds} ثانية لتفادي التكرار.");
      }
      await Future.delayed(requestDebounceDuration);
    }
    _registerRequestTime(key);
    if (!suppress && AppLogger.isEnabled) {
      log("GET: بدء الطلب للـ endpoint: $endpoint مع المعاملات: $queryParameters");
    }
    final qStr = (queryParameters != null && queryParameters.isNotEmpty)
        ? ('?${Uri(queryParameters: queryParameters).query}')
        : '';
    final effectiveUrl =
        '${_dio.options.baseUrl}${endpoint.startsWith('/') ? '' : '/'}$endpoint$qStr';
    if (!suppress && AppLogger.isEnabled) {
      log("🌐 GET: Effective URL: $effectiveUrl");
    }

    return await _retryRequest(() async {
      final oldConnect = _dio.options.connectTimeout;
      final oldReceive = _dio.options.receiveTimeout;
      try {
        if (connectTimeout != null)
          _dio.options.connectTimeout = connectTimeout;
        if (receiveTimeout != null)
          _dio.options.receiveTimeout = receiveTimeout;
        final response = await _dio.get(
          endpoint,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
        );
        if (!suppress && AppLogger.isEnabled) {
          final preview = _previewForLog(response.data);
          log("GET: تم استلام الرد من $endpoint: $preview");
        }
        return response;
      } finally {
        // restore original timeouts
        _dio.options
          ..connectTimeout = oldConnect
          ..receiveTimeout = oldReceive;
      }
    }, retries, suppressLogs: suppress);
  }

  /// دالة POST مع دعم إعادة المحاولة وتفادي التكرار.
  Future<Response> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    int retries = 3,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    CancelToken? cancelToken,
  }) async {
    final bool suppress = _shouldSuppressLogsFor(endpoint);
    // استخدم مفتاح مبني على endpoint + queryParameters لتفادي تكرار نفس الطلب
    final key = _generateRequestKey(endpoint, queryParameters);
    if (enableRequestDebounce &&
        _shouldDelayRequest(key, requestDebounceDuration)) {
      final errorMsg =
          "POST: تم تأجيل الطلب لتفادي التكرار خلال ${requestDebounceDuration.inSeconds} ثانية.";
      if (!suppress) {
        log(errorMsg);
      }
      throw Exception(errorMsg);
    }
    _registerRequestTime(key);
    if (!suppress && AppLogger.isEnabled) {
      log("📤 POST: بدء الطلب للـ endpoint: $endpoint");
    }
    if (queryParameters != null && queryParameters.isNotEmpty) {
      if (!suppress && AppLogger.isEnabled) {
        log("📤 POST: سيتم إرسال المعاملات ضمن الرابط (Query Parameters) - عدد المعاملات: ${queryParameters.length}");
        // لا تطبع القيم لتجنّب تسريب بيانات ولتخفيف الحمل
        log("📤 POST: [QP keys] ${queryParameters.keys.take(10).join(', ')}");
      }
    }
    if (data != null) {
      if (!suppress && AppLogger.isEnabled) {
        // لا تطبع القيم لتجنّب طباعة أجسام كبيرة
        final int bodyFields = data.length;
        log("📤 POST: Body fields count: $bodyFields");
      }
    }

    return await _retryRequest(() async {
      if (!suppress && AppLogger.isEnabled) {
        log("🌐 POST: جاري الإرسال الفعلي إلى السيرفر...");
      }
      final qStr = (queryParameters != null && queryParameters.isNotEmpty)
          ? ('?${Uri(queryParameters: queryParameters).query}')
          : '';
      final effectiveUrl =
          '${_dio.options.baseUrl}${endpoint.startsWith('/') ? '' : '/'}$endpoint$qStr';
      if (!suppress && AppLogger.isEnabled) {
        log("🌐 POST: Effective URL: $effectiveUrl");
      }
      final oldConnect = _dio.options.connectTimeout;
      final oldReceive = _dio.options.receiveTimeout;
      if (connectTimeout != null) _dio.options.connectTimeout = connectTimeout;
      if (receiveTimeout != null) _dio.options.receiveTimeout = receiveTimeout;
      try {
        final response = await _dio.post(
          endpoint,
          data: data,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
        );
        if (!suppress && AppLogger.isEnabled) {
          log("📥 POST: تم استلام الرد من $endpoint");
          log("📥 POST: StatusCode: ${response.statusCode}");
          final preview = _previewForLog(response.data);
          log("📥 POST: Response: $preview");
        }
        return response;
      } finally {
        _dio.options
          ..connectTimeout = oldConnect
          ..receiveTimeout = oldReceive;
      }
    }, retries, suppressLogs: suppress);
  }

  /// دالة تحميل الملفات مع طباعة تفاصيل العملية.
  Future<Response> uploadFile(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? headers,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
      });
      log("UPLOAD: بدء رفع الملف من ${file.path} للـ endpoint: $endpoint");
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );
      log("UPLOAD: تم رفع الملف بنجاح: ${response.data}");
      return response;
    } on DioException catch (e) {
      final errorMessage = _handleError(e);
      log("UPLOAD: فشل رفع الملف: $errorMessage");
      throw DioException(
        requestOptions: e.requestOptions,
        error: errorMessage,
        response: e.response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  /// إنشاء مفتاح فريد للطلب بناءً على endpoint والمعاملات.
  String _generateRequestKey(
      String endpoint, Map<String, dynamic>? queryParameters) {
    if (queryParameters == null) return endpoint;
    return '$endpoint?${queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}';
  }

  /// التحقق من ما إذا كان يجب تأجيل الطلب بناءً على آخر وقت طلب.
  bool _shouldDelayRequest(String key, Duration duration) {
    final now = DateTime.now();
    if (_lastRequestTimes.containsKey(key)) {
      final lastTime = _lastRequestTimes[key]!;
      if (now.difference(lastTime) < duration) return true;
    }
    return false;
  }

  /// تسجيل وقت الطلب الحالي.
  void _registerRequestTime(String key) {
    _lastRequestTimes[key] = DateTime.now();
  }

  /// تهيئة interceptors الخاصة بـ Dio لإضافة التوكن والتحقق من الاتصال.
  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // التحقق من الاتصال
          // final connectivityResult = await Connectivity().checkConnectivity();
          // if (connectivityResult == ConnectivityResult.none) {
          //   log("INTERCEPTOR: لا يوجد اتصال، إضافة الطلب إلى قائمة الفشل.");
          //   _addToFailedRequests(() async {
          //     return await _dio.request(options.path,
          //         options: Options(
          //           method: options.method,
          //           headers: options.headers,
          //           extra: options.extra,
          //           responseType: options.responseType,
          //         ),
          //         data: options.data,
          //         queryParameters: options.queryParameters);
          //   });
          //   return handler.reject(
          //     DioError(
          //       requestOptions: options,
          //       error: 'لا يوجد اتصال بالإنترنت.',
          //     ),
          //   );
          // }

          // إضافة توكن التوثيق إن وجد
          final token = await AuthService.getTokenFromSharedPreferences();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // تأكيد طلب JSON دائماً لتفادي صفحات HTML في الأخطاء
          options.headers['Accept'] =
              options.headers['Accept'] ?? 'application/json';
          // Mask token in logs for security
          final masked = (token == null || token.length < 8)
              ? (token == null
                  ? 'null'
                  : '${token.substring(0, token.length)}***')
              : '${token.substring(0, 6)}***${token.substring(token.length - 4)}';
          if (AppLogger.isEnabled && !_shouldSuppressLogsFor(options.path)) {
            final dataPreview = _previewForLog(options.data);
            log("INTERCEPTOR: auth=Bearer $masked - الطلب: ${options.path} - data=$dataPreview");
          }
          handler.next(options);
        },
      ),
    );
  }

  /// آلية إعادة المحاولة مع Exponential Backoff وطباعة تفاصيل المحاولات.
  Future<Response> _retryRequest(
      Future<Response> Function() request, int retries,
      {bool suppressLogs = false}) async {
    int delaySeconds = 3;
    DioException? lastException;

    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        if (!suppressLogs && AppLogger.isEnabled) {
          log("RETRY: محاولة رقم ${attempt + 1} من $retries");
        }
        return await request();
      } on DioException catch (e) {
        lastException = e;
        final errorMessage = _handleError(e);
        if (!suppressLogs && AppLogger.isEnabled) {
          log("RETRY: خطأ في محاولة ${attempt + 1}: $errorMessage");
          log("RETRY: DioException type: ${e.type}, statusCode: ${e.response?.statusCode}");
          final preview = _previewForLog(e.response?.data);
          log("RETRY: Response: $preview");
          log("RETRY: Error: ${e.error}");
        }

        final isTimeout = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout;
        if ((e.response?.statusCode == 429 ||
                _isConnectionError(e) ||
                isTimeout) &&
            attempt < retries - 1) {
          if (!suppressLogs && AppLogger.isEnabled) {
            log("RETRY: الانتظار لمدة $delaySeconds ثانية (+jitter) قبل المحاولة التالية.");
          }
          final jitterMs = math.Random().nextInt(700); // 0..699ms
          await Future.delayed(Duration(seconds: delaySeconds) + Duration(milliseconds: jitterMs));
          delaySeconds *= 2;
          continue;
        } else {
          _addToFailedRequests(request);
          if (!suppressLogs) {
            log("RETRY: إضافة الطلب الفاشل لقائمة المحاولة لاحقاً.");
          }
          rethrow;
        }
      } catch (e, st) {
        // Catch any other non-Dio exceptions
        if (!suppressLogs && AppLogger.isEnabled) {
          log("RETRY: خطأ غير متوقع في محاولة ${attempt + 1}: $e");
          log("RETRY: Stack trace: $st");
        }
        if (attempt < retries - 1) {
          await Future.delayed(Duration(seconds: delaySeconds));
          delaySeconds *= 2;
          continue;
        } else {
          rethrow;
        }
      }
    }

    // If we exhausted all retries, throw the last exception
    final finalError = "فشل الحصول على البيانات بعد $retries محاولات.";
    if (!suppressLogs && AppLogger.isEnabled) {
      log("RETRY: $finalError");
    }
    if (lastException != null) {
      throw lastException;
    }
    throw Exception(finalError);
  }

  /// إضافة دالة الطلب إلى قائمة الطلبات الفاشلة.
  void _addToFailedRequests(Future Function() request) {
    _failedRequests.add(request);
    log("FAILED REQUEST: تم إضافة الطلب إلى قائمة الفشل. إجمالي الطلبات الفاشلة: ${_failedRequests.length}");
  }

  /// التعامل مع أخطاء Dio وطباعة تفاصيلها.
  String _handleError(DioException error) {
    if (error.error is SocketException) {
      return 'انقطع الاتصال، يرجى التحقق من الإنترنت والمحاولة لاحقًا.';
    }
    if (error.response != null) {
      final data = error.response?.data;
      final msg = _extractMessageSync(data);
      if (msg != null) return msg;

      if (error.response?.statusCode == 500) {
        return 'خطأ في الخادم، يرجى المحاولة لاحقًا.';
      }
      if (error.response?.statusCode == 429) {
        return 'تم تجاوز معدل الطلبات، يرجى الانتظار والمحاولة لاحقًا.';
      }
      if (error.response?.statusCode == 403) {
        return 'تم رفض الطلب بواسطة السيرفر (403). قد يكون السبب استخدام VPN أو حظر عنوان IP';
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة الطلب، يرجى المحاولة مرة أخرى.';
    } else if (error.type == DioExceptionType.unknown &&
        error.error is SocketException) {
      return 'فشل الاتصال، يرجى المحاولة مرة أخرى.';
    }

    // Safe fallback - convert everything to String
    try {
      final responseData = error.response?.data;
      if (responseData is Map && responseData.containsKey('message')) {
        return responseData['message'].toString();
      }
    } catch (_) {}

    return 'حدث خطأ غير متوقع';
  }

  /// التحقق مما إذا كان الخطأ مرتبطاً بمشكلة الاتصال.
  bool _isConnectionError(DioException error) {
    if (error.error is SocketException) return true;
    if (error.error is HttpException) return true;
    // بعض طبقات النقل قد تعطي رسائل نصية فقط
    final msg = (
            (error.message ?? '').toLowerCase() + ' ' +
            (error.error?.toString().toLowerCase() ?? ''))
        .trim();
    if (msg.contains('unexpected eof') ||
        msg.contains('incomplete envelope') ||
        msg.contains('protocol error') ||
        msg.contains('connection closed') ||
        msg.contains('connection reset') ||
        msg.contains('broken pipe')) {
      return true;
    }
    return false;
  }

  // Lightweight log preview to avoid logging huge payloads (reduces jank/ANR).
  static String _previewForLog(Object? data, {int max = 300}) {
    try {
      if (data == null) return 'null';
      if (data is String) {
        final len = data.length;
        final snippet = len > max ? ('${data.substring(0, max)}…') : data;
        return 'String(len=$len) ' + snippet;
      }
      if (data is List) {
        return 'List(len=${data.length})';
      }
      if (data is Map) {
        return 'Map(len=${data.length})';
      }
      return data.runtimeType.toString();
    } catch (_) {
      return 'unavailable';
    }
  }

  // Synchronous extraction of 'message' from error payload.
  // Avoids heavy jsonDecode on very large strings to keep UI responsive.
  static String? _extractMessageSync(Object? data) {
    try {
      if (data == null) return null;
      if (data is Map) {
        final msg = data['message'];
        if (msg != null) return msg.toString();
        return null;
      }
      if (data is String && data.isNotEmpty) {
        // Only parse small bodies synchronously.
        if (data.length <= 4000) {
          final parsed = jsonDecode(data);
          if (parsed is Map && parsed.containsKey('message')) {
            return parsed['message'].toString();
          }
        }
        // For large non-JSON or non-parsed bodies, return short snippet.
        if (data.length < 200) return data;
      }
    } catch (_) {}
    return null;
  }

  /// تحديد ما إذا كان يجب إيقاف الطباعة لهذا المسار (غالباً عمليات الدفع)
  bool _shouldSuppressLogsFor(String path) {
    try {
      final p = path.toLowerCase();
      for (final marker in _suppressLogMarkers) {
        if (p.contains(marker)) return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// الاستماع لتغييرات الاتصال وإعادة محاولة الطلبات الفاشلة عند استعادة الاتصال.
  // void _listenForConnectionChanges() {
  //   // Connectivity()
  //   //     .onConnectivityChanged
  //   //     .listen((List<ConnectivityResult> results) {

  // }
}
