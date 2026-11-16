import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Shows a confirmation dialog and returns true if the user confirmed.
/// Used for important actions (remove member, record payment, delete…).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool danger = false,
  IconData icon = Icons.help_outline_rounded,
  Widget? header,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _AppDialog(
      icon: icon,
      header: header,
      iconColor: danger ? AppColors.red : AppColors.primary,
      iconBackground: danger ? AppColors.redSoft : AppColors.primarySoft,
      title: title,
      message: message,
      actions: [
        Expanded(
          child: AppButton(
            label: 'Cancel',
            style: AppButtonStyle.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppButton(
            label: confirmLabel,
            style: danger ? AppButtonStyle.danger : AppButtonStyle.primary,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Shows a "done" dialog with one OK button (shown after a valid form submission).
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _AppDialog(
      icon: Icons.check_rounded,
      iconColor: AppColors.primary,
      iconBackground: AppColors.primarySoft,
      title: title,
      message: message,
      actions: [
        Expanded(
          child: AppButton(label: 'OK', onPressed: () => Navigator.of(context).pop()),
        ),
      ],
    ),
  );
}

class _AppDialog extends StatelessWidget {
  final IconData icon;
  final Widget? header;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final List<Widget> actions;

  const _AppDialog({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.actions,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header ??
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: iconColor),
                ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: AppTextStyles.bodyMuted.copyWith(fontSize: 13.5)),
            const SizedBox(height: AppSpacing.xl),
            Row(children: actions),
          ],
        ),
      ),
    );
  }
}
