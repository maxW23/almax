import 'package:lklk/core/utils/logger.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:lklk/core/utils/widgets/image_custom_crop_page.dart';

class ImageHelper {
  ImageHelper._();

  static Future<File?> pickImage({
    bool isCrop = true,
    bool isScreenfull = false,
    bool cropToSquare = false,
    int? targetWidth,
    int? targetHeight,
    int? screenWidth,
    int? screenHeight,
    int quality = 35,
    BuildContext? context,
    bool useCustomCropper = false,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        log("No image selected.");
        return null;
      }

      File selectedFile = File(pickedFile.path);
      if (!selectedFile.existsSync()) {
        log("File not found.");
        return null;
      }

      if (selectedFile.path.toLowerCase().endsWith('.gif')) {
        log("GIF file detected.");
        final fileSizeMB = await _getFileSizeInMB(selectedFile);

        if (fileSizeMB < 2) return selectedFile;
        File? compressedFile =
            await _smartGifCompression(selectedFile, fileSizeMB);

        double compressedSizeMB = await _getFileSizeInMB(compressedFile);
        if (compressedSizeMB > 2) {
          log("Compressed GIF is still over 2MB");
          return null;
        }
        return compressedFile;
      }

      // Handle screen full dimensions
      if (isScreenfull) {
        if (screenWidth == null || screenHeight == null) {
          throw ArgumentError(
              'screenWidth and screenHeight are required when isScreenfull is true');
        }
        targetWidth = screenWidth;
        targetHeight = screenHeight;
        cropToSquare = false;
      }

      File processedFile = selectedFile;

      // Apply cropping if enabled
      if (isCrop || isScreenfull) {
        if (useCustomCropper && context != null) {
          try {
            final Uint8List bytes = await selectedFile.readAsBytes();
            final File? customFile = await Navigator.of(context).push<File>(
              MaterialPageRoute(
                builder: (_) => ImageCustomCropPage(
                  imageBytes: bytes,
                  cropToSquare: cropToSquare,
                  targetWidth: targetWidth,
                  targetHeight: targetHeight,
                  toolbarTitle: 'قص الصورة',
                ),
              ),
            );
            if (isCrop && customFile == null) return null;
            if (customFile != null) processedFile = customFile;
          } catch (e) {
            log('Custom cropper failed: $e');
            // Fallback to default cropper
            final CroppedFile? croppedFile = await _cropImage(
              sourcePath: selectedFile.path,
              isCrop: isCrop,
              cropToSquare: cropToSquare,
              targetWidth: targetWidth,
              targetHeight: targetHeight,
            );
            if (isCrop && croppedFile == null) return null;
            if (croppedFile != null) processedFile = File(croppedFile.path);
          }
        } else {
          final CroppedFile? croppedFile = await _cropImage(
            sourcePath: selectedFile.path,
            isCrop: isCrop,
            cropToSquare: cropToSquare,
            targetWidth: targetWidth,
            targetHeight: targetHeight,
          );

          if (isCrop && croppedFile == null) return null;
          if (croppedFile != null) processedFile = File(croppedFile.path);
        }
      }

      // Apply resizing and quality adjustment
      if (targetWidth != null && targetHeight != null) {
        final fileSizeMB = await _getFileSizeInMB(processedFile);
        int adjustedQuality = quality;

        if (isScreenfull) {
          adjustedQuality = _calculateQualityBasedOnSize(fileSizeMB);
          if (adjustedQuality == 100) {
            return processedFile;
          }
        }

        processedFile = await _resizeImage(
          processedFile,
          targetWidth,
          targetHeight,
          adjustedQuality,
        );
      }

      return processedFile;
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  static Future<double> _getFileSizeInMB(File file) async {
    final sizeInBytes = await file.length();
    return sizeInBytes / (1024 * 1024);
  }

  static int _calculateQualityBasedOnSize(double fileSizeMB) {
    if (fileSizeMB < 1) return 100;
    if (fileSizeMB <= 2) return 95;
    if (fileSizeMB <= 3) return 90;
    return 80;
  }

  static Future<CroppedFile?> _cropImage({
    required String sourcePath,
    required bool isCrop,
    bool cropToSquare = false,
    int? targetWidth,
    int? targetHeight,
  }) async {
    // Hide status bar during cropping to avoid overlap with confirm button
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}

    try {
      final result = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        aspectRatio:
            _getAspectRatio(isCrop, cropToSquare, targetWidth, targetHeight),
        uiSettings: _getUISettings(isCrop),
        compressQuality: isCrop ? 90 : 35,
        compressFormat: ImageCompressFormat.jpg,
        maxWidth: targetWidth,
        maxHeight: targetHeight,
      );
      return result;
    } finally {
      // Restore system UI overlays after cropping
      try {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);
      } catch (_) {}
    }
  }

  static CropAspectRatio? _getAspectRatio(
      bool isCrop, bool cropToSquare, int? width, int? height) {
    if (!isCrop) return null;
    if (cropToSquare) return const CropAspectRatio(ratioX: 1, ratioY: 1);
    if (width != null && height != null) {
      return CropAspectRatio(
          ratioX: width.toDouble(), ratioY: height.toDouble());
    }
    return null;
  }

  static List<PlatformUiSettings> _getUISettings(bool isCrop) {
    return [
      AndroidUiSettings(
        toolbarTitle: 'قص الصورة',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: isCrop,
        initAspectRatio: CropAspectRatioPreset.original,
        activeControlsWidgetColor: Colors.deepOrange,
        cropFrameColor: Colors.white,
        cropGridColor: Colors.white54,
        statusBarColor: Colors.deepOrange,
      ),
      IOSUiSettings(
        title: 'قص الصورة',
        aspectRatioLockEnabled: isCrop,
        resetButtonHidden: isCrop,
        doneButtonTitle: 'تم',
        cancelButtonTitle: 'إلغاء',
        aspectRatioPickerButtonHidden: false,
      ),
    ];
  }

  static Future<File> _resizeImage(
      File file, int width, int height, int quality) async {
    final image = img.decodeImage(await file.readAsBytes());
    if (image == null) return file;

    final resizedImage = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.cubic,
    );

    return File(file.path)
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: quality));
  }

  static Future<File> _smartGifCompression(
      File gifFile, double originalSizeMB) async {
    log('[GIF Compression] بدء ضغط الملف: ${gifFile.path}');
    log('[GIF Compression] الحجم الأصلي: ${originalSizeMB.toStringAsFixed(2)}MB');

    final tempDir = await getTemporaryDirectory();
    final outputFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.gif');

    try {
      log('[GIF Compression] قراءة بيانات الملف...');
      final bytes = await gifFile.readAsBytes();

      log('[GIF Compression] فك تشفير GIF...');
      final gif = img.decodeGif(bytes);
      if (gif == null) {
        log('[GIF Compression] خطأ: ملف GIF غير صالح');
        return gifFile;
      }

      log('[GIF Compression] عدد الإطارات: ${gif.frames.length}');
      log('[GIF Compression] إعدادات الضغط:');
      log(' - نسبة القياس: ${_getScaleFactor(originalSizeMB)}');
      log(' - عدد الألوان: ${_getColorCount(originalSizeMB)}');
      log(' - جودة العينة: ${_getSamplingFactor(originalSizeMB)}');

      final encoder = img.GifEncoder(
        repeat: 0,
        samplingFactor: _getSamplingFactor(originalSizeMB),
      );

      log('[GIF Compression] معالجة الإطارات...');
      for (var i = 0; i < gif.frames.length; i++) {
        final frame = gif.frames[i];
        log('[GIF Compression] معالجة الإطار ${i + 1}/${gif.frames.length}');
        log(' - المدة الأصلية: ${frame.frameDuration}ms');

        final processedFrame = _processFrame(frame, originalSizeMB);
        encoder.addFrame(processedFrame, duration: frame.frameDuration);
      }

      log('[GIF Compression] إنشاء الملف المضغوط...');
      final compressedBytes = encoder.finish();
      if (compressedBytes == null) {
        log('[GIF Compression] خطأ: فشل في إنشاء GIF');
        return gifFile;
      }

      await outputFile.writeAsBytes(compressedBytes);

      log('[GIF Compression] التحقق من الحجم الجديد...');
      return outputFile;
    } catch (e) {
      log('[GIF Compression] خطأ أثناء الضغط: ${e.toString()}');
      log('[GIF Compression] إرجاع الملف الأصلي');
      return gifFile;
    }
  }

  static img.Image _processFrame(img.Image frame, double originalSizeMB) {
    final scale = _getScaleFactor(originalSizeMB);
    log(' - نسبة القياس الحالية: $scale');

    final originalWidth = frame.width;
    final originalHeight = frame.height;

    final resized = img.copyResize(
      frame,
      width: (originalWidth * scale).round(),
      height: (originalHeight * scale).round(),
    );

    log(' - الأبعاد الجديدة: ${resized.width}x${resized.height}');

    final colorCount = _getColorCount(originalSizeMB);
    log(' - تقليل الألوان إلى: $colorCount');

    return img.quantize(resized, numberOfColors: colorCount);
  }

  static double _getScaleFactor(double sizeMB) {
    if (sizeMB > 5) return 0.5;
    if (sizeMB > 3) return 0.6;
    if (sizeMB > 1.5) return 0.75;
    return 0.9;
  }

  static int _getColorCount(double sizeMB) {
    if (sizeMB > 5) return 64;
    if (sizeMB > 3) return 128;
    return 256;
  }

  static int _getSamplingFactor(double sizeMB) {
    if (sizeMB > 5) return 30;
    if (sizeMB > 3) return 40;
    return 50;
  }
}
// class ImageHelper {
//   ImageHelper._();

