import 'package:flutter/material.dart';

import '../../../../design_system/foundations/duration/app_duration.dart';
import '../../../../design_system/foundations/radius/app_radius.dart';
import '../../../../design_system/foundations/spacing/app_spacing.dart';

/// Bouton officiel du ForeverCare UI Kit.
///
/// Utilisé dans toute l'application.
///
/// Ce composant ne contient aucune logique métier.
enum FCButtonVariant { primary, secondary, outlined, text }

enum FCButtonSize { small, medium, large }

class FCButton extends StatelessWidget {
  const FCButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = FCButtonVariant.primary,
    this.size = FCButtonSize.medium,
    this.isLoading = false,
  });

  final String label;

  final VoidCallback? onPressed;

  final IconData? icon;

  final FCButtonVariant variant;

  final FCButtonSize size;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedSwitcher(
      duration: AppDuration.fast,
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: _foregroundColor(context),
              ),
            )
          : _buildContent(context),
    );

    switch (variant) {
      case FCButtonVariant.primary:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: _filledStyle(context),
          child: child,
        );

      case FCButtonVariant.secondary:
        return FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: _filledStyle(context),
          child: child,
        );

      case FCButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: _outlinedStyle(context),
          child: child,
        );

      case FCButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: _textStyle(context),
          child: child,
        );
    }
  }

  Widget _buildContent(BuildContext context) {
    final text = Text(label);

    if (icon == null) {
      return text;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.iconSpacing),
        text,
      ],
    );
  }

  ButtonStyle _filledStyle(BuildContext context) {
    return FilledButton.styleFrom(
      minimumSize: Size.fromHeight(_height),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      animationDuration: AppDuration.fast,
    );
  }

  ButtonStyle _outlinedStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      minimumSize: Size.fromHeight(_height),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      animationDuration: AppDuration.fast,
    );
  }

  ButtonStyle _textStyle(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: Size.fromHeight(_height),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      animationDuration: AppDuration.fast,
    );
  }

  Color _foregroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (variant) {
      case FCButtonVariant.primary:
        return scheme.onPrimary;

      case FCButtonVariant.secondary:
        return scheme.onSecondaryContainer;

      case FCButtonVariant.outlined:
      case FCButtonVariant.text:
        return scheme.primary;
    }
  }

  double get _height {
    switch (size) {
      case FCButtonSize.small:
        return 44;

      case FCButtonSize.medium:
        return AppSpacing.buttonHeight;

      case FCButtonSize.large:
        return 60;
    }
  }
}
