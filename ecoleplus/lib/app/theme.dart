import 'package:flutter/material.dart';

/// Couleurs de SEDA Tech (logo) : bleu dominant, orange en accent.
abstract final class CouleursSeda {
  /// Bleu SEDA (barres, gros boutons, titres, en-têtes de tableaux).
  static const bleu = Color(0xFF1B4FA0);

  /// Bleu plus clair (dégradés, liens).
  static const bleuClair = Color(0xFF2F74D0);

  /// Bleu très clair (fonds des en-têtes doux, lignes alternées).
  static const bleuPale = Color(0xFFE8F0FB);

  /// Orange SEDA (accent : raccourcis, chiffres clés, badges).
  static const orange = Color(0xFFF39223);

  /// Orange très clair (fonds d'accent).
  static const orangePale = Color(0xFFFFEBD3);

  /// Texte sur fond orange pâle.
  static const brun = Color(0xFF6B3A00);

  /// Fond de l'application (blanc légèrement bleuté).
  static const fond = Color(0xFFF7F9FD);
}

/// Thème clair aux couleurs de SEDA Tech, gros caractères et grandes zones
/// tactiles (R5).
ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: CouleursSeda.bleu).copyWith(
    primary: CouleursSeda.bleu,
    onPrimary: Colors.white,
    primaryContainer: CouleursSeda.bleuPale,
    onPrimaryContainer: const Color(0xFF0D2A5C),
    secondary: CouleursSeda.orange,
    onSecondary: Colors.white,
    secondaryContainer: CouleursSeda.orangePale,
    onSecondaryContainer: CouleursSeda.brun,
    tertiary: const Color(0xFFB85F00),
    surface: CouleursSeda.fond,
  );
  return ThemeData(
    // Police du système Android (nommée pour que les captures du guide
    // aient le même texte que le téléphone).
    fontFamily: 'Roboto',
    colorScheme: scheme,
    scaffoldBackgroundColor: CouleursSeda.fond,
    visualDensity: VisualDensity.standard,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CouleursSeda.bleu,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CouleursSeda.bleu,
        side: const BorderSide(color: CouleursSeda.bleu),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFDCE4F0)),
      ),
    ),
    chipTheme: const ChipThemeData(
      selectedColor: CouleursSeda.orangePale,
      checkmarkColor: CouleursSeda.brun,
    ),
    badgeTheme: const BadgeThemeData(backgroundColor: CouleursSeda.orange),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CouleursSeda.orange,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: CouleursSeda.bleu, width: 2),
      ),
    ),
  );
}
