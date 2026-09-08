import '../local/app_database.dart';
import '../models/brouillon_client.dart';

/// Brouillon de fiche client (un seul brouillon actif par utilisateur),
/// entièrement local — fonctionne sans connexion internet.
class BrouillonRepository {
  BrouillonRepository(this._db);

  final AppDatabase _db;

  Future<void> enregistrer(BrouillonClient brouillon) async {
    await _db
        .into(_db.brouillonsClient)
        .insertOnConflictUpdate(brouillon.versCompagnonLocal());
  }

  Future<BrouillonClient?> recuperer(String utilisateurId) async {
    final ligne =
        await (_db.select(_db.brouillonsClient)
              ..where((t) => t.utilisateurId.equals(utilisateurId)))
            .getSingleOrNull();
    return ligne == null ? null : BrouillonClient.depuisLigneLocale(ligne);
  }

  Future<void> supprimer(String utilisateurId) async {
    await (_db.delete(
      _db.brouillonsClient,
    )..where((t) => t.utilisateurId.equals(utilisateurId))).go();
  }

  Stream<BrouillonClient?> observer(String utilisateurId) {
    final query = _db.select(_db.brouillonsClient)
      ..where((t) => t.utilisateurId.equals(utilisateurId));
    return query.watchSingleOrNull().map(
      (ligne) => ligne == null ? null : BrouillonClient.depuisLigneLocale(ligne),
    );
  }
}
