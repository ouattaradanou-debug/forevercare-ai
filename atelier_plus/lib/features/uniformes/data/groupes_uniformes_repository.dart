import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/groupe_uniforme.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
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
    final groupe = GroupeUniforme(
      id: _uuid.v4(),
      atelierId: atelierId,
      nom: nom,
      repondantNom: repondantNom,
      repondantTelephone: repondantTelephone,
      updatedAt: DateTime.now().toUtc(),
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

  /// Supprime définitivement un groupe et tout ce qui lui est associé
  /// (membres, mesures) — réservé au propriétaire, la RLS l'impose de toute
  /// façon côté serveur. Contrairement aux autres écritures de ce
  /// repository, nécessite une connexion : il n'existe pas d'opération
  /// "delete" dans la file d'attente de synchronisation (même principe que
  /// ClientsRepository.supprimerClient), une suppression ne peut donc
  /// jamais être mise en attente hors-ligne.
  Future<void> supprimerGroupe(GroupeUniforme groupe) async {
    await verifierEcritureAutorisee(_baseLocale, groupe.atelierId);
    await _client.from('groupes_uniformes').delete().eq('id', groupe.id);
    await _baseLocale.supprimerGroupeUniformeEtDependances(groupe.id);
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
      for (final ligne in lignes) {
        await _mettreEnCache(GroupeUniforme.depuisJson(ligne));
      }
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
    );
  }
}
