// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Future<void> askForDownloadPreference(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   final hasShownDialog = prefs.getBool('hasShownDownloadDialog') ?? false;

//   if (!hasShownDialog) {
//     // عرض حوار تحميل
//     final result = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const AutoSizeText("Download Files"),
//         content: const AutoSizeText("Do you want to download the files now?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, 'later'),
//             child: const AutoSizeText("Remind Me Later"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, 'never'),
//             child: const AutoSizeText("Don't Ask Again"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, 'download'),
//             child: const AutoSizeText("Download Now"),
//           ),
//         ],
//       ),
//     );

//     if (result == 'later') {
//       // عرض الإشعار لاحقًا عند فتح التطبيق
//       prefs.setBool('hasShownDownloadDialog', false);
//     } else if (result == 'never') {
//       // لا تعرض الإشعار مجددًا
//       prefs.setBool('hasShownDownloadDialog', true);
//     } else if (result == 'download') {
//       // ابدأ عملية التحميل
//       await _downloadFiles();
//       prefs.setBool('hasShownDownloadDialog', true);
//     }
//   }
// }

// Future<void> _downloadFiles() async {
//   // عملية تحميل الملفات باستخدام Dio
// }
