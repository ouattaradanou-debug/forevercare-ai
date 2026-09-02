import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Thème global de l'application.
///
/// Choix volontairement sobres et lisibles : gros contrastes, boutons
/// larges, icônes explicites — adapté à un public d'utilisateurs peu
/// technophiles (tailleurs et apprentis), souvent en usage tactile rapide.
class AppTheme {
  const AppTheme._();

  static ThemeData get clair {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaire,
      primary: AppColors.primaire,
      secondary: AppColors.secondaire,
      error: AppColors.erreur,
      surface: AppColors.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.fond,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.texte),
        bodyMedium: TextStyle(fontSize: 15, color: AppColors.texte),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaire,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaire,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDD3C8)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
    );
  }
}
