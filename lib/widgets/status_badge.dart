import 'package:flutter/material.dart';

import '../data/formatters.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum BadgeTone { neutral, success, warning, danger, info }

/// Small rounded label: "Tomorrow", "In 2 days", "Owner", "No expiry date".
class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeTone tone;

  const StatusBadge({super.key, required this.text, this.tone = BadgeTone.neutral});

  /// Badge for an expiry date (red ≤ 1 day, amber ≤ 3 days).
  factory StatusBadge.expiry(DateTime? date, {Key? key}) {
    BadgeTone tone = BadgeTone.neutral;
    if (date != null) {
      final days = Fmt.daysFromToday(date);
      if (days <= 1) {
        tone = BadgeTone.danger;
      } else if (days <= 3) {
        tone = BadgeTone.warning;
      }
    }
    return StatusBadge(key: key, text: Fmt.expiry(date), tone: tone);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (tone) {
      case BadgeTone.neutral:
        bg = AppColors.fill;
        fg = AppColors.muted;
        break;
      case BadgeTone.success:
        bg = AppColors.primarySoft;
        fg = AppColors.primary;
        break;
      case BadgeTone.warning:
        bg = AppColors.amberSoft;
        fg = AppColors.amberText;
        break;
      case BadgeTone.danger:
        bg = AppColors.redSoft;
        fg = AppColors.red;
        break;
      case BadgeTone.info:
        bg = AppColors.indigoSoft;
        fg = AppColors.indigo;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(text, style: AppTextStyles.badge.copyWith(color: fg), maxLines: 1),
    );
  }
}
