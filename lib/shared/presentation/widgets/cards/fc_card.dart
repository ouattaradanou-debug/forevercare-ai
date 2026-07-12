import 'package:flutter/material.dart';

import '../../../../design_system/foundations/radius/app_radius.dart';
import '../../../../design_system/foundations/spacing/app_spacing.dart';
import '../../../../design_system/foundations/elevation/app_elevation.dart';
import '../../../../design_system/foundations/duration/app_duration.dart';

/// Carte officielle de ForeverCare AI.
///
/// Tous les écrans de l'application doivent utiliser FCCard
/// au lieu de Card ou Container lorsque cela représente
/// un bloc de contenu.
class FCCard extends StatelessWidget {
  const FCCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.style = FCCardStyle.elevated,
  });

  final Widget child;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;

  final FCCardStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderRadius = AppRadius.card;

    BoxDecoration decoration;

    switch (style) {
      case FCCardStyle.flat:
        decoration = BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: borderRadius,
        );
        break;

      case FCCardStyle.outlined:
        decoration = BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: borderRadius,
        );
        break;

      case FCCardStyle.elevated:
        decoration = BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: borderRadius,
          boxShadow: AppElevation.card,
        );
        break;
    }

    Widget content = AnimatedContainer(
      duration: AppDuration.fast,
      margin: margin,
      padding: padding ?? AppSpacing.defaultCardPadding,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Variantes officielles des cartes.
enum FCCardStyle { flat, outlined, elevated }
