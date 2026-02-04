import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';

/// واجهة عرض رتل الهدايا المدمجة مع GiftsShowCubit
class GiftsQueueDisplayWidget extends StatefulWidget {
  const GiftsQueueDisplayWidget({super.key});

  @override
  State<GiftsQueueDisplayWidget> createState() =>
      _GiftsQueueDisplayWidgetState();
}

class _GiftsQueueDisplayWidgetState extends State<GiftsQueueDisplayWidget>
    with TickerProviderStateMixin {
  Timer? _statusUpdateTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  GiftQueueStatus? _status;

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
      _updateStatus();
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
      try {
        final cubit = context.read<GiftsShowCubit>();
        setState(() {
          _status = cubit.getQueueStatus();
        });
      } catch (e) {
        // Handle case where cubit is not available
        setState(() {
          _status = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // إخفاء الواجهة إذا كان الرتل فارغ أو غير متاح
    if (_status == null ||
        (_status!.queueSize == 0 && !_status!.isProcessing)) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 120, // تحت الـ AppBar
      right: 16,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 220,
          maxHeight: 350,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.deepPurple.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.golden.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // رأس الرتل
            _buildQueueHeader(),

            // الهدية الحالية (إذا كانت تُعرض)
            if (_status!.isProcessing && _status!.currentGift != null)
              _buildCurrentGift(_status!.currentGift!),

            // قائمة الهدايا المنتظرة
            if (_status!.nextGifts.isNotEmpty) _buildGiftsList(),

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
          colors: [AppColors.golden, Colors.amber.shade700],
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
                scale: (_status?.isProcessing ?? false)
                    ? _pulseAnimation.value
                    : 1.0,
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 22,
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء الهدية الحالية
  Widget _buildCurrentGift(dynamic currentGift) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.3),
            Colors.teal.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle, color: Colors.green, size: 16),
              const SizedBox(width: 6),
              const Text(
                'يتم العرض الآن',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildGiftItem(currentGift, -1, isCurrentGift: true),
        ],
      ),
    );
  }

  /// بناء قائمة الهدايا
  Widget _buildGiftsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      child: Column(
        children: [
          if (_status!.nextGifts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.queue, color: Colors.blue, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'في الانتظار (${_status!.nextGifts.length})',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _status!.nextGifts.length,
              itemBuilder: (context, index) {
                final gift = _status!.nextGifts[index];
                return _buildGiftItem(gift, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر هدية واحد
  Widget _buildGiftItem(dynamic gift, int index, {bool isCurrentGift = false}) {
    final isNext = index == 0 && !isCurrentGift;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentGift
            ? Colors.green.withValues(alpha: 0.2)
            : isNext
                ? AppColors.golden.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: isCurrentGift
            ? Border.all(color: Colors.green.withValues(alpha: 0.6))
            : isNext
                ? Border.all(color: AppColors.golden.withValues(alpha: 0.6))
                : null,
      ),
      child: Row(
        children: [
          // رقم الترتيب أو حالة العرض
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isCurrentGift
                  ? Colors.green
                  : isNext
                      ? AppColors.golden
                      : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCurrentGift
                  ? const Icon(Icons.play_arrow, color: Colors.white, size: 12)
                  : Text(
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
              imageUrl: gift.gift?.giftImage ?? '',
              width: 26,
              height: 26,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 26,
                height: 26,
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
                  gift.gift?.userName ?? 'مجهول',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${gift.gift?.giftType ?? 'هدية'} (${gift.sequenceNumber ?? 1}/${gift.totalCount ?? 1})',
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

          // مدة العرض
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${gift.gift?.timer ?? 3}s',
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
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            icon: Icons.queue,
            label: 'في الانتظار',
            value: '${_status?.queueSize ?? 0}',
            color: Colors.blue,
          ),
          _buildStatusItem(
            icon: (_status?.isProcessing ?? false)
                ? Icons.play_circle
                : Icons.pause_circle,
            label: (_status?.isProcessing ?? false) ? 'يتم العرض' : 'متوقف',
            value: (_status?.isProcessing ?? false) ? '1' : '0',
            color:
                (_status?.isProcessing ?? false) ? Colors.green : Colors.grey,
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
          size: 18,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
