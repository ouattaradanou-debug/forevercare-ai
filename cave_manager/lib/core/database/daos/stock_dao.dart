import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/local_stock_table.dart';
import '../tables/sync_queue_table.dart';

part 'stock_dao.g.dart';

const _uuid = Uuid();

/// DAO du cache local de stock (`LocalStock`) — voir le commentaire de
/// cette table pour la stratégie de mise à jour optimiste.
@DriftAccessor(tables: [LocalStock, SyncQueue])
class StockDao extends DatabaseAccessor<AppDatabase> with _$StockDaoMixin {
  StockDao(super.db);

  Stream<LocalStockData?> observerStock(String produitId) {
    return (select(localStock)..where((t) => t.produitId.equals(produitId)))
        .watchSingleOrNull();
  }

  Future<LocalStockData?> stockActuel(String produitId) {
    return (select(localStock)..where((t) => t.produitId.equals(produitId)))
        .getSingleOrNull();
  }

  /// Amorce le cache local pour un produit dont le stock n'a jamais été
  /// consulté sur cet appareil (première ouverture de l'écran produit,
  /// avec réseau). Sans effet si déjà présent : ne jamais écraser un solde
  /// local qui contient peut-être des ajustements pas encore synchronisés.
  Future<void> initialiserSiAbsent({
    required String produitId,
    required String caveId,
    required int quantiteCartons,
    required int quantiteBouteilles,
  }) async {
    final existant = await stockActuel(produitId);
    if (existant != null) return;
    await into(localStock).insert(
      LocalStockCompanion.insert(
        produitId: produitId,
        caveId: caveId,
        quantiteCartons: Value(quantiteCartons),
        quantiteBouteilles: Value(quantiteBouteilles),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Applique un ajustement de stock : met à jour le cache local de façon
  /// optimiste ET enfile le mouvement dans la file de synchronisation —
  /// les deux dans une seule transaction Drift, pour ne jamais se
  /// retrouver avec l'un sans l'autre (ex. app fermée brutalement entre
  /// les deux écritures).
  Future<void> ajusterStock({
    required String produitId,
    required String caveId,
    required int deltaCartons,
    required int deltaBouteilles,
    required String motif,
    required String creePar,
  }) async {
    await transaction(() async {
      final existant = await stockActuel(produitId);
      final nouveauCartons =
          math.max(0, (existant?.quantiteCartons ?? 0) + deltaCartons);
      final nouveauBouteilles =
          math.max(0, (existant?.quantiteBouteilles ?? 0) + deltaBouteilles);

      await into(localStock).insertOnConflictUpdate(
        LocalStockCompanion.insert(
          produitId: produitId,
          caveId: caveId,
          quantiteCartons: Value(nouveauCartons),
          quantiteBouteilles: Value(nouveauBouteilles),
          updatedAt: DateTime.now(),
        ),
      );

      final mouvementId = _uuid.v4();
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: _uuid.v4(),
          nomTable: 'mouvements_stock',
          entiteId: mouvementId,
          operation: 'insertion',
          payload: jsonEncode({
            'id': mouvementId,
            'cave_id': caveId,
            'produit_id': produitId,
            'delta_cartons': deltaCartons,
            'delta_bouteilles': deltaBouteilles,
            'motif': motif,
            'created_by': creePar,
          }),
          creeLe: DateTime.now(),
        ),
      );
    });
  }
}
