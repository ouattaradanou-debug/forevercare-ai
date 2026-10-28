import 'dart:io';

import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/maternelle/domain/maternelle.dart';
import 'package:ecoleplus/features/maternelle/pdf/pdf_livret.dart';
import 'package:flutter_test/flutter_test.dart';

import 'documents_directeur_test.dart' show entete, polices, texteDuPdf;

const niveaux = [
  NiveauQualitatif(
    id: 'n1',
    code: 'acquis',
    libelle: 'Acquis',
    couleur: '#2E7D32',
    pictogramme: 'plein',
  ),
  NiveauQualitatif(
    id: 'n2',
    code: 'en_cours',
    libelle: 'En cours d’acquisition',
    couleur: '#E68A00',
    pictogramme: 'moitie',
  ),
  NiveauQualitatif(
    id: 'n3',
    code: 'non_acquis',
    libelle: 'Non acquis',
    couleur: '#C62828',
    pictogramme: 'vide',
  ),
];

LivretMaternelle livret({int? rang}) => LivretMaternelle(
  entete: entete,
  classe: 'GS A',
  periode: '1er trimestre',
  enfant: 'TEST Awa',
  sexe: 'F',
  neLe: '12/03/2020',
  lignes: [
    for (final (i, d) in domainesParDefaut.indexed)
      LigneLivret(d, i == 5 ? null : niveaux[i % 3]),
  ],
  niveaux: niveaux,
  appreciation: 'Awa participe avec plaisir.',
  observation: 'Bon trimestre.',
  absences: 2,
  retards: 1,
  rang: rang,
  effectif: rang == null ? null : 12,
  signataire: const Signataire(civilite: 'madame', nom: 'OUEDRAOGO Awa'),
  enseignant: 'ENSEIGNANT Deux',
);

void main() {
  test('niveaux par défaut : 3, chacun avec couleur ET pictogramme', () {
    expect(niveauxParDefaut, hasLength(3));
    expect(
      {for (final n in niveauxParDefaut) n.pictogramme},
      hasLength(3),
      reason: 'lisibles sans la couleur',
    );
    expect(niveauxParDefaut.first.couleurArgb, 0xFF2E7D32);
    expect(Pictogramme.depuis('moitie'), Pictogramme.moitie);
    expect(Pictogramme.depuis('inconnu'), Pictogramme.plein);
  });

  test('classement facultatif : score moyen, ex-aequo, non évalué non '
      'classé', () {
    expect(
      classerEnfants({
        'a': [2, 2, 1],
        'b': [2, 1, 2],
        'c': [0, 1],
        'd': [],
      }),
      {'a': 1, 'b': 1, 'c': 3},
    );
    expect(pointsNiveau(0, 3), 2);
    expect(pointsNiveau(2, 3), 0);
    expect(texteRang(1, 12), '1er/12');
  });

  test('livret PDF : domaines, niveaux, appréciation, observation, '
      'présences ; aucune note chiffrée ; rang seulement si activé', () async {
    final pdf = await pdfLivrets(polices(), [livret()]);
    if (Platform.environment['PDF_SORTIE'] case final dossier?) {
      File('$dossier/livret.pdf').writeAsBytesSync(pdf);
    }
    final t = texteDuPdf(pdf);
    if (t == null) return;
    for (final x in [
      'LIVRET D’ÉVALUATION — MATERNELLE',
      '1er trimestre',
      'TEST Awa',
      'GS A',
      'Domaines d’apprentissage',
      'Graphisme et préécriture',
      'Acquis',
      'En cours d’acquisition',
      'Non acquis',
      'Awa participe avec plaisir.',
      'Bon trimestre.',
      '2 absence(s), 1 retard(s)',
      'La Directrice',
      'Les parents',
      '5 domaine(s) évalué(s) sur 6',
    ]) {
      expect(t, contains(x));
    }
    expect(t, isNot(contains('Rang')));
    expect(t, isNot(matches(RegExp(r'\d+([.,]\d+)?\s*/\s*(10|20)\b'))));
    final avecRang = texteDuPdf(await pdfLivrets(polices(), [livret(rang: 1)]));
    expect(avecRang, contains('Rang : 1er/12'));
  });
}
