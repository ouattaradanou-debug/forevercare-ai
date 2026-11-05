import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tables de la phase 11 (version 15).
const tablesCantine = [
  'canteen_settings',
  'canteen_beneficiaries',
  'meal_services',
  'stock_products',
  'stock_movements',
  'canteen_menus',
  // A26 (version 16).
  'canteen_years',
  'canteen_rates',
  'canteen_subscriptions',
  // Phase 12 (version 17).
  'lesson_preps',
  'ai_teacher_limits',
  // Phase 13 (version 18).
  'timetable_slots',
];

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
    for (final t in ['payment_allocations', 'fee_notes', ...tablesCantine]) {
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

  test('base du téléphone : passage de la version 14 (A23) à la 15 '
      '(cantine) puis 16 sans perte', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = Directory.systemTemp.createTempSync('migration14');
    final fichier = File('${dir.path}/ecole.db');
    var db = AppDatabase(NativeDatabase(fichier));
    await db.customStatement(
      'INSERT INTO payments (id, school_id, school_year_id, rubric, amount, '
      'method, paid_at, device_id, device_seq, receipt_number) VALUES '
      "('p', 's', 'a', 'scolarite', 5000, 'especes', '2026-11-01', 'd', 1, "
      "'R2526-A-00001')",
    );
    for (final t in tablesCantine) {
      await db.customStatement('DROP TABLE $t');
    }
    await db.customStatement(
      'ALTER TABLE payment_allocations DROP COLUMN canteen_subscription_id',
    );
    await db.customStatement('PRAGMA user_version = 14');
    await db.close();

    db = AppDatabase(NativeDatabase(fichier));
    expect((await db.select(db.payments).get()).single.amount, 5000);
    expect(await db.select(db.stockMovements).get(), isEmpty);
    expect(await db.select(db.canteenSettings).get(), isEmpty);
    await db.close();
    dir.deleteSync(recursive: true);
  });

  test('base du téléphone : passage de la version 15 (cantine) à la 16 '
      '(abonnements A26) sans perte', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = Directory.systemTemp.createTempSync('migration15');
    final fichier = File('${dir.path}/ecole.db');
    var db = AppDatabase(NativeDatabase(fichier));
    await db.customStatement(
      'INSERT INTO canteen_beneficiaries (id, school_id, student_id, '
      "school_year_id, updated_at) VALUES ('b', 's', 'e', 'a', '')",
    );
    for (final t in [
      'canteen_years',
      'canteen_rates',
      'canteen_subscriptions',
      'lesson_preps',
      'ai_teacher_limits',
      'timetable_slots',
    ]) {
      await db.customStatement('DROP TABLE $t');
    }
    for (final (t, c) in const [
      ('canteen_beneficiaries', 'monthly_reduction'),
      ('payment_allocations', 'canteen_subscription_id'),
    ]) {
      await db.customStatement('ALTER TABLE $t DROP COLUMN $c');
    }
    await db.customStatement('PRAGMA user_version = 15');
    await db.close();

    db = AppDatabase(NativeDatabase(fichier));
    final b = await db.select(db.canteenBeneficiaries).getSingle();
    expect((b.id, b.monthlyReduction), ('b', null));
    expect(await db.select(db.canteenSubscriptions).get(), isEmpty);
    await db.close();
    dir.deleteSync(recursive: true);
  });
  test('base du téléphone : passage de la version 17 (IA) à la 18 (emploi '
      'du temps) sans perte', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = Directory.systemTemp.createTempSync('migration17');
    final fichier = File('${dir.path}/ecole.db');
    var db = AppDatabase(NativeDatabase(fichier));
    await db.customStatement(
      'INSERT INTO attendance (id, school_id, class_id, student_id, day, '
      "status, updated_at) VALUES ('p', 's', 'c', 'e', '2026-11-05', "
      "'absent', '')",
    );
    await db.customStatement('DROP TABLE timetable_slots');
    await db.customStatement('PRAGMA user_version = 17');
    await db.close();

    db = AppDatabase(NativeDatabase(fichier));
    expect((await db.select(db.attendance).getSingle()).status, 'absent');
    expect(await db.select(db.timetableSlots).get(), isEmpty);
    await db.close();
    dir.deleteSync(recursive: true);
  });

  test('base du téléphone : passage de la version 18 à la 19 (index des '
      'présences) sans perte', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = Directory.systemTemp.createTempSync('migration18');
    final fichier = File('${dir.path}/ecole.db');
    var db = AppDatabase(NativeDatabase(fichier));
    await db.customStatement(
      'INSERT INTO attendance (id, school_id, class_id, student_id, day, '
      "status, updated_at) VALUES ('p', 's', 'c', 'e', '2026-11-05', "
      "'absent', '')",
    );
    await db.customStatement('DROP INDEX attendance_school_day');
    await db.customStatement('PRAGMA user_version = 18');
    await db.close();

    db = AppDatabase(NativeDatabase(fichier));
    expect((await db.select(db.attendance).getSingle()).status, 'absent');
    final index = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE name = 'attendance_school_day'",
        )
        .get();
    expect(index, hasLength(1));
    await db.close();
    dir.deleteSync(recursive: true);
  });
}
