import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';

/// 🎨 أنيميشن هدايا احترافي مع تأثيرات مذهلة
class ProfessionalGiftAnimation extends StatefulWidget {
  final GiftAnimationData giftData;
  final VoidCallback onAnimationComplete;
  final int comboLevel;
  final String? specialEffect;
  final String? queueItemId;

  const ProfessionalGiftAnimation({
    super.key,
    required this.giftData,
    required this.onAnimationComplete,
    this.comboLevel = 1,
    this.specialEffect,
    this.queueItemId,
  });

  @override
  State<ProfessionalGiftAnimation> createState() =>
      _ProfessionalGiftAnimationState();
}

class _ProfessionalGiftAnimationState extends State<ProfessionalGiftAnimation>
    with TickerProviderStateMixin {
  // ==================== المتحكمات الأساسية ====================
  late AnimationController _mainController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _trailController;
  late AnimationController _comboController;

  // ==================== الأنيميشنز ====================
  late Animation<Offset> _pathAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _opacityAnimation;

  // ==================== الجزيئات والتأثيرات ====================
  final List<Particle> _particles = [];
  final List<TrailPoint> _trailPoints = [];
  late CachedNetworkImageProvider _imageProvider;

  // ==================== المواضع ====================
  Offset? _startPosition;
  Offset? _endPosition;
  Offset? _currentPosition;

  // ==================== الثوابت الاحترافية ====================
  static const int _kParticleCount = 20;
  static const double _kGlowRadius = 30.0;
  static const double _kComboScale = 1.5;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startProfessionalAnimation();
  }

  void _initializeAnimations() {
    // حساب المدة مع تسريع combo
    final baseDuration = widget.giftData.duration;
    final speedMultiplier = 1.0 + (widget.comboLevel * 0.2);
    final duration = Duration(
        milliseconds: (baseDuration.inMilliseconds / speedMultiplier).round());

    // المتحكم الرئيسي
    _mainController = AnimationController(
      duration: duration,
      vsync: this,
    );

    // متحكم التوهج
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // متحكم الجزيئات
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // متحكم المسار
    _trailController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();

    // متحكم combo
    _comboController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (widget.comboLevel > 1) {
      _comboController.repeat(reverse: true);
    }

    // إعداد المواضع
    _startPosition = widget.giftData.senderOffset;
    _endPosition = widget.giftData.targetOffset;
    final centerPoint = widget.giftData.centerOffset;

    // مسار منحني احترافي
    _pathAnimation = TweenSequence<Offset>([
      // من المرسل للمركز بسرعة مع منحنى
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: _startPosition!,
          end: centerPoint,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      // البقاء في المركز مع اهتزاز خفيف
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: centerPoint,
          end: centerPoint,
        ),
        weight: 40,
      ),
      // من المركز للمستقبل بتسارع
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: centerPoint,
          end: _endPosition!,
        ).chain(CurveTween(curve: Curves.easeInQuart)),
        weight: 30,
      ),
    ]).animate(_mainController);

    // تكبير احترافي
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
            begin: 0.0,
            end: 1.5 * (widget.comboLevel > 1 ? _kComboScale : 1.0)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
            begin: 1.5 * (widget.comboLevel > 1 ? _kComboScale : 1.0),
            end: 2.0 * (widget.comboLevel > 1 ? _kComboScale : 1.0)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
            begin: 2.0 * (widget.comboLevel > 1 ? _kComboScale : 1.0),
            end: 0.0),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOutBack,
    ));

    // دوران ديناميكي
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: widget.comboLevel > 2 ? math.pi * 4 : math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    // توهج متدرج
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_glowController);

    // شفافية احترافية
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 10,
      ),
    ]).animate(_mainController);

    // تحضير الصورة
    _imageProvider = CachedNetworkImageProvider(widget.giftData.imageUrl);
    precacheImage(_imageProvider, context);

    // إنشاء الجزيئات
    _createParticles();
  }

  void _createParticles() {
    final random = math.Random();
    for (int i = 0; i < _kParticleCount; i++) {
      _particles.add(Particle(
        position: Offset.zero,
        velocity: Offset(
          (random.nextDouble() - 0.5) * 200,
          (random.nextDouble() - 0.5) * 200,
        ),
        color: _getParticleColor(i),
        size: random.nextDouble() * 4 + 2,
        lifespan: random.nextDouble() * 2 + 1,
      ));
    }
  }

  Color _getParticleColor(int index) {
    final colors = [
      Colors.yellow,
      Colors.orange,
      const Color(0xFFFF0000),
      Colors.purple,
      Colors.blue,
      Colors.green,
    ];

    if (widget.comboLevel > 2) {
      // ألوان قوس قزح للـ combo العالي
      return colors[index % colors.length];
    }

    // ألوان ذهبية للعادي
    return Color.lerp(Colors.yellow, Colors.orange, index / _kParticleCount)!;
  }

  void _startProfessionalAnimation() {
    // تأثير الدخول
    HapticFeedback.lightImpact();

    // بدء الأنيميشن الرئيسي
    _mainController.forward().then((_) {
      // تأثير الخروج
      if (widget.comboLevel > 1) {
        HapticFeedback.mediumImpact();
      }

      // تنظيف وإنهاء
      Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          widget.onAnimationComplete();
        }
      });
    });

    // تحديث المسار
    _mainController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = _pathAnimation.value;
          _updateTrail();
          _updateParticles();
        });
      }
    });
  }

  void _updateTrail() {
    if (_currentPosition != null) {
      _trailPoints.add(TrailPoint(
        position: _currentPosition!,
        timestamp: DateTime.now(),
        opacity: 1.0,
      ));

      // إزالة النقاط القديمة
      final now = DateTime.now();
      _trailPoints.removeWhere(
          (point) => now.difference(point.timestamp).inMilliseconds > 500);

      // تحديث الشفافية
      for (var point in _trailPoints) {
        final age = now.difference(point.timestamp).inMilliseconds;
        point.opacity = 1.0 - (age / 500);
      }
    }
  }

  void _updateParticles() {
    if (_currentPosition != null) {
      for (var particle in _particles) {
        particle.update(_currentPosition!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // طبقة المسار المضيء
        if (widget.comboLevel > 1)
          CustomPaint(
            painter: TrailPainter(
              points: _trailPoints,
              color: Colors.amber.withValues(alpha: 0.5),
            ),
            child: Container(),
          ),

        // طبقة الجزيئات
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                progress: _particleController.value,
              ),
              child: Container(),
            );
          },
        ),

        // الهدية الرئيسية مع التأثيرات
        AnimatedBuilder(
          animation: Listenable.merge([
            _mainController,
            _glowController,
          ]),
          builder: (context, child) {
            if (_currentPosition == null) return const SizedBox.shrink();

            return Positioned(
              left: _currentPosition!.dx - 40,
              top: _currentPosition!.dy - 40,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(_scaleAnimation.value)
                    ..rotateZ(_rotationAnimation.value),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      // التوهج الخارجي
                      boxShadow: [
                        if (widget.comboLevel > 1)
                          BoxShadow(
                            color: Colors.amber
                                .withValues(alpha: _glowAnimation.value * 0.8),
                            blurRadius: _kGlowRadius * _glowAnimation.value,
                            spreadRadius:
                                _kGlowRadius * 0.5 * _glowAnimation.value,
                          ),
                        BoxShadow(
                          color: Colors.yellow
                              .withValues(alpha: _glowAnimation.value * 0.6),
                          blurRadius: _kGlowRadius * 0.7 * _glowAnimation.value,
                          spreadRadius:
                              _kGlowRadius * 0.3 * _glowAnimation.value,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(
                          sigmaX: widget.comboLevel > 2 ? 2.0 : 0.0,
                          sigmaY: widget.comboLevel > 2 ? 2.0 : 0.0,
                        ),
                        child: Image(
                          image: _imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // تأثير combo خاص
        if (widget.comboLevel > 2)
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              if (_currentPosition == null ||
                  _mainController.value < 0.3 ||
                  _mainController.value > 0.7) {
                return const SizedBox.shrink();
              }

              return Positioned(
                left: _currentPosition!.dx - 60,
                top: _currentPosition!.dy - 60,
                child: IgnorePointer(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.amber.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'COMBO x${widget.comboLevel}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _trailController.dispose();
    _comboController.dispose();
    super.dispose();
  }
}

// ==================== الرسامون المخصصون ====================

/// رسام المسار المضيء
class TrailPainter extends CustomPainter {
  final List<TrailPoint> points;
  final Color color;

  TrailPainter({
    required this.points,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.position.dx, points.first.position.dy);

    for (int i = 1; i < points.length; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];

      paint.color = color.withValues(alpha: p2.opacity);
      paint.strokeWidth = 3.0 * p2.opacity;

      canvas.drawLine(
        p1.position,
        p2.position,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// رسام الجزيئات
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== نماذج البيانات ====================

/// نقطة المسار
class TrailPoint {
  final Offset position;
  final DateTime timestamp;
  double opacity;

  TrailPoint({
    required this.position,
    required this.timestamp,
    required this.opacity,
  });
}

/// جزيء
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double lifespan;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifespan,
    this.opacity = 1.0,
  });

  void update(Offset center) {
    position = center + velocity * 0.01;
    velocity *= 0.98; // احتكاك
    lifespan -= 0.016; // 60 FPS
    opacity = math.max(0, lifespan);
  }
}
