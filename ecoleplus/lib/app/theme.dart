import 'package:flutter/material.dart';

/// Thème clair, gros caractères et grandes zones tactiles (R5).
ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1B6E3C));
  return ThemeData(
    // Police du système Android (nommée pour que les captures du guide
    // aient le même texte que le téléphone).
    fontFamily: 'Roboto',
    colorScheme: scheme,
    visualDensity: VisualDensity.standard,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
