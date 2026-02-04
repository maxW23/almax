import 'dart:io';
import 'package:lklk/core/utils/logger.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

class DownloadManager {
  static final Set<String> _processedTasks = {}; // تتبع المهام المعالجة
  final MemoryTaskQueue _tq = MemoryTaskQueue()
    ..maxConcurrent = 1
    ..maxConcurrentByHost = 1
    ..minInterval = const Duration(milliseconds: 300);

  DownloadManager() {
    FileDownloader().addTaskQueue(_tq);
  }

  bool _isLikelyValidUrl(String url) {
    // Basic fast checks to avoid malformed inputs
    if (!(url.startsWith('http://') || url.startsWith('https://'))) {
      return false;
    }
    if (url.contains(' ')) return false;
    // Allow svga, but not require the extension strictly since some URLs are query based
    return true;
  }

  // يفضل استخدام elamentId كاسم ملف إذا كان متاحاً لأنه يتوافق مع الملفات المحلية المسَبَّقة من svga_files/
  String _preferredFileBaseName(ElementEntity e) {
    final elId = e.elamentId?.toString();
    if (elId != null && elId.isNotEmpty) return elId;
    final id = e.id?.toString();
    return id ?? '';
  }

  // يعيد المعرف البديل (id مقابل elamentId) إن وُجد، لنتحقق من وجود ملف بأي من الاسمين
  String? _alternateFileBaseName(ElementEntity e, String preferred) {
    final id = e.id?.toString();
    final elId = e.elamentId?.toString();
    if (preferred == id) {
      return (elId != null && elId.isNotEmpty) ? elId : null;
    } else {
      return (id != null && id.isNotEmpty) ? id : null;
    }
  }

  // ميثود لتحميل ملف منفرد
  Future<bool> downloadSingleFile(ElementEntity element) async {
    final preferredBase = _preferredFileBaseName(element);
    if (preferredBase.isEmpty) {
      _processedTasks.add('');
      return false;
    }
    final altBase = _alternateFileBaseName(element, preferredBase);
    final filename = '$preferredBase.svga';
    final taskId = filename;

    // Validate URL before proceeding
    final url = element.linkPath?.trim();
    if (url == null || url.isEmpty || !_isLikelyValidUrl(url)) {
      // Many 'lucky' small gifts intentionally have no SVGA link → skip quietly
      if ((element.type?.toLowerCase() ?? '') == 'lucky') {
        _processedTasks.add(taskId);
        return false;
      }
      log('Skipping download for element ${element.id}: invalid URL "$url"');
      _processedTasks.add(taskId);
      return false;
    }

    // التحقق إذا كانت المهمة قد عولجت مسبقاً
    if (_processedTasks.contains(taskId)) {
      log('Task $taskId already processed');
      return false;
    }

    final downloadsDir = '${AppDirectories.instance.appDirectory.path}/downloads';
    final filePreferred = File('$downloadsDir/$filename');
    final fileAlt =
        (altBase != null) ? File('$downloadsDir/$altBase.svga') : null;

    // التحقق إذا كان الملف موجود بالفعل بأي من الاسمين (المحلي المسَبَّق أو اسم التنزيل)
    if (await filePreferred.exists() || (fileAlt != null && await fileAlt.exists())) {
      log('File already exists: $filename');
      _processedTasks.add(taskId);
      return true;
    }

    // التحقق من حالة المهمة في قاعدة البيانات
    final record = await FileDownloader().database.recordForId(taskId);

    if (record != null &&
        (record.status == TaskStatus.complete ||
            record.status == TaskStatus.running)) {
      log('Skipping $taskId: already ${record.status}');
      _processedTasks.add(taskId);
      return record.status == TaskStatus.complete;
    }

    // إنشاء مهمة التحميل
    final task = DownloadTask(
      url: url,
      filename: filename,
      taskId: taskId,
      directory: 'downloads',
      updates: Updates.statusAndProgress,
      allowPause: false,
      retries: 3,
      requiresWiFi: false,
      metaData: '${element.id ?? element.elamentId ?? ''}',
    );

    try {
      // إضافة المهمة إلى الطابور
      _tq.add(task);
      _processedTasks.add(taskId);
      log('Single file download enqueued: $filename');
      return true;
    } catch (error) {
      log('Failed to enqueue single file task $taskId: $error');
      _processedTasks.add(taskId);
      return false;
    }
  }

