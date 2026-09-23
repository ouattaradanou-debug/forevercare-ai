import 'package:flutter/material.dart';

/// Thème unique de l'app : gros boutons, contrastes forts, peu de nuances —
/// pensé pour des utilisateurs à faible littératie numérique (point 29 du
/// cahier des charges : "gros boutons, icônes explicites, textes simples").
///
/// Palette choisie à la main plutôt que via `ColorScheme.fromSeed` (le
/// résultat automatique donnait un fond rose très délavé, peu "cave à
/// vin") : bordeaux profond en couleur de marque, doré/champagne en
/// accent secondaire, fond ivoire chaud plutôt que blanc pur.
ThemeData construireTheme() {
  const bordeaux = Color(0xFF7A1F2B);
  const bordeauxFonce = Color(0xFF4E0F18);
  const dore = Color(0xFFB08D57);
  const ivoire = Color(0xFFFFFBF5);
  // Fond des écrans : rose poudré, dans les mêmes tons que le bordeaux de
  // la barre du haut (même teinte, juste très désaturée) plutôt que
  // l'ivoire neutre précédent — demandé explicitement pour harmoniser le
  // fond avec le rouge au-dessus.
  const fondEcran = Color(0xFFFBECEC);

  final colorScheme = const ColorScheme.light(
    primary: bordeaux,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFF6DADD),
    onPrimaryContainer: bordeauxFonce,
    secondary: dore,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF3E7D3),
    onSecondaryContainer: Color(0xFF4A3B1F),
    tertiary: Color(0xFF3F5B45),
    onTertiary: Colors.white,
    surface: ivoire,
    onSurface: Color(0xFF2B1A1D),
    surfaceContainerHighest: Color(0xFFF1E3E0),
    error: Color(0xFFB3261E),
    onError: Colors.white,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);

  return base.copyWith(
    scaffoldBackgroundColor: fondEcran,
    // NB : l'agrandissement global du texte n'est PAS fait ici via
    // `textTheme.apply(fontSizeFactor: ...)` — ce plante avec Material 3
    // car certains styles du TextTheme par défaut ont `fontSize == null`
    // (bug reproduit par `test/widget_test.dart`, un crash immédiat au
    // démarrage). Il est appliqué sans risque au niveau de `MaterialApp`
    // via `MediaQuery`/`TextScaler` — voir `app.dart`.
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: bordeaux,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bordeaux,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: bordeaux,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dore.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dore.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: bordeaux, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: ivoire,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFFF3E7D3),
      labelStyle: const TextStyle(
          color: Color(0xFF4A3B1F), fontWeight: FontWeight.w600),
      side: BorderSide.none,
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
