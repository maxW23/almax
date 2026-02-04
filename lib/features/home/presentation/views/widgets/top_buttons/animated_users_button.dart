import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

/// AnimatedUsersButton
/// ويدجت عامة لعرض صور مستخدمين داخل زر بخلفية ثابتة مع أنيميشن تبديل مجموعات.
/// - تحافظ على نفس الأنيميشن: SlideTransition خروج/دخول، مدة 6 ثواني،
///   تبديل مجموعتين بشكل متتابع، البداية من الأسفل.
/// - مرنة عبر باراميترات للتحكم الكامل بالسلوك.
class AnimatedUsersButton extends StatefulWidget {
  // ===== المظهر =====
  /// مسار صورة خلفية الزر
  final String buttonImagePath;

  /// مسار إطار الصورة الذي يوضع فوق كل صورة مستخدم
  final String frameImagePath;

  /// أيقونة اختيارية تُعرض في المنتصف بين الصور
  final String? middleIconPath;

  // ===== البيانات =====
  /// Endpoint مباشر. إذا تم تمريره، يُستخدم مباشرة.
  final String? apiEndpoint;

  /// كود الـ API (يُستخدم إذا لم يتم تمرير apiEndpoint).
  /// code == 1 => '/toproom1'، غير ذلك => '/top/{code}'
  final int? apiCode;

  /// تفعيل ForceRefresh عند الجلب الأول لتجاوز الكاش
  final bool forceRefresh;

  // ===== سلوك العرض =====
  /// عدد الصور في كل مجموعة (مثلاً: 3 لـ Top، 2 لـ Relation)
  final int itemsPerGroup;

  /// عدد المجموعات المراد عرضها (يُشتق منه الحد الأقصى للعناصر). إن لم يُمرر، تُستخدم مجموعتان.
  final int? groupsCount;

  /// حد أقصى للعناصر (إن تم تمريره يُقدَّم على groupsCount)
  final int? totalItemsLimit;

  /// دالة يتم استدعاؤها عند الضغط على الزر
  final VoidCallback? onTap;

  // ===== إعدادات شكلية إضافية =====
  /// حشوة داخلية لمحتوى الصور داخل الخلفية
  final EdgeInsets contentPadding;

  /// حجم الصورة الدائري (الافتراضي 36 ليطابق AnimatedTopButton)
  final double avatarSize;

  /// نسبة فراغ يمين الزر (0.14 كما في الويدجات الأصلية)
  final double rightSpacerFraction;

  /// مدة دورة الأنيميشن (الافتراضي 6000ms)
  final Duration duration;

  /// إزاحة رأسية بسيطة لإزاحة المحتوى (كما في الأصل = 5)
  final double verticalOffset;

  const AnimatedUsersButton({
    super.key,
    required this.buttonImagePath,
    required this.frameImagePath,
    this.middleIconPath,
    this.apiEndpoint,
    this.apiCode,
    this.forceRefresh = false,
    // العرض الافتراضي: مجموعتان × itemsPerGroup
    required this.itemsPerGroup,
    this.groupsCount,
    this.totalItemsLimit,
    this.onTap,
    this.contentPadding = const EdgeInsets.only(top: 10),
    this.avatarSize = 36.0,
    this.rightSpacerFraction = 0.14,
    this.duration = const Duration(milliseconds: 6000),
    this.verticalOffset = 5.0,
  });

  @override
  State<AnimatedUsersButton> createState() => _AnimatedUsersButtonState();
}

