import 'package:shared_preferences/shared_preferences.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/core/services/secure_storage_service.dart';
import 'dart:convert';
import 'dart:developer' as dev;

class AuthService {
  // Cache في الذاكرة لتحسين الأداء
  static String? _cachedToken;
  static DateTime? _tokenCacheTime;
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// جلب التوكن من Cache أو التخزين الآمن مع fallback للـ SharedPreferences
  static Future<String?> getTokenFromSharedPreferences() async {
    // التحقق من الـ cache أولاً
    if (_isCacheValid() && _cachedToken != null) {
      dev.log("🚀 [AUTH_SERVICE] Token retrieved from cache",
          name: 'AuthService');
      return _cachedToken;
    }

    try {
      // محاولة جلب التوكن من التخزين الآمن
      final token = await SecureStorageService.getToken();
      if (token != null) {
        _updateTokenCache(token);
        dev.log("✅ [AUTH_SERVICE] Token retrieved from secure storage",
            name: 'AuthService');
        return token;
      }
      // في حال عدم وجود توكن في التخزين الآمن: محاولة هجرة التوكن من SharedPreferences مرة واحدة
      try {
        final prefs = await SharedPreferences.getInstance();
        final legacyToken = prefs.getString('token');
        if (legacyToken != null && legacyToken.trim().isNotEmpty) {
          // انقل إلى التخزين الآمن ثم احذف النسخة القديمة
          await SecureStorageService.saveToken(legacyToken);
          await prefs.remove('token');
          _updateTokenCache(legacyToken);
          dev.log(
              "🔁 [AUTH_SERVICE] Migrated token from SharedPreferences to secure storage",
              name: 'AuthService');
          return legacyToken;
        }
      } catch (migrateErr) {
        dev.log(
            "⚠️ [AUTH_SERVICE] Migration check failed (SharedPreferences): $migrateErr",
            name: 'AuthService');
      }
      return null;
    } catch (e) {
      dev.log("❌ [AUTH_SERVICE] Failed to get token: $e", name: 'AuthService');
      return null;
    }
  }

  /// التحقق من صحة الـ cache
  static bool _isCacheValid() {
    if (_tokenCacheTime == null) return false;
    return DateTime.now().difference(_tokenCacheTime!) < _cacheExpiry;
  }

  /// تحديث الـ cache للتوكن
  static void _updateTokenCache(String token) {
    _cachedToken = token;
    _tokenCacheTime = DateTime.now();
  }

  /// مسح الـ cache
  static void _clearCache() {
    _cachedToken = null;
    _tokenCacheTime = null;
  }

  /// التحقق من صحة التوكن
  /// ملاحظة: بعض الأنظمة تستخدم JWT أو رموز بدون أي فواصل خاصة.
  /// نعتمد تحققاً مبسطاً: غير فارغ وطوله معقول.
  static bool _isValidToken(String? token) {
    final t = token?.trim();
    if (t == null || t.isEmpty) return false;
    // قبول رموز حديثة (مثل JWT) بطول >= 8
    return t.length >= 8;
  }

  /// حفظ التوكن في التخزين الآمن مع fallback للـ SharedPreferences
  static Future<void> saveTokenToSharedPreferences(String? token) async {
    final trimmed = token?.trim();
    if (!_isValidToken(trimmed)) {
      dev.log("❌ [AUTH_SERVICE] Invalid token format, not saving",
          name: 'AuthService');
      return;
    }

    try {
      // محاولة حفظ التوكن في التخزين الآمن
      await SecureStorageService.saveToken(trimmed!);
      _updateTokenCache(trimmed); // تحديث الـ cache
      dev.log("✅ [AUTH_SERVICE] Token saved securely and cached",
          name: 'AuthService');
    } catch (e) {
      dev.log("❌ [AUTH_SERVICE] Failed to save token securely: $e",
          name: 'AuthService');
    }
  }

