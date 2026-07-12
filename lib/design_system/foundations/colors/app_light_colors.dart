import 'package:flutter/material.dart';

/// Palette officielle du thème clair de ForeverCare AI.
///
/// Toutes les couleurs du thème clair proviennent
/// exclusivement de cette classe.
abstract final class AppLightColors {
  AppLightColors._();

  //--------------------------------------------------------------------------
  // Brand
  //--------------------------------------------------------------------------

  static const Color primary = Color(0xFF2E7D32);

  static const Color primaryLight = Color(0xFF4CAF50);

  static const Color primaryDark = Color(0xFF1B5E20);

  static const Color secondary = Color(0xFF1565C0);

  static const Color accent = Color(0xFFFFB300);

  //--------------------------------------------------------------------------
  // Background
  //--------------------------------------------------------------------------

  static const Color background = Color(0xFFF7F9FC);

  //--------------------------------------------------------------------------
  // Surface
  //--------------------------------------------------------------------------

  static const Color surface = Colors.white;

  static const Color card = Colors.white;

  //--------------------------------------------------------------------------
  // Text
  //--------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFF1C1C1C);

  static const Color textSecondary = Color(0xFF6E6E6E);

  //--------------------------------------------------------------------------
  // Border
  //--------------------------------------------------------------------------

  static const Color border = Color(0xFFE0E0E0);

  static const Color divider = Color(0xFFE5E7EB);

  //--------------------------------------------------------------------------
  // Status
  //--------------------------------------------------------------------------

  static const Color success = Color(0xFF2E7D32);

  static const Color warning = Color(0xFFF9A825);

  static const Color error = Color(0xFFC62828);

  static const Color info = Color(0xFF0277BD);

  //--------------------------------------------------------------------------
  // Misc
  //--------------------------------------------------------------------------

  static const Color overlay = Color(0x66000000);

  static const Color disabled = Color(0xFFBDBDBD);
}
