import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../auth/providers/auth_providers.dart';

/// Regroupe les réglages de l'atelier (types de tenue, équipe) et les
/// préférences d'affichage (thème), accessible depuis l'icône ⚙️ de
/// l'accueil.
class EcranParametres extends ConsumerWidget {
  const EcranParametres({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estProprietaire = ref.watch(estProprietaireProvider);
    final modeTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          if (estProprietaire) ...[
            const _EnTeteSection(titre: 'Atelier'),
            ListTile(
              leading: const Icon(Icons.checkroom_outlined),
              title: const Text('Mes types de tenue'),
              subtitle: const Text('Gabarits et champs de mesure'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.typesTenue),
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Mon équipe'),
              subtitle: const Text('Gérer mes apprentis'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.apprentis),
            ),
            const Divider(height: 32),
          ],
          const _EnTeteSection(titre: 'Affichage'),
          RadioListTile<ThemeMode>(
            title: const Text('Clair'),
            secondary: const Icon(Icons.light_mode_outlined),
            value: ThemeMode.light,
            groupValue: modeTheme,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).definir(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sombre'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: ThemeMode.dark,
            groupValue: modeTheme,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).definir(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Système'),
            subtitle: const Text('Suit le réglage de votre téléphone'),
            secondary: const Icon(Icons.brightness_auto_outlined),
            value: ThemeMode.system,
            groupValue: modeTheme,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).definir(mode!),
          ),
        ],
      ),
    );
  }
}

class _EnTeteSection extends StatelessWidget {
  const _EnTeteSection({required this.titre});

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        titre,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
