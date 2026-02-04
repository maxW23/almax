import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PodiumSkeleton extends StatelessWidget {
  const PodiumSkeleton({super.key, this.height = 220});
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget circle(double size) => Shimmer.fromColors(
          baseColor: Colors.white12,
          highlightColor: Colors.white24,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Background podium image placeholder
          Positioned.fill(
            child: Center(
              child: Shimmer.fromColors(
                baseColor: Colors.white10,
                highlightColor: Colors.white24,
                child: Container(
                  width: 260,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          // Rank 1 (center)
          Positioned(
            top: height * 0.12,
            left: 0,
            right: 0,
            child: Center(child: circle(72)),
          ),
          // Rank 2 (left)
          Positioned(
            top: height * 0.22,
            left: 36,
            child: circle(56),
          ),
          // Rank 3 (right)
          Positioned(
            top: height * 0.26,
            right: 36,
            child: circle(56),
          ),
        ],
      ),
    );
  }
}

class RankingRowSkeleton extends StatelessWidget {
  const RankingRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Shimmer.fromColors(
          baseColor: Colors.white12,
          highlightColor: Colors.white24,
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        children: [
          // rank
          SizedBox(width: 32, child: bar(24, 16)),
          const SizedBox(width: 8),
          // avatar + name
          Expanded(
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.white12,
                  highlightColor: Colors.white24,
                  child: const CircleAvatar(radius: 16, backgroundColor: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(child: bar(double.infinity, 14)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // points and last active
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  bar(50, 14),
                ],
              ),
              const SizedBox(height: 4),
              bar(70, 10),
            ],
          )
        ],
      ),
    );
  }
}

class RankingTabSkeleton extends StatelessWidget {
  const RankingTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PodiumSkeleton(),
        // period selector pills
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Expanded(child: _pill()),
              const SizedBox(width: 8),
              Expanded(child: _pill()),
              const SizedBox(width: 8),
              Expanded(child: _pill()),
            ],
          ),
        ),
        // list skeleton
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: 10,
            itemBuilder: (_, __) => const RankingRowSkeleton(),
          ),
        ),
      ],
    );
  }

  Widget _pill() => Shimmer.fromColors(
        baseColor: Colors.white12,
        highlightColor: Colors.white24,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}