//   static Future<File?> pickImage({
//     bool isCrop = true,
//     bool isScreenfull = false,
//     bool cropToSquare = false,
//     int? targetWidth,
//     int? targetHeight,
//     int? screenWidth,
//     int? screenHeight,
//     int quality = 35,
//   }) async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//       if (pickedFile == null) {
//         log("No image selected.");
//         return null;
//       }

//       File selectedFile = File(pickedFile.path);
//       if (!selectedFile.existsSync()) {
//         log("File not found.");
//         return null;
//       }

//        if (selectedFile.path.toLowerCase().endsWith('.gif')) {
//         log("GIF file detected.");
//         final fileSizeMB = await _getFileSizeInMB(selectedFile);

//         if (fileSizeMB < 1) return selectedFile;
//         return await _smartGifCompression(selectedFile, fileSizeMB);
//       }

//       // Handle screen full dimensions
//       if (isScreenfull) {
//         if (screenWidth == null || screenHeight == null) {
//           throw ArgumentError(
//               'screenWidth and screenHeight are required when isScreenfull is true');
//         }
//         targetWidth = screenWidth;
//         targetHeight = screenHeight;
//         cropToSquare = false;
//       }

//       File? processedFile = selectedFile;

//       // Apply cropping if enabled
//       if (isCrop || isScreenfull) {
//         final CroppedFile? croppedFile = await _cropImage(
//           sourcePath: selectedFile.path,
//           isCrop: isCrop,
//           cropToSquare: cropToSquare,
//           targetWidth: targetWidth,
//           targetHeight: targetHeight,
//         );

