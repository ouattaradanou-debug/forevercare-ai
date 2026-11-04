import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:uuid/uuid.dart';

/// Cantine (module 10.9) : réglages, bénéficiaires, pointage des repas,
/// stock de vivres, menus. Tout fonctionne hors ligne ; les mouvements de
/// stock ne sont jamais modifiés ni supprimés.
class CantineRepository {
  new(this.store);

  final LocalStore store;
  AppDatabase get db => store.db;
  static const _uuid = Uuid();

  static String _v5(String nom) => _uuid.v5(Namespace.url.value, nom);

  // ------------------------------ Réglages ------------------------------

  static String idReglages(String schoolId) =>
      _v5('ecoleplus:cantine:$schoolId');

  Stream<CanteenSettingsRow?> watchReglages(String schoolId) => (db.select(
    db.canteenSettings,
  )..where((c) => c.schoolId.equals(schoolId))).watchSingleOrNull();

  /// Mode de fonctionnement et définition locale ; avec participation des
  /// familles, la rubrique « Cantine » est ajoutée à la grille des frais.
  Future<void> enregistrerReglages({
    required String schoolId,
    required String mode,
    String? definition,
  }) async {
    if (!modesCantine.containsKey(mode)) {
      throw const UserMessage('Mode de fonctionnement inconnu.');
    }
    await db.transaction(() async {
      await store.save('canteen_settings', {
        'id': idReglages(schoolId),
        'school_id': schoolId,
        'mode': mode,
        'local_definition': (definition ?? '').trim().isEmpty
            ? null
            : definition!.trim(),
        'deleted_at': null,
      });
      if (mode != 'sans_participation') await _assurerRubrique(schoolId);
    });
  }

  /// Rubrique « Cantine » des Finances (même identifiant sur tous les
  /// téléphones ; reprise si elle avait été retirée).
  Future<void> _assurerRubrique(String schoolId) async {
    final id = _v5('ecoleplus:rubrique:$schoolId:$rubriqueCantine');
    final r = await (db.select(
      db.feeRubrics,
    )..where((x) => x.id.equals(id))).getSingleOrNull();
    if (r != null && r.deletedAt == null) return;
    final ordre = await (db.select(
      db.feeRubrics,
    )..where((x) => x.schoolId.equals(schoolId))).get();
    await store.save('fee_rubrics', {
      'id': id,
      'school_id': schoolId,
      'code': rubriqueCantine,
      'label': r?.label ?? 'Cantine',
      'sort_order':
          r?.sortOrder ??
          ordre.fold<int>(0, (m, x) => x.sortOrder > m ? x.sortOrder : m) + 10,
      'deleted_at': null,
    });
  }

  // ---------------------------- Bénéficiaires ---------------------------

  static String idBeneficiaire(String studentId, String yearId) =>
      _v5('ecoleplus:beneficiaire:$studentId:$yearId');

  Stream<List<CanteenBeneficiaryRow>> watchBeneficiaires(String yearId) =>
      (db.select(
            db.canteenBeneficiaries,
          )..where((b) => b.schoolYearId.equals(yearId) & b.deletedAt.isNull()))
          .watch();

