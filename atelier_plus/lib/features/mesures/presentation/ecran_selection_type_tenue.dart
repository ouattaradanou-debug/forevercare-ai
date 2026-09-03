import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/gabarits_providers.dart';

/// Choix du type de tenue avant la prise de mesure.
///
/// Hydrate elle-même le cache des gabarits (comme EcranGestionTypesTenue) :
/// un tailleur qui va directement "Prendre une mesure" sans jamais être
/// passé par l'écran de gestion des types de tenue doit quand même voir
/// les gabarits par défaut, pas une liste vide.
class EcranSelectionTypeTenue extends ConsumerStatefulWidget {
  const EcranSelectionTypeTenue({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<EcranSelectionTypeTenue> createState() => _EcranSelectionTypeTenueState();
}

class _EcranSelectionTypeTenueState extends ConsumerState<EcranSelectionTypeTenue> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(gabaritsRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final types = ref.watch(typesTenueVisiblesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quel type de tenue ?')),
      body: types.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (liste) {
          if (liste.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucun gabarit disponible pour le moment.\n'
                  'Connectez-vous à internet une première fois pour les récupérer.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: liste.length,
            itemBuilder: (context, index) {
              final type = liste[index];
              return ListTile(
                leading: const Icon(Icons.checkroom),
                title: Text(type.nom),
                subtitle: Text(type.sexe[0].toUpperCase() + type.sexe.substring(1)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.priseMesure(widget.clientId, type.id)),
              );
            },
          );
        },
      ),
    );
  }
}
