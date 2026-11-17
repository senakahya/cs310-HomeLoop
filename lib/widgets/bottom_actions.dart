import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Buttons fixed to the bottom of a form screen (e.g. [Cancel] [Save]).
/// Pass Expanded(...) children to share the width.
class BottomActions extends StatelessWidget {
  final List<Widget> children;

  const BottomActions({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.screen, AppSpacing.md),
          child: Row(children: children),
        ),
      ),
    );
  }
}
