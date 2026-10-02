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

  Future<GroupeUniforme> creerGroupe({required String atelierId, required String nom}) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final groupe = GroupeUniforme(
      id: _uuid.v4(),
      atelierId: atelierId,
      nom: nom,
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

  Stream<List<GroupeUniforme>> observerGroupes(String atelierId) {
    return _baseLocale.observerGroupesUniformes(atelierId).map(
          (lignes) => lignes
              .map(
                (l) => GroupeUniforme(
                  id: l.id,
                  atelierId: l.atelierId,
                  nom: l.nom,
                  updatedAt: l.updatedAt,
                ),
              )
              .toList(),
        );
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

  Future<void> _mettreEnCache(GroupeUniforme groupe) {
    return _baseLocale.enregistrerGroupeUniforme(
      id: groupe.id,
      atelierId: groupe.atelierId,
      nom: groupe.nom,
      updatedAt: groupe.updatedAt,
    );
  }
}
