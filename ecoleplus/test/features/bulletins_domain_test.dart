import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/bulletins/domain/bulletin.dart';
import 'package:ecoleplus/features/bulletins/pdf/pdf_bulletin.dart';
import 'package:ecoleplus/features/forms/domain/fiche_scolarite.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_b4.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:ecoleplus/features/security/domain/journal.dart';
import 'package:flutter_test/flutter_test.dart';

PolicesPdf polices() {
  ByteData lire(String n) => ByteData.sublistView(
    File('assets/fonts/Roboto-$n.ttf').readAsBytesSync(),
  );
  return PolicesPdf(
    normale: lire('Regular'),
    grasse: lire('Bold'),
    italique: lire('Italic'),
  );
}

String? texteDuPdf(Uint8List octets) {
  if (!File('/usr/bin/pdftotext').existsSync()) return null;
  final dir = Directory.systemTemp.createTempSync('pdf');
  final f = File('${dir.path}/f.pdf')..writeAsBytesSync(octets);
  final r = Process.runSync('pdftotext', ['-layout', f.path, '-']);
  dir.deleteSync(recursive: true);
  return r.stdout as String;
}

void main() {
  group('modèle de bulletin', () {
    test('valeurs par défaut, objet JSON, texte JSON (même deux fois)', () {
      expect(ModeleBulletin.depuis(null).titre, 'BULLETIN DE NOTES');
      expect(ModeleBulletin.depuis({'rang': false}).afficherRang, isFalse);
      expect(
        ModeleBulletin.depuis('{"titre":"BULLETIN TRIMESTRIEL"}').titre,
        'BULLETIN TRIMESTRIEL',
      );
      expect(
        ModeleBulletin.depuis(r'"{\"total\":false}"').afficherTotal,
        isFalse,
      );
      expect(ModeleBulletin.depuis('pas du json').afficherRang, isTrue);
      final m = const ModeleBulletin().avec({'parents': false, 'titre': ' '});
      expect((m.signatureParents, m.titre), (false, 'BULLETIN DE NOTES'));
    });
  });

  group('fiche de scolarité', () {
    test('classement en fraction : 7e/39, 1re/39, ex-aequo', () {
      expect(
        const CoursSuivi(
          niveau: 'CM1',
          essai: 1,
          rang: 7,
          effectif: 39,
        ).classement,
        '7e/39',
      );
      expect(
        const CoursSuivi(
          niveau: 'CM1',
          essai: 1,
          rang: 1,
          effectif: 39,
          fille: true,
        ).classement,
        '1re/39',
      );
      expect(
        const CoursSuivi(
          niveau: 'CM1',
          essai: 1,
          rang: 2,
          exAequo: true,
          effectif: 39,
        ).classement,
        '2e ex/39',
      );
    });

    test('redoublement : seconde colonne du niveau ; le plus récent gagne', () {
      final m = coursParCase(const [
        CoursSuivi(niveau: 'CM1', essai: 1, date: '2025-06-30', rang: 5),
        CoursSuivi(niveau: 'CM1', essai: 2, date: '2026-06-30', rang: 1),
        CoursSuivi(niveau: 'CM1', essai: 2, date: '2026-01-01', rang: 9),
        CoursSuivi(niveau: 'PS', essai: 1, rang: 3), // maternelle : ignorée
      ]);
      expect(m.keys, unorderedEquals([('CM1', 1), ('CM1', 2)]));
      expect(m[('CM1', 2)]!.rang, 1);
    });

    test('copie conforme dans le journal d’activité', () {
      expect(
        decrireEvenement(
          action: 'creation',
          table: 'scolarity_copy_log',
          detailsJson: '{"valeurs":{"is_certified_copy":true}}',
          acteur: 'Directeur Test',
        ).phrase,
        'Directeur Test a généré une fiche de scolarité (copie conforme)',
      );
    });
  });

  test('PDF : bulletin d’école privée et fiche de scolarité avec '
      'redoublement et copie conforme', () async {
    final r = Resultat(
      const Eleve('a', 'TEST Aïcha', fille: true),
      const {'fr': 700, 'ma': 800},
      1500,
      Fraction.de(750, 1),
      uneSeuleNote: const {'ma'},
    )..rang = 1;
    final b = Bulletin(
      entete: const ['BURKINA FASO', 'Ministère Test'],
      ecole: 'École Test',
      annee: '2025-2026',
      classe: 'CM1 A',
      periode: '1er trimestre',
      eleve: 'TEST Aïcha',
      matricule: '12',
      titresCases: const ['Éval.', 'Compo.'],
      lignes: const [
        LigneBulletin(
          matiere: 'Français',
          coefficient: 100,
          cases: ['8', '6'],
          moyenne: 700,
        ),
        LigneBulletin(
          matiere: 'Mathématiques',
          coefficient: 100,
          cases: ['—', '8'],
          moyenne: 800,
          uneSeuleNote: true,
        ),
      ],
      resultat: r,
      statistiques: const Statistiques(
        classes: 3,
        effectif: 39,
        meilleure: 750,
        plusFaible: 500,
        moyenneClasse: 620,
      ),
      appreciation: 'Bon trimestre',
    );
    final bulletin = await pdfBulletins(polices(), const ModeleBulletin(), [
      b,
      b,
    ]);
    final fiche = await pdfB4(
      polices(),
      FicheScolarite(
        entete: const ['Ministère Test'],
        pays: 'BURKINA FASO',
        nom: 'TEST Aïcha',
        ecole: 'École Test',
        cours: coursParCase(const [
          CoursSuivi(
            niveau: 'CM1',
            essai: 1,
            date: '2025-06-30',
            moyenne: 520,
            rang: 5,
            effectif: 30,
            fille: true,
          ),
          CoursSuivi(
            niveau: 'CM1',
            essai: 2,
            date: '2026-06-30',
            moyenne: 800,
            rang: 1,
            effectif: 39,
            fille: true,
          ),
        ]),
        sortiLe: '15/07/2026',
        allantA: 'Collège Test',
        copieConforme: true,
        dateCopie: '27/10/2026',
      ),
    );
    final sortie = Directory('build/pdf_phase4')..createSync(recursive: true);
    File('${sortie.path}/bulletin.pdf').writeAsBytesSync(bulletin);
    File('${sortie.path}/B4.pdf').writeAsBytesSync(fiche);
    expect(String.fromCharCodes(bulletin.take(5)), '%PDF-');
    final tb = texteDuPdf(bulletin);
    if (tb != null) {
      for (final x in [
        'BULLETIN DE NOTES — 1er trimestre',
        'Éval.',
        'Compo.',
        'Mathématiques *',
        'Total des points : 15',
        'Moyenne : 7,5 / 10',
        'Rang : 1re/39',
        'Bon trimestre',
      ]) {
        expect(tb, contains(x));
      }
      expect('\f'.allMatches(tb).length, greaterThanOrEqualTo(2));
    }
    final tf = texteDuPdf(fiche);
    if (tf != null) {
      for (final x in [
        'FICHE DE SCOLARITÉ',
        'COPIE CONFORME',
        'C.M.1',
        '5e/30',
        '1re/39',
        '5,2',
        'Collège Test',
        'délivrée le 27/10/2026',
        'Établissement suivant n° 2',
      ]) {
        expect(tf, contains(x));
      }
    }
  });

  test(
    'base du téléphone : passage de la version 5 à la 11 sans perte',
    () async {
      final dir = Directory.systemTemp.createTempSync('migration');
      final fichier = File('${dir.path}/ecole.db');
      var db = AppDatabase(NativeDatabase(fichier));
      await db.customStatement(
        'INSERT INTO levels (code, cycle, label, sort_order) '
        "VALUES ('CM1', 'primaire', 'CM1', 5)",
      );
      // Retour à l'état d'une base de la phase 3 (version 5).
      for (final t in [
        'report_templates',
        'report_cards',
        'scolarity_copy_log',
        'issued_documents',
        'activity_objectives',
        'activity_lines',
        'form_versions',
        'learning_domains',
        'qualitative_levels',
        'preschool_periods',
        'preschool_evaluations',
        'preschool_booklets',
        'attendance',
        'card_templates',
        'student_cards',
        'documents',
        'document_uploads',
        'document_files',
      ]) {
        await db.customStatement('DROP TABLE $t');
      }
      for (final (t, c) in const [
        ('schools', 'director_civility'),
        ('schools', 'director_grade'),
        ('teachers', 'assignment_decision_number'),
        ('teachers', 'assignment_decision_date'),
        ('teachers', 'service_start_date'),
        ('official_forms', 'locked_version'),
        ('official_forms', 'show_objective_average'),
        ('schools', 'preschool_ranking'),
        ('schools', 'logo_path'),
        ('schools', 'storage_quota_bytes'),
        ('schools', 'library_teacher_mode'),
        ('official_forms', 'signed_scan_document_id'),
      ]) {
        await db.customStatement('ALTER TABLE $t DROP COLUMN $c');
      }
      await db.customStatement('PRAGMA user_version = 5');
      await db.close();

      db = AppDatabase(NativeDatabase(fichier));
      expect(await db.select(db.levels).get(), hasLength(1));
      await db
          .into(db.reportCards)
          .insert(
            ReportCardsCompanion.insert(
              id: 'r',
              schoolId: 's',
              studentId: 'e',
              classId: 'c',
              updatedAt: '2026-10-27T08:00:00Z',
            ),
          );
      expect(await db.select(db.reportCards).get(), hasLength(1));
      await db.close();
      dir.deleteSync(recursive: true);
    },
  );
}
