import 'package:flutter/material.dart';

/// Gestion officielle du responsive pour ForeverCare AI.
///
/// Toutes les décisions d'affichage adaptatif doivent
/// utiliser cette classe.
abstract final class AppBreakpoints {
  AppBreakpoints._();

  //--------------------------------------------------------------------------
  // Largeurs officielles
  //--------------------------------------------------------------------------

  static const double mobile = 600;

  static const double tablet = 840;

  static const double desktop = 1200;

  static const double largeDesktop = 1600;

  //--------------------------------------------------------------------------
  // Largeur maximale du contenu
  //--------------------------------------------------------------------------

  static const double maxContentWidth = 1400;

  //--------------------------------------------------------------------------
  // Dimensions écran
  //--------------------------------------------------------------------------

  static double width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double height(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  //--------------------------------------------------------------------------
  // Détection des appareils
  //--------------------------------------------------------------------------

  static bool isMobile(BuildContext context) {
    return width(context) < mobile;
  }

  static bool isTablet(BuildContext context) {
    final w = width(context);

    return w >= mobile && w < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return width(context) >= desktop;
  }

  static bool isLargeDesktop(BuildContext context) {
    return width(context) >= largeDesktop;
  }

  //--------------------------------------------------------------------------
  // Largeur du contenu
  //--------------------------------------------------------------------------

  static double contentWidth(BuildContext context) {
    final w = width(context);

    if (w > maxContentWidth) {
      return maxContentWidth;
    }

    return w;
  }
}
