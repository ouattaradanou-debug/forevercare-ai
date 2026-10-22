import 'package:ecoleplus/core/import/analyse_import.dart';
import 'package:ecoleplus/core/import/tableur.dart';
import 'package:ecoleplus/features/students/domain/import_eleves.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/xlsx.dart';

void main() {
  test('xlsx : textes partagés, nombres, cellules et lignes vides', () {
    final lignes = lireTableur(
      fabriquerXlsx([
        ['Nom', 'Prénoms', null, 'Né le'],
        ['TEST', 'Aïcha & Co', null, 42744],
        [null, null, null, null],
        ['TEST', 'Boukary', 'M'],
      ]),
    );
    expect(lignes[0], ['Nom', 'Prénoms', null, 'Né le']);
    expect(lignes[1], ['TEST', 'Aïcha & Co', null, '42744']);
    expect(lignes[2], isEmpty, reason: 'ligne vide conservée (numérotation)');
    expect(lignes[3], ['TEST', 'Boukary', 'M']);
  });

  test('csv : séparateur « ; », guillemets, BOM, fins de ligne Windows', () {
    final l = lireTableur(
      csvUtf8('﻿Nom;Prénoms\r\n"OUÉ; DRAOGO";"Jean ""Petit"""\r\n'),
    );
    expect(l, [
      ['Nom', 'Prénoms'],
      ['OUÉ; DRAOGO', 'Jean "Petit"'],
    ]);
    expect(lireCsv('a,b\n1,2'), [
      ['a', 'b'],
      ['1', '2'],
    ]);
  });

  test('dates : 14/03/2017, 2017-03-14, numéro de série Excel', () {
    expect(dateDeCellule('14/03/2017'), '2017-03-14');
    expect(dateDeCellule('4/3/17'), '2017-03-04');
    expect(dateDeCellule('2017-03-14'), '2017-03-14');
    expect(dateDeCellule('42808'), '2017-03-14');
    expect(dateDeCellule('31/02/2017'), isNull);
    expect(dateDeCellule('demain'), isNull);
  });

  test('fichier qui n’est pas un tableur : message clair', () {
    expect(
      () => lireTableur(csvUtf8('PK\u0003\u0004 abîmé')),
      throwsA(isA<TableurIllisible>()),
    );
  });

  AnalyseImport analyser(List<List<String?>> lignes, {Set<String>? exist}) =>
      analyserImport(
        lignes,
        colonnes: colonnesEleves,
        valider: validerEleve({'cm1a', 'ce1a'}),
        cleDoublon: cleDoublonEleve,
        existants: exist ?? {},
      );

  test('import élèves : doublons, lignes vides et erreurs expliquées', () {
    const e9 =
        'Ligne 9 : date de naissance « 31/02/2017 » illisible (attendu : '
        '14/03/2017)';
    const e10 =
        'Ligne 10 : la classe « CM3 » n’existe pas cette année (créez-la '
        'd’abord)';
    final a = analyser(
      [
        [],
        ['N°', 'NOM', 'Prénom(s)', 'Sexe', 'Date de naissance', 'Classe', 'X'],
        ['1', 'TEST', 'Aïcha', 'F', '10/01/2017', 'CM1 A', 'ignoré'],
        ['2', 'TEST', 'Boukary', 'Garçon', '22/05/2017', 'cm1a'],
        [],
        [null, null, null, null, null, null, null],
        ['3', 'TEST', 'Aïcha', 'F', '10/01/2017', 'CM1 A'], // doublon
        ['4', null, 'Sans nom', 'F'],
        ['5', 'TEST', 'Clarisse', 'F', '31/02/2017', 'CM1 A'],
        ['6', 'TEST', 'Daouda', 'M', null, 'CM3'],
        ['7', 'TEST', 'Élise', 'X'],
        ['8', 'EXISTANT', 'Moussa', 'G', '30/11/2018', 'CE1 A'],
      ],
      exist: {cleEleve('Existant', 'MOUSSA', '2018-11-30')},
    );
    expect(a.valides.map((l) => l['prenoms']), ['Aïcha', 'Boukary']);
    expect(a.vides, 2);
    expect(a.doublons.map((d) => d.toString()), [
      'Ligne 7 : même personne qu’à la ligne 3',
      'Ligne 12 : déjà enregistré dans l’école',
    ]);
    expect(a.erreurs.map((e) => e.toString()), [
      'Ligne 8 : le nom manque',
      e9,
      e10,
      'Ligne 11 : sexe « X » non reconnu (F ou G)',
    ]);
    expect(a.colonnesIgnorees, ['X']);
    expect(a.valides.first['numero'], '1', reason: 'reprise registre papier');
  });

  test('colonne obligatoire absente : message clair', () {
    expect(
      () => analyser([
        ['Nom', 'Classe'],
        ['TEST', 'CM1 A'],
      ]),
      throwsA(
        isA<TableurIllisible>().having(
          (e) => e.message,
          'message',
          contains('« Prénoms »'),
        ),
      ),
    );
  });
}