class _AnimatedUsersButtonState extends State<AnimatedUsersButton>
    with TickerProviderStateMixin {
  // ===== Animation fields =====
  late AnimationController _controller;
  late Animation<Offset> _slideOut;
  late Animation<Offset> _slideIn;

  // مؤشر المجموعة الحالية
  int _currentGroup = 0;

  // بدء الأنيميشن بعد أول تحميل لضمان البداية من الأسفل
  bool _started = false;

  // إجمالي العناصر المستهدفة (limit) وعدد المجموعات الفعلي
  int _limit = 0;
  int _maxGroups = 1;

  // Cubit محلي يتم إنشاؤه مرة واحدة لتجنّب إنشاء cubit في كل build
  late final TopUsersCubit _cubit;
  // نحتفظ بالـ endpoint الحالي لمعرفة التغييرات بين إعادة البناء
  late String _endpoint;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // احسب endpoint مرة واحدة عند الإنشاء
    _endpoint = _resolveEndpoint();
    // أنشئ Cubit مرة واحدة فقط
    _cubit = TopUsersCubit();
    // الجلب الأول (مع احترام forceRefresh إن طُلب)
    _cubit.fetchTopImages(_endpoint, forceRefresh: widget.forceRefresh);
  }

  @override
  void dispose() {
    _controller.dispose();
    // إغلاق الـ Cubit عند التخلص من الودجت
    _cubit.close();
    super.dispose();
  }

  // ===== animation setup =====
  void _setupAnimations() {
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // خروج: أسفل -> منتصف (توقف) -> أعلى
    _slideOut = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1500,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(Offset.zero),
        weight: 3000,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1500,
      ),
    ]).animate(_controller);

    // دخول: يبدأ في الربع الأخير من الزمن (0.75 -> 1.0)
    _slideIn = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeInOutCubic),
    ));

    // التبديل بين المجموعات وإعادة التشغيل من طور المنتصف
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentGroup = (_currentGroup + 1) % _maxGroups;
        });
        _controller.forward(from: 0.25);
      }
    });
  }

  // ===== endpoint resolve =====
  String _resolveEndpoint() {
    if (widget.apiEndpoint != null && widget.apiEndpoint!.isNotEmpty) {
      return widget.apiEndpoint!;
    }
    final code = widget.apiCode ?? 0;
    if (code == 1) return '/toproom1';
    return '/top/$code';
  }

  @override
  void didUpdateWidget(covariant AnimatedUsersButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // أعد حساب endpoint وإذا تغيّر أعِد الجلب مرة واحدة
    final newEndpoint = _resolveEndpoint();
    if (newEndpoint != _endpoint) {
      _endpoint = newEndpoint;
      _cubit.fetchTopImages(_endpoint, forceRefresh: true);
    }
  }

  // ===== data helpers =====
  /// يحدد الحد الأقصى للعناصر المستهدفة اعتماداً على البراميترات
  int _computeLimit() {
    if (widget.totalItemsLimit != null) {
      final v = widget.totalItemsLimit!;
      if (v < 0) return 0;
      if (v > 1000) return 1000;
      return v;
    }
    final groups = widget.groupsCount ?? 2; // افتراضي مجموعتان
    final v = groups * widget.itemsPerGroup;
    if (v < 0) return 0;
    if (v > 1000) return 1000;
    return v;
  }

  /// إرجاع صور المجموعة الحالية اعتماداً على الفهرس والحجم
  List<String> _getCurrentImages(List<String> all) {
    final startRaw = _currentGroup * widget.itemsPerGroup;
    final start = startRaw < 0
        ? 0
        : (startRaw > all.length ? all.length : startRaw);
    final endRaw = start + widget.itemsPerGroup;
    final end = endRaw > all.length ? all.length : endRaw;
    if (start >= end) return const [];
    return all.sublist(start, end);
  }

  /// المجموعة التالية (للـ SlideTransition الثاني)
  List<String> _getNextImages(List<String> all) {
    final nextGroup = (_currentGroup + 1) % _maxGroups;
    final startRaw = nextGroup * widget.itemsPerGroup;
    final start = startRaw < 0
        ? 0
        : (startRaw > all.length ? all.length : startRaw);
    final endRaw = start + widget.itemsPerGroup;
    final end = endRaw > all.length ? all.length : endRaw;
    if (start >= end) return const [];
    return all.sublist(start, end);
  }

  // ===== UI builders =====
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.buttonImagePath),
              fit: BoxFit.fill,
            ),
          ),
          child: BlocBuilder<TopUsersCubit, TopUsersState>(
            builder: (context, state) {
              if (state is TopImagesLoaded) {
                // تجهيز البيانات وفقاً للحدود المطلوبة
                final imgs = state.imageUrls;
                _limit = _computeLimit();
                final limited = (imgs.length > _limit && _limit > 0)
                    ? imgs.take(_limit).toList()
                    : imgs.toList();

                if (limited.isEmpty) return const SizedBox.shrink();

                // حساب عدد المجموعات الفعلي
                _maxGroups = (limited.length / widget.itemsPerGroup).ceil();
                if (_maxGroups < 1) _maxGroups = 1;
                if (_currentGroup >= _maxGroups) _currentGroup = 0;

                final current = _getCurrentImages(limited);
                final next = _getNextImages(limited);

                // بدء الأنيميشن بعد أول تحميل فقط
                if (!_started) {
                  _started = true;
                  _controller.forward(from: 0.0);
                }

                return ClipRect(
                  child: Stack(
                    children: [
                      SlideTransition(
                        position: _slideOut,
                        child: Transform.translate(
                          offset: Offset(0, widget.verticalOffset),
                          child: _buildImagesRow(current),
                        ),
                      ),
                      SlideTransition(
                        position: _slideIn,
                        child: Transform.translate(
                          offset: Offset(0, widget.verticalOffset),
                          child: _buildImagesRow(next),
                        ),
                      ),
                    ],
                  ),
                );
              }
              // تحميل/خطأ -> لا شيء (مطابق للويدجات الأصلية)
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  /// بناء صف الصور مع إدراج الأيقونة الوسطية (إن وُجدت)
  Widget _buildImagesRow(List<String> imageUrls) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rightSpacer = constraints.maxWidth * widget.rightSpacerFraction;

        final children = <Widget>[];
        final n = imageUrls.length;
        final double dim = widget.avatarSize;
        final double radius = dim / 2;

        // مساعد: يبني صورة مستخدم واحدة
        Widget buildAvatar(String url) {
          return SizedBox(
            width: dim,
            height: dim,
            child: Center(
              child: CircularUserImage(
                imagePath: url,
                radius: radius,
                innerPadding: .8,
                frameOverlayAsset: widget.frameImagePath,
                frameOverlayAssetFit: BoxFit.cover,
              ),
            ),
          );
        }

        // توليد العناصر مع مراعاة middleIconPath
        if (n == 0) {
          // لا شيء
        } else if (n == 1) {
          children.add(buildAvatar(imageUrls[0]));
        } else {
          // عند وجود أيقونة، ضعها في المنتصف
          final hasMiddle = (widget.middleIconPath != null && widget.middleIconPath!.isNotEmpty);
          if (hasMiddle) {
            // الموضع الأوسط بين العناصر (مثالي لحالة 2 صورة)
            final mid = n ~/ 2;
            for (int i = 0; i < n; i++) {
              if (i == mid) {
                children.add(_buildMiddleIcon());
              }
              children.add(buildAvatar(imageUrls[i]));
            }
          } else {
            // بدون أيقونة وسطية
            for (final url in imageUrls) {
              children.add(buildAvatar(url));
            }
          }
        }

        return Padding(
          padding: widget.contentPadding,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: children,
                ),
              ),
              // ترك فراغ يمين الزر
              SizedBox(width: rightSpacer),
            ],
          ),
        );
      },
    );
  }

  /// أيقونة وسطية اختيارية
  Widget _buildMiddleIcon() {
    return (widget.middleIconPath == null)
        ? const SizedBox.shrink()
        : Image.asset(
            widget.middleIconPath!,
            width: 25,
            height: 25,
            fit: BoxFit.fill,
          );
  }
}
