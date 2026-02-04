import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;

/// مدير الصوت المحسن للأداء العالي
class OptimizedAudioManager {
  static final OptimizedAudioManager _instance =
      OptimizedAudioManager._internal();
  factory OptimizedAudioManager() => _instance;
  OptimizedAudioManager._internal();

  // إعدادات الأداء
  static const int maxConcurrentStreams = 20; // حد أقصى للصوتيات المتزامنة
  static const int soundLevelUpdateInterval = 250; // فترة تحديث مستوى الصوت
  static const double minSoundLevelThreshold = 0.1; // حد أدنى لمستوى الصوت
  static const int batchUpdateSize = 10; // حجم دفعة التحديث

  // قوائم المستخدمين والصوت
  final Map<String, double> _soundLevels = {};
  final Map<String, DateTime> _lastUpdate = {};
  final Queue<SoundLevelUpdate> _pendingUpdates = Queue();
  final StreamController<Map<String, double>> _soundLevelStreamController =
      StreamController<Map<String, double>>.broadcast();

  // معالجة التحديثات
  Timer? _updateTimer;
  bool _isProcessing = false;
  int _totalUpdatesReceived = 0;
  int _droppedUpdates = 0;

  // الحصول على Stream للصوت
  Stream<Map<String, double>> get soundLevelStream =>
      _soundLevelStreamController.stream;

  // الحصول على مستويات الصوت الحالية
  Map<String, double> get currentSoundLevels => Map.from(_soundLevels);

  /// تهيئة مدير الصوت
  void initialize() {
    _startProcessing();
  }

  /// بدء معالجة التحديثات
  void _startProcessing() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      Duration(milliseconds: soundLevelUpdateInterval),
      (_) => _processSoundUpdates(),
    );
  }

  /// إضافة تحديث مستوى صوت
  void updateSoundLevel(String userId, double level) {
    _totalUpdatesReceived++;

    // تجاهل المستويات المنخفضة جداً
    if (level < minSoundLevelThreshold) {
      level = 0.0;
    }

    // التحقق من معدل التحديث
    final now = DateTime.now();
    final lastUpdateTime = _lastUpdate[userId];
    if (lastUpdateTime != null) {
      final timeDiff = now.difference(lastUpdateTime).inMilliseconds;
      if (timeDiff < 50) {
        // تجاهل التحديثات السريعة جداً
        _droppedUpdates++;
        return;
      }
    }

    _lastUpdate[userId] = now;
    _pendingUpdates.add(SoundLevelUpdate(userId, level, now));

    // تنظيف الطابور إذا كان كبيراً جداً
    while (_pendingUpdates.length > maxConcurrentStreams * 2) {
      _pendingUpdates.removeFirst();
      _droppedUpdates++;
    }
  }

  /// معالجة تحديثات الصوت
  void _processSoundUpdates() {
    if (_isProcessing || _pendingUpdates.isEmpty) return;

    _isProcessing = true;

    try {
      // معالجة دفعة من التحديثات
      final Map<String, double> batchUpdates = {};
      int processed = 0;

      while (_pendingUpdates.isNotEmpty && processed < batchUpdateSize) {
        final update = _pendingUpdates.removeFirst();

        // تجميع التحديثات للمستخدم الواحد
        if (!batchUpdates.containsKey(update.userId) ||
            batchUpdates[update.userId]! < update.level) {
          batchUpdates[update.userId] = update.level;
        }

        processed++;
      }

      // تطبيق التحديثات
      bool hasChanges = false;
      batchUpdates.forEach((userId, level) {
        final oldLevel = _soundLevels[userId] ?? 0.0;
        if ((oldLevel - level).abs() > 0.05) {
          // تحديث فقط إذا كان التغيير ملحوظ
          _soundLevels[userId] = level;
          hasChanges = true;
        }
      });

      // تنظيف المستويات القديمة (silence detection)
      final now = DateTime.now();
      _lastUpdate.forEach((userId, lastTime) {
        if (now.difference(lastTime).inSeconds > 2) {
          _soundLevels[userId] = 0.0;
          hasChanges = true;
        }
      });

      // إرسال التحديث إذا كان هناك تغييرات
      if (hasChanges) {
        _soundLevelStreamController.add(Map.from(_soundLevels));
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// الحصول على المستخدمين النشطين صوتياً
  List<String> getActiveSpeakers() {
    return _soundLevels.entries
        .where((entry) => entry.value > minSoundLevelThreshold)
        .map((entry) => entry.key)
        .toList();
  }

  /// تنظيف مستوى صوت مستخدم
  void clearUserSoundLevel(String userId) {
    _soundLevels.remove(userId);
    _lastUpdate.remove(userId);
    _soundLevelStreamController.add(Map.from(_soundLevels));
  }

  /// تنظيف جميع المستويات
  void clearAll() {
    _soundLevels.clear();
    _lastUpdate.clear();
    _pendingUpdates.clear();
    _soundLevelStreamController.add({});
  }

  /// إيقاف المعالجة
  void dispose() {
    _updateTimer?.cancel();
    _soundLevelStreamController.close();
    clearAll();
  }

  /// طباعة الإحصائيات
  void printStats() {
    final activeSpeakers = getActiveSpeakers();
    dev.log('''
🎤 Audio Performance Stats:
├─ Total Updates: $_totalUpdatesReceived
├─ Dropped Updates: $_droppedUpdates
├─ Active Speakers: ${activeSpeakers.length}
├─ Total Users: ${_soundLevels.length}
└─ Drop Rate: ${_totalUpdatesReceived > 0 ? (_droppedUpdates / _totalUpdatesReceived * 100).toStringAsFixed(1) : '0'}%
    ''');
  }
}

/// بيانات تحديث مستوى الصوت
class SoundLevelUpdate {
  final String userId;
  final double level;
  final DateTime timestamp;

  SoundLevelUpdate(this.userId, this.level, this.timestamp);
}