  // ميثود للتحقق من حالة ملف معين
  Future<FileDownloadStatus> checkFileStatus(String filename) async {
    final filePath =
        '${AppDirectories.instance.appDirectory.path}/downloads/$filename';
    final file = File(filePath);

    if (await file.exists()) {
      return FileDownloadStatus.completed;
    }

    final record = await FileDownloader().database.recordForId(filename);
    if (record != null) {
      return _mapTaskStatusToFileStatus(record.status);
    }

    return FileDownloadStatus.notFound;
  }

  // ميثود للحصول على مسار الملف المحمل
  Future<String?> getFilePath(ElementEntity element) async {
    final preferredBase = _preferredFileBaseName(element);
    final altBase = _alternateFileBaseName(element, preferredBase);
    final downloadsDir = '${AppDirectories.instance.appDirectory.path}/downloads';
    final preferredPath = '$downloadsDir/$preferredBase.svga';
    final altPath = (altBase != null) ? '$downloadsDir/$altBase.svga' : null;

    if (File(preferredPath).existsSync()) {
      return preferredPath;
    }
    if (altPath != null && File(altPath).existsSync()) {
      return altPath;
    }
    return null;
  }

  // ميثود لإعادة تحميل ملف فاشل
  Future<bool> retryFailedDownload(ElementEntity element) async {
    final preferredBase = _preferredFileBaseName(element);
    final altBase = _alternateFileBaseName(element, preferredBase);
    // إزالة أي مُعرّفات قد تكون مُضافة سابقاً
    if (preferredBase.isNotEmpty) {
      _processedTasks.remove('$preferredBase.svga');
    }
    if (altBase != null && altBase.isNotEmpty) {
      _processedTasks.remove('$altBase.svga');
    }

    return await downloadSingleFile(element);
  }

  // دالة مساعدة لتحويل حالة المهمة
  FileDownloadStatus _mapTaskStatusToFileStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.complete:
        return FileDownloadStatus.completed;
      case TaskStatus.running:
        return FileDownloadStatus.downloading;
      case TaskStatus.failed:
        return FileDownloadStatus.failed;
      case TaskStatus.canceled:
        return FileDownloadStatus.cancelled;
      case TaskStatus.notFound:
        return FileDownloadStatus.notFound;
      case TaskStatus.paused:
        return FileDownloadStatus.paused;
      case TaskStatus.waitingToRetry:
        return FileDownloadStatus.retrying;
      case TaskStatus.enqueued:
        return FileDownloadStatus.queued;
    }
  }

  Future<void> enqueueSubset(List<ElementEntity> subset) async {
    for (final e in subset) {
      final preferredBase = _preferredFileBaseName(e);
      if (preferredBase.isEmpty) {
        _processedTasks.add('');
        continue;
      }
      final altBase = _alternateFileBaseName(e, preferredBase);
      final filename = '$preferredBase.svga';
      final taskId = filename;

      final url = e.linkPath?.trim();
      if (url == null || url.isEmpty || !_isLikelyValidUrl(url)) {
        // 'lucky' items (small gifts) typically have only PNG images; no SVGA
        if ((e.type?.toLowerCase() ?? '') == 'lucky') {
          _processedTasks.add(taskId);
          continue;
        }
        log('Skipping enqueue for element ${e.id}: invalid URL "$url"');
        _processedTasks.add(taskId);
        continue;
      }

      if (_processedTasks.contains(taskId)) {
        continue;
      }

      final downloadsDir = '${AppDirectories.instance.appDirectory.path}/downloads';
      final filePreferred = File('$downloadsDir/$filename');
      final fileAlt = (altBase != null) ? File('$downloadsDir/$altBase.svga') : null;

      if (await filePreferred.exists() || (fileAlt != null && await fileAlt.exists())) {
        log('Skipping existing file $filename');
        _processedTasks.add(taskId);
        continue;
      }

      final record = await FileDownloader().database.recordForId(taskId);

      if (record != null &&
          (record.status == TaskStatus.complete ||
              record.status == TaskStatus.running)) {
        log('Skipping $taskId: already ${record.status}');
        _processedTasks.add(taskId);
        continue;
      }

      final task = DownloadTask(
        url: url,
        filename: filename,
        taskId: taskId,
        directory: 'downloads',
        updates: Updates.statusAndProgress,
        allowPause: false,
        retries: 3,
        requiresWiFi: false,
        metaData: '${e.id ?? e.elamentId ?? ''}',
      );

      try {
        _tq.add(task);
        _processedTasks.add(taskId);
      } catch (error) {
        log('Failed to enqueue task $taskId: $error');
        _processedTasks.add(taskId);
      }
    }
  }
}

// enum لحالة التحميل
enum FileDownloadStatus {
  completed,
  downloading,
  failed,
  cancelled,
  notFound,
  paused,
  retrying,
  queued
}