//         if (isCrop && croppedFile == null) return null;
//         if (croppedFile != null) processedFile = File(croppedFile.path);
//       }

//       // Apply resizing and quality adjustment
//       if (targetWidth != null && targetHeight != null) {
//         final fileSizeMB = await _getFileSizeInMB(processedFile!);
//         int adjustedQuality = quality;

//         if (isScreenfull) {
//           adjustedQuality = _calculateQualityBasedOnSize(fileSizeMB);
//           if (adjustedQuality == 100) {
//             // تخطى الضغط إذا كانت الجودة 100%
//             return processedFile;
//           }
//         }

//         processedFile = await _resizeImage(
//           processedFile!,
//           targetWidth,
//           targetHeight,
//           adjustedQuality,
//         );
//       }

//       return processedFile;
//     } catch (e) {
//       log("Error: $e");
//       return null;
//     }
//   }

//   static Future<double> _getFileSizeInMB(File file) async {
//     final sizeInBytes = await file.length();
//     return sizeInBytes / (1024 * 1024);
//   }

//   static int _calculateQualityBasedOnSize(double fileSizeMB) {
//     if (fileSizeMB < 1) return 100;    // أقل من 1 ميجا: جودة كاملة
//     if (fileSizeMB <= 2) return 95;     // 1-2 ميجا: جودة 95%
//     if (fileSizeMB <= 3) return 90;     // 2-3 ميجا: جودة 90%
//     return 80;                          // أكثر من 3 ميجا: جودة 80%
//   }

