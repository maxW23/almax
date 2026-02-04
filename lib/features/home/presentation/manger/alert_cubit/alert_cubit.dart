import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/realtime/notification_realtime_service.dart';

import 'alert_state.dart';

class AlertCubit extends Cubit<AlertState> {
  AlertCubit() : super(AlertInitial());

  // منع الاستدعاء المتكرر خلال نافذة زمنية قصيرة
  DateTime? _lastFetchedAt;
  final Duration _ttl = const Duration(seconds: 15);
  bool _fetchedOnce = false;

  Future<void> fetchAlerts() async {
    // اجلب مرة واحدة فقط عند بداية التطبيق
    if (_fetchedOnce) {
      return;
    }
    // إذا تم الجلب مؤخراً، لا تعيد الجلب فوراً لتقليل الاستهلاك
    if (_lastFetchedAt != null &&
        DateTime.now().difference(_lastFetchedAt!) < _ttl) {
      // لا تغيّر الحالة الحالية حتى لا تومض الـ UI بلا داعٍ
      return;
    }
    emit(AlertLoading());

    try {
      final response = await sl<ApiService>().get('/user/new/alert');
      log("AlertCubit AlertCubit ${response.data}");
      if (response.statusCode == 200) {
        // Parse the JSON string into a Map
        final Map<String, dynamic> data = jsonDecode(response.data);

        emit(AlertLoaded(
          massage: data['Massage'] as int, // Use correct key name
          relation: data['relation'] as int,
          friendRequest: data['friendrequest'] as int,
          visitorList: data['visitorlist'] as int,
        ));
        // Seed the realtime counters once at app start
        try {
          await NotificationRealtimeService.instance.setBaselineCounts(
            chat: data['Massage'] as int?,
            visitor: data['visitorlist'] as int?,
            friend: data['friendrequest'] as int?,
            relation: data['relation'] as int?,
          );
        } catch (_) {}
        _lastFetchedAt = DateTime.now();
        _fetchedOnce = true;
      } else {
        emit(AlertError(message: "Failed to load alerts"));
      }
    } catch (e) {
      emit(AlertError(message: "Error: ${e.toString()}"));
    }
  }
}
