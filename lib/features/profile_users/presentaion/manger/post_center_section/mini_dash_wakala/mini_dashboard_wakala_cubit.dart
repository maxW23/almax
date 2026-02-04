import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';

import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:bloc/bloc.dart';
part 'mini_dashboard_wakala_state.dart';

class MiniDashboardWakalaCubit extends Cubit<MiniDashboardState> {
  final ApiService _apiService;
  List<UserEntity> _users = [];

  MiniDashboardWakalaCubit({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(const MiniDashboardState());

  Future<void> loadUsers() async {
    emit(state.copyWith(status: MiniDashboardStatus.loading));
    try {
      final response = await _apiService.get('/mini_dashboard');
      if (response.statusCode == 500) {
        log('Server error: 500', name: 'loadUsers');
        emit(state.copyWith(
          status: MiniDashboardStatus.error,
          message: 'خطأ في الخادم (500)',
        ));
        return;
      }

      final data = json.decode(response.data as String) as List<dynamic>;
      _users = data.map((e) => UserEntity.fromJson(e)).toList();
      emit(state.copyWith(
        status: MiniDashboardStatus.loaded,
        users: _users,
        message: 'تم تحميل البيانات بنجاح',
      ));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 500) {
        log('DioError 500: ${e.message}', name: 'loadUsers');
        emit(state.copyWith(
          status: MiniDashboardStatus.error,
          message: 'خطأ في الخادم (500)',
        ));
      } else {
        log('DioError: ${e.message}', name: 'loadUsers');
        emit(state.copyWith(
          status: MiniDashboardStatus.error,
          message: 'فشل في تحميل البيانات',
        ));
      }
    } catch (e) {
      log('Unknown error: $e', name: 'loadUsers');
      emit(state.copyWith(
        status: MiniDashboardStatus.error,
        message: 'حدث خطأ غير متوقع',
      ));
    }
  }

  Future<void> acceptUser(String id) async {
    emit(state.copyWith(
      status: MiniDashboardStatus.acceptUserLoading,
      userId: id,
    ));

    try {
      final response = await _apiService.get('/add/wakel/accept/$id');
      // سجِّل القيم للتصحيح عند الحاجة
      log('acceptUser raw data: ${response.data}', name: 'acceptUser');
      log('acceptUser data type: ${response.data.runtimeType}',
          name: 'acceptUser');

      final result = (response.data as String).trim();
      if (result == 'done') {
        emit(state.copyWith(
          status: MiniDashboardStatus.acceptUserSuccess,
          userId: id,
          message: 'تم قبول المستخدم بنجاح',
        ));
      } else {
        log('acceptUserUnexpected: ${response.data}', name: 'acceptUser');

        emit(state.copyWith(
          status: MiniDashboardStatus.acceptUserError,
          userId: id,
          message: 'فشل في قبول المستخدم: $result',
        ));
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      emit(state.copyWith(
        status: MiniDashboardStatus.acceptUserError,
        userId: id,
        message: status == 500 ? 'خطأ في الخادم (500)' : 'فشل في قبول المستخدم',
      ));
    }
  }

  Future<void> deleteUser(String id) async {
    emit(state.copyWith(
      status: MiniDashboardStatus.deleteUserLoading,
      userId: id,
    ));

    try {
      final response = await _apiService.get('/del/wakel/accept/$id');
      if (response.statusCode == 500) {
        log('Server error: 500', name: 'deleteUser');
        emit(state.copyWith(
          status: MiniDashboardStatus.deleteUserError,
          userId: id,
          message: 'خطأ في الخادم (500)',
        ));
        return;
      }

      if (response.data == 'done') {
        log('deleteUserSuccess: ${response.data}', name: 'deleteUser');
        emit(state.copyWith(
          status: MiniDashboardStatus.deleteUserSuccess,
          userId: id,
          message: 'تم حذف المستخدم بنجاح',
        ));
      } else {
        log('deleteUserUnexpected: ${response.data}', name: 'deleteUser');
        emit(state.copyWith(
          status: MiniDashboardStatus.deleteUserError,
          userId: id,
          message: 'فشل في حذف المستخدم',
        ));
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      log('DioError: ${e.message}', name: 'deleteUser');
      emit(state.copyWith(
        status: status == 500
            ? MiniDashboardStatus.deleteUserError
            : MiniDashboardStatus.deleteUserError,
        userId: id,
        message: status == 500 ? 'خطأ في الخادم (500)' : 'فشل في حذف المستخدم',
      ));
    } catch (e) {
      log('Unknown error: $e', name: 'deleteUser');
      emit(state.copyWith(
        status: MiniDashboardStatus.deleteUserError,
        userId: id,
        message: 'حدث خطأ غير متوقع',
      ));
    }
  }
}
