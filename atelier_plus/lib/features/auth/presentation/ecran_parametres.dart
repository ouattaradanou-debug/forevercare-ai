import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/preference_theme.dart';

const _bleuSeda = Color(0xFF1B4FA0);

/// Réglages de l'atelier : abonnement, thème et champs de mesure.
class EcranParametres extends ConsumerWidget {
  const EcranParametres({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.card_membership_outlined, color: _bleuSeda),
              title: const Text('Renouveler mon abonnement'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.abonnement),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined, color: _bleuSeda),
              title: const Text('Thème'),
              subtitle: Text(_libelleTheme(themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _choisirTheme(context, ref, themeMode),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.straighten_outlined, color: _bleuSeda),
              title: const Text('Champs de mesure'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.typesTenue),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  String _libelleTheme(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }

  Future<void> _choisirTheme(BuildContext context, WidgetRef ref, ThemeMode actuel) async {
    final choisi = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                value: mode,
                groupValue: actuel,
                activeColor: _bleuSeda,
                title: Text(_libelleTheme(mode)),
                onChanged: (valeur) => Navigator.of(context).pop(valeur),
              ),
          ],
        ),
      ),
    );
    if (choisi != null) {
      await ref.read(themeModeProvider.notifier).definir(choisi);
    }
  }
}
