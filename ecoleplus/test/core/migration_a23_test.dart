import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('base du téléphone : passage de la version 13 (A22) à la 14 (A23) '
      'sans perte, reçus existants gardés', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = Directory.systemTemp.createTempSync('migration13');
    final fichier = File('${dir.path}/ecole.db');
    var db = AppDatabase(NativeDatabase(fichier));
    await db.customStatement(
      'INSERT INTO payments (id, school_id, school_year_id, rubric, amount, '
      'method, paid_at, device_id, device_seq, receipt_number) VALUES '
      "('p', 's', 'a', 'scolarite', 5000, 'especes', '2026-11-01', 'd', 1, "
      "'R2526-A-00001')",
    );
    // Retour à l'état d'une base A22 (version 13).
    for (final t in ['payment_allocations', 'fee_notes']) {
      await db.customStatement('DROP TABLE $t');
    }
    for (final (t, c) in const [
      ('fee_items', 'payment_terms'),
      ('fee_installments', 'starts_on'),
      ('payments', 'payer_phone'),
      ('payments', 'method_label'),
    ]) {
      await db.customStatement('ALTER TABLE $t DROP COLUMN $c');
    }
    await db.customStatement('PRAGMA user_version = 13');
    await db.close();

    db = AppDatabase(NativeDatabase(fichier));
    final p = (await db.select(db.payments).get()).single;
    expect(
      (p.receiptNumber, p.amount, p.methodLabel),
      ('R2526-A-00001', 5000, null),
    );
    expect(await db.select(db.paymentAllocations).get(), isEmpty);
    expect(await db.select(db.feeNotes).get(), isEmpty);
    await db.close();
    dir.deleteSync(recursive: true);
  });
}
