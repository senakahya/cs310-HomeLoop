import 'package:flutter/material.dart';

/// All colours used in HomeLoop. Values come from the Step 2.1 design system.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF136F55);
  static const Color primaryDark = Color(0xFF0E5240);
  static const Color primarySoft = Color(0xFFDDF0E7);
  static const Color primaryTint = Color(0xFFEEF7F2);
  static const Color lime = Color(0xFFD4F36A);

  // Neutrals
  static const Color ink = Color(0xFF0E1A14);
  static const Color ink2 = Color(0xFF36403A);
  static const Color muted = Color(0xFF6B736E);
  static const Color faint = Color(0xFF9DA49F);
  static const Color background = Color(0xFFF3F4F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color fill = Color(0xFFECEEE9);
  static const Color line = Color(0xFFE3E5DF);
  static const Color lineSoft = Color(0xFFEEF0EB);

  // Status
  static const Color amber = Color(0xFFE0901F);
  static const Color amberSoft = Color(0xFFFCEFD7);
  static const Color amberText = Color(0xFFA15F05);
  static const Color red = Color(0xFFE0474F);
  static const Color redSoft = Color(0xFFFDE8E9);
  static const Color redText = Color(0xFF8E2534);

  // Expenses module accent
  static const Color indigo = Color(0xFF5A5FE0);
  static const Color indigoSoft = Color(0xFFECEDFD);

  // Overlays & shadows (colours with alpha)
  static const Color shadow = Color(0x1A0E1A14);
  static const Color scrim = Color(0x800A120E);
  static const Color whiteMuted = Color(0xB3FFFFFF);
}
