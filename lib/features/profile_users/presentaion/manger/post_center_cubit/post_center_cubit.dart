import 'dart:convert';

import 'package:lklk/features/profile_users/domain/entities/wakala_info.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:lklk/core/services/api_service.dart'; // استيراد ApiService

part 'post_center_state.dart';

class PostCenterCubit extends Cubit<PostCenterState> {
  final ApiService _apiService = ApiService(); // إنشاء كائن من ApiService

  PostCenterCubit() : super(PostCenterInitial());

  Future<void> fetchWakalaInfo() async {
    const endpoint = '/wakala/info'; // endpoint المناسب

    try {
      final response =
          await _apiService.get(endpoint); // استخدام دالة get من ApiService

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);

        if (data is Map<String, dynamic>) {
          final wakalaInfo = WakalaInfo.fromJson(data);
          emit(PostCenterSuccess(wakalaInfo));
        } else {
          emit(PostCenterError("Invalid response format"));
        }
      } else {
        emit(PostCenterError("Failed to fetch data"));
      }
    } catch (e) {
      emit(PostCenterError("Error: $e"));
    }
  }
}
