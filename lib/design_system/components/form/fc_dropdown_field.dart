import 'package:flutter/material.dart';

import '../../foundations/radius/app_radius.dart';
import '../../foundations/spacing/app_spacing.dart';

/// Liste déroulante officielle du ForeverCare Design Language.
///
/// Toutes les listes déroulantes de l'application
/// doivent utiliser exclusivement ce composant.
class FCDropdownField<T> extends StatelessWidget {
  const FCDropdownField({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.itemLabelBuilder,
  });

  /// Libellé du champ.
  final String? label;

  /// Texte affiché lorsqu'aucune valeur n'est sélectionnée.
  final String? hint;

  /// Valeur sélectionnée.
  final T? value;

  /// Liste des éléments.
  final List<T> items;

  /// Callback de changement.
  final ValueChanged<T?>? onChanged;

  /// Validation.
  final FormFieldValidator<T>? validator;

  /// Champ activé ou non.
  final bool enabled;

  /// Icône à gauche.
  final Widget? prefixIcon;

  /// Icône à droite.
  final Widget? suffixIcon;

  /// Permet de personnaliser le texte affiché.
  final String Function(T value)? itemLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.fieldSpacing),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        validator: validator,
        onChanged: enabled ? onChanged : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          border: OutlineInputBorder(borderRadius: AppRadius.input),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabelBuilder != null
                      ? itemLabelBuilder!(item)
                      : item.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
