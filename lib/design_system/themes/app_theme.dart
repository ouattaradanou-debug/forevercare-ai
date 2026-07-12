import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

/// Point d'entrée officiel des thèmes de ForeverCare AI.
///
/// Toute l'application doit accéder aux thèmes via cette classe.
abstract final class AppTheme {
  AppTheme._();

  /// Thème clair.
  static ThemeData get light => LightTheme.theme;

  /// Thème sombre.
  static ThemeData get dark => DarkTheme.theme;
}
