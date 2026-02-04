import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TaskItemSkeleton extends StatelessWidget {
  const TaskItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget shimmerBox({double? width, double height = 14, BorderRadius? radius}) {
      return Shimmer.fromColors(
        baseColor: Colors.white12,
        highlightColor: Colors.white24,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius ?? BorderRadius.circular(8),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: shimmerBox(width: double.infinity, height: 16)),
              const SizedBox(width: 12),
              shimmerBox(width: 70, height: 28, radius: BorderRadius.circular(14)),
            ],
          ),
          const SizedBox(height: 12),
          // progress bar placeholder
          shimmerBox(width: double.infinity, height: 10, radius: BorderRadius.circular(6)),
          const SizedBox(height: 12),
          Row(
            children: [
              shimmerBox(width: 60, height: 22, radius: BorderRadius.circular(12)),
              const Spacer(),
              shimmerBox(width: 90, height: 28, radius: BorderRadius.circular(14)),
            ],
          ),
        ],
      ),
    );
  }
}
