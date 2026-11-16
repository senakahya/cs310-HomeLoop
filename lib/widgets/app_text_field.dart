import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Filled text field with a label above it and inline validation errors below.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final IconData? icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final String? prefixText;
  final Widget? suffix;
  final VoidCallback? onTap;
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.enabled = true,
    this.prefixText,
    this.suffix,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    Widget? suffix = widget.suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20, color: AppColors.faint),
        onPressed: () => setState(() => _hidden = !_hidden),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: 7),
              child: Text(widget.label, style: AppTextStyles.label),
            ),
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _hidden,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onChanged: widget.onChanged,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            style: AppTextStyles.body,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.faint),
              helperText: widget.helper,
              helperStyle: AppTextStyles.caption,
              helperMaxLines: 2,
              errorStyle: AppTextStyles.caption.copyWith(color: AppColors.red, fontWeight: FontWeight.w500),
              errorMaxLines: 2,
              prefixText: widget.prefixText,
              prefixIcon: widget.icon == null
                  ? null
                  : Icon(widget.icon, size: 19, color: AppColors.muted),
              suffixIcon: suffix,
              filled: true,
              fillColor: widget.enabled ? AppColors.fill : const Color(0xFFE9EAE5),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
              border: _border(Colors.transparent, 2),
              enabledBorder: _border(Colors.transparent, 2),
              disabledBorder: _border(Colors.transparent, 2),
              focusedBorder: _border(AppColors.primary, 2),
              errorBorder: _border(AppColors.red, 2),
              focusedErrorBorder: _border(AppColors.red, 2),
            ),
          ),
        ],
      ),
    );
  }
}
