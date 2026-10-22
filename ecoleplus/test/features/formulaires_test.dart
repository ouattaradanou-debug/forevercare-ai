import 'dart:io';
import 'dart:typed_data';

import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:flutter_test/flutter_test.dart';

const _ts = '2026-10-01T00:00:00Z';

TeacherRow enseignant(
  String id,
  String nom, {
  String status = 'actif',
  String? generale,
  String? nomination,
}) => TeacherRow(
  id: id,
  schoolId: 'e',
  lastName: nom,
  firstNames: 'Test',
  sex: 'F',
  matricule: 'MAT-$id',
  phone: '70000000',
  birthDate: '1985-03-14',
  birthPlace: 'Ville Test',
  emploi: 'Instituteur (exemple)',
  categorie: 'B',
  echelon: '3',
  tenureStatus: 'T',
  status: status,
  seniorityGeneralFrom: generale,
  communeNominationDate: nomination,
  pupilSchoolName: 'École Ancienne',
  pupilSchoolEntryDate: '1991-10-01',
  pupilSchoolExitDate: '1997-06-30',
  newPost: status == 'parti' ? 'École Voisine' : null,
  updatedAt: _ts,
);

StudentRow eleve(String id, String prenom, int? numero) => StudentRow(
  id: id,
  schoolId: 'e',
  lastName: 'TEST',
  firstNames: prenom,
  birthDate: '2017-01-10',
  registryNumber: numero,
  entryDate: '2023-10-02',
  updatedAt: _ts,
);

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

const params = ParametresImpression(
  anneeScolaire: '2025-2026',
  ceb: 'CEB Test 2',
  ecole: 'École Test',
  province: 'Province Test',
  commune: 'Commune Test',
  faitA: 'Ville Test',
  faitLe: '2026-10-15',
  directeur: 'Directeur Test',
  dateReference: '2025-12-31',
);

/// Texte extrait du PDF (pdftotext) quand l'outil est présent, pour vérifier
/// les intitulés réellement imprimés.
String? texteDuPdf(Uint8List octets) {
  if (!File('/usr/bin/pdftotext').existsSync()) return null;
  final dir = Directory.systemTemp.createTempSync('pdf');
  final f = File('${dir.path}/f.pdf')..writeAsBytesSync(octets);
  final r = Process.runSync('pdftotext', ['-layout', f.path, '-']);
  dir.deleteSync(recursive: true);
  return r.stdout as String;
}

