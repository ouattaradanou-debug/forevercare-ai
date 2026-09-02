import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../providers/auth_providers.dart';

/// Écran d'accueil minimal de la Phase 1 : confirme la connexion, affiche
/// l'atelier courant et donne accès à la gestion des apprentis. Le vrai
/// tableau de bord (statistiques, accès rapide clients/rendez-vous) sera
/// construit dans les phases suivantes.
class EcranAccueilProvisoire extends ConsumerWidget {
  const EcranAccueilProvisoire({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atelier = ref.watch(atelierCourantProvider);
    final utilisateur = ref.watch(utilisateurCourantProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);

    return Scaffold(
      appBar: AppBar(
        title: atelier.when(
          data: (a) => Text(a?.nom ?? 'Atelier+'),
          loading: () => const Text('Atelier+'),
          error: (_, __) => const Text('Atelier+'),
        ),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).deconnecter();
              if (context.mounted) context.go(AppRoutes.connexion);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              utilisateur.when(
                data: (u) => Text(
                  u == null ? '' : 'Bonjour ${u.nom}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              if (estProprietaire)
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.apprentis),
                  icon: const Icon(Icons.people_outline),
                  label: const Text('Gérer mes apprentis'),
                ),
              const SizedBox(height: 16),
              Text(
                'Clients, mesures, rendez-vous et finances arrivent dans les '
                'phases suivantes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
