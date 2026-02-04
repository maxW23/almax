import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:persistent_device_id/persistent_device_id.dart';

class DeviceInfoHelper {
  static Future<String?> getIpAddress() async {
    try {
      final ipAddress = IpAddress(type: RequestType.json);
      final data = await ipAddress.getIpAddress();
      if (data is Map && data.containsKey('ip')) {
        return (data['ip'] as String);
      } else if (data is String) {
        return data;
      } else {
        return data?.toString();
      }
    } on IpAddressException {
      return null;
    }
  }

  static Future<int> getAppVersion() async {
    //vvvv1234
    const version = 58;
    return version;
  }
}

class AuthResult {
  final String? token;
  final UserEntity? user;
  final String? errorMessage;
  final bool isBanned;

  AuthResult({
    this.token,
    this.user,
    this.errorMessage,
    this.isBanned = false,
  });

  bool get isSuccess => token != null && user != null && !isBanned;
}

class AuthApiClient {
  final ApiService _apiService = ApiService();

  Future<AuthResult?> authenticateUserGoogle(
      UserEntity user, RoomCubit roomCubit, BuildContext context) async {
    final deviceId = await PersistentDeviceId.getDeviceId();
    final ip = await DeviceInfoHelper.getIpAddress();
    final version = await DeviceInfoHelper.getAppVersion();
    final encodedName = Uri.encodeComponent(user.name?.trim() ?? "user");

    final endpoint =
        '/auth/login?email=${user.email}&id=${user.iduser}&name=$encodedName&img=${user.img}&deviceId=$deviceId&ip=$ip&version=$version';

    log("DeviceId: $deviceId --- IP: $ip -- Version: $version");

    return await _serviceAuth(endpoint, "Google");
  }

  Future<AuthResult?> authenticateUser(RoomCubit roomCubit,
      BuildContext context, String email, String password) async {
    final endpoint = '/auth/login2?email=$email&password=$password';

    await AuthService.saveUserEmailAndPasswordToSharedPreferences(
        email, password);

    return await _serviceAuth(endpoint, "email");
  }

  Future<AuthResult?> _serviceAuth(String endpoint, String type) async {
    try {
      final response = await _apiService.post(endpoint);
      log("Response data: ${response.data}");

      if (response.statusCode == 200) {
        final responseData =
            response.data is String ? jsonDecode(response.data) : response.data;

        // تحقق من وجود رسالة خطأ أو حظر
        String? serverMessage;
        if (responseData is String) {
          serverMessage = responseData;
        } else if (responseData is Map && responseData.containsKey('message')) {
          serverMessage = responseData['message']?.toString();
        }

        final isBanned = serverMessage?.contains("محظور") == true;

        if (isBanned) {
          await AuthService.clearUserAndTokenFromSharedPreferences();
          return AuthResult(
            isBanned: true,
            errorMessage: serverMessage ?? 'محظور من التطبيق',
          );
        }

        // لو فيه رسالة خطأ أخرى (مثلاً تحت مفتاح error أو similar)
        if (serverMessage != null && serverMessage.isNotEmpty && !isBanned) {
          // هنا لو تريد اعتبار أي رسالة ليست حظر رسائل خطأ عامة:
          // لكن حسب منطقك إذا ما في حظر فاكيد البيانات صحيحة، لذلك قد تتجاهلها أو تخزنها.
        }

        try {
          final token = responseData['token']?.toString();
          if (token == null) throw Exception("Token is null");

          await AuthService.saveTokenToSharedPreferences(token);

          final userAuth = responseData['user'] != null
              ? UserEntity.fromMap(responseData['user'] as Map<String, dynamic>)
              : null;

          if (userAuth != null) {
            await AuthService.saveUserToSharedPreferences(userAuth);
            await AuthService.saveUserTypeToSharedPreferences(type);
          } else {
            throw Exception("User data is null");
          }

          return AuthResult(token: token, user: userAuth);
        } catch (e) {
          log("Error parsing user/token: ${e.toString()}");
          await AuthService.clearUserAndTokenFromSharedPreferences();
          return AuthResult(errorMessage: "فشل في قراءة بيانات المستخدم");
        }
      } else {
        // في حالة كود غير 200 حاول استخراج رسالة الخطأ إن وجدت
        String? serverMessage;
        if (response.data != null) {
          if (response.data is String) {
            serverMessage = response.data;
          } else if (response.data is Map &&
              response.data.containsKey('message')) {
            serverMessage = response.data['message']?.toString();
          }
        }
        await AuthService.clearUserAndTokenFromSharedPreferences();
        return AuthResult(
            errorMessage: serverMessage ?? "فشل في الاتصال بالخادم");
      }
    } catch (e) {
      log("Network or unexpected error: ${e.toString()}");
      await AuthService.clearUserAndTokenFromSharedPreferences();
      return AuthResult(errorMessage: "حدث خطأ أثناء الاتصال بالخادم");
    }
  }
}
