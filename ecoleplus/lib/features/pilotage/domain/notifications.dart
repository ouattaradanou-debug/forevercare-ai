import 'package:flutter/material.dart';

/// Une notification de l'application (cloche de l'accueil). Elles sont
/// calculées sur le téléphone à partir des données de l'école : rien
/// n'est envoyé quand l'application est fermée.
class NotificationEcole {
  const new({
    required this.id,
    required this.titre,
    required this.route,
    this.detail,
    this.icone = Icons.notifications_outlined,
    this.importante = false,
  });

  /// Stable pour une même situation (« appel:2026-11-05:classe ») : une
  /// notification lue ne revient pas, une nouvelle situation oui.
  final String id;
  final String titre;
  final String? detail;
  final String route;
  final IconData icone;
  final bool importante;
}

/// Non lues d'abord, importantes d'abord.
List<NotificationEcole> trierNotifications(
  List<NotificationEcole> l,
  Set<String> lues,
) => [...l]
  ..sort((a, b) {
    final la = lues.contains(a.id) ? 1 : 0;
    final lb = lues.contains(b.id) ? 1 : 0;
    if (la != lb) return la.compareTo(lb);
    return (b.importante ? 1 : 0).compareTo(a.importante ? 1 : 0);
  });