//   static Future<CroppedFile?> _cropImage({
//     required String sourcePath,
//     required bool isCrop,
//     bool cropToSquare = false,
//     int? targetWidth,
//     int? targetHeight,
//   }) async {
//     return await ImageCropper().cropImage(
//       sourcePath: sourcePath,
//       aspectRatio:
//           _getAspectRatio(isCrop, cropToSquare, targetWidth, targetHeight),
//       uiSettings: _getUISettings(isCrop),
//       compressQuality: isCrop ? 90 : 35,
//       compressFormat: ImageCompressFormat.jpg,
//       maxWidth: targetWidth,
//       maxHeight: targetHeight,
//     );
//   }

//   static CropAspectRatio? _getAspectRatio(
//       bool isCrop, bool cropToSquare, int? width, int? height) {
//     if (!isCrop) return null;
//     if (cropToSquare) return const CropAspectRatio(ratioX: 1, ratioY: 1);
//     if (width != null && height != null)
//       return CropAspectRatio(
//           ratioX: width.toDouble(), ratioY: height.toDouble());
//     return null;
//   }

//   static List<PlatformUiSettings> _getUISettings(bool isCrop) {
//     return [
//       AndroidUiSettings(
//         toolbarTitle: 'قص الصورة',
//         toolbarColor: Colors.deepOrange,
//         toolbarWidgetColor: Colors.white,
//         lockAspectRatio: isCrop,
//         initAspectRatio: CropAspectRatioPreset.original,
//         activeControlsWidgetColor: Colors.deepOrange,
//         cropFrameColor: Colors.white,
//         cropGridColor: Colors.white54,
//       ),
//       IOSUiSettings(
//         title: 'قص الصورة',
//         aspectRatioLockEnabled: isCrop,
//         resetButtonHidden: isCrop,
//         doneButtonTitle: 'تم',
//         cancelButtonTitle: 'إلغاء',
//         aspectRatioPickerButtonHidden: false,
//       ),
//     ];
//   }

//   static Future<File> _resizeImage(
//       File file, int width, int height, int quality) async {
//     final image = img.decodeImage(await file.readAsBytes());
//     if (image == null) return file;

//     final resizedImage = img.copyResize(
//       image,
//       width: width,
//       height: height,
//       interpolation: img.Interpolation.cubic,
//     );

//     return File(file.path)
//       ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: quality));
//   }
// static Future<File> _smartGifCompression(File gifFile, double originalSizeMB) async {
//     log('[GIF Compression] بدء ضغط الملف: ${gifFile.path}');
//     log('[GIF Compression] الحجم الأصلي: ${originalSizeMB.toStringAsFixed(2)}MB');

//     final tempDir = await getTemporaryDirectory();
//     final outputFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.gif');

//     try {
//       log('[GIF Compression] قراءة بيانات الملف...');
//       final bytes = await gifFile.readAsBytes();

