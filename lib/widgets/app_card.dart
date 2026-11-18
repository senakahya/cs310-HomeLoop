import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// White rounded card with a soft shadow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final bool shadow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color = AppColors.surface,
    this.shadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: shadow
            ? const [
                BoxShadow(color: Color(0x0A1F2522), blurRadius: 2, offset: Offset(0, 1)),
                BoxShadow(color: AppColors.shadow, blurRadius: 26, offset: Offset(0, 10), spreadRadius: -16),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Square rounded box with an icon inside (list leading icons).
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  const IconTile({
    super.key,
    required this.icon,
    this.background = AppColors.fill,
    this.foreground = AppColors.ink2,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.35),
      ),
      child: Icon(icon, color: foreground, size: size * 0.5),
    );
  }
}

/// Thin divider used between rows inside a card.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.lineSoft);
  }
}
