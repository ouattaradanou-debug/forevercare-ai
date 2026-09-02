import 'package:flutter/material.dart';

/// Palette de couleurs de base de l'application (avant personnalisation
/// visuelle par la marque de l'atelier, voir feature `branding` en Phase 4 —
/// seul le logo/nom sont personnalisables, pas la palette de l'app elle-même).
class AppColors {
  const AppColors._();

  static const Color primaire = Color(0xFF8A4B24); // Terre cuite / artisanat
  static const Color secondaire = Color(0xFFD4A24C); // Doré (fil, boubou)
  static const Color fond = Color(0xFFFAF6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color erreur = Color(0xFFB3261E);
  static const Color succes = Color(0xFF2E7D32);
  static const Color avertissement = Color(0xFFED6C02);
  static const Color texte = Color(0xFF231A14);
  static const Color texteAttenue = Color(0xFF6F6259);
}