  /// حفظ بيانات المستخدم في التخزين الآمن مع fallback للـ SharedPreferences
  static Future<void> saveUserToSharedPreferences(UserEntity? user) async {
    if (user == null) return;

    try {
      // محاولة حفظ بيانات المستخدم في التخزين الآمن
      await SecureStorageService.saveUser(user.toMap());
      dev.log("✅ [AUTH_SERVICE] User data saved securely", name: 'AuthService');
    } catch (e) {
      dev.log(
          "⚠️ [AUTH_SERVICE] Secure storage failed, using SharedPreferences fallback: $e",
          name: 'AuthService');
      // fallback للـ SharedPreferences العادي
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toMap()));
        dev.log(
            "✅ [AUTH_SERVICE] User data saved to SharedPreferences as fallback",
            name: 'AuthService');
      } catch (fallbackError) {
        dev.log(
            "❌ [AUTH_SERVICE] Both secure and regular storage failed: $fallbackError",
            name: 'AuthService');
      }
    }
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // امسح بيانات المستخدم
    await prefs.remove('user');

    // امسح بيانات أخرى إذا كنت تخزنها
    await prefs.remove('userType');
    await prefs.remove('email');
    await prefs.remove('password');

    // لو عندك أي مفاتيح إضافية تخص المستخدم، امسحها هنا أيضًا
  }

  /// حفظ البريد الإلكتروني وكلمة المرور في التخزين الآمن
  static Future<void> saveUserEmailAndPasswordToSharedPreferences(
      String email, String password) async {
    try {
      await SecureStorageService.saveEmail(email);
      await SecureStorageService.savePassword(password);
      dev.log("✅ [AUTH_SERVICE] Credentials saved securely",
          name: 'AuthService');
    } catch (e) {
      dev.log("❌ [AUTH_SERVICE] Failed to save credentials: $e",
          name: 'AuthService');
    }
  }

  /// حفظ نوع المستخدم في التخزين الآمن
  static Future<void> saveUserTypeToSharedPreferences(String type) async {
    try {
      await SecureStorageService.saveUserType(type);
      dev.log("✅ [AUTH_SERVICE] User type saved securely", name: 'AuthService');
    } catch (e) {
      dev.log("❌ [AUTH_SERVICE] Failed to save user type: $e",
          name: 'AuthService');
    }
  }

  /// استرجاع بيانات المستخدم من التخزين الآمن مع fallback للـ SharedPreferences
  static Future<UserEntity?> getUserFromSharedPreferences() async {
    try {
      // محاولة جلب بيانات المستخدم من التخزين الآمن
      final userData = await SecureStorageService.getUser();
      if (userData != null) {
        return UserEntity.fromMap(userData);
      }
      return null;
    } catch (e) {
      dev.log(
          "⚠️ [AUTH_SERVICE] Secure storage failed, using SharedPreferences fallback: $e",
          name: 'AuthService');
      // fallback للـ SharedPreferences العادي
      try {
        final prefs = await SharedPreferences.getInstance();
        final userData = prefs.getString('user');
        if (userData != null) {
          return UserEntity.fromMap(jsonDecode(userData));
        }
        return null;
      } catch (fallbackError) {
        dev.log(
            "❌ [AUTH_SERVICE] Both secure and regular storage failed: $fallbackError",
            name: 'AuthService');
        return null;
      }
    }
  }

  /// مسح بيانات المستخدم والتوكن من التخزين الآمن
  static Future<void> clearUserAndTokenFromSharedPreferences() async {
    try {
      await SecureStorageService.clearUserCredentials();
      _clearCache(); // مسح الـ cache أيضاً
      dev.log("✅ [AUTH_SERVICE] All user data and cache cleared securely",
          name: 'AuthService');
    } catch (e) {
      dev.log("❌ [AUTH_SERVICE] Failed to clear user data: $e",
          name: 'AuthService');
      _clearCache(); // مسح الـ cache حتى لو فشل التخزين الآمن
    }
  }

  /// حذف قيمة محددة من SharedPreferences
  static Future<void> removeKeyFromSharedPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// جلب البريد الإلكتروني من التخزين الآمن
  static Future<String?> getEmailFromSharedPreferences() async {
    try {
      return await SecureStorageService.getEmail();
    } catch (e) {
      dev.log("❌ [AUTH_SERVICE] Failed to get email: $e", name: 'AuthService');
      return null;
    }
  }

  /// جلب كلمة المرور من التخزين الآمن
  static Future<String?> getPasswordFromSharedPreferences() async {
    try {
      return await SecureStorageService.getPassword();
    } catch (e) {
      dev.log("❌ [AUTH_SERVICE] Failed to get password: $e",
          name: 'AuthService');
      return null;
    }
  }

  /// جلب نوع المستخدم من التخزين الآمن
  static Future<String?> getUserTypeFromSharedPreferences() async {
    try {
      return await SecureStorageService.getUserType();
    } catch (e) {
      dev.log("❌ [AUTH_SERVICE] Failed to get user type: $e",
          name: 'AuthService');
      return null;
    }
  }

  /// جلب البريد الإلكتروني وكلمة المرور ونوع المستخدم معًا من التخزين الآمن
  static Future<Map<String, String?>> getUserCredentialsAndType() async {
    try {
      return {
        'email': await SecureStorageService.getEmail(),
        'password': await SecureStorageService.getPassword(),
        'userType': await SecureStorageService.getUserType(),
      };
    } catch (e) {
      dev.log("❌ [AUTH_SERVICE] Failed to get credentials: $e",
          name: 'AuthService');
      return {
        'email': null,
        'password': null,
        'userType': null,
      };
    }
  }
}
