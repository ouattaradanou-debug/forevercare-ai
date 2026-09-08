import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/app_database.dart';
import '../models/champ_mesure.dart';
import '../models/type_tenue.dart';

/// Gabarits (types de tenue + champs de mesure) : synchronisation depuis
/// Supabase et lecture locale (hors-ligne d'abord).
class GabaritRepository {
  GabaritRepository(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;

  /// Récupère les gabarits par défaut (`atelier_id` nul) et ceux propres à
  /// l'atelier, et les met en cache local. Appelé après connexion (voir
  /// `RecuperationCompteService`) quand une connexion internet est
  /// disponible ; les lectures suivantes se font uniquement depuis le
  /// cache local.
  Future<void> synchroniserGabarits(String atelierId) async {
    final List<Map<String, dynamic>> lignesTypes = await _client
        .from('types_tenue')
        .select()
        .or('atelier_id.is.null,atelier_id.eq.$atelierId');

    final List<TypeTenue> types = lignesTypes
        .map(TypeTenue.depuisSupabase)
        .toList();
    for (final TypeTenue t in types) {
      await _db
          .into(_db.typesTenue)
          .insertOnConflictUpdate(t.versCompagnonLocal());
    }

    if (types.isEmpty) return;

    final List<Map<String, dynamic>> lignesChamps = await _client
        .from('champs_mesure')
        .select()
        .inFilter('type_tenue_id', types.map((t) => t.id).toList());

    final List<ChampMesure> champs = lignesChamps
        .map(ChampMesure.depuisSupabase)
        .toList();
    for (final ChampMesure c in champs) {
      await _db
          .into(_db.champsMesure)
          .insertOnConflictUpdate(c.versCompagnonLocal());
    }
  }

  Stream<List<TypeTenue>> observerTypesTenue({
    required String sexe,
    required String atelierId,
  }) {
    final query = _db.select(_db.typesTenue)
      ..where(
        (t) =>
            t.sexe.equals(sexe) &
            (t.atelierId.isNull() | t.atelierId.equals(atelierId)),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.nom)]);
    return query.watch().map(
      (lignes) => lignes.map(TypeTenue.depuisLigneLocale).toList(),
    );
  }

  Stream<List<ChampMesure>> observerChampsActifs(String typeTenueId) {
    final query = _db.select(_db.champsMesure)
      ..where(
        (c) => c.typeTenueId.equals(typeTenueId) & c.statut.equals('actif'),
      )
      ..orderBy([(c) => OrderingTerm.asc(c.ordre)]);
    return query.watch().map(
      (lignes) => lignes.map(ChampMesure.depuisLigneLocale).toList(),
    );
  }
}
