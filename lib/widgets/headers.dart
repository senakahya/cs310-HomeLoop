import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Compact top bar used on detail and form screens: [‹]  Title  [actions]
class ScreenHeader extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onLeading;
  final List<Widget> actions;

  const ScreenHeader({
    super.key,
    this.title = '',
    this.leadingIcon = Icons.chevron_left_rounded,
    this.onLeading,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          CircleIconButton(
            icon: leadingIcon,
            tooltip: leadingIcon == Icons.close_rounded ? 'Close' : 'Back',
            onTap: onLeading ?? () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: actions.isEmpty ? 42 : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  actions[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Large left-aligned title used on the four tab screens.
class LargeTitleHeader extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final Widget? trailing;

  const LargeTitleHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.display.copyWith(fontSize: 31)),
                if (subtitle != null) ...[
                  const SizedBox(height: 5),
                  DefaultTextStyle(style: AppTextStyles.caption.copyWith(fontSize: 13), child: subtitle!),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// "Section title ................ Action"
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.lg, AppSpacing.xs, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
