import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }

  static String get(String key) {
    return dotenv.get(key);
  }
}
