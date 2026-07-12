import 'package:flutter/material.dart';

/// Rayons officiels du ForeverCare Design Language (FDL).
///
/// Toutes les bordures arrondies de l'application doivent
/// utiliser exclusivement cette classe.
abstract final class AppRadius {
  AppRadius._();

  //--------------------------------------------------------------------------
  // Valeurs numériques
  //--------------------------------------------------------------------------

  static const double none = 0;

  static const double xs = 4;

  static const double sm = 8;

  static const double md = 12;

  static const double lg = 16;

  static const double xl = 20;

  static const double xxl = 24;

  static const double pill = 999;

  //--------------------------------------------------------------------------
  // BorderRadius
  //--------------------------------------------------------------------------

  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));

  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));

  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));

  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));

  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));

  static const BorderRadius radiusPill = BorderRadius.all(
    Radius.circular(pill),
  );

  //--------------------------------------------------------------------------
  // Formes spécialisées
  //--------------------------------------------------------------------------

  static const BorderRadius card = radiusLg;

  static const BorderRadius dialog = radiusXl;

  static const BorderRadius button = radiusLg;

  static const BorderRadius input = radiusMd;

  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}
