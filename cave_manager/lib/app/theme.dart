import 'package:flutter/material.dart';

/// Thème unique de l'app : gros boutons, contrastes forts, peu de nuances —
/// pensé pour des utilisateurs à faible littératie numérique (point 29 du
/// cahier des charges : "gros boutons, icônes explicites, textes simples").
ThemeData construireTheme() {
  const couleurPrincipale = Color(0xFF7A1F2B); // bordeaux (cave à vin)

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: couleurPrincipale,
      brightness: Brightness.light,
    ),
  );

  return base.copyWith(
    // NB : l'agrandissement global du texte n'est PAS fait ici via
    // `textTheme.apply(fontSizeFactor: ...)` — ce plante avec Material 3
    // car certains styles du TextTheme par défaut ont `fontSize == null`
    // (bug reproduit par `test/widget_test.dart`, un crash immédiat au
    // démarrage). Il est appliqué sans risque au niveau de `MaterialApp`
    // via `MediaQuery`/`TextScaler` — voir `app.dart`.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );
}
