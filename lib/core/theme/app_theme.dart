import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Thème visuel centralisé d'Atelier+.
///
/// Toute l'identité visuelle de l'application (couleurs, typographie,
/// boutons, cartes, champs de saisie) est définie ici pour garantir une
/// cohérence totale entre les écrans, quelle que soit la fonctionnalité.
class AppTheme {
  AppTheme._();

  static ThemeData get clair {
    const ColorScheme scheme = ColorScheme.light(
      primary: AppColors.indigo700,
      onPrimary: AppColors.ecru50,
      primaryContainer: AppColors.indigo900,
      onPrimaryContainer: AppColors.ecru50,
      secondary: AppColors.terracotta600,
      onSecondary: AppColors.ecru50,
      tertiary: AppColors.or500,
      onTertiary: AppColors.anthracite900,
      surface: AppColors.blanc,
      onSurface: AppColors.anthracite900,
      surfaceContainerHighest: AppColors.ecru100,
      error: AppColors.erreur,
      onError: AppColors.blanc,
      outline: AppColors.bordure,
    );

    return _construire(scheme, fond: AppColors.ecru50);
  }

  static ThemeData get sombre {
    const ColorScheme scheme = ColorScheme.dark(
      primary: AppColors.or500,
      onPrimary: AppColors.anthracite900,
      primaryContainer: AppColors.indigo700,
      onPrimaryContainer: AppColors.ecru50,
      secondary: AppColors.terracotta300,
      onSecondary: AppColors.anthracite900,
      tertiary: AppColors.or300,
      onTertiary: AppColors.anthracite900,
      surface: Color(0xFF242231),
      onSurface: AppColors.ecru50,
      surfaceContainerHighest: Color(0xFF2E2C3D),
      error: Color(0xFFE3897A),
      onError: AppColors.anthracite900,
      outline: Color(0xFF4A4658),
    );

    return _construire(scheme, fond: AppColors.indigo900);
  }

  static ThemeData _construire(ColorScheme scheme, {required Color fond}) {
    final TextTheme texte = AppTypography.textTheme(scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: fond,
      textTheme: texte,
      splashFactory: InkRipple.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: texte.headlineMedium,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 26),
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(AppTapTarget.min),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          textStyle: texte.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.bouton),
          ),
          elevation: 0,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          minimumSize: const Size.fromHeight(AppTapTarget.min),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          textStyle: texte.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.bouton),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(AppTapTarget.min),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          textStyle: texte.labelLarge,
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.bouton),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, AppTapTarget.min),
          textStyle: texte.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.bouton),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppTapTarget.min, AppTapTarget.min),
          foregroundColor: scheme.onSurface,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        labelStyle: texte.bodyMedium,
        hintStyle: texte.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.champ),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.champ),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.champ),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.champ),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        labelStyle: texte.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pastille),
        ),
        side: BorderSide.none,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary.withValues(alpha: 0.4)
              : scheme.surfaceContainerHighest,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.6),
        thickness: 1,
        space: AppSpacing.l,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.primaryContainer,
        contentTextStyle: texte.bodyMedium?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.champ),
        ),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
