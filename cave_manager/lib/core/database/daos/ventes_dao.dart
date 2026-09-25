import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'ventes_dao.g.dart';

const _uuid = Uuid();

/// Une ligne du panier au moment de la vente (pas une table Drift : un
/// simple objet passé à [VentesDao.creerCommande]). `sousTotal` est
/// recalculé ici (pas seulement affiché) pour correspondre exactement à
/// la contrainte `check` de `commande_lignes` côté serveur.
class LigneAVendre {
  const LigneAVendre({
    required this.produitId,
    required this.quantiteCartons,
    required this.quantiteBouteilles,
    required this.prixGrosUnitaire,
    required this.prixDetailUnitaire,
  });

  final String produitId;
  final int quantiteCartons;
  final int quantiteBouteilles;
  final int prixGrosUnitaire;
  final int prixDetailUnitaire;

  int get sousTotal =>
      quantiteCartons * prixGrosUnitaire +
      quantiteBouteilles * prixDetailUnitaire;
}

/// DAO de création d'une commande — seule partie de la Phase 3 où
/// l'offline-first est un besoin explicite du cahier des charges ("toute
/// prise de commande"). Enfile la commande puis chacune de ses lignes dans
/// la file de synchronisation générique, dans une seule transaction Drift
/// locale (même principe que `StockDao.ajusterStock`).
///
/// L'ordre d'enfilement (commande d'abord, lignes ensuite) importe : la
/// commande doit exister côté serveur avant ses lignes (clé étrangère).
/// `SyncEngine.traiterFile` traite les entrées dans l'ordre de `creeLe`
/// et jamais en parallèle, donc cet ordre est respecté en pratique ; dans
/// le cas limite où une ligne serait tout de même synchronisée avant sa
/// commande (horloge locale peu précise), elle échoue simplement et sera
/// retentée au cycle de synchronisation suivant — aucune donnée perdue.
@DriftAccessor(tables: [SyncQueue])
class VentesDao extends DatabaseAccessor<AppDatabase> with _$VentesDaoMixin {
  VentesDao(super.db);

  Future<void> creerCommande({
    required String caveId,
    String? clientId,
    required String creePar,
    required List<LigneAVendre> lignes,
  }) async {
    await transaction(() async {
      final commandeId = _uuid.v4();
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: _uuid.v4(),
          nomTable: 'commandes',
          entiteId: commandeId,
          operation: 'insertion',
          payload: jsonEncode({
            'id': commandeId,
            'cave_id': caveId,
            if (clientId != null) 'client_id': clientId,
            'created_by': creePar,
          }),
          creeLe: DateTime.now(),
        ),
      );

      for (final ligne in lignes) {
        final ligneId = _uuid.v4();
        await into(syncQueue).insert(
          SyncQueueCompanion.insert(
            id: _uuid.v4(),
            nomTable: 'commande_lignes',
            entiteId: ligneId,
            operation: 'insertion',
            payload: jsonEncode({
              'id': ligneId,
              'commande_id': commandeId,
              'produit_id': ligne.produitId,
              'quantite_cartons': ligne.quantiteCartons,
              'quantite_bouteilles': ligne.quantiteBouteilles,
              'prix_gros_unitaire': ligne.prixGrosUnitaire,
              'prix_detail_unitaire': ligne.prixDetailUnitaire,
              'sous_total': ligne.sousTotal,
            }),
            creeLe: DateTime.now(),
          ),
        );
      }
    });
  }

  /// Corrige la quantité d'une ligne déjà enregistrée (demande explicite :
  /// le client renonce à une partie de son achat avant que la vente soit
  /// finalisée). Protégé côté serveur par `commande_lignes_update` :
  /// uniquement possible tant que la commande est encore 'en_attente'.
  Future<void> modifierLigne({
    required String ligneId,
    required String commandeId,
    required String produitId,
    required int quantiteCartons,
    required int quantiteBouteilles,
    required int prixGrosUnitaire,
    required int prixDetailUnitaire,
  }) {
    final sousTotal = quantiteCartons * prixGrosUnitaire +
        quantiteBouteilles * prixDetailUnitaire;
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        id: _uuid.v4(),
        nomTable: 'commande_lignes',
        entiteId: ligneId,
        operation: 'modification',
        payload: jsonEncode({
          'id': ligneId,
          'commande_id': commandeId,
          'produit_id': produitId,
          'quantite_cartons': quantiteCartons,
          'quantite_bouteilles': quantiteBouteilles,
          'prix_gros_unitaire': prixGrosUnitaire,
          'prix_detail_unitaire': prixDetailUnitaire,
          'sous_total': sousTotal,
        }),
        creeLe: DateTime.now(),
      ),
    );
  }

  /// Retire un produit dont le client a renoncé. Même protection que
  /// [modifierLigne] (commande encore 'en_attente' uniquement).
  Future<void> supprimerLigne(String ligneId) {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        id: _uuid.v4(),
        nomTable: 'commande_lignes',
        entiteId: ligneId,
        operation: 'suppression',
        payload: jsonEncode({'id': ligneId}),
        creeLe: DateTime.now(),
      ),
    );
  }
}
