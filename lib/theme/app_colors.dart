import 'package:flutter/material.dart';

/// All colours used in HomeLoop – a soft, muted palette (pine green, charcoal,
/// warm ivory and champagne). Values come from the Step 2.1 design system.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF34594C);
  static const Color primaryDark = Color(0xFF27463B);
  static const Color primarySoft = Color(0xFFE3EBE6);
  static const Color primaryTint = Color(0xFFF1F5F2);
  /// Soft champagne accent (tab bar pill, highlights on dark cards).
  static const Color accent = Color(0xFFE6D8BC);

  /// Old name of [accent], kept so screens that still use it compile.
  static const Color lime = accent;

  // Neutrals
  static const Color ink = Color(0xFF1F2522);
  static const Color ink2 = Color(0xFF434A46);
  static const Color muted = Color(0xFF737873);
  static const Color faint = Color(0xFFA3A7A2);
  static const Color background = Color(0xFFF6F4EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color fill = Color(0xFFEEEBE4);
  static const Color line = Color(0xFFE4E0D7);
  static const Color lineSoft = Color(0xFFEFECE6);

  // Status
  static const Color amber = Color(0xFFC08A3E);
  static const Color amberSoft = Color(0xFFF5EBDB);
  static const Color amberText = Color(0xFF8C6224);
  static const Color red = Color(0xFFB5525B);
  static const Color redSoft = Color(0xFFF6E4E5);
  static const Color redText = Color(0xFF7E2F37);

  // Expenses module accent
  static const Color indigo = Color(0xFF646A9E);
  static const Color indigoSoft = Color(0xFFECEDF4);

  // Overlays & shadows (colours with alpha)
  static const Color shadow = Color(0x1A1F2522);
  static const Color scrim = Color(0x800A120E);
  static const Color whiteMuted = Color(0xB3FFFFFF);
}
