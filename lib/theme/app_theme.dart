import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// The single ThemeData of the app. Cards, dialogs and buttons are styled
/// in our own widgets (lib/widgets), so the theme only sets the basics.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.background,
      error: AppColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.bodyFont,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          fontFamily: AppTextStyles.bodyFont,
          color: Colors.white,
        ),
        actionTextColor: AppColors.lime,
      ),
    );
  }
}
