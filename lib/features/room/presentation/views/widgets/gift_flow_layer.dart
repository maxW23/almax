import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';
import 'package:lklk/features/room/presentation/views/widgets/optimized_gift_animation_widget.dart';

/// استخدام Flow بدلاً من Stack لأداء أفضل مع عدد كبير من الهدايا
class GiftFlowLayer extends StatefulWidget {
  final List<GiftAnimationData> activeGifts;
  final Function(GiftAnimationData) onGiftComplete;

  const GiftFlowLayer({
    super.key,
    required this.activeGifts,
    required this.onGiftComplete,
  });

  @override
  State<GiftFlowLayer> createState() => _GiftFlowLayerState();
}

class _GiftFlowLayerState extends State<GiftFlowLayer> {

  @override
  Widget build(BuildContext context) {
    // استخدام Flow للأداء الأمثل
    return Flow(
      delegate: GiftFlowDelegate(
        giftPositions: _calculateGiftPositions(),
      ),
      children: widget.activeGifts.asMap().entries.map((entry) {
        final index = entry.key;
        final giftData = entry.value;
        final baseId = giftData.giftId ?? giftData.hashCode.toString();
        final key = ValueKey<String>('${baseId}#$index');

        return RepaintBoundary(
          key: key,
          child: OptimizedGiftAnimationWidget(
            giftData: giftData,
            giftId: baseId,
            onAnimationComplete: () => widget.onGiftComplete(giftData),
          ),
        );
      }).toList(),
    );
  }

  Map<int, Offset> _calculateGiftPositions() {
    final positions = <int, Offset>{};

    for (int i = 0; i < widget.activeGifts.length; i++) {
      // توزيع ذكي للهدايا لتجنب التداخل
      final angle = (i * 2 * 3.14159) / widget.activeGifts.length;
      final radius = 50.0 + (i * 10);

      positions[i] = Offset(
        radius * (1 + (angle * 0.1)),
        radius * (1 + (angle * 0.1)),
      );
    }

    return positions;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Flow Delegate محسن للهدايا
class GiftFlowDelegate extends FlowDelegate {
  final Map<int, Offset> giftPositions;

  GiftFlowDelegate({required this.giftPositions});

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; i++) {
      final offset = giftPositions[i] ?? Offset.zero;

      // رسم كل هدية في موضعها المحسوب
      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          offset.dx,
          offset.dy,
          0,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(GiftFlowDelegate oldDelegate) {
    return giftPositions != oldDelegate.giftPositions;
  }
}
