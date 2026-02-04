import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lklk/features/room/presentation/views/widgets/enhanced_lucky_gift_manager.dart';

/// 🎨 واجهة عرض رتل هدايا الحظ الاحترافية
class EnhancedLuckyGiftDisplay extends StatefulWidget {
  const EnhancedLuckyGiftDisplay({super.key});

  @override
  State<EnhancedLuckyGiftDisplay> createState() =>
      _EnhancedLuckyGiftDisplayState();
}

class _EnhancedLuckyGiftDisplayState extends State<EnhancedLuckyGiftDisplay>
    with TickerProviderStateMixin {
  final EnhancedLuckyGiftManager _manager = EnhancedLuckyGiftManager();
  EnhancedQueueStatus? _status;
  Timer? _statusTimer;

  // ==================== أنيميشنز الواجهة ====================
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _comboFlashController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _comboFlashAnimation;

  // حالة الواجهة
  bool _isExpanded = false;
  bool _showComboAlert = false;
  ComboInfo? _currentCombo;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startMonitoring();
  }

  void _initializeAnimations() {
    // نبضة للأيقونة
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // انزلاق للواجهة
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // وميض combo
    _comboFlashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _comboFlashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_comboFlashController);

    // إضافة مستمع combo
    _manager.addComboListener(_onComboTriggered);
  }

  void _startMonitoring() {
    _statusTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        final newStatus = _manager.getStatus();
        setState(() {
          _status = newStatus;

          // تحريك النبضة عند وجود هدايا
          if (newStatus.queueSize > 0 && !_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          } else if (newStatus.queueSize == 0 && _pulseController.isAnimating) {
            _pulseController.stop();
          }
        });
      }
    });

    // عرض الواجهة بأنيميشن
    _slideController.forward();
  }

  void _onComboTriggered(ComboInfo combo) {
    if (combo.level >= 3) {
      setState(() {
        _currentCombo = combo;
        _showComboAlert = true;
      });

      // تأثير haptic
      HapticFeedback.mediumImpact();

      // وميض
      _comboFlashController.forward().then((_) {
        _comboFlashController.reverse();
      });

      // إخفاء بعد 3 ثواني
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showComboAlert = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == null) return const SizedBox.shrink();

    return Stack(
      children: [
        // الواجهة الرئيسية
        Positioned(
          top: 100,
          right: 16,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isExpanded ? 280 : 60,
                height: _isExpanded ? 400 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.purple.shade900.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(_isExpanded ? 20 : 30),
                  border: Border.all(
                    color: _getStatusColor(),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor().withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child:
                    _isExpanded ? _buildExpandedView() : _buildCollapsedView(),
              ),
            ),
          ),
        ),

        // تنبيه Combo
        if (_showComboAlert && _currentCombo != null) _buildComboAlert(),

        // مؤشر الأداء
        if (_isExpanded)
          Positioned(
            top: 510,
            right: 16,
            child: _buildPerformanceIndicator(),
          ),
      ],
    );
  }

  Widget _buildCollapsedView() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.amber.shade300,
                  Colors.amber.shade600,
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 28,
                ),
                if (_status!.queueSize > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '${_status!.queueSize}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedView() {
    return Column(
      children: [
        // الرأس
        _buildHeader(),

        // معلومات الحالة
        _buildStatusBar(),

        // قائمة الهدايا
        Expanded(
          child: _buildGiftList(),
        ),

        // Combos النشطة
        if (_status!.activeCombos.isNotEmpty) _buildActiveCombos(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade600,
            Colors.amber.shade800,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Lucky Gifts Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                _isExpanded = false;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            icon: Icons.queue,
            value: '${_status!.queueSize}',
            label: 'Queue',
            color: Colors.blue,
          ),
          _buildStatusItem(
            icon: Icons.play_arrow,
            value: '${_status!.displayingCount}',
            label: 'Active',
            color: Colors.green,
          ),
          _buildStatusItem(
            icon: Icons.speed,
            value: _status!.performanceFps.toStringAsFixed(0),
            label: 'FPS',
            color: _status!.performanceFps >= 50 ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildGiftList() {
    if (_status!.topPriorityGifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              color: Colors.white.withValues(alpha: 0.3),
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'No gifts in queue',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _status!.topPriorityGifts.length,
      itemBuilder: (context, index) {
        final gift = _status!.topPriorityGifts[index];
        return _buildGiftItem(gift, index);
      },
    );
  }

  Widget _buildGiftItem(PriorityGiftItem gift, int index) {
    final isFirst = index == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: isFirst
            ? LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.3),
                  Colors.orange.withValues(alpha: 0.2),
                ],
              )
            : null,
        color: isFirst ? null : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Priority indicator
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _getPriorityColors(gift.priority),
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // صورة الهدية
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: gift.imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),

          // معلومات الهدية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      gift.senderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (gift.comboLevel > 1)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'x${gift.comboLevel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  '→ ${gift.receiverName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // العدد والأولوية
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'x${gift.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'P: ${gift.priority}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCombos() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🔥 Active Combos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: _status!.activeCombos.values.map((combo) {
              return Chip(
                backgroundColor: Colors.orange.shade700,
                label: Text(
                  '${combo.senderName} x${combo.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComboAlert() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.3,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _comboFlashAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _comboFlashAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade600,
                    const Color(0xFFE53935),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '🔥 COMBO! 🔥',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentCombo!.senderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Level ${_currentCombo!.level}',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceIndicator() {
    final fps = _status?.performanceFps ?? 60;
    final color = fps >= 50
        ? Colors.green
        : fps >= 30
            ? Colors.orange
            : const Color(0xFFFF0000);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            '${fps.toStringAsFixed(0)} FPS',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_status == null) return Colors.grey;
    if (_status!.queueSize > 10) return const Color(0xFFFF0000);
    if (_status!.queueSize > 5) return Colors.orange;
    if (_status!.queueSize > 0) return Colors.amber;
    return Colors.green;
  }

  List<Color> _getPriorityColors(int priority) {
    if (priority >= 1000) return [Colors.purple, Colors.pink];
    if (priority >= 500) return [const Color(0xFFFF0000), Colors.orange];
    if (priority >= 200) return [Colors.orange, Colors.amber];
    return [Colors.blue, Colors.cyan];
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    _comboFlashController.dispose();
    super.dispose();
  }
}
