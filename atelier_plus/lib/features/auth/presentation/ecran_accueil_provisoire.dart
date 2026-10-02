import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/sync/sync_providers.dart';
import '../../abonnement/presentation/bandeau_essai.dart';
import '../../abonnement/providers/abonnement_providers.dart';
import '../providers/auth_providers.dart';

/// Écran d'accueil minimal : confirme la connexion, affiche le nom et le
/// logo de l'atelier, le bandeau d'essai le cas échéant, et donne accès
/// aux clients, aux rendez-vous, à la vente prête à porter et (pour le
/// propriétaire) à l'abonnement. Les réglages de l'atelier (types de
/// tenue, équipe) et le thème sont regroupés dans l'écran Paramètres,
/// accessible via l'icône ⚙️. Le vrai tableau de bord (statistiques) sera
/// construit dans une phase ultérieure.
class EcranAccueilProvisoire extends ConsumerStatefulWidget {
  const EcranAccueilProvisoire({super.key});

  @override
  ConsumerState<EcranAccueilProvisoire> createState() => _EcranAccueilProvisoireState();
}

class _EcranAccueilProvisoireState extends ConsumerState<EcranAccueilProvisoire> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(abonnementRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          const BandeauEssai(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.dateLongue(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                IconButton(
                  tooltip: 'Paramètres',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(AppRoutes.parametres),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    atelier.when(
                      data: (a) => a?.logoUrl == null
                          ? const CircleAvatar(radius: 36, child: Icon(Icons.storefront, size: 32))
                          : CircleAvatar(
                              radius: 36,
                              backgroundImage: NetworkImage(a!.logoUrl!),
                            ),
                      loading: () => const SizedBox(height: 72),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutes.ventePretAPorter),
                      icon: const Icon(Icons.checkroom_outlined),
                      label: const Text('Vente prête à porter'),
                    ),
                    if (estProprietaire) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push(AppRoutes.abonnement),
                        icon: const Icon(Icons.workspace_premium_outlined),
                        label: const Text('Mon abonnement'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
