import 'package:flutter/material.dart';

/// هذا الديالوغ يعرض خيارات المدة ويعيد القيمة المختارة
class CustomDurationDialog extends StatelessWidget {
  const CustomDurationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // القيم مع النصوص
    final Map<String, String> options = {
      "5m": "خمس دقائق",
      "1h": "ساعة",
      "1m": "شهر",
      "1y": "سنة",
    };

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // حجم على قد المحتوى
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "اختر المدة",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // نرسم الخيارات
            ...options.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(entry.key); // ترجيع القيمة
                  },
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
