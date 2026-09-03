import 'package:flutter/material.dart';

/// Exécute [action] et affiche l'erreur dans un SnackBar si elle échoue.
///
/// Utilisé pour les actions rapides (interrupteurs, éléments de menu) qui
/// n'ont pas de zone d'erreur dédiée dans un formulaire — notamment pour
/// que `ModeConsultationSeuleException` (abonnement expiré) reste visible
/// à l'utilisateur au lieu d'échouer silencieusement.
Future<void> executerAvecErreurAffichee(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
