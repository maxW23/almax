import 'package:dio/dio.dart';
import 'package:lklk/core/config/app_config.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/utils/logger.dart';

abstract class LiveKitTokenApi {
  Future<String?> fetchToken({required String identity, required String roomId});
}

class LiveKitTokenApiImpl implements LiveKitTokenApi {
  final ApiService _api;
  LiveKitTokenApiImpl(this._api);

  @override
  Future<String?> fetchToken({required String identity, required String roomId}) async {
    try {
      // Using ApiService baseUrl (AppConfig.apiBaseUrl)
      final Response resp = await _api.get(
        '/livekit/token',
        queryParameters: {
          'identity': identity,
          'room': roomId,
        },
        retries: 2,
      );
      final data = resp.data;
      if (data is Map && data['token'] is String) return data['token'] as String;
      if (data is String && data.contains('.')) return data;
      if (AppLogger.isEnabled) {
        log('LiveKitTokenApi: Unexpected token response type: ${data.runtimeType}');
      }
    } catch (e) {
      if (AppLogger.isEnabled) {
        log('LiveKitTokenApi: error fetching token: $e');
      }
    }
    return null;
  }
}
