import 'package:flutter/material.dart';

class TasksLocalization {
  static String getLocalizedString(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;

    final Map<String, Map<String, String>> translations = {
      'en': {
        'levels': 'Levels',
        'myLevel': 'My Level',
        'upgrades': 'Upgrades',
        'ranking': 'Ranking',
        'tasks': 'Tasks',
        'missions': 'Missions',
        'dailyTasks': 'Daily Tasks',
        'weeklyTasks': 'Weekly Tasks',
        'monthlyTasks': 'Monthly Tasks',
        'completed': 'Completed',
        'inProgress': 'In Progress',
        'notStarted': 'Not Started',
        'points': 'Points',
        'level': 'Level',
        'currentLevel': 'Current Level',
        'nextLevel': 'Next Level',
        'pointsToUpgrade': 'Points to Upgrade',
        'progress': 'Progress',
        'searchUsers': 'Search users by name or ID',
        'noUsersToSearch': 'No users to search',
        'noResults': 'No results for \'{query}\'',
        'rawMissions': 'Raw Missions',
        'copied': 'Copied',
        'noMissionsResponse': 'No missions response yet',
        'loadingTasks': 'Loading tasks...',
        'errorLoadingTasks': 'Error loading tasks',
        'refreshTasks': 'Refresh Tasks',
        'daily': 'Daily',
        'weekly': 'Weekly',
        'monthly': 'Monthly',
        'topUsers': 'Top Users',
        'topAgencies': 'Top Agencies',
        'rank': 'Rank',
        'user': 'User',
        'agency': 'Agency',
        'score': 'Score',
        'enjoyAdvantages': 'Enjoy Advantages of the Level.',
        'promote': 'Promote',
        'taskCompleted': 'Completed',
        'pts': 'PTS',
        'numberOfPointsToUpgrade': 'Number of Points\nTo Upgrade',
        'numberOfPointsNow': 'Number of Points\nNow',
        'loading': 'Loading...',
        'error': 'Error',
      },
      'ar': {
        'levels': 'المستويات',
        'myLevel': 'مستواي',
        'upgrades': 'الترقيات',
        'ranking': 'الترتيب',
        'tasks': 'المهام',
        'missions': 'المهمات',
        'dailyTasks': 'المهام اليومية',
        'weeklyTasks': 'المهام الأسبوعية',
        'monthlyTasks': 'المهام الشهرية',
        'completed': 'مكتملة',
        'inProgress': 'قيد التنفيذ',
        'notStarted': 'لم تبدأ',
        'points': 'نقاط',
        'level': 'مستوى',
        'currentLevel': 'المستوى الحالي',
        'nextLevel': 'المستوى التالي',
        'pointsToUpgrade': 'نقاط للترقية',
        'progress': 'التقدم',
        'searchUsers': 'البحث عن المستخدمين بالاسم أو المعرف',
        'noUsersToSearch': 'لا يوجد مستخدمون للبحث',
        'noResults': 'لا توجد نتائج لـ \'{query}\'',
        'rawMissions': 'المهمات الخام',
        'copied': 'تم النسخ',
        'noMissionsResponse': 'لا يوجد رد مهمات بعد',
        'loadingTasks': 'جاري تحميل المهام...',
        'errorLoadingTasks': 'خطأ في تحميل المهام',
        'refreshTasks': 'تحديث المهام',
        'daily': 'يومي',
        'weekly': 'أسبوعي',
        'monthly': 'شهري',
        'topUsers': 'أفضل المستخدمين',
        'topAgencies': 'أفضل الوكالات',
        'rank': 'الترتيب',
        'user': 'مستخدم',
        'agency': 'وكالة',
        'score': 'النقاط',
        'enjoyAdvantages': 'استمتع بمزايا المستوى.',
        'promote': 'ترقية',
        'taskCompleted': 'مكتملة',
        'pts': 'نقطة',
        'numberOfPointsToUpgrade': 'عدد النقاط\nللترقية',
        'numberOfPointsNow': 'عدد النقاط\nالحالية',
        'loading': 'جاري التحميل...',
        'error': 'خطأ',
      },
    };

    return translations[locale]?[key] ?? translations['en']?[key] ?? key;
  }

  // Helper methods for commonly used strings
  static String levels(BuildContext context) =>
      getLocalizedString(context, 'levels');
  static String myLevel(BuildContext context) =>
      getLocalizedString(context, 'myLevel');
  static String upgrades(BuildContext context) =>
      getLocalizedString(context, 'upgrades');
  static String ranking(BuildContext context) =>
      getLocalizedString(context, 'ranking');
  static String tasks(BuildContext context) =>
      getLocalizedString(context, 'tasks');
  static String missions(BuildContext context) =>
      getLocalizedString(context, 'missions');
  static String loadingTasks(BuildContext context) =>
      getLocalizedString(context, 'loadingTasks');
  static String errorLoadingTasks(BuildContext context) =>
      getLocalizedString(context, 'errorLoadingTasks');
  static String searchUsers(BuildContext context) =>
      getLocalizedString(context, 'searchUsers');
  static String noUsersToSearch(BuildContext context) =>
      getLocalizedString(context, 'noUsersToSearch');
  static String noResults(BuildContext context, String query) =>
      getLocalizedString(context, 'noResults').replaceAll('{query}', query);
  static String rawMissions(BuildContext context) =>
      getLocalizedString(context, 'rawMissions');
  static String copied(BuildContext context) =>
      getLocalizedString(context, 'copied');
  static String noMissionsResponse(BuildContext context) =>
      getLocalizedString(context, 'noMissionsResponse');
  static String user(BuildContext context) =>
      getLocalizedString(context, 'user');
  static String daily(BuildContext context) =>
      getLocalizedString(context, 'daily');
  static String weekly(BuildContext context) =>
      getLocalizedString(context, 'weekly');
  static String monthly(BuildContext context) =>
      getLocalizedString(context, 'monthly');
  static String enjoyAdvantages(BuildContext context) =>
      getLocalizedString(context, 'enjoyAdvantages');
  static String promote(BuildContext context) =>
      getLocalizedString(context, 'promote');
  static String taskCompleted(BuildContext context) =>
      getLocalizedString(context, 'taskCompleted');
  static String pts(BuildContext context) => getLocalizedString(context, 'pts');
  static String numberOfPointsToUpgrade(BuildContext context) =>
      getLocalizedString(context, 'numberOfPointsToUpgrade');
  static String numberOfPointsNow(BuildContext context) =>
      getLocalizedString(context, 'numberOfPointsNow');
  static String loading(BuildContext context) =>
      getLocalizedString(context, 'loading');
  static String error(BuildContext context) =>
      getLocalizedString(context, 'error');
}
