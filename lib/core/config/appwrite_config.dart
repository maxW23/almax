import 'package:appwrite/appwrite.dart';
import 'package:lklk/core/utils/logger.dart';

class AppwriteConfig {
  static final Client client = Client();
  static Account? account;
  static Databases? databases;
  static Realtime? realtime;
  static RealtimeSubscription? _currentSubscription;
  static final List<RealtimeSubscription> _subscriptions = <RealtimeSubscription>[];
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      client
          .setEndpoint('https://api.lklklive.com/v1')
          .setProject('687d38670008930cc439')
          .setSelfSigned(status: true);

      account = Account(client);
      databases = Databases(client);
      realtime = Realtime(client);

      // التحقق من وجود جلسة نشطة قبل إنشاء واحدة جديدة
      try {
        await account!.get();
        AppLogger.debug('Using existing session');
      } catch (e) {
        AppLogger.debug('Creating new anonymous session');
        await account!.createAnonymousSession();
      }

      _isInitialized = true;
    } catch (e) {
      AppLogger.debug('Failed to initialize Appwrite: $e');
      rethrow;
    }
  }

  static Future<void> close() async {
    try {
      // Close all active subscriptions safely
      for (final sub in List<RealtimeSubscription>.from(_subscriptions)) {
        try {
          await sub.close();
        } catch (_) {}
      }
      _subscriptions.clear();
      try {
        await _currentSubscription?.close();
      } catch (_) {}
      _currentSubscription = null;

      // تسجيل الخروج فقط إذا كان هناك جلسة نشطة
      try {
        await account?.deleteSession(sessionId: 'current');
      } catch (e) {
        AppLogger.debug('Error deleting session: $e');
      }
    } catch (e) {
      AppLogger.debug('Error closing Appwrite connections: $e');
    } finally {
      _isInitialized = false;
    }
  }

  static RealtimeSubscription subscribe(List<String> channels) {
    final sub = realtime!.subscribe(channels);
    _subscriptions.add(sub);
    _currentSubscription = sub; // keep reference to the most recent
    return sub;
  }
}
