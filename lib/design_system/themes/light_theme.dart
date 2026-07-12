import 'package:flutter/material.dart';

import '../foundations/colors/app_light_colors.dart';
import '../foundations/typography/app_typography.dart';

/// Thème clair officiel de ForeverCare AI.
abstract final class LightTheme {
  LightTheme._();

  static ThemeData get theme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppLightColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppLightColors.primary,
          secondary: AppLightColors.secondary,
          surface: AppLightColors.surface,
          error: AppLightColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppLightColors.background,
      textTheme: AppTypography.textTheme,
      fontFamily: AppTypography.textTheme.bodyMedium?.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
