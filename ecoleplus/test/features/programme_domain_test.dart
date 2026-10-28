import 'dart:convert';
import 'dart:io';

import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/programme/domain/programme.dart';
import 'package:ecoleplus/features/programme/pdf/pdf_programme.dart';
import 'package:flutter_test/flutter_test.dart';

import 'documents_directeur_test.dart' show entete, polices, texteDuPdf;

/// 14 objectifs (critère du GO de la phase 5), 2 activités chacun.
List<ObjectifProgramme> quatorze() => [
  for (var i = 1; i <= 14; i++)
    ObjectifProgramme(
      libelle: 'Objectif numéro $i',
      activites: [
        for (var j = 1; j <= 2; j++)
          ActiviteProgramme(
            activite: 'Activité $i.$j',
            echeanceDate: '2026-0${j + 1}-15',
            echeanceTexte: j == 2 ? 'Toute l’année' : null,
            contrainte: 'Contrainte $i.$j',
            attendu: 'Attendu $i.$j',
            atteint: 'Atteint $i.$j',
            taux: j == 1 ? 100 : 66.666,
          ),
      ],
    ),
];

void main() {
  test('taux : saisie et affichage (0 à 100, deux décimales)', () {
    expect(lireTaux('75'), 75);
    expect(lireTaux('66,666'), 66.67);
    expect(lireTaux(' 80 % '), 80);
    expect(lireTaux(''), isNull);
    expect(() => lireTaux('120'), throwsFormatException);
    expect(() => lireTaux('abc'), throwsFormatException);
    expect(texteTaux(66.666), '66,67');
    expect(texteTaux(100), '100');
    expect(texteTaux(12.5), '12,5');
    expect(texteTaux(null), '');
  });

  test('moyenne de l’objectif : taux renseignés seulement', () {
    const o = ObjectifProgramme(
      libelle: 'O',
      activites: [
        ActiviteProgramme(activite: 'a', taux: 100),
        ActiviteProgramme(activite: 'b', taux: 50),
        ActiviteProgramme(activite: 'c'),
      ],
    );
    expect(o.tauxMoyen, 75);
    expect(
      const ObjectifProgramme(libelle: 'O', activites: []).tauxMoyen,
      isNull,
    );
  });

  test('échéance : le texte l’emporte sur la date', () {
    expect(
      const ActiviteProgramme(
        activite: 'a',
        echeanceDate: '2026-03-15',
      ).echeance,
      '15/03/2026',
    );
    expect(
      const ActiviteProgramme(
        activite: 'a',
        echeanceDate: '2026-03-15',
        echeanceTexte: '1er trimestre',
      ).echeance,
      '1er trimestre',
    );
  });

  test('propositions du modèle : modifiables, retrouvées sans accents', () {
    expect(
      suggestionsPour('GERER rationnellement les ressources'),
      contains('Répartition des enseignants dans les classes'),
    );
    expect(suggestionsPour('Objectif libre'), isEmpty);
  });

  test('instantané d’une version : relu à l’identique', () {
    final d = DonneesProgramme(
      formulaire: FormulaireActivites.bilan,
      entete: entete,
      objectifs: quatorze(),
      signataire: const Signataire(civilite: 'madame', nom: 'OUEDRAOGO Awa'),
      faitA: 'Ziniaré',
      faitLe: '2026-06-30',
      moyenneParObjectif: true,
    );
    final relu = DonneesProgramme.depuisJson(
      jsonDecode(jsonEncode(d.versJson())) as Map<String, dynamic>,
    );
    expect(jsonEncode(relu.versJson()), jsonEncode(d.versJson()));
  });

  test('PDF B6 : 14 objectifs, colonnes du modèle, A4 paysage', () async {
    final d = DonneesProgramme(
      formulaire: FormulaireActivites.programme,
      entete: entete,
      objectifs: quatorze(),
      signataire: const Signataire(
        civilite: 'monsieur',
        nom: 'SAWADOGO Paul',
        grade: 'Inspecteur',
      ),
      faitA: 'Ziniaré',
      faitLe: '2025-10-20',
    );
    final pdf = await pdfProgramme(polices(), d);
    if (Platform.environment['PDF_SORTIE'] case final dossier?) {
      File('$dossier/B6.pdf').writeAsBytesSync(pdf);
    }
    final t = texteDuPdf(pdf);
    if (t == null) return;
    for (final attendu in [
      'PROGRAMME D’ACTIVITÉS AU TITRE DE L’ANNÉE SCOLAIRE 2025-2026',
      'N° d’ordre',
      'Objectifs',
      'Activités prévues',
      'Échéances',
      'Contrainte de réalisation',
      'Résultats attendus',
      'Objectif numéro 14',
      'Activité 14.2',
      'Toute l’année',
      '15/02/2026',
      'Fait à Ziniaré, le 20/10/2025',
      'Le Directeur',
      'SAWADOGO Paul',
      'L’Inspecteur, chef de la circonscription',
    ]) {
      expect(t, contains(attendu));
    }
    expect(t, isNot(contains('Résultats atteints')));
  });

  test('PDF B7 : mêmes lignes, résultats, taux et moyenne', () async {
    final d = DonneesProgramme(
      formulaire: FormulaireActivites.bilan,
      entete: entete,
      objectifs: quatorze(),
      moyenneParObjectif: true,
    );
    final pdf = await pdfProgramme(polices(), d);
    if (Platform.environment['PDF_SORTIE'] case final dossier?) {
      File('$dossier/B7.pdf').writeAsBytesSync(pdf);
    }
    final t = texteDuPdf(pdf);
    if (t == null) return;
    for (final attendu in [
      'BILAN DE PROGRAMME ANNUEL D’ACTIVITÉS',
      'Année scolaire : 2025-2026',
      'Résultats atteints',
      'Taux de réussite (%)',
      'Attendu 14.2',
      'Atteint 14.2',
      '66,67',
      'Moyenne de l’objectif',
      '83,33',
    ]) {
      expect(t, contains(attendu));
    }
    expect(t, isNot(contains('Contrainte de réalisation')));
  });
}
