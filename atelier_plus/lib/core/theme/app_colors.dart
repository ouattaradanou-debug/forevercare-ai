import 'package:flutter/material.dart';

/// Palette de couleurs de base de l'application — couleurs officielles de
/// SEDA Tech (voir assets/images/logo_seda_tech.png), appliquées à toute
/// l'application via `AppTheme` (avant personnalisation du logo/nom de
/// l'atelier, voir feature `branding` en Phase 4 — seuls le logo/nom sont
/// personnalisables, pas la palette de l'app elle-même).
class AppColors {
  const AppColors._();

  static const Color primaire = Color(0xFF1B4FA0); // Bleu SEDA Tech
  static const Color secondaire = Color(0xFFF5821F); // Orange SEDA Tech
  static const Color fond = Color(0xFFF7F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color erreur = Color(0xFFB3261E);
  static const Color succes = Color(0xFF2E7D32);
  static const Color avertissement = Color(0xFFED6C02);
  static const Color texte = Color(0xFF1B1B1F);
  static const Color texteAttenue = Color(0xFF6F6259);
}
