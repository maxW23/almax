import 'package:dio/dio.dart';
import 'package:lklk/core/services/api_service.dart';

class TasksApiService {
  final ApiService _apiService;

  TasksApiService(this._apiService);

  // GET /user/mession - قائمة المهمات (الرابط الصحيح)
  // يرسل بارامتر ln مع لغة المستخدم (ar للعربية، en للإنجليزية)
  Future<Response> getUserMissions({String? languageCode}) async {
    try {
      // اجعل ln ضمن الـ endpoint مباشرة
      final ln =
          (languageCode == 'en' || languageCode == 'ar') ? languageCode : 'ar';
      final endpoint = '/user/mession?ln=$ln';

      final resp = await _apiService.get(endpoint);
      // ignore: avoid_print
      print('[TasksApiService] GET $endpoint -> ${resp.data}');
      return resp;
    } on DioException catch (e) {
      // ignore: avoid_print
      print(
          '[TasksApiService] GET user/mession error: status=${e.response?.statusCode}, data=${e.response?.data}');
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('[TasksApiService] GET user/mession error: $e');
      rethrow;
    }
  }

  // POST cointo/point - تحويل من كوينز الى العملة الجديدة
  Future<Response> convertCoinsToPoints({required int amount}) async {
    return await _apiService.post(
      'cointo/point',
      data: {'amount': amount},
    );
  }

  // GET change/wp
  Future<Response> getChangeWp() async {
    return await _apiService.get('change/wp');
  }

  // Additional endpoints for complete functionality
  Future<Response> claimTaskReward({required String taskId}) async {
    return await _apiService.post(
      'user/mission/claim',
      data: {'taskId': taskId},
    );
  }

  Future<Response> getUserLevel() async {
    return await _apiService.get('user/level');
  }

  Future<Response> getRankings({
    required String type, // daily, weekly, monthly
    required int page,
    required int limit,
  }) async {
    return await _apiService.get(
      'rankings',
      queryParameters: {
        'type': type,
        'page': page,
        'limit': limit,
      },
    );
  }
}