  /// Marque (ou retire) un élève bénéficiaire pour l'année ; en mode
  /// mixte, [participe] indique si sa famille paie. Le retrait garde
  /// l'historique (la ligne reste, « non bénéficiaire »).
  Future<void> definirBeneficiaire({
    required String schoolId,
    required String yearId,
    required String studentId,
    required bool beneficiaire,
    bool? participe,
  }) async {
    final id = idBeneficiaire(studentId, yearId);
    final avant = await (db.select(
      db.canteenBeneficiaries,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    await store.save('canteen_beneficiaries', {
      'id': id,
      'school_id': schoolId,
      'school_year_id': yearId,
      'student_id': studentId,
      'is_beneficiary': beneficiaire,
      'contributes': ?participe,
      if (avant?.since == null && beneficiaire)
        'since': store.clock.nowIso().substring(0, 10),
      'deleted_at': null,
    });
  }

  // ------------------------------ Pointage ------------------------------

  static String idPointage(String schoolId, String jour, String? classId) =>
      _v5('ecoleplus:repas:$schoolId:$jour:${classId ?? '-'}');

  Stream<List<MealServiceRow>> watchPointages(String schoolId) =>
      (db.select(db.mealServices)
            ..where((m) => m.schoolId.equals(schoolId) & m.deletedAt.isNull())
            ..orderBy([(m) => OrderingTerm.asc(m.day)]))
          .watch();

  /// Nombre de repas servis un jour pour une classe ([classId] null :
  /// autres repas, personnel…). Saisi deux fois (deux téléphones) : la
  /// dernière saisie remplace la première, jamais d'addition.
  Future<void> pointer({
    required String schoolId,
    required String jour,
    required String? classId,
    required int repas,
  }) async {
    if (repas < 0) {
      throw const UserMessage('Le nombre de repas ne peut pas être négatif.');
    }
    if (repas > 5000) {
      throw const UserMessage(
        'Nombre de repas trop grand : vérifiez la saisie.',
      );
    }
    await store.save('meal_services', {
      'id': idPointage(schoolId, jour, classId),
      'school_id': schoolId,
      'day': jour,
      'class_id': classId,
      'meals_count': repas,
      'deleted_at': null,
    });
  }

  // ------------------------------ Produits ------------------------------

  Stream<List<StockProductRow>> watchProduits(String schoolId) =>
      (db.select(db.stockProducts)
            ..where((p) => p.schoolId.equals(schoolId) & p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .watch();

  static String _cle(String nom) =>
      sansAccentsRubrique(nom.trim().toLowerCase())
          .replaceAll(RegExp(r'\s+'), ' ');

  /// Nouveau produit (liste libre) ; même nom sur deux téléphones hors
  /// ligne = même produit.
  Future<String> ajouterProduit({
    required String schoolId,
    required String nom,
    required String unite,
    double? seuil,
  }) async {
    final n = nom.trim();
    final u = unite.trim();
    if (n.isEmpty) throw const UserMessage('Indiquez le nom du produit.');
    if (u.isEmpty) throw const UserMessage('Indiquez l’unité (kg, sac…).');
    if (seuil != null && seuil < 0) {
      throw const UserMessage('Le seuil d’alerte ne peut pas être négatif.');
    }
    final actifs = await (db.select(
      db.stockProducts,
    )..where((p) => p.schoolId.equals(schoolId) & p.deletedAt.isNull())).get();
    if (actifs.any((p) => _cle(p.name) == _cle(n))) {
      throw UserMessage('Le produit « $n » existe déjà.');
    }
    final id = _v5('ecoleplus:produit:$schoolId:${_cle(n)}');
    await store.save('stock_products', {
      'id': id,
      'school_id': schoolId,
      'name': n,
      'unit': u,
      'alert_threshold': seuil,
      'deleted_at': null,
    });
    return id;
  }

  Future<void> modifierProduit(
    StockProductRow p, {
    required String nom,
    required String unite,
    double? seuil,
  }) async {
    final n = nom.trim();
    if (n.isEmpty || unite.trim().isEmpty) {
      throw const UserMessage('Indiquez le nom et l’unité du produit.');
    }
    final autres =
        await (db.select(db.stockProducts)..where(
              (x) =>
                  x.schoolId.equals(p.schoolId) &
                  x.deletedAt.isNull() &
                  x.id.equals(p.id).not(),
            ))
            .get();
    if (autres.any((x) => _cle(x.name) == _cle(n))) {
      throw UserMessage('Le produit « $n » existe déjà.');
    }
    await store.save('stock_products', {
      'id': p.id,
      'name': n,
      'unit': unite.trim(),
      'alert_threshold': seuil,
    });
  }

  /// Retire un produit de la liste (seulement quand son stock est nul ; ses
  /// mouvements restent dans l'historique).
  Future<void> retirerProduit(StockProductRow p) async {
    final stock = stockCourant(await _mouvementsDe(p.id), p.id);
    if (stock != 0) {
      throw UserMessage(
        'Il reste ${qte(stock)} ${p.unit} de « ${p.name} » : faites d’abord '
        'une sortie ou un inventaire.',
      );
    }
    await store.save('stock_products', {
      'id': p.id,
      'deleted_at': store.clock.nowIso(),
    });
  }

  // ----------------------------- Mouvements -----------------------------

  Stream<List<StockMovementRow>> watchMouvements(String schoolId) =>
      (db.select(db.stockMovements)
            ..where((m) => m.schoolId.equals(schoolId))
            ..orderBy([
              (m) => OrderingTerm.desc(m.occurredOn),
              (m) => OrderingTerm.desc(m.createdAt),
            ]))
          .watch();

  Future<List<StockMovementRow>> _mouvementsDe(String produitId) => (db.select(
    db.stockMovements,
  )..where((m) => m.productId.equals(produitId))).get();

  Future<StockProductRow> _produit(String id) =>
      (db.select(db.stockProducts)..where((p) => p.id.equals(id))).getSingle();

  /// Entrée de vivres, avec sa provenance.
  Future<StockMovementRow> entree({
    required String produitId,
    required double quantite,
    required String provenance,
    required String date,
    String? notes,
  }) async {
    if (quantite <= 0) {
      throw const UserMessage('La quantité doit être supérieure à zéro.');
    }
    if (!provenances.containsKey(provenance)) {
      throw const UserMessage('Indiquez la provenance.');
    }
    final p = await _produit(produitId);
    return await _ecrire(p, {
      'kind': 'entree',
      'quantity_delta': arrondiQte(quantite),
      'provenance': provenance,
      'occurred_on': date,
      'notes': _propre(notes),
    });
  }

  /// Sortie de vivres : refusée au-delà du stock restant.
  Future<StockMovementRow> sortie({
    required String produitId,
    required double quantite,
    required String motif,
    required String date,
    String? notes,
  }) async {
    if (!motifsSortie.containsKey(motif)) {
      throw const UserMessage('Indiquez le motif de la sortie.');
    }
    final p = await _produit(produitId);
    return await db.transaction(() async {
      final stock = stockCourant(await _mouvementsDe(p.id), p.id);
      final refus = controleSortie(
        stock: stock,
        quantite: quantite,
        unite: p.unit,
      );
      if (refus != null) throw UserMessage(refus);
      return await _ecrire(p, {
        'kind': 'sortie',
        'quantity_delta': -arrondiQte(quantite),
        'out_reason': motif,
        'occurred_on': date,
        'notes': _propre(notes),
      });
    });
  }

  /// Inventaire : la quantité comptée devient le stock ; l'écart est
  /// enregistré comme ajustement motivé. Renvoie null s'il n'y a aucun
  /// écart.
  Future<StockMovementRow?> inventaire({
    required String produitId,
    required double compte,
    required String motif,
    required String date,
  }) async {
    if (compte < 0) {
      throw const UserMessage('La quantité comptée ne peut pas être négative.');
    }
    final p = await _produit(produitId);
    return await db.transaction(() async {
      final stock = stockCourant(await _mouvementsDe(p.id), p.id);
      final ecart = arrondiQte(compte - stock);
      if (ecart == 0) return null;
      if (motif.trim().isEmpty) {
        throw UserMessage(
          'Écart de ${qte(ecart)} ${p.unit} : indiquez le motif (perte, '
          'erreur de saisie…).',
        );
      }
      return await _ecrire(p, {
        'kind': 'ajustement',
        'quantity_delta': ecart,
        'occurred_on': date,
        'reason': motif.trim(),
      });
    });
  }

  /// Annule un mouvement par le mouvement inverse motivé (jamais de
  /// suppression). Refusée si le stock deviendrait négatif.
  Future<StockMovementRow> annuler(StockMovementRow m, String motif) async {
    if (motif.trim().isEmpty) {
      throw const UserMessage('Indiquez le motif de l’annulation.');
    }
    if (m.kind == 'annulation') {
      throw const UserMessage(
        'Une annulation ne peut pas être annulée : saisissez un nouveau '
        'mouvement.',
      );
    }
    final p = await _produit(m.productId);
    return await db.transaction(() async {
      final tous = await _mouvementsDe(p.id);
      if (tous.any((x) => x.reversesMovementId == m.id)) {
        throw const UserMessage('Ce mouvement est déjà annulé.');
      }
      final apres = arrondiQte(stockCourant(tous, p.id) - m.quantityDelta);
      if (apres < 0) {
        throw UserMessage(
          'Annulation impossible : le stock deviendrait négatif '
          '(${qte(apres)} ${p.unit}). Une partie a déjà été sortie.',
        );
      }
      return await _ecrire(p, {
        'kind': 'annulation',
        'quantity_delta': -m.quantityDelta,
        'occurred_on': store.clock.nowIso().substring(0, 10),
        'reverses_movement_id': m.id,
        'reason': motif.trim(),
      });
    });
  }

  static String? _propre(String? t) =>
      (t ?? '').trim().isEmpty ? null : t!.trim();

  Future<StockMovementRow> _ecrire(
    StockProductRow p,
    Map<String, Object?> champs,
  ) async {
    final s = await db.select(db.localSession).getSingleOrNull();
    if (s == null) throw const UserMessage('Session introuvable.');
    final id = _uuid.v4();
    await db.transaction(() async {
      final pris =
          await (db.select(db.stockMovements)
                ..where((x) => x.deviceId.equals(s.deviceId)))
              .map((x) => x.deviceSeq)
              .get();
      await store.save('stock_movements', {
        'id': id,
        'school_id': p.schoolId,
        'product_id': p.id,
        ...champs,
        'device_id': s.deviceId,
        'device_seq': prochainNumero(pris),
        'created_by': s.userId,
        'created_at': store.clock.nowIso(),
      });
    });
    return await (db.select(
      db.stockMovements,
    )..where((x) => x.id.equals(id))).getSingle();
  }

  // ------------------------------- Menus --------------------------------

  Stream<List<CanteenMenuRow>> watchMenus(String schoolId) =>
      (db.select(db.canteenMenus)
            ..where((m) => m.schoolId.equals(schoolId) & m.deletedAt.isNull())
            ..orderBy([(m) => OrderingTerm.desc(m.weekStart)]))
          .watch();

  /// Menu de la semaine (texte libre, modifiable).
  Future<void> enregistrerMenu({
    required String schoolId,
    required String jour,
    required String texte,
  }) async {
    final semaine = lundi(jour);
    await store.save('canteen_menus', {
      'id': _v5('ecoleplus:menu:$schoolId:$semaine'),
      'school_id': schoolId,
      'week_start': semaine,
      'content': texte.trim(),
      'deleted_at': null,
    });
  }
}
