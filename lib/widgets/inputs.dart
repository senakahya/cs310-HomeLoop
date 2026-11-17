import 'package:flutter/material.dart';

import '../data/formatters.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Rounded chip that can be selected (filters, units, currencies, payer).
class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Widget? leading;

  const PillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink2;
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.ink : AppColors.line),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(leading != null ? 4 : 14, 0, 14, 0),
          child: SizedBox(
            height: 34,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 6)],
                if (icon != null) ...[Icon(icon, size: 15, color: fg), const SizedBox(width: 6)],
                Text(label, style: AppTextStyles.label.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A wrap of chips where exactly one is selected.
class ChoiceChipsField<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const ChoiceChipsField({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final option in options)
          PillChip(
            label: labelOf(option),
            selected: option == selected,
            onTap: () => onChanged(option),
          ),
      ],
    );
  }
}

/// Segmented control: [ Fridge | Freezer | Pantry ], [ Consumed | Discarded ].
class SegmentedChoice<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;
  final ValueChanged<T> onChanged;

  const SegmentedChoice({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.iconOf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40,
                  decoration: BoxDecoration(
                    color: option == selected ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: option == selected
                        ? const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3))]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (iconOf != null) ...[
                        Icon(iconOf!(option), size: 16,
                            color: option == selected ? AppColors.ink : AppColors.muted),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          labelOf(option),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label.copyWith(
                            color: option == selected ? AppColors.ink : AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// [ − ]   1.5 L   [ + ]
class QuantityStepper extends StatelessWidget {
  final double value;
  final double step;
  final double min;
  final double? max;
  final String unit;
  final ValueChanged<double> onChanged;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.min = 0,
    this.max,
    this.unit = '',
  });

  Widget _button(IconData icon, VoidCallback? onTap) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: onTap == null ? AppColors.faint : AppColors.ink),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canDecrease = value - step >= min - 0.0001;
    final canIncrease = max == null || value + step <= max! + 0.0001;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        children: [
          _button(Icons.remove_rounded, canDecrease ? () => onChanged(value - step) : null),
          Expanded(
            child: Text(
              unit.isEmpty ? Fmt.qty(value) : '${Fmt.qty(value)} $unit',
              textAlign: TextAlign.center,
              style: AppTextStyles.number,
            ),
          ),
          _button(Icons.add_rounded, canIncrease ? () => onChanged(value + step) : null),
        ],
      ),
    );
  }
}

/// Label above a non-text input (stepper, chips, segmented control).
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: 7, top: AppSpacing.xs),
      child: Text(text, style: AppTextStyles.label),
    );
  }
}

/// Tappable field that shows a value and opens a picker (e.g. a date picker).
class PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final String? helper;
  final String? error;
  final bool placeholder;

  const PickerField({
    super.key,
    required this.label,
    required this.value,
    this.icon = Icons.calendar_today_outlined,
    this.onTap,
    this.helper,
    this.error,
    this.placeholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: 7),
              child: Text(label, style: AppTextStyles.label),
            ),
          Material(
            color: enabled ? AppColors.fill : const Color(0xFFE9EAE5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.field),
              side: BorderSide(color: error != null ? AppColors.red : Colors.transparent, width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.field),
              onTap: onTap,
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const SizedBox(width: AppSpacing.lg),
                    Icon(icon, size: 19, color: enabled ? AppColors.muted : AppColors.faint),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: placeholder || !enabled ? AppColors.faint : AppColors.ink,
                        ),
                      ),
                    ),
                    if (enabled) const Icon(Icons.expand_more_rounded, color: AppColors.muted),
                    const SizedBox(width: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs, top: 6),
              child: Text(error!, style: AppTextStyles.caption.copyWith(color: AppColors.red, fontWeight: FontWeight.w500)),
            )
          else if (helper != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs, top: 6),
              child: Text(helper!, style: AppTextStyles.caption),
            ),
        ],
      ),
    );
  }
}
