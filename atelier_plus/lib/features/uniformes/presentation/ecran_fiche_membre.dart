import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/widgets/en_tete_section.dart';
import '../../../data/models/membre_groupe_uniforme.dart';
import '../../auth/providers/auth_providers.dart';
import '../../branding/data/donnees_export_client.dart';
import '../../branding/providers/branding_providers.dart';
import '../../mesures/providers/gabarits_providers.dart';
import '../../mesures/utils/choix_gabarit.dart';
import '../providers/uniformes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);

/// Fiche récapitulative d'un membre de groupe — même principe que la fiche
/// client (EcranFicheClient) : informations puis dernières mesures connues,
/// affichées en lecture seule, avec la possibilité de reprendre une mesure.
/// Contrairement à un client (un seul gabarit fixé par son sexe), un membre
/// peut avoir plusieurs types de tenue : chacun avec au moins une mesure
/// obtient sa propre carte.
class EcranFicheMembre extends ConsumerStatefulWidget {
  const EcranFicheMembre({super.key, required this.membre});

  final MembreGroupeUniforme membre;

  @override
  ConsumerState<EcranFicheMembre> createState() => _EcranFicheMembreState();
}

class _EcranFicheMembreState extends ConsumerState<EcranFicheMembre> {
  late MembreGroupeUniforme _membre;
  late Future<List<GroupeMesureExport>> _chargement;

  @override
  void initState() {
    super.initState();
    _membre = widget.membre;
    _chargement = _charger();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(gabaritsRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  Future<List<GroupeMesureExport>> _charger() async {
    // Attendu (pas en arrière-plan) : même raison que
    // EcranFicheClient._charger, sinon un appareil qui n'a pas pris la
    // mesure lui-même afficherait une fiche vide.
    await ref.read(mesuresUniformeRepositoryProvider).chargerDepuisServeur(_membre.id);
    return ref.read(donneesExportMembreProvider).dernieresMesuresParType(_membre.id);
  }

  Future<void> _basculerTenueTerminee() async {
    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null || !mounted) return;
    final miseAJour = await ref.read(membresGroupeUniformeRepositoryProvider).basculerTenueTerminee(
          atelierId: utilisateur.atelierId,
          membre: _membre,
        );
    if (mounted) setState(() => _membre = miseAJour);
  }

  /// Formulaire "Modifier le membre" (nom et sexe), avec un accès direct à
  /// la suppression — même principe que
  /// EcranGroupesUniformes._modifierGroupe.
  Future<void> _modifierMembre() async {
    final nomCtrl = TextEditingController(text: _membre.nomComplet);
    String? sexe = _membre.sexe;

    final resultat = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          scrollable: true,
          title: const Text('Modifier le membre', style: TextStyle(color: _bleuSeda)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nom et prénom'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Homme', label: Text('Homme')),
                  ButtonSegment(value: 'Femme', label: Text('Femme')),
                ],
                selected: sexe == null ? {} : {sexe!},
                emptySelectionAllowed: true,
                onSelectionChanged: (selection) =>
                    setDialogState(() => sexe = selection.isEmpty ? null : selection.first),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(dialogContext, 'supprimer'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFB3261E)),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Supprimer le membre'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(foregroundColor: _bleuSeda),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, 'enregistrer'),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF5821F)),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (resultat == null || !mounted) return;

    if (resultat == 'supprimer') {
      await _confirmerSuppressionMembre();
      return;
    }

