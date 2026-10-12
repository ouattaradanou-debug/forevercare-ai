import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../data/models/champ_mesure.dart';
import '../../../data/models/type_tenue.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/gabarits_providers.dart';

/// Gestion des champs d'un type de tenue : ajout de champ personnalisé,
/// masquage (jamais de suppression définitive). Sur un gabarit par défaut
/// (non modifiable, voir supabase/README.md), seule l'action "Dupliquer"
/// est proposée.
class EcranGestionChamps extends ConsumerWidget {
  const EcranGestionChamps({super.key, required this.type});

  final TypeTenue type;

  Future<void> _demanderMasquage(BuildContext context, WidgetRef ref, ChampMesure champ) async {
    final repo = ref.read(gabaritsRepositoryProvider);
    final utilise = await repo.champUtiliseParDesMesures(champ);

    if (!context.mounted) return;

    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Masquer "${champ.nom}" ?'),
        content: Text(
          utilise
              ? 'Ce champ a déjà été utilisé dans des mesures existantes. '
                  'Le masquer ne supprime pas cet historique, mais il '
                  'n\'apparaîtra plus dans les nouvelles prises de mesure.'
              : 'Ce champ n\'apparaîtra plus dans les nouvelles prises de mesure. '
                  'Il pourra être réactivé plus tard.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Masquer')),
        ],
      ),
    );

    if (confirmer == true) {
      await executerAvecErreurAffichee(
        context,
        () => repo.masquerChamp(champ, atelierId: type.atelierId),
      );
    }
  }

  Future<void> _ajouterChamp(BuildContext context, WidgetRef ref) async {
    final controleur = TextEditingController();
    final nom = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau champ de mesure'),
        content: TextField(
          controller: controleur,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom du champ (ex : Tour de mollet)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controleur.text.trim()),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (nom != null && nom.isNotEmpty) {
      await ref.read(gabaritsRepositoryProvider).ajouterChamp(
            typeTenueId: type.id,
            nom: nom,
            atelierId: type.atelierId,
          );
    }
  }

  Future<void> _reordonner(
    BuildContext context,
    WidgetRef ref,
    List<ChampMesure> liste,
    int ancienIndex,
    int nouvelIndex,
  ) async {
    final reordonnee = List<ChampMesure>.of(liste);
    if (nouvelIndex > ancienIndex) nouvelIndex -= 1;
    final champ = reordonnee.removeAt(ancienIndex);
    reordonnee.insert(nouvelIndex, champ);
    await executerAvecErreurAffichee(
      context,
      () => ref
          .read(gabaritsRepositoryProvider)
          .reordonnerChamps(reordonnee, atelierId: type.atelierId),
    );
  }

  Future<void> _dupliquer(BuildContext context, WidgetRef ref) async {
    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null) return;
    final copie = await ref.read(gabaritsRepositoryProvider).dupliquerGabarit(
          source: type,
          atelierId: utilisateur.atelierId,
        );
    if (context.mounted) {
      context.pushReplacement(AppRoutes.gestionChampsTypeTenue(copie.id), extra: copie);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final champs = ref.watch(tousLesChampsProvider(type.id));
    final estProprietaire = ref.watch(estProprietaireProvider);
    final peutModifier = estProprietaire && !type.estGabaritParDefaut;

    return Scaffold(
      appBar: AppBar(
        title: Text(type.nom),
        actions: [
          if (estProprietaire && type.estGabaritParDefaut)
            TextButton.icon(
              onPressed: () => _dupliquer(context, ref),
              icon: const Icon(Icons.copy_all, color: Colors.white),
              label: const Text('Dupliquer', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (type.estGabaritParDefaut)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.secondaryContainer,
              padding: const EdgeInsets.all(12),
              child: const Text(
                'Gabarit par défaut : non modifiable. Dupliquez-le pour '
                'personnaliser ses champs.',
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: champs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
              data: (liste) {
                if (liste.isEmpty) {
                  return const Center(child: Text('Aucun champ de mesure.'));
                }
                Widget construireLigne(int index) {
                  final champ = liste[index];
                  final actif = champ.statut == StatutChamp.actif;
                  return ListTile(
                    key: ValueKey(champ.id),
                    title: Text(champ.nom),
                    subtitle: Text('Unité : ${champ.unite}${actif ? '' : ' — masqué'}'),
                    trailing: peutModifier
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: actif,
                                onChanged: (valeur) async {
                                  final repo = ref.read(gabaritsRepositoryProvider);
                                  if (valeur) {
                                    await executerAvecErreurAffichee(
                                      context,
                                      () => repo.reactiverChamp(champ, atelierId: type.atelierId),
                                    );
                                  } else {
                                    await _demanderMasquage(context, ref, champ);
                                  }
                                },
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.drag_handle, color: Color(0xFF6F6259)),
                                ),
                              ),
                            ],
                          )
                        : null,
                  );
                }

                if (!peutModifier) {
                  return ListView.builder(
                    itemCount: liste.length,
                    itemBuilder: (context, index) => construireLigne(index),
                  );
                }

                // Glisser-déposer (poignée dédiée) pour que le tailleur
                // organise les champs selon ses préférences — l'ordre
                // choisi ici est le même utilisé par la prise de mesure,
                // pour un client comme pour un membre de groupe d'uniformes.
                return ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: liste.length,
                  itemBuilder: (context, index) => construireLigne(index),
                  onReorder: (ancienIndex, nouvelIndex) =>
                      _reordonner(context, ref, liste, ancienIndex, nouvelIndex),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: peutModifier
          ? FloatingActionButton.extended(
              onPressed: () => _ajouterChamp(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un champ'),
            )
          : null,
    );
  }
}
