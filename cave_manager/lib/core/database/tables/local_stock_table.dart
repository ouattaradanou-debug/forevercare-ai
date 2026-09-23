import 'package:drift/drift.dart';

/// Cache local (Drift) des quantités de stock.
///
/// Contrairement à `LocalCaves`/`LocalProfiles` (répliques passives),
/// cette table est mise à jour de façon **optimiste** : dès qu'un ajustement
/// de stock est enregistré (voir `StockDao.ajusterStock`), le delta est
/// appliqué ici immédiatement, avant même la synchronisation — c'est ce qui
/// permet de consulter et de modifier le stock hors ligne. La valeur
/// distincte (`stock`, côté Supabase) reste la source de vérité définitive :
/// deux appareils qui ajustent le même produit hors ligne verront chacun
/// leur propre delta appliqué localement, puis les deux deltas s'additionner
/// côté serveur au retour de connexion (voir migration 0007) — pas de
/// Last-Write-Wins.
class LocalStock extends Table {
  TextColumn get produitId => text()();
  TextColumn get caveId => text()();
  IntColumn get quantiteCartons => integer().withDefault(const Constant(0))();
  IntColumn get quantiteBouteilles =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {produitId};
}
