import 'package:flutter/material.dart';

/// Palette officielle du thème sombre de ForeverCare AI.
///
/// Toutes les couleurs du thème sombre proviennent
/// exclusivement de cette classe.
abstract final class AppDarkColors {
  AppDarkColors._();

  //--------------------------------------------------------------------------
  // Brand
  //--------------------------------------------------------------------------

  static const Color primary = Color(0xFF66BB6A);

  static const Color primaryLight = Color(0xFF81C784);

  static const Color primaryDark = Color(0xFF2E7D32);

  static const Color secondary = Color(0xFF64B5F6);

  static const Color accent = Color(0xFFFFCA28);

  //--------------------------------------------------------------------------
  // Background
  //--------------------------------------------------------------------------

  static const Color background = Color(0xFF121212);

  //--------------------------------------------------------------------------
  // Surface
  //--------------------------------------------------------------------------

  static const Color surface = Color(0xFF1E1E1E);

  static const Color card = Color(0xFF252525);

  //--------------------------------------------------------------------------
  // Text
  //--------------------------------------------------------------------------

  static const Color textPrimary = Colors.white;

  static const Color textSecondary = Color(0xFFBDBDBD);

  //--------------------------------------------------------------------------
  // Border
  //--------------------------------------------------------------------------

  static const Color border = Color(0xFF3A3A3A);

  static const Color divider = Color(0xFF424242);

  //--------------------------------------------------------------------------
  // Status
  //--------------------------------------------------------------------------

  static const Color success = Color(0xFF66BB6A);

  static const Color warning = Color(0xFFFFCA28);

  static const Color error = Color(0xFFEF5350);

  static const Color info = Color(0xFF4FC3F7);

  //--------------------------------------------------------------------------
  // Misc
  //--------------------------------------------------------------------------

  static const Color overlay = Color(0x99000000);

  static const Color disabled = Color(0xFF757575);
}
