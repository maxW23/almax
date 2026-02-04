// ملف صغير لتجميع تعريفات مشتركة

enum LuckyBagType { normal, superr }

/// نتيجة الديالوغ التي سنرجعها للأب
class LuckyBagResult {
  final LuckyBagType type; // نوع الحقيبة (اختياري للاستخدام المستقبلي)
  final int amount; // how: قيمة الكوينز (كمية حقيبة الحظ)
  final int maxParticipants; // who: الحد الأقصى لعدد المشاركين

  const LuckyBagResult({
    required this.type,
    required this.amount,
    required this.maxParticipants,
  });
}
