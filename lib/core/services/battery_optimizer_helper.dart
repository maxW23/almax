// import 'package:disable_battery_optimization/disable_battery_optimization.dart';
// import 'package:lklk/generated/l10n.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BatterySettingsHelper {
//   /// التحقق مما إذا كان تحسين البطارية معطل
//   static const String _keyManufacturerPromptShown = 'manufacturer_prompt_shown';
//   static const String _keyAllOptimizationsPromptShown = 'all_optimizations_prompt_shown';

//   /// التحقق مما إذا كان تحسين البطارية معطل
//   static Future<bool?> isBatteryOptimizationDisabled() async {
//     bool? isBatteryOptimizationDisabled =
//         await DisableBatteryOptimization.isBatteryOptimizationDisabled;
//     return isBatteryOptimizationDisabled;
//   }

//   /// التحقق مما إذا كان الخيار الخاص بالشركة المصنعة قد تم عرضه مسبقًا
//   static Future<bool> hasManufacturerPromptBeenShown() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_keyManufacturerPromptShown) ?? false;
//   }

//   /// تحديث حالة عرض الخيار الخاص بالشركة المصنعة
//   static Future<void> setManufacturerPromptShown() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyManufacturerPromptShown, true);
//   }

//   /// التحقق مما إذا كان الخيار الخاص بجميع التحسينات قد تم عرضه مسبقًا
//   static Future<bool> hasAllOptimizationsPromptBeenShown() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_keyAllOptimizationsPromptShown) ?? false;
//   }

//   /// تحديث حالة عرض الخيار الخاص بجميع التحسينات
//   static Future<void> setAllOptimizationsPromptShown() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyAllOptimizationsPromptShown, true);
//   }

//   /// فتح إعدادات تعطيل تحسين البطارية الخاصة بالشركة المصنعة
//   static Future<void> openManufacturerBatteryOptimizationSettings(context) async {
//     try {
//       bool hasBeenShown = await hasManufacturerPromptBeenShown();
//       if (hasBeenShown) {
//         // AppLogger.debug(S.of(context).manufacturerPromptAlreadyShown);
//         return;
//       }

//       await DisableBatteryOptimization.showDisableManufacturerBatteryOptimizationSettings(
//         S.of(context).manufacturerOptimizationTitle,
//         S.of(context).manufacturerOptimizationDescription,
//       );
//       AppLogger.debug(S.of(context).openedManufacturerSettings);

//       await setManufacturerPromptShown(); // تحديث الحالة بعد عرض الخيار
//     } catch (e) {
//       AppLogger.debug(S.of(context).failedToOpenSettings(e.toString()));
//     }
//   }

//   /// فتح إعدادات تعطيل كل تحسينات البطارية
//   static Future<void> openAllBatteryOptimizationSettings(context) async {
//     try {
//       bool hasBeenShown = await hasAllOptimizationsPromptBeenShown();
//       if (hasBeenShown) {
//         // AppLogger.debug(S.of(context).allOptimizationsPromptAlreadyShown);
//         return;
//       }

//       await DisableBatteryOptimization.showDisableAllOptimizationsSettings(
//         S.of(context).enableAutoStartTitle,
//         S.of(context).enableAutoStartDescription,
//         S.of(context).manufacturerOptimizationTitle,
//         S.of(context).manufacturerOptimizationDescription,
//       );
//       AppLogger.debug(S.of(context).openedAllSettings);

//       await setAllOptimizationsPromptShown(); // تحديث الحالة بعد عرض الخيار
//     } catch (e) {
//       AppLogger.debug(S.of(context).failedToOpenSettings(e.toString()));
//     }
//   }

//   /// فتح إعدادات تعطيل تحسين البطارية
//   static Future<void> openBatteryOptimizationSettings(context) async {
//     try {
//       bool isDisabled = await isBatteryOptimizationDisabled() ?? false;

//       if (isDisabled) {
//         AppLogger.debug(S.of(context).batteryOptimizationAlreadyDisabled);
//       } else {
//         await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
//         AppLogger.debug(S.of(context).openedBatteryOptimizationSettings);
//       }
//     } catch (e) {
//       AppLogger.debug(S.of(context).failedToOpenSettings(e.toString()));
//     }
//   }

// }
