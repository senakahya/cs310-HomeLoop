import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

enum NoteTone { info, warning, error }

/// Coloured note box with an icon, e.g. "This only updates the shopping list…".
class InfoNote extends StatelessWidget {
  final String text;
  final String? title;
  final NoteTone tone;

  const InfoNote({super.key, required this.text, this.title, this.tone = NoteTone.info});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color iconColor;
    Color textColor = AppColors.ink2;
    IconData icon = Icons.info_outline_rounded;
    switch (tone) {
      case NoteTone.info:
        bg = AppColors.primaryTint;
        iconColor = AppColors.primary;
        break;
      case NoteTone.warning:
        bg = const Color(0xFFFAF3E7);
        iconColor = AppColors.amber;
        break;
      case NoteTone.error:
        bg = AppColors.redSoft;
        iconColor = AppColors.red;
        textColor = AppColors.redText;
        icon = Icons.warning_amber_rounded;
        break;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(title!, style: AppTextStyles.label.copyWith(color: textColor, fontWeight: FontWeight.w700)),
                Text(text, style: AppTextStyles.caption.copyWith(color: textColor, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state: big icon, title, message and one button (S08·a, S11·a, S15·a).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    this.color = AppColors.primary,
    this.background = AppColors.primarySoft,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(36)),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.title.copyWith(fontSize: 20), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTextStyles.bodyMuted, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: buttonLabel, icon: Icons.add_rounded, onPressed: onPressed, expand: false),
        ],
      ),
    );
  }
}
