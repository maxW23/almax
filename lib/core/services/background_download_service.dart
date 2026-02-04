import 'dart:async';

import 'package:background_downloader/background_downloader.dart';

class DownloadService {
  DownloadService._();
  static final instance = DownloadService._();

  final _controller = StreamController<TaskStatusUpdate>.broadcast();

  Stream<TaskStatusUpdate> get updates => _controller.stream;

  void handleStatus(TaskStatusUpdate update) {
    _controller.add(update);
  }

  void dispose() {
    _controller.close();
  }
}
// import 'dart:io';
// import 'package:lklk/core/utils/functions/file_utils.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
// import 'package:dio/dio.dart';
// import 'package:hive/hive.dart';

// class DownloadService {
//   // تحقق مما إذا كان الملف قد تم تحميله مسبقًا
//   static Future<bool> isFileDownloaded(String fileId) async {
//     // final Directory dir = await getApplicationDocumentsDirectory();
//     final String filePath =
//         '${AppDirectories.instance.appDirectory.path}/downloads/$fileId.svga';
//     log.log("filePath :$filePath -- ${File(filePath).existsSync()}");
//     return File(filePath).existsSync();
//   }

//   // تحميل الملف باستخدام FlutterDownloader
//   static Future<void> downloadFileFlutterDownloader(
//       ElementEntity element) async {
//     // final Directory dir = await getApplicationDocumentsDirectory();
//     final String downloadPath = '${AppDirectories.instance.appDirectory.path}/downloads';
//     await Directory(downloadPath).create(recursive: true);
//     final filePath = '$downloadPath/${element.id}.svga';

//     if (await isFileDownloaded(element.id.toString())) {
//       log.log('File already exists: $filePath');
//       return;
//     }

//     await FlutterDownloader.enqueue(
//       url: element.linkPath!,
//       savedDir: downloadPath,
//       fileName: '${element.id}.svga',
//       showNotification: false,/////
//       openFileFromNotification: false,/////

//     );
//     log.log('Download started for: ${element.id}');
//   }

//   // تحميل الملف باستخدام Dio مع تحديث قاعدة البيانات
//   static Future<void> downloadFileWithDio(ElementEntity element) async {
//     final dio = Dio();
//     // final Directory dir = await getApplicationDocumentsDirectory();
//     final String downloadPath = '${AppDirectories.instance.appDirectory.path}/downloads';
//     await Directory(downloadPath).create(recursive: true);
//     final String filePath = '$downloadPath/${element.id}.svga';

//     if (await isFileDownloaded(element.id.toString())) {
//       log.log('File already exists: $filePath');
//       return;
//     }

//     try {
//       await dio.download(
//         element.linkPath!,
//         filePath,

//       );

//       log.log('Download completed: $filePath');

//       var box = await Hive.openBox('elements');
//       var updatedElement = element.markAsDownloaded(filePath);
//       await box.put(updatedElement.id, updatedElement);
//       log.log('File path saved to Hive: $filePath');
//     } catch (e) {
//       log.log('Download failed for ${element.id}: $e');
//       throw Exception('Failed to download file: ${element.id}');
//     }
//   }
// }
