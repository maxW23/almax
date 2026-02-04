import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/tasks_api_service.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/ranking_entity.dart';
import 'tasks_state.dart';
import '../../../home/presentation/manger/language/language_cubit.dart';

class _MissionsParsed {
  final List<TaskEntity> myLevelTasks;
  final List<TaskEntity> upgradeTasks;
  const _MissionsParsed(this.myLevelTasks, this.upgradeTasks);
}

// عينة مهام عربية fallback عندما يكون الـ endpoint غير متاح
const String kSampleMissionsAr = r'''
{
    "مهمة يومية جلوس 4 ساعات على المايك 500 نقطة": [
        true,
        "22735"
    ],
    "مهمة يومية لعب لودو 500 نقطة": false,
    "مهمة يومية ارسال هدية 500 نقطة": false,
    "مهمة يومية  دعوى مستخدم 12600 نقطة": false,
    "مهمة يومية  تلقي هدايا بقيمة 15000 كوينز  250 نقطة": [
        false,
        0,
        15000
    ],
    "مهمة يومية  ارسال خمس هدايا اقفال  50 نقطة": [
        false,
        0,
        5
    ],
    "مهمة   تعيير اسم  750 نقطة": false,
    "مهمة  الفي اي بي شراء في اي بي لاول مرة   25000 نقطة": true,
    "مهمة دعوى 10 اشخاص 63000 نقطة": [
        false,
        0,
        10
    ],
    "مهمة دعوى 25 اشخاص 157500 نقطة": [
        false,
        0,
        25
    ],
    "مهمة دعوى 50 اشخاص 315000 نقطة": [
        false,
        0,
        50
    ],
    "مهمة دعوى 100 اشخاص 630000 نقطة": [
        false,
        0,
        100
    ],
    "مهمة جلوس على المايك 100 ساعة 15000 نقطة": [
        true,
        973.77,
        100
    ],
    "مهمة جلوس على المايك 500 ساعة 25000 نقطة": [
        true,
        973.77,
        500
    ],
    "مهمة جلوس على المايك 1000 ساعة 60000 نقطة": [
        false,
        973.77,
        1000
    ],
    "مهمة استلام 500 هدية 5000 نقطة": [
        true,
        28736,
        500
    ],
    "مهمة استلام 1000 هدية 10000 نقطة": [
        true,
        28736,
        1000
    ],
    "مهمة استلام 250 هدية بالون 10000 نقطة": [
        false,
        61,
        250
    ],
    "مهمة استلام 150 هدية ورد 10000 نقطة": [
        false,
        126,
        150
    ],
    "مهمة استلام 20 هدية اسد 50000 نقطة": [
        false,
        19,
        20
    ],
    "مهمة ارسال 15 هدية اسد 50000 نقطة": [
        false,
        14,
        15
    ],
    "مهمة ارسال 75 هدية بصل 25000 نقطة": [
        false,
        27,
        75
    ],
    "مهمة مشروب الحظ ارسال 250 هدية مشروب الحظ 7000 نقطة": [
        true,
        287,
        250
    ],
    "مهمة كعكة الحظ ارسال 250 هدية كعكة الحظ 7000 نقطة": [
        false,
        215,
        250
    ]
},
''';

// Top-level function for compute() isolate JSON decoding
Map<String, dynamic> decodeJsonToMapIsolate(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is Map<String, dynamic>) {
    return Map<String, dynamic>.from(decoded);
  }
  if (decoded is Map) {
    return Map<String, dynamic>.from(
      (decoded as Map).map((k, v) => MapEntry(k.toString(), v)),
    );
  }
  throw const FormatException('JSON not a Map');
}

class TasksCubit extends Cubit<TasksState> {
  final TasksApiService _apiService;
  final LanguageCubit _languageCubit;
  DateTime? _lastLoadedAt;
  String? _lastLang;
  Duration _ttl = const Duration(minutes: 3);

  TasksCubit(this._apiService, this._languageCubit) : super(TasksInitial());

  /// الحصول على كود اللغة الحالية (ar أو en)
  String _getCurrentLanguageCode() {
    try {
      final languageCode = _languageCubit.state.languageCode;
      return (languageCode == 'ar' || languageCode == 'en') ? languageCode : 'ar';
    } catch (e) {
      // في حالة حدوث خطأ، نرجع العربية كافتراضي
      return 'ar';
    }
  }

  // ---- Local cache helpers (SharedPreferences) ----
  static const String _kCachePrefix = 'tasks_cache_v1_';

