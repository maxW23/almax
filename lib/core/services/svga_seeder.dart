import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SvgaSeeder {
  /// ينسخ جميع ملفات SVGA الموجودة تحت مجلد الأصول 'svgaـfiles/'
  /// إلى مجلد محلي: ApplicationDocumentsDirectory/downloads/
  /// - عملية آمنة ومتكررة: تنسخ فقط الملفات غير الموجودة.
  static Future<void> seedIfNeeded() async {
    try {
      // مجلد التخزين المحلي: .../downloads/
      final appDocDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(p.join(appDocDir.path, 'downloads'));
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // قراءة AssetManifest لاستخراج جميع الأصول
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

      // البحث عن كل ملفات SVGA تحت 'svga files/'
      final svgaAssets = manifestMap.keys.where(
        (key) =>
            key.startsWith('svga_files/') &&
            key.toLowerCase().endsWith('.svga'),
      );

      // نسخ الملفات غير الموجودة فقط
      for (final assetPath in svgaAssets) {
        final fileName = p.basename(assetPath);
        final localFile = File(p.join(downloadsDir.path, fileName));
        if (await localFile.exists()) {
          continue; // موجود مسبقاً
        }
        final data = await rootBundle.load(assetPath);
        final bytes = data.buffer.asUint8List();
        await localFile.writeAsBytes(bytes, flush: true);
      }
    } catch (_) {
      // تجاهل الأخطاء بهدوء لتجنب تعطيل شاشة البداية
    }
  }
}
