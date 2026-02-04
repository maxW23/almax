import 'package:encrypt/encrypt.dart';

class SecurityUtils {
  // في SecurityUtils
  static final _key = Key.fromUtf8('32-char-long-encryption-key!@#');
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  static String decrypt(String encryptedData) {
    return _encrypter.decrypt64(encryptedData, iv: _iv);
  }
}
