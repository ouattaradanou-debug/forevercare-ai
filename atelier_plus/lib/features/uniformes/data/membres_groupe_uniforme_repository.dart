import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/membre_groupe_uniforme.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';

/// Gestion des membres d'un groupe d'uniformes (les personnes dont on
/// prend les mesures dans le cadre d'une commande groupée).
class MembresGroupeUniformeRepository {
  MembresGroupeUniformeRepository({
    required SupabaseClient client,
    required AppDatabase baseLocale,
  })  : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  Future<MembreGroupeUniforme> ajouterMembre({
    required String atelierId,
    required String groupeId,
    String? nom,
    String? prenom,
    String? sexe,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final membre = MembreGroupeUniforme(
      id: _uuid.v4(),
      groupeId: groupeId,
      nom: nom,
      prenom: prenom,
      sexe: sexe,
      tenueTerminee: false,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCache(membre);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'membres_groupe_uniforme',
      recordId: membre.id,
      operation: 'insert',
      payload: membre.versJson(),
    );
    return membre;
  }

  Future<MembreGroupeUniforme> basculerTenueTerminee({
    required String atelierId,
    required MembreGroupeUniforme membre,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final miseAJour = membre.copierAvec(tenueTerminee: !membre.tenueTerminee);
    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'membres_groupe_uniforme',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    return miseAJour;
  }

  /// Corrige le nom et/ou le sexe d'un membre (erreur de saisie, ou
  /// changement) — même principe que GroupesUniformesRepository.modifierGroupe.
  Future<MembreGroupeUniforme> modifierMembre({
    required String atelierId,
    required MembreGroupeUniforme membre,
    required String nom,
    String? sexe,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    // Purge d'abord toute tâche de synchronisation périmée pour ce membre.
    await _baseLocale.retirerTachesPourEnregistrement('membres_groupe_uniforme', membre.id);
    final miseAJour = MembreGroupeUniforme(
      id: membre.id,
      groupeId: membre.groupeId,
      nom: nom,
      prenom: null,
      sexe: sexe,
      tenueTerminee: membre.tenueTerminee,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'membres_groupe_uniforme',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    return miseAJour;
  }

  /// Supprime définitivement un membre et ses mesures — nécessite une
  /// connexion, comme GroupesUniformesRepository.supprimerGroupe : il
  /// n'existe pas d'opération "delete" dans la file d'attente de
  /// synchronisation.
  Future<void> supprimerMembre({
    required String atelierId,
    required MembreGroupeUniforme membre,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    await _client.from('membres_groupe_uniforme').delete().eq('id', membre.id);
    await _baseLocale.supprimerMembreGroupeUniformeEtDependances(membre.id);
  }

  Stream<List<MembreGroupeUniforme>> observerMembres(String groupeId) {
    return _baseLocale.observerMembresDuGroupe(groupeId).map(
          (lignes) => lignes
              .map(
                (l) => MembreGroupeUniforme(
                  id: l.id,
                  groupeId: l.groupeId,
                  nom: l.nom,
                  prenom: l.prenom,
                  sexe: l.sexe,
                  tenueTerminee: l.tenueTerminee,
                  updatedAt: l.updatedAt,
                ),
              )
              .toList(),
        );
  }

  Future<void> chargerDepuisServeur(String groupeId) async {
    try {
      final lignes =
          await _client.from('membres_groupe_uniforme').select().eq('groupe_id', groupeId);
      for (final ligne in lignes) {
        await _mettreEnCache(MembreGroupeUniforme.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : le cache local existant reste utilisable.
    }
  }

  Future<void> _mettreEnCache(MembreGroupeUniforme membre) {
    return _baseLocale.enregistrerMembreGroupeUniforme(
      id: membre.id,
      groupeId: membre.groupeId,
      nom: membre.nom,
      prenom: membre.prenom,
      sexe: membre.sexe,
      tenueTerminee: membre.tenueTerminee,
      updatedAt: membre.updatedAt,
    );
  }
}
