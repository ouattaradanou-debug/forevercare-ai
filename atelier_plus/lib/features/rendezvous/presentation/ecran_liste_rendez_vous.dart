import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_providers.dart';
import '../../clients/providers/clients_providers.dart';
import '../providers/rendezvous_providers.dart';

/// Liste des rendez-vous de l'atelier, triée par date — lecture locale
/// (hors-ligne au quotidien).
class EcranListeRendezVous extends ConsumerStatefulWidget {
  const EcranListeRendezVous({super.key});

  @override
  ConsumerState<EcranListeRendezVous> createState() => _EcranListeRendezVousState();
}

class _EcranListeRendezVousState extends ConsumerState<EcranListeRendezVous> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(rendezVousRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rdvs = ref.watch(rendezVousTriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rendez-vous')),
      body: rdvs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (liste) {
          final actifs = liste.where((r) => r.statut != AppConstants.rdvAnnule).toList();
          if (actifs.isEmpty) {
            return const Center(child: Text('Aucun rendez-vous à venir.'));
          }
          return ListView.builder(
            itemCount: actifs.length,
            itemBuilder: (context, index) {
              final rdv = actifs[index];
              final client = ref.watch(clientParIdProvider(rdv.clientId));
              return ListTile(
                leading: Icon(
                  rdv.type == AppConstants.rdvEssayage ? Icons.checkroom : Icons.local_shipping,
                ),
                title: Text(client.valueOrNull?.nomComplet ?? '…'),
                subtitle: Text(
                  '${Formatters.dateHeure(rdv.dateHeure)} — '
                  '${rdv.type == AppConstants.rdvEssayage ? 'Essayage' : 'Livraison'}',
                ),
                trailing: _PuceStatut(statut: rdv.statut),
                onTap: () => _afficherActions(context, ref, rdv.id, rdv.statut),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.creationRendezVous),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau rendez-vous'),
      ),
    );
  }

  Future<void> _afficherActions(
    BuildContext context,
    WidgetRef ref,
    String rendezVousId,
    String statutActuel,
  ) async {
    final nouveauStatut = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Confirmer'),
              onTap: () => Navigator.pop(context, AppConstants.rdvConfirme),
            ),
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text('Marquer comme terminé'),
              onTap: () => Navigator.pop(context, AppConstants.rdvTermine),
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('Annuler ce rendez-vous'),
              onTap: () => Navigator.pop(context, AppConstants.rdvAnnule),
            ),
          ],
        ),
      ),
    );

    if (nouveauStatut != null && nouveauStatut != statutActuel) {
      await ref.read(rendezVousRepositoryProvider).changerStatutParId(
            rendezVousId,
            nouveauStatut,
          );
    }
  }
}

class _PuceStatut extends StatelessWidget {
  const _PuceStatut({required this.statut});

  final String statut;

  @override
  Widget build(BuildContext context) {
    final Color couleur;
    final String libelle;
    switch (statut) {
      case AppConstants.rdvConfirme:
        couleur = Colors.green;
        libelle = 'Confirmé';
        break;
      case AppConstants.rdvTermine:
        couleur = Colors.blueGrey;
        libelle = 'Terminé';
        break;
      default:
        couleur = Colors.orange;
        libelle = 'Planifié';
    }
    return Chip(
      label: Text(libelle, style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: couleur,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