    final nom = nomCtrl.text.trim();
    if (nom.isEmpty) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null || !mounted) return;
    final miseAJour = await ref.read(membresGroupeUniformeRepositoryProvider).modifierMembre(
          atelierId: utilisateur.atelierId,
          membre: _membre,
          nom: nom,
          sexe: sexe,
        );
    if (mounted) setState(() => _membre = miseAJour);
  }

  /// Confirmation avant suppression définitive — supprime aussi toutes les
  /// mesures du membre. Impossible à annuler, comme la suppression d'un
  /// groupe ou d'un client.
  Future<void> _confirmerSuppressionMembre() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text(
          'Cette action supprime définitivement "${_membre.nomComplet}", ainsi que '
          'toutes ses mesures. Impossible à annuler.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null || !mounted) return;
    try {
      await ref.read(membresGroupeUniformeRepositoryProvider).supprimerMembre(
            atelierId: utilisateur.atelierId,
            membre: _membre,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  /// Ouvre directement la prise de mesure pour le gabarit par défaut du
  /// sexe du membre (même résolution que EcranFicheClient._ouvrirPriseMesure),
  /// sans passer par la liste "Quel type de tenue ?" — repli sur cette
  /// liste seulement si le sexe n'est pas renseigné ou qu'aucun gabarit par
  /// défaut n'existe pour ce sexe.
  Future<void> _ouvrirPriseMesure() async {
    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null || !mounted) return;

    if (_membre.sexe != null) {
      final types = await ref.read(typesTenueVisiblesProvider.future);
      if (!mounted) return;
      final gabarit = choisirGabaritPourSexe(types, utilisateur.atelierId, _membre.sexe!);
      if (gabarit != null) {
        await context.push(
          AppRoutes.priseMesureMembre(_membre.id, gabarit.id),
          extra: _membre.nomComplet,
        );
        if (mounted) setState(() => _chargement = _charger());
        return;
      }
    }

    await context.push(
      AppRoutes.selectionTypeTenueMembre(_membre.id),
      extra: _membre.nomComplet,
    );
    if (mounted) setState(() => _chargement = _charger());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_membre.nomComplet, overflow: TextOverflow.ellipsis),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier ou supprimer le membre',
            onPressed: _modifierMembre,
          ),
        ],
      ),
      body: FutureBuilder<List<GroupeMesureExport>>(
        future: _chargement,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final groupes = snapshot.data ?? const [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CarteInfosMembre(membre: _membre, onBasculerTenue: _basculerTenueTerminee),
              const SizedBox(height: 28),
              EnTeteSection(
                icone: Icons.straighten_outlined,
                couleurFond: const Color(0xFFF5DCD3),
                couleurIcone: const Color(0xFF8A4B24),
                titre: 'Mesures',
                onTap: _ouvrirPriseMesure,
              ),
              const SizedBox(height: 12),
              if (groupes.isEmpty)
                const _Carte(child: Text('Aucune mesure enregistrée pour ce membre.'))
              else
                for (final groupe in groupes) ...[
                  _CarteMesuresGroupe(groupe: groupe),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

/// Conteneur blanc arrondi commun à toutes les cartes de la fiche — même
/// style que _Carte de EcranFicheClient.
class _Carte extends StatelessWidget {
  const _Carte({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 4)],
      ),
      child: child,
    );
  }
}

class _LigneInfo extends StatelessWidget {
  const _LigneInfo(this.libelle, this.valeur);

  final String libelle;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: const TextStyle(color: Color(0xFF6F6259))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valeur,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteInfosMembre extends StatelessWidget {
  const _CarteInfosMembre({required this.membre, required this.onBasculerTenue});

  final MembreGroupeUniforme membre;
  final VoidCallback onBasculerTenue;

  @override
  Widget build(BuildContext context) {
    return _Carte(
      child: Column(
        children: [
          _LigneInfo('Nom et prénom', membre.nomComplet),
          _LigneInfo('Sexe', membre.sexe ?? 'Non renseigné'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tenue terminée', style: TextStyle(color: Color(0xFF6F6259))),
                Switch(
                  value: membre.tenueTerminee,
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (_) => onBasculerTenue(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dernières mesures connues pour un type de tenue, en lecture seule (nom
/// du champ à gauche, valeur à droite) — même présentation que la fiche
/// client, avec en plus le nom du type de tenue en en-tête de carte.
class _CarteMesuresGroupe extends StatelessWidget {
  const _CarteMesuresGroupe({required this.groupe});

  final GroupeMesureExport groupe;

  @override
  Widget build(BuildContext context) {
    return _Carte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupe.nomTypeTenue,
            style: const TextStyle(fontWeight: FontWeight.bold, color: _bleuSeda),
          ),
          const Divider(height: 16),
          for (final ligne in groupe.lignes) _LigneInfo(ligne.nomChamp, ligne.valeur),
        ],
      ),
    );
  }
}
