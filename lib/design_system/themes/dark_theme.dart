import 'package:flutter/material.dart';

import '../foundations/colors/app_dark_colors.dart';
import '../foundations/typography/app_typography.dart';

/// Thème sombre officiel de ForeverCare AI.
abstract final class DarkTheme {
  DarkTheme._();

  static ThemeData get theme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppDarkColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppDarkColors.primary,
          secondary: AppDarkColors.secondary,
          surface: AppDarkColors.surface,
          error: AppDarkColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppDarkColors.background,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppDarkColors.textPrimary,
        displayColor: AppDarkColors.textPrimary,
      ),
      fontFamily: AppTypography.textTheme.bodyMedium?.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
