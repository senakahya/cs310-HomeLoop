import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonStyle { primary, secondary, danger, dangerSoft, text, lime }

/// Pill-shaped button used everywhere (Primary action, Secondary / Cancel, …).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonStyle style;
  final bool small;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AppButtonStyle.primary,
    this.small = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    BorderSide border = BorderSide.none;
    switch (style) {
      case AppButtonStyle.primary:
        background = AppColors.primary;
        foreground = Colors.white;
        break;
      case AppButtonStyle.secondary:
        background = AppColors.surface;
        foreground = AppColors.ink;
        border = const BorderSide(color: AppColors.line, width: 1.5);
        break;
      case AppButtonStyle.danger:
        background = AppColors.red;
        foreground = Colors.white;
        break;
      case AppButtonStyle.dangerSoft:
        background = AppColors.redSoft;
        foreground = AppColors.red;
        break;
      case AppButtonStyle.text:
        background = Colors.transparent;
        foreground = AppColors.primary;
        break;
      case AppButtonStyle.lime:
        background = AppColors.lime;
        foreground = AppColors.ink;
        break;
    }
    if (onPressed == null) {
      background = AppColors.fill;
      foreground = AppColors.faint;
      border = BorderSide.none;
    }

    final height = small ? 38.0 : 54.0;
    final button = SizedBox(
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledForegroundColor: foreground,
          padding: EdgeInsets.symmetric(horizontal: small ? AppSpacing.lg : AppSpacing.xl),
          shape: StadiumBorder(side: border),
          textStyle: AppTextStyles.button.copyWith(fontSize: small ? 13 : 15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: small ? 16 : 19),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (expand)
              Flexible(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              )
            else
              Text(label, maxLines: 1),
          ],
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Round icon button used in app bars (back, close, edit, add).
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool dark;
  final Color? iconColor;
  final String? tooltip;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.dark = false,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: dark ? AppColors.ink : AppColors.surface,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4), spreadRadius: -6),
            ],
          ),
          child: Icon(
            icon,
            size: 21,
            color: iconColor ?? (dark ? AppColors.lime : AppColors.ink),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
