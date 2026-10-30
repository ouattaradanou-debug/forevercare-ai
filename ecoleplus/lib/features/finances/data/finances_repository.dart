import 'dart:io';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Finances (module 10) : grille, encaissements numérotés hors ligne,
/// annulations motivées, dépenses avec justificatif, clôtures. Les
/// encaissements et dépenses ne sont jamais modifiés ni supprimés.
class FinancesRepository {
  new(this.store, {required this.remote, required this.mediaDir});

  final LocalStore store;
  final SyncRemote remote;
  final Directory? mediaDir;
  AppDatabase get db => store.db;

  static const compartiment = 'finances';
  static const _uuid = Uuid();

  // ------------------------------ Lecture -------------------------------

  Stream<List<FeeItemRow>> watchGrille(String yearId) =>
      (db.select(db.feeItems)
            ..where((f) => f.schoolYearId.equals(yearId) & f.deletedAt.isNull())
            ..orderBy([
              (f) => OrderingTerm.asc(f.rubric),
              (f) => OrderingTerm.asc(f.label),
            ]))
          .watch();

  Stream<List<FeeInstallmentRow>> watchTranches() =>
      (db.select(db.feeInstallments)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.dueOn)]))
          .watch();

  Stream<List<DiscountRow>> watchRemises() =>
      (db.select(db.discounts)
            ..where((d) => d.deletedAt.isNull())
            ..orderBy([(d) => OrderingTerm.asc(d.label)]))
          .watch();

  /// Remises attribuées (avec la remise) pour l'année.
  Stream<List<(DiscountRow, StudentDiscountRow)>> watchAttributions(
    String yearId,
  ) {
    final q =
        db.select(db.studentDiscounts).join([
          innerJoin(
            db.discounts,
            db.discounts.id.equalsExp(db.studentDiscounts.discountId),
          ),
        ])..where(
          db.studentDiscounts.schoolYearId.equals(yearId) &
              db.studentDiscounts.deletedAt.isNull() &
              db.discounts.deletedAt.isNull(),
        );
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (r.readTable(db.discounts), r.readTable(db.studentDiscounts)),
      ],
    );
  }

  Stream<List<PaymentRow>> watchPaiements(String yearId) =>
      (db.select(db.payments)
            ..where((x) => x.schoolYearId.equals(yearId))
            ..orderBy([
              (x) => OrderingTerm.desc(x.paidAt),
              (x) => OrderingTerm.desc(x.receiptNumber),
            ]))
          .watch();

  Stream<PaymentRow?> watchPaiement(String id) => (db.select(
    db.payments,
  )..where((x) => x.id.equals(id))).watchSingleOrNull();

  Stream<List<ExpenseRow>> watchDepenses(String yearId) =>
      (db.select(db.expenses)
            ..where((x) => x.schoolYearId.equals(yearId))
            ..orderBy([(x) => OrderingTerm.desc(x.spentOn)]))
          .watch();

  Stream<List<CashClosingRow>> watchClotures(String schoolId) =>
      (db.select(db.cashClosings)
            ..where((c) => c.schoolId.equals(schoolId))
            ..orderBy([(c) => OrderingTerm.desc(c.periodMonth)]))
          .watch();

  // ---------------------------- Paramétrage -----------------------------

  Future<String> enregistrerLigne(Map<String, Object?> champs) async {
    final id = (champs['id'] as String?) ?? _uuid.v4();
    await store.save('fee_items', {...champs, 'id': id});
    return id;
  }

  Future<void> retirerLigne(String id) =>
      store.save('fee_items', {'id': id, 'deleted_at': store.clock.nowIso()});

  Future<void> enregistrerTranche(Map<String, Object?> champs) => store.save(
    'fee_installments',
    {...champs, 'id': (champs['id'] as String?) ?? _uuid.v4()},
  );

  Future<void> retirerTranche(String id) => store.save('fee_installments', {
    'id': id,
    'deleted_at': store.clock.nowIso(),
  });

  Future<void> enregistrerRemise(Map<String, Object?> champs) => store.save(
    'discounts',
    {...champs, 'id': (champs['id'] as String?) ?? _uuid.v4()},
  );

  Future<void> retirerRemise(String id) =>
      store.save('discounts', {'id': id, 'deleted_at': store.clock.nowIso()});

  /// Une remise donnée à un élève pour l'année (une seule fois).
  Future<void> attribuerRemise({
    required String schoolId,
    required String yearId,
    required String studentId,
    required String discountId,
  }) => store.save('student_discounts', {
    'id': _uuid.v5(
      Namespace.url.value,
      'ecoleplus:remise:$studentId:$discountId:$yearId',
    ),
    'school_id': schoolId,
    'school_year_id': yearId,
    'student_id': studentId,
    'discount_id': discountId,
    'deleted_at': null,
  });

  Future<void> retirerAttribution(String id) => store.save(
    'student_discounts',
    {'id': id, 'deleted_at': store.clock.nowIso()},
  );

  // ---------------------------- Encaissement ----------------------------

  Future<LocalSessionRow> _session() async {
    final s = await db.select(db.localSession).getSingleOrNull();
    if (s == null) throw const UserMessage('Session introuvable.');
    if (s.deviceSeries == null || s.deviceSeries!.isEmpty) {
      throw const UserMessage(
        'Ce téléphone n’a pas encore de série de reçus : connectez-vous une '
        'fois à Internet, puis réessayez.',
      );
    }
    return s;
  }

  Future<SchoolYearRow> _annee(String yearId) => (db.select(
    db.schoolYears,
  )..where((y) => y.id.equals(yearId))).getSingle();

  /// Encaisse un paiement : numéro de reçu définitif tout de suite, même
  /// sans Internet (série de ce téléphone + numéro suivant).
  Future<PaymentRow> encaisser({
    required String schoolId,
    required String yearId,
    required String? studentId,
    required String rubric,
    required String? feeItemId,
    required int montant,
    required String mode,
    String? reference,
    String? payeur,
  }) async {
    if (montant <= 0) {
      throw const UserMessage('Le montant doit être supérieur à zéro.');
    }
    if (mode != 'especes' && (reference ?? '').trim().isEmpty) {
      throw UserMessage(
        'Indiquez la référence du paiement (${libelleMode(mode)}).',
      );
    }
    return await _ecrirePaiement(
      schoolId: schoolId,
      yearId: yearId,
      champs: {
        'student_id': studentId,
        'rubric': rubric,
        'fee_item_id': feeItemId,
        'amount': montant,
        'method': mode,
        'reference': (reference ?? '').trim().isEmpty
            ? null
            : reference!.trim(),
        'payer_name': (payeur ?? '').trim().isEmpty ? null : payeur!.trim(),
      },
    );
  }

  /// Annule un reçu par une écriture opposée motivée (contre-passation) ;
  /// le reçu d'origine reste tel quel.
  Future<PaymentRow> annuler(PaymentRow recu, String motif) async {
    if (motif.trim().isEmpty) {
      throw const UserMessage('Indiquez le motif de l’annulation.');
    }
    if (recu.reversesPaymentId != null) {
      throw const UserMessage(
        'Une annulation ne peut pas être annulée : faites un nouvel '
        'encaissement.',
      );
    }
    final deja = await (db.select(
      db.payments,
    )..where((x) => x.reversesPaymentId.equals(recu.id))).getSingleOrNull();
    if (deja != null) {
      throw UserMessage('Ce reçu est déjà annulé (${deja.receiptNumber}).');
    }
    return await _ecrirePaiement(
      schoolId: recu.schoolId,
      yearId: recu.schoolYearId,
      champs: {
        'student_id': recu.studentId,
        'rubric': recu.rubric,
        'fee_item_id': recu.feeItemId,
        'amount': -recu.amount,
        'method': recu.method,
        'reference': recu.reference,
        'payer_name': recu.payerName,
        'reverses_payment_id': recu.id,
        'reversal_reason': motif.trim(),
      },
    );
  }

  Future<PaymentRow> _ecrirePaiement({
    required String schoolId,
    required String yearId,
    required Map<String, Object?> champs,
  }) async {
    final s = await _session();
    final annee = await _annee(yearId);
    final id = _uuid.v4();
    // Calcul du numéro et écriture dans la même transaction : deux
    // encaissements rapides n'obtiennent jamais le même numéro.
    await db.transaction(() async {
      final pris =
          await (db.select(db.payments)..where(
                (x) =>
                    x.deviceId.equals(s.deviceId) &
                    x.schoolYearId.equals(yearId),
              ))
              .map((x) => x.deviceSeq)
              .get();
      final n = prochainNumero(pris);
      await store.save('payments', {
        'id': id,
        'school_id': schoolId,
        'school_year_id': yearId,
        ...champs,
        'paid_at': store.clock.nowIso(),
        'received_by': s.userId,
        'device_id': s.deviceId,
        'device_seq': n,
        'receipt_number': numeroRecu(annee.label, s.deviceSeries!, n),
        'created_at': store.clock.nowIso(),
      });
    });
    return await (db.select(
      db.payments,
    )..where((x) => x.id.equals(id))).getSingle();
  }

  // ------------------------------ Dépenses ------------------------------

  /// Enregistre une dépense (justificatif facultatif : photo ou PDF), avec
  /// un numéro de pièce de ce téléphone.
  Future<ExpenseRow> depenser({
    required String schoolId,
    required String yearId,
    required String categorie,
    required String libelle,
    required int montant,
    required String date,
    required String mode,
    (Uint8List, String)? justificatif,
  }) async {
    if (montant <= 0) {
      throw const UserMessage('Le montant doit être supérieur à zéro.');
    }
    if (libelle.trim().isEmpty) {
      throw const UserMessage('Indiquez l’objet de la dépense.');
    }
    final id = _uuid.v4();
    String? chemin;
    if (justificatif != null) {
      final (octets, type) = justificatif;
      final ext = type == 'application/pdf' ? 'pdf' : 'jpg';
      chemin = '$schoolId/depenses/$id.$ext';
      final local = File(p.join(mediaDir!.path, chemin));
      await local.parent.create(recursive: true);
      await local.writeAsBytes(octets, flush: true);
    }
    return await _ecrireDepense(
      schoolId: schoolId,
      yearId: yearId,
      id: id,
      champs: {
        'category': categorie,
        'label': libelle.trim(),
        'amount': montant,
        'spent_on': date,
        'method': mode,
        'justification_path': chemin,
      },
      envoi: chemin == null
          ? null
          : (
              chemin,
              justificatif!.$2 == 'application/pdf'
                  ? 'application/pdf'
                  : 'image/jpeg',
            ),
    );
  }

  Future<ExpenseRow> annulerDepense(ExpenseRow d, String motif) async {
    if (motif.trim().isEmpty) {
      throw const UserMessage('Indiquez le motif de l’annulation.');
    }
    if (d.reversesExpenseId != null) {
      throw const UserMessage('Une annulation ne peut pas être annulée.');
    }
    final deja = await (db.select(
      db.expenses,
    )..where((x) => x.reversesExpenseId.equals(d.id))).getSingleOrNull();
    if (deja != null) {
      throw const UserMessage('Cette dépense est déjà annulée.');
    }
    return await _ecrireDepense(
      schoolId: d.schoolId,
      yearId: d.schoolYearId,
      id: _uuid.v4(),
      champs: {
        'category': d.category,
        'label': d.label,
        'amount': -d.amount,
        'spent_on': store.clock.nowIso().substring(0, 10),
        'method': d.method,
        'reverses_expense_id': d.id,
        'reversal_reason': motif.trim(),
      },
    );
  }

  Future<ExpenseRow> _ecrireDepense({
    required String schoolId,
    required String yearId,
    required String id,
    required Map<String, Object?> champs,
    (String, String)? envoi,
  }) async {
    final s = await _session();
    final annee = await _annee(yearId);
    await db.transaction(() async {
      final pris =
          await (db.select(db.expenses)..where(
                (x) =>
                    x.deviceId.equals(s.deviceId) &
                    x.schoolYearId.equals(yearId),
              ))
              .map((x) => x.deviceSeq)
              .get();
      final n = prochainNumero(pris);
      await store.save('expenses', {
        'id': id,
        'school_id': schoolId,
        'school_year_id': yearId,
        ...champs,
        'device_id': s.deviceId,
        'device_seq': n,
        'voucher_number': numeroPiece(annee.label, s.deviceSeries!, n),
        'created_by': s.userId,
        'created_at': store.clock.nowIso(),
      });
      if (envoi != null) {
        final (chemin, type) = envoi;
        await db
            .into(db.fileUploads)
            .insert(
              FileUploadsCompanion.insert(
                localPath: p.join(mediaDir!.path, chemin),
                bucket: compartiment,
                objectPath: chemin,
                contentType: type,
                createdAt: store.clock.nowIso(),
              ),
            );
      }
    });
    return await (db.select(
      db.expenses,
    )..where((x) => x.id.equals(id))).getSingle();
  }

  /// Justificatif d'une dépense : sur ce téléphone, sinon téléchargé
  /// (Internet nécessaire ; jamais téléchargé automatiquement).
  Future<Uint8List> justificatif(ExpenseRow d) async {
    final chemin = d.justificationPath;
    if (chemin == null) throw const UserMessage('Aucun justificatif.');
    final local = File(p.join(mediaDir!.path, chemin));
    if (local.existsSync()) return await local.readAsBytes();
    try {
      final octets = await remote.download(compartiment, chemin);
      await local.parent.create(recursive: true);
      await local.writeAsBytes(octets, flush: true);
      return octets;
    } on Object {
      throw const UserMessage(
        'Justificatif pas encore sur ce téléphone : connectez-vous à '
        'Internet pour l’afficher.',
      );
    }
  }

  // ------------------------------ Clôture -------------------------------

  /// Clôture d'un mois : le solde de caisse est figé (une seule clôture
  /// par mois, même faite sur deux téléphones).
  Future<void> cloturer({
    required String schoolId,
    required String mois,
    required int solde,
    String? notes,
  }) async {
    final id = _uuid.v5(
      Namespace.url.value,
      'ecoleplus:cloture:$schoolId:$mois',
    );
    final deja = await (db.select(
      db.cashClosings,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (deja != null) {
      throw UserMessage('Le mois $mois est déjà clôturé.');
    }
    final s = await _session();
    await store.save('cash_closings', {
      'id': id,
      'school_id': schoolId,
      'period_month': '$mois-01',
      'closing_balance': solde,
      'closed_by': s.userId,
      'notes': (notes ?? '').trim().isEmpty ? null : notes!.trim(),
      'created_at': store.clock.nowIso(),
    });
  }
}
