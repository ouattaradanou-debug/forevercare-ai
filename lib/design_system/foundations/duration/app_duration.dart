/// Durées officielles du ForeverCare Design Language (FDL).
///
/// Toutes les animations, transitions et temporisations
/// de l'application doivent utiliser exclusivement cette classe.
abstract final class AppDuration {
  AppDuration._();

  //--------------------------------------------------------------------------
  // Durées de base
  //--------------------------------------------------------------------------

  static const Duration instant = Duration(milliseconds: 0);

  static const Duration veryFast = Duration(milliseconds: 100);

  static const Duration fast = Duration(milliseconds: 150);

  static const Duration normal = Duration(milliseconds: 250);

  static const Duration medium = Duration(milliseconds: 350);

  static const Duration slow = Duration(milliseconds: 500);

  static const Duration verySlow = Duration(milliseconds: 700);

  static const Duration extraSlow = Duration(milliseconds: 1000);

  //--------------------------------------------------------------------------
  // Transitions Material
  //--------------------------------------------------------------------------

  static const Duration pageTransition = normal;

  static const Duration dialogTransition = fast;

  static const Duration bottomSheetTransition = medium;

  static const Duration snackbar = Duration(seconds: 3);

  static const Duration tooltip = Duration(milliseconds: 1200);

  //--------------------------------------------------------------------------
  // Chargement
  //--------------------------------------------------------------------------

  static const Duration splash = Duration(seconds: 2);

  static const Duration skeleton = Duration(milliseconds: 900);

  static const Duration refresh = Duration(milliseconds: 800);

  //--------------------------------------------------------------------------
  // Feedback utilisateur
  //--------------------------------------------------------------------------

  static const Duration successAnimation = fast;

  static const Duration errorAnimation = normal;

  static const Duration warningAnimation = normal;

  static const Duration infoAnimation = fast;

  //--------------------------------------------------------------------------
  // Délais
  //--------------------------------------------------------------------------

  static const Duration debounce = Duration(milliseconds: 400);

  static const Duration searchDelay = Duration(milliseconds: 500);

  static const Duration autoSave = Duration(seconds: 2);

  static const Duration sessionRefresh = Duration(minutes: 5);
}
