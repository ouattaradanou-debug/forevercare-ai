import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typographie d'Atelier+.
///
/// Deux familles de polices, choisies pour concilier caractère et lisibilité :
/// - "Fraunces" (empattements chauds, dessinée pour l'édition) pour les titres
///   et les montants : elle donne à l'écran d'accueil un rendu soigné et
///   artisanal, loin des polices système génériques des CRM classiques.
/// - "Inter" (sans-serif humaniste, très testée en accessibilité) pour tout
///   le texte d'interface et les formulaires : elle reste parfaitement lisible
///   à petite taille pour des utilisateurs peu technophiles.
///
/// Choix documenté : les polices sont chargées via `google_fonts`, qui les
/// met en cache localement après un premier téléchargement. Le tout premier
/// lancement doit donc idéalement avoir lieu avec une connexion internet
/// disponible (ce qui correspond à la création du compte atelier) ; en cas
/// d'indisponibilité, l'application bascule automatiquement sur la police
/// système sans jamais bloquer l'utilisateur — la lisibilité au quotidien
/// hors-ligne n'est donc jamais compromise.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color texteBase) {
    final TextTheme base = TextTheme(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 1.15,
        letterSpacing: -0.5,
        color: texteBase,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.18,
        letterSpacing: -0.3,
        color: texteBase,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: texteBase,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.22,
        color: texteBase,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: texteBase,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: texteBase,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: texteBase,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: texteBase,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
        color: texteBase,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.3,
        color: AppColors.anthracite500,
      ),
    );
    return base;
  }
}
