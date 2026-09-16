import 'package:flutter/material.dart';

/// Palette de couleurs d'Atelier+.
///
/// Inspirée de l'univers de la couture ouest-africaine : l'indigo du bogolan
/// et des boubous teints, la terre cuite des tissus wax, le fil d'or des
/// finitions soignées, et l'écru du coton brut. Cette palette évite
/// volontairement les couleurs Material par défaut (bleu/violet génériques)
/// pour donner à l'application une identité visuelle distinctive et
/// artisanale plutôt qu'un aspect "logiciel de gestion" générique.
class AppColors {
  AppColors._();

  // Indigo — couleur de marque principale (boutons, appbar, éléments actifs).
  static const Color indigo900 = Color(0xFF171A3A);
  static const Color indigo800 = Color(0xFF232A5C);
  static const Color indigo700 = Color(0xFF2E3778);
  static const Color indigo600 = Color(0xFF3B4699);
  static const Color indigo500 = Color(0xFF4C58B8);

  // Terre cuite — couleur d'accent chaude (actions secondaires, badges).
  static const Color terracotta700 = Color(0xFF9C4A26);
  static const Color terracotta600 = Color(0xFFB5582F);
  static const Color terracotta500 = Color(0xFFC96B3F);
  static const Color terracotta300 = Color(0xFFE3A47E);

  // Or — couleur de mise en valeur (essai gratuit, éléments premium).
  static const Color or600 = Color(0xFFB4872A);
  static const Color or500 = Color(0xFFD1A438);
  static const Color or300 = Color(0xFFE8C878);

  // Écru / coton — fonds clairs.
  static const Color ecru50 = Color(0xFFFBF6EE);
  static const Color ecru100 = Color(0xFFF5EDE0);
  static const Color ecru200 = Color(0xFFEAE0CC);

  // Anthracite — texte et fonds sombres.
  static const Color anthracite900 = Color(0xFF201E24);
  static const Color anthracite700 = Color(0xFF3A3742);
  static const Color anthracite500 = Color(0xFF6B6774);

  // États fonctionnels.
  static const Color succes = Color(0xFF3D7A5C);
  static const Color alerte = Color(0xFFC7973A);
  static const Color erreur = Color(0xFFB4432F);

  // Vert foncé — met en évidence un membre de groupe d'uniformes dont la
  // tenue est confectionnée (voir GroupeUniformeDetailPage). Plus sombre
  // que `succes`, pour un signal fort et sans ambiguïté.
  static const Color vertFonce = Color(0xFF1B4332);

  // Neutres.
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color bordure = Color(0xFFDED2BC);
}
