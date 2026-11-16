import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles. Headings use the custom font Plus Jakarta Sans, body text uses Inter.
class AppTextStyles {
  AppTextStyles._();

  static const String headingFont = 'PlusJakartaSans';
  static const String bodyFont = 'Inter';

  // Headings
  static const TextStyle display = TextStyle(
    fontFamily: headingFont,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    height: 1.1,
    color: AppColors.ink,
  );

  static const TextStyle title = TextStyle(
    fontFamily: headingFont,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );

  static const TextStyle screenTitle = TextStyle(
    fontFamily: headingFont,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: headingFont,
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle amount = TextStyle(
    fontFamily: headingFont,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static const TextStyle number = TextStyle(
    fontFamily: headingFont,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.muted,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static const TextStyle label = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.ink2,
  );

  static const TextStyle button = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
}
