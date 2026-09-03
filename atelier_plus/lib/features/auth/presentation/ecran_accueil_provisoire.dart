import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/sync/sync_providers.dart';
import '../providers/auth_providers.dart';

/// Écran d'accueil minimal : confirme la connexion, affiche l'atelier
/// courant et donne accès aux apprentis, aux clients, aux types de tenue et
/// aux rendez-vous. Le vrai tableau de bord (statistiques) sera construit
/// dans une phase ultérieure.
class EcranAccueilProvisoire extends ConsumerWidget {
  const EcranAccueilProvisoire({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atelier = ref.watch(atelierCourantProvider);
    final utilisateur = ref.watch(utilisateurCourantProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);
    final tachesEnAttente = ref.watch(tachesSyncEnAttenteProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: atelier.when(
          data: (a) => Text(a?.nom ?? 'Atelier+'),
          loading: () => const Text('Atelier+'),
          error: (_, __) => const Text('Atelier+'),
        ),
        actions: [
          if (tachesEnAttente > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Tooltip(
                  message: '$tachesEnAttente modification(s) en attente de connexion',
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text('$tachesEnAttente', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
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
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.clients),
                icon: const Icon(Icons.people_alt_outlined),
                label: const Text('Mes clients'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.rendezVous),
                icon: const Icon(Icons.event_outlined),
                label: const Text('Rendez-vous'),
              ),
              if (estProprietaire) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.typesTenue),
                  icon: const Icon(Icons.checkroom_outlined),
                  label: const Text('Mes types de tenue'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.apprentis),
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Gérer mes apprentis'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
