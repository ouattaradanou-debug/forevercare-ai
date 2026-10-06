import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/preference_theme.dart';
import '../providers/auth_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);

/// Réglages de l'atelier : abonnement, thème, équipe et champs de mesure
/// (ces deux dernières commandes réservées au propriétaire).
class EcranParametres extends ConsumerWidget {
  const EcranParametres({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);

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
              title: const Text(
                'Renouveler mon abonnement',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.abonnement),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined, color: _bleuSeda),
              title: const Text('Thème', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_libelleTheme(themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _choisirTheme(context, ref, themeMode),
            ),
            if (estProprietaire) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.diversity_3_outlined, color: _bleuSeda),
                title: const Text('Mon équipe', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.apprentis),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.straighten_outlined, color: _bleuSeda),
                title: const Text(
                  'Champs de mesure',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.champsDeMesure),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.draw_outlined, color: _bleuSeda),
                title: const Text('Ma signature', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Utilisée sur les factures PDF'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.signatureAtelier),
              ),
            ],
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
