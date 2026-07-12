import 'package:flutter/material.dart';

/// Espacements officiels du ForeverCare Design Language (FDL).
///
/// Toutes les marges, paddings et espacements de l'application
/// doivent utiliser exclusivement cette classe.
///
/// Les widgets du FCUI Kit doivent privilégier les
/// Design Tokens sémantiques (cardPadding, screenPadding, etc.)
/// plutôt que les valeurs numériques.
abstract final class AppSpacing {
  AppSpacing._();

  //--------------------------------------------------------------------------
  // Primitive spacing scale (8px Grid System)
  //--------------------------------------------------------------------------

  static const double none = 0;

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 48;
  static const double massive = 56;
  static const double hero = 64;
  static const double screen = 80;
  static const double section = 96;

  //--------------------------------------------------------------------------
  // Generic EdgeInsets
  //--------------------------------------------------------------------------

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  //--------------------------------------------------------------------------
  // Semantic paddings
  //--------------------------------------------------------------------------

  /// Padding principal des écrans.
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  /// Padding standard des cartes.
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Padding des formulaires.
  static const EdgeInsets formPadding = EdgeInsets.all(lg);

  /// Padding des boîtes de dialogue.
  static const EdgeInsets dialogPadding = EdgeInsets.all(xxl);

  //--------------------------------------------------------------------------
  // Semantic spacing
  //--------------------------------------------------------------------------

  /// Espacement entre deux grandes sections.
  static const double sectionSpacing = xxxl;

  /// Espacement entre deux cartes.
  static const double cardSpacing = lg;

  /// Espacement entre les éléments d'une liste.
  static const double itemSpacing = md;

  /// Espacement entre les champs d'un formulaire.
  static const double fieldSpacing = lg;

  /// Espacement entre un titre et son contenu.
  static const double titleSpacing = sm;

  /// Espacement entre une icône et un texte.
  static const double iconSpacing = sm;

  //--------------------------------------------------------------------------
  // Semantic aliases
  //--------------------------------------------------------------------------

  static const EdgeInsets screenPadding = pagePadding;

  static const EdgeInsets defaultCardPadding = cardPadding;

  static const EdgeInsets defaultFormPadding = formPadding;

  //--------------------------------------------------------------------------
  // Standard dimensions
  //--------------------------------------------------------------------------

  static const double buttonHeight = 52;

  static const double inputHeight = 56;

  static const double appBarHeight = 64;

  static const double bottomBarHeight = 72;
}
