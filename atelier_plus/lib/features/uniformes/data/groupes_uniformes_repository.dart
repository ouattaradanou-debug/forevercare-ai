import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/local/database.dart';
import '../../../data/models/groupe_uniforme.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../../data/sync/lecture_tolerante.dart';
import '../../abonnement/data/abonnement_guard.dart';

/// Gestion des groupes de mesures d'uniformes (promotion, établissement,
/// équipe), séparés des fiches clients individuelles.
class GroupesUniformesRepository {
  GroupesUniformesRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  Future<GroupeUniforme> creerGroupe({
    required String atelierId,
    required String nom,
    String? repondantNom,
    String? repondantTelephone,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final maintenant = DateTime.now().toUtc();
    final groupe = GroupeUniforme(
      id: _uuid.v4(),
      atelierId: atelierId,
      nom: nom,
      repondantNom: repondantNom,
      repondantTelephone: repondantTelephone,
      updatedAt: maintenant,
      createdAt: maintenant,
    );

    await _mettreEnCache(groupe);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'groupes_uniformes',
      recordId: groupe.id,
      operation: 'insert',
      payload: groupe.versJson(),
    );
    return groupe;
  }

  /// Corrige le nom du groupe et/ou les coordonnées du répondant (erreur de
  /// saisie à la création, ou changement de répondant).
  Future<GroupeUniforme> modifierGroupe({
    required GroupeUniforme groupe,
    required String nom,
    String? repondantNom,
    String? repondantTelephone,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, groupe.atelierId);
    // Même précaution que les autres repositories "modifier" : purge
    // d'abord toute tâche de synchronisation périmée pour ce groupe.
    await _baseLocale.retirerTachesPourEnregistrement('groupes_uniformes', groupe.id);
    final miseAJour = GroupeUniforme(
      id: groupe.id,
      atelierId: groupe.atelierId,
      nom: nom,
      repondantNom: repondantNom,
      repondantTelephone: repondantTelephone,
      updatedAt: DateTime.now().toUtc(),
      createdAt: groupe.createdAt,
      supprimeLe: groupe.supprimeLe,
    );

    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'groupes_uniformes',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    return miseAJour;
  }

  /// Vrai si ce groupe a été créé il y a moins de deux semaines — voir
  /// ClientsRepository._recent, même principe et même seuil
  /// (AppConstants.dureeConservationFinances). Ancienneté inconnue (cache
  /// local pas encore rafraîchi depuis la dernière mise à jour de
  /// l'application) : jamais considérée comme récente, pour ne jamais
  /// supprimer par erreur des finances déjà comptabilisées.
  bool _recent(DateTime? createdAt) =>
      createdAt != null &&
      DateTime.now().toUtc().difference(createdAt) < AppConstants.dureeConservationFinances;

  /// Supprime un groupe — réservé au propriétaire, la RLS l'impose de toute
  /// façon côté serveur (`groupes_uniformes_update`/`_delete` exigent
  /// `est_proprietaire()` pour tout le monde, apprenti compris).
  ///
  /// Un groupe créé depuis moins de deux semaines est réellement supprimé,
  /// avec tout ce qui lui est associé (membres, mesures, photos,
  /// rendez-vous, commande, paiements) : probable erreur de saisie récente.
  /// Au-delà de ce délai, le groupe est seulement masqué (il disparaît de
  /// l'application) mais sa commande et ses paiements sont conservés
  /// intacts, pour que les récapitulatifs financiers de l'atelier ne
  /// reculent jamais après coup (voir
  /// AppConstants.dureeConservationFinances).
  ///
  /// Dans les deux cas, suppression locale d'abord — même principe que
  /// ClientsRepository.supprimerClient : la fiche disparaît immédiatement
  /// de l'écran, sans attendre une réponse serveur ni même une connexion.
  Future<void> supprimerGroupe(GroupeUniforme groupe) async {
    await verifierEcritureAutorisee(_baseLocale, groupe.atelierId);

    if (_recent(groupe.createdAt)) {
      await _baseLocale.supprimerGroupeUniformeEtDependances(groupe.id);
      unawaited(
        ecrireEtSynchroniser(
          client: _client,
          baseLocale: _baseLocale,
          table: 'groupes_uniformes',
          recordId: groupe.id,
          operation: 'delete',
          payload: const {},
        ),
      );
      return;
    }

    final quand = DateTime.now().toUtc();
    await _baseLocale.masquerGroupeConserverFinances(groupe.id, quand);
    unawaited(
      ecrireEtSynchroniser(
        client: _client,
        baseLocale: _baseLocale,
        table: 'groupes_uniformes',
        recordId: groupe.id,
        operation: 'update',
        payload: {'supprime_le': quand.toIso8601String(), 'updated_at': quand.toIso8601String()},
      ),
    );
  }

  Stream<List<GroupeUniforme>> observerGroupes(String atelierId) {
    return _baseLocale.observerGroupesUniformes(atelierId).map(
          (lignes) => lignes.map(_depuisLigne).toList(),
        );
  }

  Future<GroupeUniforme?> groupeParId(String id) async {
    final ligne = await _baseLocale.groupeUniformeParId(id);
    return ligne == null ? null : _depuisLigne(ligne);
  }

  Future<void> chargerDepuisServeur(String atelierId) async {
    try {
      final lignes =
          await _client.from('groupes_uniformes').select().eq('atelier_id', atelierId);
      // Un groupe supprimé localement hors-ligne (créé il y a moins de deux
      // semaines, donc réellement retiré) reste sur le serveur jusqu'à ce
      // que cette suppression en file d'attente soit rejouée : ne pas le
      // remettre en cache ici, sous peine de le faire réapparaître — même
      // principe que ClientsRepository.chargerDepuisServeur.
      final idsSupprimes = await _baseLocale.idsEnAttenteDeSuppression('groupes_uniformes');
      await pourChaqueLigne(lignes, (ligne) async {
        final groupe = GroupeUniforme.depuisJson(ligne);
        if (idsSupprimes.contains(groupe.id)) return;
        await _mettreEnCache(groupe);
      });
    } catch (_) {
      // Hors-ligne : le cache local existant reste utilisable.
    }
  }

  GroupeUniforme _depuisLigne(GroupeUniformeEntry l) {
    return GroupeUniforme(
      id: l.id,
      atelierId: l.atelierId,
      nom: l.nom,
      repondantNom: l.repondantNom,
      repondantTelephone: l.repondantTelephone,
      updatedAt: l.updatedAt,
      createdAt: l.createdAt,
      supprimeLe: l.supprimeLe,
    );
  }

  Future<void> _mettreEnCache(GroupeUniforme groupe) {
    return _baseLocale.enregistrerGroupeUniforme(
      id: groupe.id,
      atelierId: groupe.atelierId,
      nom: groupe.nom,
      repondantNom: groupe.repondantNom,
      repondantTelephone: groupe.repondantTelephone,
      updatedAt: groupe.updatedAt,
      createdAt: groupe.createdAt,
      supprimeLe: groupe.supprimeLe,
    );
  }
}
