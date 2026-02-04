import 'package:dio/dio.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/features/invitations/data/models/invite_profit_response.dart';
import 'package:lklk/features/invitations/data/models/invite_person.dart';

class InvitationsApiService {
  final ApiService _apiService;
  InvitationsApiService(this._apiService);

  Future<InviteProfitResponse> getInviteProfit({String? languageCode}) async {
    try {
      final ln =
          (languageCode == 'ar' || languageCode == 'en') ? languageCode : 'en';
      final Response resp = await _apiService.get(
        '/count/profit',
        queryParameters: {'ln': ln},
      );
      final body = resp.data?.toString() ?? '{}';
      final parsed = InviteProfitResponse.fromResponseBody(body);
      log('[InvitationsApiService] /count/profit -> people=${parsed.people}, profit=${parsed.profit}');
      return parsed;
    } on DioException catch (e) {
      log('[InvitationsApiService] error: status=${e.response?.statusCode}, data=${e.response?.data}');
      rethrow;
    } catch (e) {
      log('[InvitationsApiService] error: $e');
      rethrow;
    }
  }

  Future<List<InvitePerson>> getInvitePeople() async {
    try {
      final Response resp = await _apiService.get(
        '/count/invite/peopel',
      );
      final body = resp.data?.toString() ?? '{}';
      final parsed = InvitePerson.listFromResponseBody(body);
      log('[InvitationsApiService] /count/invite/peopel -> count=${parsed.length}');
      return parsed;
    } on DioException catch (e) {
      log('[InvitationsApiService] error(peopel): status=${e.response?.statusCode}, data=${e.response?.data}');
      rethrow;
    } catch (e) {
      log('[InvitationsApiService] error(peopel): $e');
      rethrow;
    }
  }
}
