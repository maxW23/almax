import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as dev;

/// خدمة التخزين الآمن للبيانات الحساسة مثل التوكن
/// تستخدم flutter_secure_storage للتشفير الآمن
class SecureStorageService {
  // إعدادات التخزين الآمن
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'lklk_secure_prefs',
      preferencesKeyPrefix: 'lklk_',
    ),
    iOptions: IOSOptions(
      groupId: 'group.com.lklklive.lklk',
      accountName: 'lklk_keychain',
      synchronizable: true,
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // مفاتيح التخزين
  static const String _tokenKey = 'secure_token';
  static const String _userKey = 'secure_user';
  static const String _emailKey = 'secure_email';
  static const String _passwordKey = 'secure_password';
  static const String _userTypeKey = 'secure_user_type';

  // ==================== طرق التوكن الآمنة ====================

  /// حفظ التوكن بشكل آمن
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      dev.log("🔐 [SECURE_STORAGE] Token saved securely",
          name: 'SecureStorage');
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to save token: $e",
          name: 'SecureStorage');
      rethrow;
    }
  }

  /// جلب التوكن الآمن
  static Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        dev.log("🔓 [SECURE_STORAGE] Token retrieved successfully",
            name: 'SecureStorage');
      } else {
        dev.log("🔍 [SECURE_STORAGE] No token found", name: 'SecureStorage');
      }
      return token;
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to get token: $e",
          name: 'SecureStorage');
      return null;
    }
  }

  /// حذف التوكن
  static Future<void> removeToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      dev.log("🗑️ [SECURE_STORAGE] Token removed", name: 'SecureStorage');
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to remove token: $e",
          name: 'SecureStorage');
    }
  }

  // ==================== طرق بيانات المستخدم الآمنة ====================

  /// حفظ بيانات المستخدم بشكل آمن
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      final userJson = jsonEncode(userData);
      await _secureStorage.write(key: _userKey, value: userJson);
      dev.log("👤 [SECURE_STORAGE] User data saved securely",
          name: 'SecureStorage');
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to save user data: $e",
          name: 'SecureStorage');
      rethrow;
    }
  }

  /// جلب بيانات المستخدم الآمنة
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        dev.log("👤 [SECURE_STORAGE] User data retrieved successfully",
            name: 'SecureStorage');
        return userData;
      }
      dev.log("👤 [SECURE_STORAGE] No user data found", name: 'SecureStorage');
      return null;
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to get user data: $e",
          name: 'SecureStorage');
      return null;
    }
  }

  /// حذف بيانات المستخدم
  static Future<void> removeUser() async {
    try {
      await _secureStorage.delete(key: _userKey);
      dev.log("👤 [SECURE_STORAGE] User data removed", name: 'SecureStorage');
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to remove user data: $e",
          name: 'SecureStorage');
    }
  }

  // ==================== طرق بيانات الاعتماد الآمنة ====================

  /// حفظ البريد الإلكتروني بشكل آمن
  static Future<void> saveEmail(String email) async {
    try {
      await _secureStorage.write(key: _emailKey, value: email);
      dev.log("📧 [SECURE_STORAGE] Email saved securely",
          name: 'SecureStorage');
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to save email: $e",
          name: 'SecureStorage');
      rethrow;
    }
  }

  /// جلب البريد الإلكتروني الآمن
  static Future<String?> getEmail() async {
    try {
      return await _secureStorage.read(key: _emailKey);
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to get email: $e",
          name: 'SecureStorage');
      return null;
    }
  }

  /// حفظ كلمة المرور بشكل آمن
  static Future<void> savePassword(String password) async {
    try {
      await _secureStorage.write(key: _passwordKey, value: password);
      dev.log("🔑 [SECURE_STORAGE] Password saved securely",
          name: 'SecureStorage');
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to save password: $e",
          name: 'SecureStorage');
      rethrow;
    }
  }

  /// جلب كلمة المرور الآمنة
  static Future<String?> getPassword() async {
    try {
      return await _secureStorage.read(key: _passwordKey);
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to get password: $e",
          name: 'SecureStorage');
      return null;
    }
  }

  /// حفظ نوع المستخدم بشكل آمن
  static Future<void> saveUserType(String userType) async {
    try {
      await _secureStorage.write(key: _userTypeKey, value: userType);
      dev.log("🏷️ [SECURE_STORAGE] User type saved securely",
          name: 'SecureStorage');
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to save user type: $e",
          name: 'SecureStorage');
      rethrow;
    }
  }

  /// جلب نوع المستخدم الآمن
  static Future<String?> getUserType() async {
    try {
      return await _secureStorage.read(key: _userTypeKey);
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to get user type: $e",
          name: 'SecureStorage');
      return null;
    }
  }

  // ==================== طرق التنظيف ====================

  /// مسح جميع البيانات الآمنة
  static Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      dev.log("🧹 [SECURE_STORAGE] All secure data cleared",
          name: 'SecureStorage');
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to clear all data: $e",
          name: 'SecureStorage');
    }
  }

  /// مسح بيانات محددة
  static Future<void> clearUserCredentials() async {
    try {
      await removeToken();
      await removeUser();
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
      await _secureStorage.delete(key: _userTypeKey);
      dev.log("🧹 [SECURE_STORAGE] User credentials cleared",
          name: 'SecureStorage');
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to clear user credentials: $e",
          name: 'SecureStorage');
    }
  }

  // ==================== طرق المساعدة ====================

  /// التحقق من وجود التوكن
  static Future<bool> hasToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to check token existence: $e",
          name: 'SecureStorage');
      return false;
    }
  }

  /// التحقق من وجود بيانات المستخدم
  static Future<bool> hasUser() async {
    try {
      final user = await _secureStorage.read(key: _userKey);
      return user != null && user.isNotEmpty;
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to check user existence: $e",
          name: 'SecureStorage');
      return false;
    }
  }

  /// جلب جميع المفاتيح المحفوظة
  static Future<Map<String, String>> getAllSecureData() async {
    try {
      final allData = await _secureStorage.readAll();
      dev.log("📋 [SECURE_STORAGE] Retrieved ${allData.length} secure items",
          name: 'SecureStorage');
      return allData;
    } catch (e) {
      dev.log("❌ [SECURE_STORAGE] Failed to get all data: $e",
          name: 'SecureStorage');
      return {};
    }
  }

  /// معلومات حالة التخزين الآمن
  static Future<Map<String, dynamic>> getStorageInfo() async {
    return {
      'hasToken': await hasToken(),
      'hasUser': await hasUser(),
      'totalItems': (await getAllSecureData()).length,
      'storageType': 'flutter_secure_storage',
      'platform': 'Android/iOS Keychain',
    };
  }
}
