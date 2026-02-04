import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:lklk/core/utils/logger.dart';

class AppwriteValidator {
  final Client _client = Client();
  late final Account _account;

  /// تهيئة الاتصال بـ Appwrite
  Future<void> initAppwrite() async {
    await dotenv.load(fileName: ".env");

    _client
        .setEndpoint(dotenv.get('APPWRITE_ENDPOINT'))
        .setProject(dotenv.get('APPWRITE_PROJECT_ID'))
        .setEndPointRealtime(dotenv.get('End_Point_Realtime'))
        .setSelfSigned(status: true); // true فقط في وضع التطوير

    _account = Account(_client);
  }

  /// اختبار اتصال Appwrite
  Future<void> testAppwriteConnection() async {
    try {
      await _account.createAnonymousSession();
      final response = await _account.get();
      AppLogger.debug(
          '✅ تم الاتصال بـ Appwrite بنجاح | User: ${response.toMap()}');
    } catch (e) {
      throw Exception('❌ فشل الاتصال بـ Appwrite: $e');
    }
  }

  /// اختبار تشفير البيانات
  void testDataEncryption() {
    const testData = 'SecureData123';
    final key = encrypt.Key.fromUtf8('32-char-long-encryption-key!@#');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(testData, iv: iv);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    if (decrypted != testData) {
      throw Exception('❌ فشل اختبار التشفير!');
    }
    AppLogger.debug('✅ تم اختبار التشفير بنجاح');
  }

  /// التحقق من ملف .env
  void checkEnvFile() {
    final requiredVars = ['APPWRITE_ENDPOINT', 'APPWRITE_PROJECT_ID'];
    for (final varName in requiredVars) {
      if (!dotenv.env.containsKey(varName)) {
        throw Exception('❌ المفتاح $varName غير موجود في ملف .env!');
      }
    }
    AppLogger.debug('✅ جميع متغيرات البيئة موجودة');
  }

  /// اختبار شامل لكل شيء
  Future<void> runFullValidation() async {
    AppLogger.debug('--- بدء التحقق من الإعدادات ---');
    await initAppwrite();
    checkEnvFile();
    await testAppwriteConnection();
    testDataEncryption();
    AppLogger.debug('--- تم التحقق بنجاح! ---');
  }
}
