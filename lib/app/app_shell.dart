import 'package:flutter/material.dart';

import '../design_system/themes/app_theme.dart';

/// Shell principal de ForeverCare AI.
///
/// Centralise les services globaux de l'application.
/// Les fonctionnalités (Router, Riverpod, Drift, etc.)
/// seront ajoutées progressivement.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(data: AppTheme.light, child: child);
  }
}
