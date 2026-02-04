import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileQuickActionItem {
  final String title;
  final String icon; // can be .svg or raster
  final VoidCallback onTap;
  ProfileQuickActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class ProfileQuickActionsRow extends StatelessWidget {
  final List<ProfileQuickActionItem> items;
  final EdgeInsetsGeometry padding;
  final double iconContainerSize;
  final double iconSize;
  final double spacing;
  final double runSpacing;

  const ProfileQuickActionsRow({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.iconContainerSize = 48,
    this.iconSize = 30,
    this.spacing = 16,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int n = items.length;
          if (n == 0) return const SizedBox.shrink();

          // Base total width needed (without considering extra Row distribution)
          final double baseTotal = n * iconContainerSize + (n - 1) * spacing;
          double scale = 1.0;
          if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
            scale = (constraints.maxWidth / baseTotal).clamp(0.0, 1.0);
          }

          // If too many items even after scaling under a threshold, wrap to new line
          const double minScale = 0.75;
          if (scale < minScale) {
            final double ic = iconContainerSize * minScale;
            final double isz = iconSize * minScale;
            return Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: spacing * 0.5,
              runSpacing: runSpacing,
              children: [
                for (final it in items)
                  _QuickActionButton(
                    title: it.title,
                    icon: it.icon,
                    onTap: it.onTap,
                    iconContainerSize: ic,
                    iconSize: isz,
                  ),
              ],
            );
          }

          final double ic = iconContainerSize * scale;
          final double isz = iconSize * scale;
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < n; i++)
                _QuickActionButton(
                  title: items[i].title,
                  icon: items[i].icon,
                  onTap: items[i].onTap,
                  iconContainerSize: ic,
                  iconSize: isz,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  final double iconContainerSize;
  final double iconSize;

  const _QuickActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.iconContainerSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            // decoration: BoxDecoration(
            //     // color: const Color(0xFFF6F7FB),

            //     // borderRadius: BorderRadius.circular(12),
            //     ),
            alignment: Alignment.center,
            child: icon.toLowerCase().endsWith('.svg')
                ? SvgPicture.asset(
                    icon,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    icon,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: iconContainerSize + 8,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
