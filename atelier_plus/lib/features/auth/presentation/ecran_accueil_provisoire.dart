import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/sync/sync_providers.dart';
import '../../abonnement/presentation/bandeau_essai.dart';
import '../../abonnement/providers/abonnement_providers.dart';
import '../providers/auth_providers.dart';

/// Écran d'accueil minimal : bandeau du haut avec la date du jour et
/// l'icône ⚙️ Paramètres, bandeau d'essai le cas échéant, nom/logo de
/// l'atelier, puis l'accès aux clients, aux rendez-vous et à la vente
/// prête à porter. Les réglages de l'atelier (types de tenue, équipe,
/// abonnement) et le thème sont regroupés dans l'écran Paramètres. Le vrai
/// tableau de bord (statistiques) sera construit dans une phase ultérieure.
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
    final tachesEnAttente = ref.watch(tachesSyncEnAttenteProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          Formatters.dateLongue(DateTime.now()),
          style: const TextStyle(fontSize: 15),
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
          // À l'extrême droite du bandeau, comme demandé.
          IconButton(
            tooltip: 'Paramètres',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.parametres),
          ),
        ],
      ),
      body: Column(
        children: [
          const BandeauEssai(),
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
                    const SizedBox(height: 8),
                    atelier.when(
                      data: (a) => Text(
                        a?.nom ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8),
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
