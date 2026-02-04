import 'package:lklk/core/utils/logger.dart';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';

class SvgaUtils {
  static final Set<String> _inFlightDownloads = <String>{};
  // ميثود ثابت للتحقق من وجود الملف
  static String? getValidFilePath(String? elementId) {
    if (elementId == null) return null;
    // تحديد المسار الكامل للملف باستخدام elamentId
    // log("AppDirectory in method: ${AppDirectories.instance.appDirectory.path}");
    // log("downloads folder exists? ${Directory('${AppDirectories.instance.appDirectory.path}/downloads').existsSync()}");
    String pathOfSvgaFile =
        "${AppDirectories.instance.appDirectory.path}/downloads/$elementId.svga";

    // فحص إذا كان الملف موجودًا في المسار المحدد
    bool fileExists = File(pathOfSvgaFile).existsSync();
    // تتبع مفصل لعملية التحقق من وجود الملف
    try {
      log('[SVGA] exist-check: id=$elementId path=$pathOfSvgaFile exists=$fileExists');
    } catch (_) {}

    // log("getValidFilePath -- $fileExists --- $pathOfSvgaFile");

    // إذا كان الملف موجودًا في المسار المحدد، قم بإرجاعه
    return fileExists ? pathOfSvgaFile : null;
  }

  static Future<bool> _directDownloadFile(String elementId, String url) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) {
        log('[SVGA] direct HTTP status ${response.statusCode} for id=$elementId');
        return false;
      }
      final dirPath = "${AppDirectories.instance.appDirectory.path}/downloads";
      final file = File('$dirPath/$elementId.svga');
      await file.create(recursive: true);
      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.flush();
      await sink.close();
      return true;
    } catch (e) {
      log('[SVGA] direct download exception: $e');
      return false;
    }
  }

  static Future<String?> getValidFilePathWithDownload(
    String? elementId, {
    String? downloadUrl,
  }) async {
    if (elementId == null || elementId.isEmpty) return null;

    // التحقق أولاً إذا الملف موجود
    final existingPath = getValidFilePath(elementId);
    if (existingPath != null) {
      try {
        log('[SVGA] hit-cache: id=$elementId path=$existingPath');
      } catch (_) {}
      return existingPath;
    }

    if (downloadUrl != null && downloadUrl.isNotEmpty) {
      // Normalize and validate URL
      final normalized = _normalizeUrl(downloadUrl);
      if (normalized == null) {
        log('SVGA download skipped: invalid URL: $downloadUrl');
        return null;
      }

      // إذا كان هناك تنزيل جارٍ لنفس المعرف، انتظر قليلاً حتى يُحفظ الملف
      if (_inFlightDownloads.contains(elementId)) {
        try {
          log('[SVGA] wait-existing: id=$elementId (coalescing)');
        } catch (_) {}
        for (int i = 0; i < 12; i++) { // ~2.4s
          await Future.delayed(const Duration(milliseconds: 200));
          final cached = getValidFilePath(elementId);
          if (cached != null) return cached;
        }
        // لو لم يظهر الملف خلال الانتظار، تابع للمحاولة أدناه (قد يكون التنزيل فشل)
      }

      try {
        _inFlightDownloads.add(elementId);
        log('[SVGA] download-start: id=$elementId url=$normalized');
      } catch (_) {}
      bool success = false;
      try {
        success = await _downloadFile(elementId, normalized);
      } finally {
        _inFlightDownloads.remove(elementId);
      }
      if (success) {
        try {
          log('[SVGA] download-success: id=$elementId');
        } catch (_) {}
        return getValidFilePath(elementId);
      }
      try {
        log('[SVGA] download-failed: id=$elementId');
      } catch (_) {}

      // محاولة تنزيل مباشرة متزامنة كحل احتياطي
      try {
        log('[SVGA] direct-download-attempt: id=$elementId url=$normalized');
        final ok = await _directDownloadFile(elementId, normalized);
        if (ok) {
          log('[SVGA] direct-download-success: id=$elementId');
          return getValidFilePath(elementId);
        } else {
          log('[SVGA] direct-download-failed: id=$elementId');
        }
      } catch (e) {
        log('[SVGA] direct-download-error: $e');
      }
    }

    try {
      log('[SVGA] no-path: id=$elementId url=${downloadUrl ?? 'N/A'}');
    } catch (_) {}
    return null;
  }

  static Future<bool> _downloadFile(
      String elementId, String downloadUrl) async {
    try {
      log('[SVGA] enqueue-download: id=$elementId filename=$elementId.svga dir=downloads');
      final filename = '$elementId.svga';
      final task = DownloadTask(
        url: downloadUrl,
        filename: filename,
        taskId: filename,
        directory: 'downloads',
        updates: Updates.statusAndProgress,
        allowPause: false,
        retries: 2,
        requiresWiFi: false,
        metaData: elementId,
      );

      final result = await FileDownloader().download(task);

      if (result.status == TaskStatus.complete) {
        log("File downloaded successfully: $filename");
        return true;
      } else {
        log("File download failed: ${result.status}");
        return false;
      }
    } catch (e) {
      log("Error downloading file: $e");
      return false;
    }
  }

  // Try to normalize URLs that may be missing scheme or are protocol-relative
  static String? _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }
    // If server returns domain without scheme
    if (trimmed.startsWith('lklklive.com')) {
      return 'https://$trimmed';
    }
    // If path-like URL (e.g., '/svga/123.svga'), assume lklklive host
    if (trimmed.startsWith('/')) {
      return 'https://lklklive.com$trimmed';
    }
    return null;
  }
}

class AppDirectories {
  static final AppDirectories _instance = AppDirectories._internal();

  late Directory appDirectory;

  AppDirectories._internal();

  static AppDirectories get instance => _instance;

  Future<void> init() async {
    appDirectory = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDirectory.path}/downloads');
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
      log('Created downloads dir at ${downloadsDir.path}');
    }
  }
}
