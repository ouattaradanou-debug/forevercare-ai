import 'app_dark_colors.dart';
import 'app_light_colors.dart';

/// Point d'entrée officiel des palettes de couleurs.
///
/// Toute l'application doit accéder aux couleurs via cette façade.
abstract final class AppColors {
  AppColors._();

  /// Palette du thème clair.
  static Type get light => AppLightColors;

  /// Palette du thème sombre.
  static Type get dark => AppDarkColors;
}