void main() {
  test('B1 : 15 colonnes dans l’ordre du modèle, anciennetés à la date de '
      'référence, enseignant parti exclu', () {
    final lignes = lignesB1(
      enseignants: [
        enseignant('2', 'ZONGO', generale: '2008-10-01'),
        enseignant('1', 'BAMBA'),
        enseignant('3', 'PARTI', status: 'parti'),
      ],
      affectations: const [
        TeacherAssignmentRow(
          id: 'a',
          schoolId: 'e',
          schoolYearId: 'y',
          teacherId: '2',
          classId: 'c',
          fonction: 'Adjoint',
          updatedAt: _ts,
        ),
      ],
      classes: const [
        ClassRow(
          id: 'c',
          schoolId: 'e',
          schoolYearId: 'y',
          levelCode: 'CM1',
          name: 'CM1 A',
          updatedAt: _ts,
        ),
      ],
      diplomes: const [
        TeacherDiplomaRow(
          id: 'd1',
          schoolId: 'e',
          teacherId: '2',
          nature: 'BAC',
          deliveredOn: '2005-07-15',
          isAcademic: true,
          updatedAt: _ts,
        ),
        TeacherDiplomaRow(
          id: 'd2',
          schoolId: 'e',
          teacherId: '2',
          nature: 'Licence',
          deliveredOn: '2012-07-15',
          isAcademic: true,
          updatedAt: _ts,
        ),
        TeacherDiplomaRow(
          id: 'd3',
          schoolId: 'e',
          teacherId: '2',
          nature: 'CAP',
          deliveredOn: '2015-07-15',
          isAcademic: false,
          updatedAt: _ts,
        ),
      ],
      reference: DateTime(2025, 12, 31),
    );
    expect(enteteB1.length, 15);
    expect(lignes.length, 2, reason: 'l’enseignant parti n’est pas listé');
    expect(lignes[0][2], 'BAMBA Test');
    expect(lignes[1], [
      '2',
      'MAT-2',
      'ZONGO Test',
      'Instituteur (exemple)',
      'B ; 3',
      '14/03/1985',
      'F',
      'CM1 A',
      'Adjoint',
      'Licence', // dernier diplôme ACADÉMIQUE (le CAP ne l'est pas)
      '17 ans 2 mois 30 j',
      '',
      '',
      '',
      '70000000',
    ]);
  });

  test('B2 : ordre des numéros, élèves sortis inclus, numéros provisoires '
      'non imprimés, « venant de » dans les observations', () {
    final eleves = [
      eleve('b', 'Boukary', 2),
      eleve('a', 'Aïcha', 1),
      eleve('p', 'Provisoire', null),
    ];
    final lignes = lignesB2(
      eleves: eleves,
      parents: const [
        GuardianRow(
          id: 'g',
          schoolId: 'e',
          studentId: 'a',
          relation: 'pere',
          fullName: 'Parent Test',
          profession: 'Cultivateur',
          domicile: 'Quartier Test',
          isLodger: false,
          sortOrder: 0,
          updatedAt: _ts,
        ),
      ],
      registres: const [
        StudentRegistryRow(
          id: 'b',
          schoolId: 'e',
          originSchool: 'École Ancienne',
          cepDate: '2025-06-20',
          updatedAt: _ts,
        ),
      ],
    );
    expect(enteteB2.length, 9);
    expect(lignes.map((l) => l[0]), ['1', '2']);
    expect(lignes[0].sublist(1, 6), [
      'TEST Aïcha',
      '10/01/2017',
      'Parent Test',
      'Cultivateur, Quartier Test',
      '02/10/2023',
    ]);
    expect(lignes[1][6], '20/06/2025');
    expect(lignes[1][8], 'Venant de : École Ancienne');
    expect(enAttenteB2(eleves), 1);
  });

  test('B3 : double page (7 + 6 colonnes), historiques sur plusieurs lignes, '
      'enseignant parti conservé', () {
    final lignes = lignesB3(
      enseignants: [
        enseignant('1', 'RÉCENT', nomination: '2024-10-01'),
        enseignant('2', 'ANCIEN', nomination: '2019-10-01', status: 'parti'),
      ],
      affectations: const [],
      classes: const [],
      communes: const [
        TeacherPostingRow(
          id: 'p2',
          schoolId: 'e',
          teacherId: '2',
          commune: 'Commune Test',
          nominatedOn: '2019-10-01',
          sortOrder: 2,
          updatedAt: _ts,
        ),
        TeacherPostingRow(
          id: 'p1',
          schoolId: 'e',
          teacherId: '2',
          commune: 'Commune Ancienne',
          nominatedOn: '2008-10-01',
          sortOrder: 1,
          updatedAt: _ts,
        ),
      ],
      interruptions: const [
        TeacherInterruptionRow(
          id: 'i',
          schoolId: 'e',
          teacherId: '2',
          cause: 'Disponibilité',
          startsOn: '2015-01-01',
          endsOn: '2015-12-31',
          updatedAt: _ts,
        ),
      ],
      recompenses: const [],
      diplomes: const [],
    );
    expect(enteteB3Gauche.length + enteteB3Droite.length, 13);
    expect(lignes.map((l) => l.gauche[0]), ['ANCIEN Test', 'RÉCENT Test']);
    final a = lignes.first;
    expect(a.gauche, [
      'ANCIEN Test',
      '14/03/1985 à Ville Test',
      '01/10/2019',
      'T',
      '',
      'École Ancienne (entrée le 01/10/1991, sortie le 30/06/1997)',
      '',
    ]);
    expect(
      a.droite[0],
      'Commune Ancienne (01/10/2008)\nCommune Test (01/10/2019)',
    );
    expect(a.droite[1], 'Disponibilité : du 01/01/2015 au 31/12/2015');
    expect(a.droite[4], 'Nouveau poste : École Voisine');
  });

  test(
    'PDF B1, B2, B3 : générés en A4 paysage avec les intitulés du modèle',
    () async {
      final b1 = await pdfB1(polices(), params, [
        for (var i = 0; i < 30; i++)
          ['${i + 1}', 'MAT', 'NOM Prénom', ...List.filled(12, 'x')],
      ]);
      final b2 = await pdfB2(polices(), params, [
        for (var i = 1; i <= 60; i++)
          [
            '$i',
            'TEST Élève $i',
            '10/01/2017',
            'Parent',
            'Cultivateur',
            '',
            '',
            '',
            '',
          ],
      ]);
      final b3 = await pdfB3(polices(), params, [
        for (var i = 0; i < 10; i++)
          LigneB3(
            ['ENSEIGNANT $i', ...List.filled(6, 'g$i')],
            [
              // Historique sur plusieurs lignes (colonne 8) : la ligne garde
              // la même hauteur sur les pages de gauche et de droite.
              if (i.isEven)
                'Commune A (01/10/2008)\nCommune B (01/10/2012)\n'
                    'Commune C (01/10/2019)'
              else
                'Commune A (01/10/2008)',
              ...List.filled(5, 'd$i'),
            ],
          ),
      ]);
      for (final p in [b1, b2, b3]) {
        expect(String.fromCharCodes(p.take(5)), '%PDF-');
      }
      // Sorties gardées pour la comparaison visuelle (docs/TESTS_PHASE_2.md).
      final sortie = Directory('build/pdf_formulaires')
        ..createSync(recursive: true);
      File('${sortie.path}/B1.pdf').writeAsBytesSync(b1);
      File('${sortie.path}/B2.pdf').writeAsBytesSync(b2);
      File('${sortie.path}/B3.pdf').writeAsBytesSync(b3);

      final t1 = texteDuPdf(b1);
      if (t1 != null) {
        for (final x in [
          'CEB de CEB Test 2',
          'Année scolaire 2025-2026',
          'FICHE DE RENSEIGNEMENT DU PERSONNEL PAR ÉCOLE',
          'Ancienneté',
          'Dernier diplôme',
          'Fait à Ville Test, le 15/10/2026',
          'Directeur Test',
        ]) {
          expect(t1, contains(x));
        }
        final t2 = texteDuPdf(b2)!;
        for (final x in [
          'Mod. 557',
          'REGISTRE MATRICULE',
          'Province de Province Test',
          'TEST Élève 60',
          'C.E.P.',
        ]) {
          expect(t2, contains(x));
        }
        final t3 = texteDuPdf(b3)!;
        expect(t3, contains('REGISTRE DU PERSONNEL ENSEIGNANT'));
        expect(t3, contains('Récompenses obtenues'));
        expect(t3, contains('Page 4/4'), reason: '10 lignes = 2 doubles pages');
      }
    },
  );
}
