/// Échelle d'espacement et de rayons communs à toute l'application.
///
/// Les valeurs sont volontairement généreuses : les utilisateurs visés sont
/// peu technophiles, souvent en boutique avec des interruptions fréquentes,
/// donc les zones de tap et les respirations visuelles doivent rester larges.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double card = 20;
  static const double bouton = 16;
  static const double champ = 14;
  static const double pastille = 999;
}

/// Taille minimale d'une zone tactile, conforme aux recommandations
/// d'accessibilité (48dp) et adaptée à un usage debout en atelier.
class AppTapTarget {
  AppTapTarget._();

  static const double min = 56;
}
