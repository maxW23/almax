import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/room/presentation/views/widgets/lucky_gift_queue_manager.dart';

/// واجهة عرض رتل هدايا الحظ
class LuckyGiftQueueWidget extends StatefulWidget {
  const LuckyGiftQueueWidget({super.key});

  @override
  State<LuckyGiftQueueWidget> createState() => _LuckyGiftQueueWidgetState();
}

class _LuckyGiftQueueWidgetState extends State<LuckyGiftQueueWidget>
    with TickerProviderStateMixin {
  final LuckyGiftQueueManager _queueManager = LuckyGiftQueueManager();
  LuckyGiftQueueStatus _status = const LuckyGiftQueueStatus(
    queueSize: 0,
    displayingCount: 0,
    isProcessing: false,
    nextGifts: [],
  );

  Timer? _statusUpdateTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد أنيميشن النبضة
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // تحديث الحالة كل ثانية
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _status = _queueManager.getStatus();
        });
      }
    });

    // تحديث الحالة الأولي
    _updateStatus();
  }

  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _updateStatus() {
    if (mounted) {
      setState(() {
        _status = _queueManager.getStatus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // إخفاء الواجهة إذا كان الرتل فارغ
    if (_status.queueSize == 0 && _status.displayingCount == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 120, // تحت الـ AppBar
      right: 16,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 300,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.purple.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.golden.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // رأس الرتل
            _buildQueueHeader(),

            // قائمة الهدايا المنتظرة
            if (_status.nextGifts.isNotEmpty) _buildGiftsList(),

            // معلومات الحالة
            _buildStatusInfo(),
          ],
        ),
      ),
    );
  }

  /// بناء رأس الرتل
  Widget _buildQueueHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.golden, Colors.amber.shade600],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _status.isProcessing ? _pulseAnimation.value : 1.0,
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          const GradientText(
            'رتل الهدايا',
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white70],
            ),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء قائمة الهدايا
  Widget _buildGiftsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: _status.nextGifts.length,
        itemBuilder: (context, index) {
          final gift = _status.nextGifts[index];
          return _buildGiftItem(gift, index);
        },
      ),
    );
  }

  /// بناء عنصر هدية واحد
  Widget _buildGiftItem(LuckyGiftQueueItem gift, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: index == 0
            ? AppColors.golden.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: index == 0
            ? Border.all(color: AppColors.golden.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          // رقم الترتيب
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: index == 0 ? AppColors.golden : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // صورة الهدية
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: gift.imageUrl,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 24,
                height: 24,
                color: Colors.grey,
                child: const Icon(Icons.card_giftcard,
                    size: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // معلومات الهدية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.senderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '→ ${gift.receiverName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // عدد الهدايا
          if (gift.count > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.golden,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x${gift.count}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// بناء معلومات الحالة
  Widget _buildStatusInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            icon: Icons.queue,
            label: 'في الانتظار',
            value: '${_status.queueSize}',
            color: Colors.blue,
          ),
          _buildStatusItem(
            icon: Icons.play_circle,
            label: 'يتم العرض',
            value: '${_status.displayingCount}',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  /// بناء عنصر معلومات الحالة
  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}
