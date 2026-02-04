import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:developer' as dev;

/// مُحسِّن كاش الصور - تحسين بسيط وآمن
class ImageCacheOptimizer {
  static const String _logTag = 'ImageCacheOptimizer';

  /// تحسين إعدادات كاش الصور
  static void optimizeImageCache() {
    try {
      // زيادة حجم كاش الصور في الذاكرة
      PaintingBinding.instance.imageCache.maximumSize = 200; // بدلاً من 100
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          50 << 20; // 50 MB بدلاً من 10 MB

      dev.log('✅ Image cache optimized - Size: 200, Bytes: 50MB',
          name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to optimize image cache: $e', name: _logTag);
    }
  }

  /// مسح كاش الصور عند الحاجة
  static void clearImageCache() {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      dev.log('🗑️ Image cache cleared', name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to clear image cache: $e', name: _logTag);
    }
  }

  /// إحصائيات كاش الصور
  static Map<String, dynamic> getCacheStats() {
    final cache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': cache.currentSize,
      'maximumSize': cache.maximumSize,
      'currentSizeBytes': cache.currentSizeBytes,
      'maximumSizeBytes': cache.maximumSizeBytes,
      'liveImageCount': cache.liveImageCount,
      'pendingImageCount': cache.pendingImageCount,
    };
  }

  /// تحسين صورة واحدة
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: (width ?? 200).toInt(),
      maxHeightDiskCache: (height ?? 200).toInt(),
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child:
                const Icon(Icons.error_outline, color: const Color(0xFFFF0000)),
          ),
    );
  }
}

/// Widget محسن للصور الدائرية
class OptimizedCircularImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedCircularImage({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ImageCacheOptimizer.optimizedImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: placeholder,
        errorWidget: errorWidget,
      ),
    );
  }
}
