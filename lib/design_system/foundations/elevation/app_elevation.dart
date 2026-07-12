import 'package:flutter/material.dart';

/// Niveaux d'élévation et ombres officiels
/// du ForeverCare Design Language (FDL).
abstract final class AppElevation {
  AppElevation._();

  //--------------------------------------------------------------------------
  // Material Elevation
  //--------------------------------------------------------------------------

  static const double level0 = 0;

  static const double level1 = 1;

  static const double level2 = 2;

  static const double level3 = 3;

  static const double level4 = 4;

  static const double level6 = 6;

  static const double level8 = 8;

  static const double level12 = 12;

  static const double level16 = 16;

  static const double level24 = 24;

  //--------------------------------------------------------------------------
  // Box Shadows
  //--------------------------------------------------------------------------

  static const List<BoxShadow> shadowXs = [
    BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x18000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 12)),
  ];

  //--------------------------------------------------------------------------
  // Styles prêts à l'emploi
  //--------------------------------------------------------------------------

  static const List<BoxShadow> card = shadowSm;

  static const List<BoxShadow> dialog = shadowLg;

  static const List<BoxShadow> floating = shadowXl;

  static const List<BoxShadow> button = shadowXs;
}
