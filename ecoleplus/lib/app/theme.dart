import 'package:ecoleplus/app/charte.dart';
import 'package:flutter/material.dart';

export 'package:ecoleplus/app/charte.dart';

/// Thème unique de l'application, construit sur la charte graphique (A28) :
/// bleu marine structurant, orange pour l'accent, surfaces blanches sur fond
/// gris très clair, gros caractères et grandes zones tactiles (R5).
ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: Charte.marine).copyWith(
    primary: Charte.marine,
    onPrimary: Charte.blanc,
    primaryContainer: Charte.bleuClair,
    onPrimaryContainer: Charte.marineFonce,
    secondary: Charte.orange,
    onSecondary: Charte.blanc,
    secondaryContainer: Charte.orangePale,
    onSecondaryContainer: const Color(0xFF6B3600),
    tertiary: Charte.orangeFonce,
    error: Charte.rouge,
    errorContainer: Charte.rougePale,
    onErrorContainer: const Color(0xFF7A1D1D),
    surface: Charte.blanc,
    onSurface: Charte.marineFonce,
    onSurfaceVariant: Charte.texteSecondaire,
    outline: const Color(0xFF8C96A8),
    outlineVariant: Charte.bordure,
    surfaceContainerLowest: Charte.blanc,
    surfaceContainerLow: const Color(0xFFF8FAFD),
    surfaceContainer: Charte.fond,
    surfaceContainerHighest: const Color(0xFFE9EEF5),
  );
  const police = 'Roboto';
  final bordureChamp = OutlineInputBorder(
    borderRadius: BorderRadius.circular(Charte.rayonBouton),
    borderSide: const BorderSide(color: Charte.bordure),
  );
  final formeBouton = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Charte.rayonBouton),
  );
  return ThemeData(
    // Police du système Android (nommée pour que les captures du guide
    // aient le même texte que le téléphone).
    fontFamily: police,
    colorScheme: scheme,
    scaffoldBackgroundColor: Charte.fond,
    visualDensity: VisualDensity.standard,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Charte.marineFonce,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Charte.marineFonce,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Charte.marineFonce,
      ),
      bodyLarge: TextStyle(fontSize: 17, color: Charte.marineFonce),
      bodyMedium: TextStyle(fontSize: 15, color: Charte.marineFonce),
      bodySmall: TextStyle(fontSize: 13, color: Charte.texteSecondaire),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Charte.marine,
      foregroundColor: Charte.blanc,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: police,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Charte.blanc,
      ),
    ),
    // Bouton principal (Enregistrer, Valider) : marine. Les actions phares
    // utilisent [StylesBoutons.accent] (orange).
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Charte.marine,
        foregroundColor: Charte.blanc,
        disabledBackgroundColor: const Color(0xFFDDE3EC),
        disabledForegroundColor: const Color(0xFF8C96A8),
        minimumSize: const Size.fromHeight(54),
        shape: formeBouton,
        textStyle: const TextStyle(
          fontFamily: police,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Charte.marine,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: Color(0xFFB9C4D6)),
        shape: formeBouton,
        textStyle: const TextStyle(
          fontFamily: police,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Charte.bleu,
        minimumSize: const Size(48, 44),
        shape: formeBouton,
        textStyle: const TextStyle(
          fontFamily: police,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
    ),
    cardTheme: CardThemeData(
      color: Charte.blanc,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Charte.rayon),
        side: const BorderSide(color: Charte.bordure),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Charte.marine,
      contentPadding: EdgeInsets.symmetric(horizontal: 14),
    ),
    dividerTheme: const DividerThemeData(color: Charte.bordure, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Charte.blanc,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: bordureChamp,
      enabledBorder: bordureChamp,
      focusedBorder: bordureChamp.copyWith(
        borderSide: const BorderSide(color: Charte.marine, width: 2),
      ),
      errorBorder: bordureChamp.copyWith(
        borderSide: const BorderSide(color: Charte.rouge),
      ),
      focusedErrorBorder: bordureChamp.copyWith(
        borderSide: const BorderSide(color: Charte.rouge, width: 2),
      ),
      labelStyle: const TextStyle(color: Charte.texteSecondaire),
      floatingLabelStyle: const TextStyle(color: Charte.marine),
      helperStyle: const TextStyle(color: Charte.texteSecondaire),
      errorStyle: const TextStyle(color: Charte.rouge),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Charte.blanc,
        border: bordureChamp,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Charte.blanc,
      selectedColor: Charte.orangePale,
      checkmarkColor: Charte.orangeFonce,
      side: const BorderSide(color: Charte.bordure),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: const TextStyle(
        fontFamily: police,
        fontSize: 14,
        color: Charte.marineFonce,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Charte.orangePale
              : Charte.blanc,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF6B3600)
              : Charte.marineFonce,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: Color(0xFFB9C4D6)),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Charte.blanc : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Charte.marine : null,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Charte.marine : null,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Charte.marine : null,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Charte.blanc,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Charte.rayonDialogue),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: police,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Charte.marineFonce,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: police,
        fontSize: 16,
        color: Charte.marineFonce,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Charte.blanc,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Charte.rayonDialogue),
        ),
      ),
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Charte.marineFonce,
      contentTextStyle: const TextStyle(
        fontFamily: police,
        fontSize: 15,
        color: Charte.blanc,
      ),
      actionTextColor: Charte.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Charte.rayonBouton),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Charte.orange,
      linearTrackColor: Color(0xFFFCE3C7),
    ),
    badgeTheme: const BadgeThemeData(backgroundColor: Charte.orange),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Charte.orange,
      foregroundColor: Charte.blanc,
    ),
    expansionTileTheme: const ExpansionTileThemeData(
      iconColor: Charte.marine,
      collapsedIconColor: Charte.marine,
    ),
  );
}

/// Styles des boutons qui ne sont pas le bouton principal : mêmes couleurs
/// dans tous les modules.
abstract final class StylesBoutons {
  /// Action phare d'un écran (Encaisser, Valider l'appel, Créer…) : orange.
  static final ButtonStyle accent = FilledButton.styleFrom(
    backgroundColor: Charte.orange,
    foregroundColor: Charte.blanc,
  );

  /// Action destructive (Supprimer, Annuler un reçu, Déconnecter) : rouge.
  static final ButtonStyle danger = OutlinedButton.styleFrom(
    foregroundColor: Charte.rouge,
    side: const BorderSide(color: Color(0xFFF0B4B4)),
  );

  /// Bouton destructif plein (confirmation d'une suppression).
  static final ButtonStyle dangerPlein = FilledButton.styleFrom(
    backgroundColor: Charte.rouge,
    foregroundColor: Charte.blanc,
  );
}