//       log('[GIF Compression] فك تشفير GIF...');
//       final gif = img.decodeGif(bytes);
//       if (gif == null) {
//         log('[GIF Compression] خطأ: ملف GIF غير صالح');
//         return gifFile;
//       }

//       log('[GIF Compression] عدد الإطارات: ${gif.frames.length}');
//       log('[GIF Compression] إعدادات الضغط:');
//       log(' - نسبة القياس: ${_getScaleFactor(originalSizeMB)}');
//       log(' - عدد الألوان: ${_getColorCount(originalSizeMB)}');
//       log(' - جودة العينة: ${_getSamplingFactor(originalSizeMB)}');

//       final encoder = img.GifEncoder(
//         repeat: 0,
//         samplingFactor: _getSamplingFactor(originalSizeMB),
//       );

//       log('[GIF Compression] معالجة الإطارات...');
//       for (var i = 0; i < gif.frames.length; i++) {
//         final frame = gif.frames[i];
//         log('[GIF Compression] معالجة الإطار ${i + 1}/${gif.frames.length}');
//         log(' - المدة الأصلية: ${frame.frameDuration}ms');

//         final processedFrame = _processFrame(frame, originalSizeMB);
//         encoder.addFrame(processedFrame, duration: frame.frameDuration);
//       }

//       log('[GIF Compression] إنشاء الملف المضغوط...');
//       final compressedBytes = encoder.finish();
//       if (compressedBytes == null) {
//         log('[GIF Compression] خطأ: فشل في إنشاء GIF');
//         return gifFile;
//       }

//       await outputFile.writeAsBytes(compressedBytes);

//       log('[GIF Compression] التحقق من الحجم الجديد...');
//       return await _verifyAndRecompress(outputFile, originalSizeMB);
//     } catch (e) {
//       log('[GIF Compression] خطأ أثناء الضغط: ${e.toString()}');
//       log('[GIF Compression] إرجاع الملف الأصلي');
//       return gifFile;
//     }
//   }

//  static img.Image _processFrame(img.Image frame, double originalSizeMB) {
//     final scale = _getScaleFactor(originalSizeMB);
//     log(' - نسبة القياس الحالية: $scale');

//     final originalWidth = frame.width;
//     final originalHeight = frame.height;

//     final resized = img.copyResize(
//       frame,
//       width: (originalWidth * scale).round(),
//       height: (originalHeight * scale).round(),
//     );

//     log(' - الأبعاد الجديدة: ${resized.width}x${resized.height}');

//     final colorCount = _getColorCount(originalSizeMB);
//     log(' - تقليل الألوان إلى: $colorCount');

//     return img.quantize(resized, numberOfColors: colorCount);
//   }
//  static Future<File> _verifyAndRecompress(File outputFile, double originalSizeMB) async {
//     final newSizeMB = await _getFileSizeInMB(outputFile);
//     log('[GIF Compression] الحجم بعد الضغط: ${newSizeMB.toStringAsFixed(2)}MB');

//     if (newSizeMB > 1.5 && originalSizeMB > 1.5) {
//       log('[GIF Compression] الحجم لا يزال أكبر من 1.5MB، إعادة الضغط...');
//       return _smartGifCompression(outputFile, newSizeMB);
//     }

//     log('[GIF Compression] الضغط اكتمل بنجاح');
//     return outputFile;
//   }
//   static double _getScaleFactor(double sizeMB) {
//     if (sizeMB > 5) return 0.5;
//     if (sizeMB > 3) return 0.6;
//     if (sizeMB > 1.5) return 0.75;
//     return 0.9;
//   }

//   static int _getColorCount(double sizeMB) {
//     if (sizeMB > 5) return 64;
//     if (sizeMB > 3) return 128;
//     return 256;
//   }

//   static int _getSamplingFactor(double sizeMB) {
//     if (sizeMB > 5) return 30;
//     if (sizeMB > 3) return 40;
//     return 50;
//   }

// }