  Future<void> _saveCache(String lang, String? rawText) async {
    if (rawText == null) return;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('$_kCachePrefix$lang', rawText);
      await sp.setInt('$_kCachePrefix${lang}_ts', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      // ignore
    }
  }

  Future<String?> _tryLoadCachedRaw(String lang) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('$_kCachePrefix$lang');
      final ts = sp.getInt('$_kCachePrefix${lang}_ts');
      if (raw == null || ts == null) return null;
      return raw;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _decodeToMapAsync(dynamic raw) async {
    final text = raw is String ? raw : jsonEncode(raw);
    return compute(decodeJsonToMapIsolate, text);
  }

  Future<void> loadTasks({bool force = false}) async {
    // TTL skip: if we have loaded recently with same language, reuse state
    final langNow = _getCurrentLanguageCode();
    if (!force && _lastLoadedAt != null && _lastLang == langNow) {
      final elapsed = DateTime.now().difference(_lastLoadedAt!);
      if (elapsed < _ttl && state is TasksLoaded) {
        // Skip reloading; keep current state
        return;
      }
    }

    // 1) Cache-first fast emission (if available)
    bool emittedFromCache = false;
    if (!force) {
      try {
        final cachedRaw = await _tryLoadCachedRaw(langNow);
        if (cachedRaw != null && cachedRaw.trim().isNotEmpty) {
          final cachedMap = await _decodeToMapAsync(cachedRaw);
          final parsedCached = _parseMissions(cachedMap);
          final cachedLoaded = TasksLoaded(
            myLevelTasks: parsedCached.myLevelTasks,
            upgradeTasks: parsedCached.upgradeTasks,
            userLevel: null,
            dailyRankings: _getMockRankings(),
            weeklyRankings: _getMockRankings(),
            monthlyRankings: _getMockRankings(),
            topAgencies: _getMockAgencies(),
            selectedTabIndex: 0,
            selectedRankingPeriod: 'Daily',
            rawMissionsText: cachedRaw,
          );
          emit(cachedLoaded);
          emittedFromCache = true;
        }
      } catch (_) {
        // ignore cache errors
      }
    }

    if (!emittedFromCache) {
      emit(TasksLoading());
    }

    try {
      late final Map<String, dynamic> missionsMap;
      String? rawText;

      try {
        // الحصول على لغة المستخدم الحالية
        final currentLanguage = _getCurrentLanguageCode();
        // ignore: avoid_print
        print(
            '[TasksCubit] 🎯 loadTasks START -> languageCode=$currentLanguage');
        Response resp;
        try {
          resp = await _apiService
              .getUserMissions(languageCode: currentLanguage)
              .timeout(const Duration(seconds: 6));
        } on TimeoutException catch (_) {
          // quick retry
          await Future.delayed(const Duration(milliseconds: 250));
          resp = await _apiService
              .getUserMissions(languageCode: currentLanguage)
              .timeout(const Duration(seconds: 6));
        }
        // ignore: avoid_print
        print('[TasksCubit] ✅ API SUCCESS -> status=${resp.statusCode}');
        final dynamic raw = resp.data;
        rawText = raw is String ? raw : jsonEncode(raw);
        // بعض الخوادم قد ترجع HTML بدلاً من JSON عند 404
        if (rawText.trimLeft().startsWith('<!DOCTYPE')) {
          throw const FormatException('HTML instead of JSON');
        }
        missionsMap = await _decodeToMapAsync(raw);
        // save cache
        _saveCache(langNow, rawText);
      } on DioException catch (e) {
        // ignore: avoid_print
        print(
            '[TasksCubit] ❌ API FAILED -> status=${e.response?.statusCode}, error=${e.message}');
        // 404 أو 500 للـ mission/mession => نستخدم العينة العربية كـ fallback لكي لا تتعطل الشاشة
        if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
          // ignore: avoid_print
          print('[TasksCubit] 🔄 Using FALLBACK data due to server error');
          rawText = kSampleMissionsAr;
          missionsMap = await _decodeToMapAsync(kSampleMissionsAr);
        } else {
          // quick retry once on network error
          try {
            await Future.delayed(const Duration(milliseconds: 250));
            final currentLanguage = _getCurrentLanguageCode();
            final resp = await _apiService
                .getUserMissions(languageCode: currentLanguage)
                .timeout(const Duration(seconds: 6));
            final dynamic raw = resp.data;
            rawText = raw is String ? raw : jsonEncode(raw);
            if (rawText.trimLeft().startsWith('<!DOCTYPE')) {
              throw const FormatException('HTML instead of JSON');
            }
            missionsMap = await _decodeToMapAsync(raw);
            _saveCache(langNow, rawText);
          } catch (_) {
            rethrow;
          }
        }
      } on FormatException {
        // ignore: avoid_print
        print('[TasksCubit] 🔄 Using FALLBACK data due to format error');
        rawText = kSampleMissionsAr;
        missionsMap = await _decodeToMapAsync(kSampleMissionsAr);
      }

      final parsed = _parseMissions(missionsMap);
      // ignore: avoid_print
      print(
          '[TasksCubit] 📊 Parsed tasks -> myLevel=${parsed.myLevelTasks.length}, upgrade=${parsed.upgradeTasks.length}');

      // Rankings and agencies remain mocked for now
      final dailyRankings = _getMockRankings();
      final topAgencies = _getMockAgencies();

      final loaded = TasksLoaded(
        myLevelTasks: parsed.myLevelTasks,
        upgradeTasks: parsed.upgradeTasks,
        userLevel: null,
        dailyRankings: dailyRankings,
        weeklyRankings: dailyRankings,
        monthlyRankings: dailyRankings,
        topAgencies: topAgencies,
        selectedTabIndex: 0,
        selectedRankingPeriod: 'Daily',
        rawMissionsText: rawText,
      );
      emit(loaded);
      _lastLoadedAt = DateTime.now();
      _lastLang = langNow;
      // ignore: avoid_print
      print('[TasksCubit] ✅ TasksLoaded emitted successfully');
    } catch (e) {
      // Fallback to mock on error to avoid blank screen (كحل أخير)
      final myLevelTasks = _getMockMyLevelTasks();
      final upgradeTasks = _getMockUpgradeTasks();
      final dailyRankings = _getMockRankings();
      final topAgencies = _getMockAgencies();
      final loaded = TasksLoaded(
        myLevelTasks: myLevelTasks,
        upgradeTasks: upgradeTasks,
        userLevel: null,
        dailyRankings: dailyRankings,
        weeklyRankings: dailyRankings,
        monthlyRankings: dailyRankings,
        topAgencies: topAgencies,
        selectedTabIndex: 0,
        selectedRankingPeriod: 'Daily',
        rawMissionsText: null,
      );
      emit(loaded);
      _lastLoadedAt = DateTime.now();
      _lastLang = langNow;
    }
  }

  void changeTab(int index) {
    if (state is TasksLoaded) {
      emit((state as TasksLoaded).copyWith(selectedTabIndex: index));
    }
  }

  void changeRankingPeriod(String period) {
    if (state is TasksLoaded) {
      emit((state as TasksLoaded).copyWith(selectedRankingPeriod: period));
    }
  }

  Future<void> claimReward(String taskId) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(TaskClaimLoading(taskId));

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        // Update task as completed
        final updatedTasks = currentState.myLevelTasks.map((task) {
          if (task.id == taskId) {
            return TaskEntity(
              id: task.id,
              title: task.title,
              description: task.description,
              currentProgress: task.totalProgress,
              totalProgress: task.totalProgress,
              points: task.points,
              isCompleted: true,
              icon: task.icon,
              type: task.type,
            );
          }
          return task;
        }).toList();

        emit(currentState.copyWith(myLevelTasks: updatedTasks));

        // Uncomment when API is ready
        // await _apiService.claimTaskReward(taskId: taskId);
      } catch (e) {
        emit(TaskClaimError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> convertCoinsToPoints(int amount) async {
    try {
      await _apiService.convertCoinsToPoints(amount: amount);
      // Reload tasks after conversion
      await loadTasks(force: true);
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  // --- Parsing helpers ---
  _MissionsParsed _parseMissions(Map<String, dynamic> data) {
    final List<TaskEntity> myLevelTasks = [];
    final List<TaskEntity> upgradeTasks = [];

    data.forEach((key, value) {
      final String title = key.toString();
      final TaskType type = _inferTypeFromTitle(title);
      final task = _toTaskEntity(title, value, type);
      // التحقق من المهام اليومية بالعربية والإنجليزية
      final bool isDaily = title.contains('يومية') ||
          title.contains('يومي') ||
          title.toLowerCase().contains('daily mission');
      if (isDaily) {
        myLevelTasks.add(task);
        // ignore: avoid_print
        print('[TasksCubit] 📅 Daily task: $title');
      } else {
        upgradeTasks.add(task);
        // ignore: avoid_print
        print('[TasksCubit] 🎯 Upgrade task: $title');
      }
    });

    return _MissionsParsed(myLevelTasks, upgradeTasks);
  }

  TaskEntity _toTaskEntity(String title, dynamic value, TaskType type) {
    bool completed = false;
    int current = 0;
    int total = 0; // 0 means unlimited / not provided

    if (value is bool) {
      completed = value;
    } else if (value is List) {
      if (value.isNotEmpty) {
        completed = value[0] == true;
      }
      if (value.length >= 2) {
        current = _toInt(value[1]);
      }
      if (value.length >= 3) {
        total = _toInt(value[2]);
      }
    }

    if (total > 0 && current > total) current = total;

    final points = _extractPoints(title) ?? 0;

    return TaskEntity(
      id: title,
      title: title,
      description: title,
      currentProgress: current,
      totalProgress: total,
      points: points,
      isCompleted: completed,
      icon: null,
      type: type,
    );
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.round();
    final s = v.toString();
    // handle numbers like "22735" or "973.77"
    final idx = s.indexOf('.');
    final normalized = idx >= 0 ? s.substring(0, idx) : s;
    return int.tryParse(normalized) ?? 0;
  }

  int? _extractPoints(String title) {
    // البحث عن النقاط بالعربية: "... 500 نقطة"
    final reAr = RegExp(r'([0-9,]+)\s*نقطة');
    final mAr = reAr.firstMatch(title);
    if (mAr != null) {
      final pointsStr = mAr.group(1)!.replaceAll(',', '');
      return int.tryParse(pointsStr);
    }

    // البحث عن النقاط بالإنجليزية: "... 500 points" أو "– 500 points"
    final reEn = RegExp(r'[–-]\s*([0-9,]+)\s*points');
    final mEn = reEn.firstMatch(title);
    if (mEn != null) {
      final pointsStr = mEn.group(1)!.replaceAll(',', '');
      return int.tryParse(pointsStr);
    }

    return null;
  }

  TaskType _inferTypeFromTitle(String title) {
    // التحقق من المهام اليومية بالعربية والإنجليزية
    if (title.contains('يومية') ||
        title.contains('يومي') ||
        title.toLowerCase().contains('daily mission')) {
      return TaskType.daily;
    }

    // التحقق من المهام الخاصة بالعربية والإنجليزية
    const specialsAr = [
      'اسد',
      'بصل',
      'ورد',
      'بالون',
      'مشروب الحظ',
      'كعكة الحظ'
    ];
    const specialsEn = [
      'lion',
      'onion',
      'flower',
      'balloon',
      'lucky drink',
      'fortune cake'
    ];

    final titleLower = title.toLowerCase();
    for (final s in specialsAr) {
      if (title.contains(s)) return TaskType.special;
    }
    for (final s in specialsEn) {
      if (titleLower.contains(s)) return TaskType.special;
    }

    return TaskType.achievement;
  }

  // Mock data methods
  List<TaskEntity> _getMockMyLevelTasks() {
    return [
      TaskEntity(
        id: '1',
        title: 'Stay 4 hours on mic',
        description: 'Stay on microphone for 4 hours',
        currentProgress: 0,
        totalProgress: 500,
        points: 500,
        isCompleted: false,
        type: TaskType.daily,
      ),
      TaskEntity(
        id: '2',
        title: 'Play Ludo',
        description: 'Play Ludo game',
        currentProgress: 0,
        totalProgress: 500,
        points: 500,
        isCompleted: false,
        type: TaskType.daily,
      ),
      TaskEntity(
        id: '3',
        title: 'Send Gifts',
        description: 'Send gifts to friends',
        currentProgress: 0,
        totalProgress: 500,
        points: 500,
        isCompleted: false,
        type: TaskType.daily,
      ),
      TaskEntity(
        id: '4',
        title: 'Invite 10 Users',
        description: 'Invite 10 new users',
        currentProgress: 0,
        totalProgress: 63000,
        points: 63000,
        isCompleted: false,
        type: TaskType.achievement,
      ),
      TaskEntity(
        id: '5',
        title: 'Invite 25 Users',
        description: 'Invite 25 new users',
        currentProgress: 0,
        totalProgress: 157500,
        points: 157500,
        isCompleted: false,
        type: TaskType.achievement,
      ),
      TaskEntity(
        id: '6',
        title: 'Invite 50 Users',
        description: 'Invite 50 new users',
        currentProgress: 0,
        totalProgress: 315000,
        points: 315000,
        isCompleted: false,
        type: TaskType.achievement,
      ),
      TaskEntity(
        id: '7',
        title: 'Invite 100 Users',
        description: 'Invite 100 new users',
        currentProgress: 0,
        totalProgress: 630000,
        points: 630000,
        isCompleted: false,
        type: TaskType.achievement,
      ),
      TaskEntity(
        id: '8',
        title: 'Stay 100 hours on mic',
        description: 'Stay on microphone for 100 hours',
        currentProgress: 0,
        totalProgress: 15000,
        points: 15000,
        isCompleted: false,
        type: TaskType.achievement,
      ),
    ];
  }

  List<TaskEntity> _getMockUpgradeTasks() {
    return [
      TaskEntity(
        id: '9',
        title: 'Stay 500 hours on mic',
        description: 'Stay on microphone for 500 hours',
        currentProgress: 0,
        totalProgress: 25000,
        points: 25000,
        isCompleted: false,
        type: TaskType.achievement,
      ),
      TaskEntity(
        id: '10',
        title: 'Stay 1000 hours on mic',
        description: 'Stay on microphone for 1000 hours',
        currentProgress: 0,
        totalProgress: 60000,
        points: 60000,
        isCompleted: false,
        type: TaskType.achievement,
      ),
      TaskEntity(
        id: '11',
        title: 'Receive 500 Gifts',
        description: 'Receive 500 gifts from friends',
        currentProgress: 0,
        totalProgress: 5000,
        points: 5000,
        isCompleted: false,
        type: TaskType.achievement,
      ),
      TaskEntity(
        id: '12',
        title: 'Receive 1000 Gifts',
        description: 'Receive 1000 gifts from friends',
        currentProgress: 0,
        totalProgress: 10000,
        points: 10000,
        isCompleted: false,
        type: TaskType.achievement,
      ),
      TaskEntity(
        id: '13',
        title: 'Receive 250 Balloon Gifts',
        description: 'Receive 250 balloon gifts',
        currentProgress: 0,
        totalProgress: 10000,
        points: 10000,
        isCompleted: false,
        type: TaskType.special,
      ),
      TaskEntity(
        id: '14',
        title: 'Receive 150 Red Flower Gifts',
        description: 'Receive 150 red flower gifts',
        currentProgress: 0,
        totalProgress: 10000,
        points: 10000,
        isCompleted: false,
        type: TaskType.special,
      ),
      TaskEntity(
        id: '15',
        title: 'Receive 20 Lion Gifts',
        description: 'Receive 20 lion gifts',
        currentProgress: 0,
        totalProgress: 50000,
        points: 50000,
        isCompleted: false,
        type: TaskType.special,
      ),
      TaskEntity(
        id: '16',
        title: 'Receive 15 Lion Gifts',
        description: 'Receive 15 lion gifts',
        currentProgress: 0,
        totalProgress: 25000,
        points: 25000,
        isCompleted: false,
        type: TaskType.special,
      ),
      TaskEntity(
        id: '17',
        title: 'Receive 75 Onion Gifts',
        description: 'Receive 75 onion gifts',
        currentProgress: 0,
        totalProgress: 25000,
        points: 25000,
        isCompleted: false,
        type: TaskType.special,
      ),
    ];
  }

  List<RankingEntity> _getMockRankings() {
    return List.generate(10, (index) {
      return RankingEntity(
        rank: index + 1,
        userId: 'user_${index + 1}',
        userName: index == 3
            ? 'Al Emprater'
            : index == 4
                ? 'Stars'
                : index == 5
                    ? 'Bent Masr'
                    : index == 6
                        ? 'Al Maroukia'
                        : index == 7
                            ? 'Prince'
                            : index == 8
                                ? 'King Masr'
                                : index == 9
                                    ? 'Bent Tunisia'
                                    : 'User ${index + 1}',
        userImage: '',
        points: 6585500 - (index * 100),
        level: index < 3
            ? 3
            : index < 6
                ? 2
                : 1,
        hasVip: index < 5,
        vipLevel: index < 2
            ? 5
            : index < 4
                ? 3
                : 1,
        hasDiamond: index < 7,
        diamondLevel: index < 3
            ? 3
            : index < 5
                ? 2
                : 1,
        country: index % 2 == 0 ? 'EG' : null,
        lastActive: DateTime.now().subtract(Duration(hours: index)),
      );
    });
  }

  List<AgencyRankingEntity> _getMockAgencies() {
    return [
      AgencyRankingEntity(
        rank: 1,
        agencyName: 'Agency',
        agencyImage: '',
        totalPoints: 6585500,
      ),
      AgencyRankingEntity(
        rank: 2,
        agencyName: 'Agency',
        agencyImage: '',
        totalPoints: 6585500,
      ),
      AgencyRankingEntity(
        rank: 3,
        agencyName: 'Agency',
        agencyImage: '',
        totalPoints: 6585500,
      ),
    ];
  }
}
