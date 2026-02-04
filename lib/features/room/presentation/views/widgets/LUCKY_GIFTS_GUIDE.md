# 🎯 دليل نظام هدايا الحظ الاحترافي

## 📋 المحتويات
1. [نظرة عامة](#نظرة-عامة)
2. [المكونات](#المكونات)
3. [التكامل السريع](#التكامل-السريع)
4. [الاستخدام المتقدم](#الاستخدام-المتقدم)
5. [حل المشاكل](#حل-المشاكل)

---

## 🎯 نظرة عامة

نظام هدايا الحظ الاحترافي يوفر:
- ✨ أنيميشن مذهل مع تأثيرات جزيئات وتوهج
- ⚡ معالجة فائقة السرعة (100ms)
- 🎯 نظام أولويات ذكي
- 🔥 نظام Combo للهدايا المتتالية
- 📊 مراقب أداء يضمن 60 FPS

---

## 📦 المكونات

### 1. **EnhancedLuckyGiftManager**
مدير الرتل المحسّن مع نظام الأولويات

### 2. **ProfessionalGiftAnimation**
أنيميشن احترافي مع تأثيرات مذهلة

### 3. **EnhancedLuckyGiftDisplay**
واجهة عرض تفاعلية وعصرية

### 4. **LuckyGiftSystemIntegration**
نظام التكامل الذي يربط كل شيء

---

## 🚀 التكامل السريع

### الخطوة 1: استيراد الملفات

```dart
import 'package:lklk/features/room/presentation/views/widgets/lucky_gift_system_integration.dart';
import 'package:lklk/features/room/presentation/views/widgets/enhanced_lucky_gift_display.dart';
```

### الخطوة 2: في `room_view_body.dart`

```dart
class _RoomViewBodyState extends State<RoomViewBody> {
  // إضافة النظام
  final _luckySystem = LuckyGiftSystemIntegration();
  List<Widget> _giftAnimations = [];

  @override
  void initState() {
    super.initState();
    
    // تهيئة النظام
    _luckySystem.initialize(
      onAnimationsUpdated: (animations) {
        setState(() {
          _giftAnimations = animations;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // محتوى الغرفة
        _buildRoomContent(),
        
        // طبقة أنيميشنز الهدايا
        ..._giftAnimations,
        
        // واجهة عرض الرتل
        _luckySystem.buildDisplay(),
      ],
    );
  }

  @override
  void dispose() {
    _luckySystem.dispose();
    super.dispose();
  }
}
```

### الخطوة 3: إضافة هدية عند استقبالها

```dart
void _onGiftReceived(Map<String, dynamic> giftData) {
  // التحقق من نوع الهدية
  if (giftData['type'] == 'lucky') {
    _luckySystem.addLuckyGift(
      giftId: giftData['id'],
      senderId: giftData['sender_id'],
      senderName: giftData['sender_name'],
      receiverId: giftData['receiver_id'],
      receiverName: giftData['receiver_name'],
      imageUrl: giftData['image_url'],
      count: giftData['count'],
      senderOffset: _getSenderPosition(giftData['sender_id']),
      targetOffset: _getReceiverPosition(giftData['receiver_id']),
      isVip: giftData['is_vip'] ?? false,
      specialEffect: giftData['special_effect'],
      microphoneNumber: widget.room.microphoneNumber,
    );
  }
}
```

---

## 🎨 الاستخدام المتقدم

### تخصيص الأولويات

```dart
// هدية VIP بأولوية عالية
_luckySystem.addLuckyGift(
  // ...
  isVip: true, // +1000 أولوية
  count: 999,  // +500 أولوية إضافية
  specialEffect: 'golden_burst', // +200 أولوية
);
```

### التحكم في سرعة المعالجة

في `EnhancedLuckyGiftManager`:
```dart
// تغيير سرعة المعالجة (افتراضي: 100ms)
static const Duration processingInterval = Duration(milliseconds: 50);

// تغيير الحد الأقصى للهدايا المتزامنة (افتراضي: 5)
static const int maxConcurrentGifts = 7;
```

### تخصيص التأثيرات

في `ProfessionalGiftAnimation`:
```dart
// عدد الجزيئات
static const int _kParticleCount = 30; // افتراضي: 20

// حجم التوهج
static const double _kGlowRadius = 50.0; // افتراضي: 30

// مضاعف combo
static const double _kComboScale = 2.0; // افتراضي: 1.5
```

---

## 🔧 حل المشاكل

### المشكلة: الأنيميشن بطيء
**الحل**: تحقق من FPS في الواجهة وقلل عدد الهدايا المتزامنة

### المشكلة: الهدايا لا تظهر
**الحل**: تأكد من استدعاء `initialize()` وإضافة `_giftAnimations` للـ Stack

### المشكلة: Combo لا يعمل
**الحل**: تأكد من إرسال نفس `senderId` للهدايا المتتالية

---

## 📊 مراقبة الأداء

```dart
// الحصول على حالة النظام
final status = _luckySystem.getSystemStatus();

print('Queue Size: ${status.queueSize}');
print('Displaying: ${status.displayingCount}');
print('FPS: ${status.performanceFps}');
print('Active Combos: ${status.activeCombos.length}');
```

---

## 🎯 نصائح للأداء الأمثل

1. **استخدم الأولويات بذكاء**: أعطِ الأولوية للهدايا المهمة
2. **راقب FPS**: إذا انخفض عن 50، قلل الهدايا المتزامنة
3. **نظف الذاكرة**: استدعِ `dispose()` عند الخروج من الغرفة
4. **استخدم التخزين المؤقت**: الصور المخزنة مسبقاً تحسن الأداء

---

## 📝 مثال كامل

```dart
class RoomViewWithLuckyGifts extends StatefulWidget {
  final RoomEntity room;
  
  const RoomViewWithLuckyGifts({
    super.key,
    required this.room,
  });

  @override
  State<RoomViewWithLuckyGifts> createState() => _RoomViewWithLuckyGiftsState();
}

class _RoomViewWithLuckyGiftsState extends State<RoomViewWithLuckyGifts> {
  final _luckySystem = LuckyGiftSystemIntegration();
  List<Widget> _giftAnimations = [];

  @override
  void initState() {
    super.initState();
    
    // تهيئة نظام الهدايا
    _luckySystem.initialize(
      onAnimationsUpdated: (animations) {
        if (mounted) {
          setState(() {
            _giftAnimations = animations;
          });
        }
      },
    );
    
    // الاستماع للهدايا من WebSocket
    _listenToGifts();
  }

  void _listenToGifts() {
    // مثال على WebSocket
    socketManager.on('new_gift', (data) {
      if (data['type'] == 'lucky') {
        _handleLuckyGift(data);
      }
    });
  }

  void _handleLuckyGift(Map<String, dynamic> data) {
    _luckySystem.addLuckyGift(
      giftId: data['id'],
      senderId: data['sender_id'],
      senderName: data['sender_name'],
      receiverId: data['receiver_id'],
      receiverName: data['receiver_name'],
      imageUrl: data['image_url'],
      count: data['count'],
      senderOffset: Offset(50, 400), // من موضع المرسل
      targetOffset: Offset(300, 400), // إلى موضع المستقبل
      centerOffset: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2 - 100,
      ),
      isVip: data['is_vip'] ?? false,
      specialEffect: data['special_effect'],
      microphoneNumber: widget.room.microphoneNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // محتوى الغرفة الأساسي
          RoomContent(room: widget.room),
          
          // طبقة أنيميشنز الهدايا
          ..._giftAnimations,
          
          // واجهة عرض الرتل الاحترافية
          _luckySystem.buildDisplay(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _luckySystem.dispose();
    super.dispose();
  }
}
```

---

## ✅ الخلاصة

النظام الآن:
- ✅ **جاهز للاستخدام** بخطوات بسيطة
- ✅ **احترافي** بتأثيرات مذهلة
- ✅ **سريع** بمعالجة 100ms
- ✅ **ذكي** بنظام أولويات
- ✅ **قابل للتوسع** يدعم مئات الهدايا

للدعم: راجع الكود المصدري أو اتصل بفريق التطوير 🚀
