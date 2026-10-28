import 'dart:typed_data';

import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:ecoleplus/features/documents/pdf/pdf_documents.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:ecoleplus/features/programme/domain/programme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _pointilles = '……………………';

/// Programme d'activités (B6) et bilan annuel (B7) : A4 paysage ; la case
/// d'un objectif couvre toutes ses activités (cellules fusionnées).
Future<Uint8List> pdfProgramme(PolicesPdf polices, DonneesProgramme d) {
  final doc = pw.Document(theme: polices.theme, title: d.formulaire.titre)
    ..addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape.copyWith(
          marginLeft: 30,
          marginRight: 30,
          marginTop: 26,
          marginBottom: 26,
        ),
        build: (_) => [
          enteteLongPdf(d.entete),
          pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                d.formulaire == FormulaireActivites.programme
                    ? '${d.formulaire.titrePdf} '
                          '${d.entete.anneeScolaire ?? '20…-20…'}'
                    : d.formulaire.titrePdf,
                style: const pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
          ),
          if (d.formulaire == FormulaireActivites.bilan)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  'Année scolaire : ${d.entete.anneeScolaire ?? '20…-20…'}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
            ),
          pw.SizedBox(height: 10),
          _tableau(d),
          _signatures(d),
        ],
      ),
    );
  return doc.save();
}

const _taille = 8.5;
const _style = pw.TextStyle(fontSize: _taille);
const _gras = pw.TextStyle(fontSize: _taille, fontWeight: pw.FontWeight.bold);

pw.Widget _cellule(String t, pw.TextStyle s, {bool? centre}) =>
    caseTableau(t, s, centre: centre);

/// Colonnes des activités (à droite de « N° » et « Objectifs ») et leurs
/// largeurs relatives.
List<(String, double)> _colonnes(FormulaireActivites f) => switch (f) {
  FormulaireActivites.programme => const [
    ('Activités prévues', 3),
    ('Échéances', 1.4),
    ('Contrainte de réalisation', 2),
    ('Résultats attendus', 2.6),
  ],
  FormulaireActivites.bilan => const [
    ('Activités prévues', 3),
    ('Résultats attendus', 2.4),
    ('Résultats atteints', 2.4),
    ('Taux de réussite (%)', 1.2),
  ],
};

List<String> _valeurs(FormulaireActivites f, ActiviteProgramme a) =>
    switch (f) {
      FormulaireActivites.programme => [
        a.activite,
        a.echeance,
        a.contrainte ?? '',
        a.attendu ?? '',
      ],
      FormulaireActivites.bilan => [
        a.activite,
        a.attendu ?? '',
        a.atteint ?? '',
        texteTaux(a.taux),
      ],
    };

/// Colonnes toujours centrées : échéances (dates) et taux.
bool _colonneCentree(FormulaireActivites f, int i) => switch (f) {
  FormulaireActivites.programme => i == 1,
  FormulaireActivites.bilan => i == 3,
};

/// Petit tableau des activités d'un objectif, sans bord extérieur (le
/// grand tableau le dessine) : ses colonnes s'alignent sur l'en-tête.
pw.Widget _interieur(
  List<(String, double)> colonnes,
  List<(List<pw.Widget>, pw.BoxDecoration?)> lignes,
) => pw.Table(
  border: const pw.TableBorder(
    horizontalInside: traitInterieur,
    verticalInside: traitInterieur,
  ),
  columnWidths: {
    for (final (i, c) in colonnes.indexed) i: pw.FlexColumnWidth(c.$2),
  },
  children: [
    for (final (cases, fond) in lignes)
      pw.TableRow(
        decoration: fond,
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: cases,
      ),
  ],
);

pw.Widget _tableau(DonneesProgramme d) {
  final f = d.formulaire;
  final colonnes = _colonnes(f);
  pw.Widget activites(ObjectifProgramme o) => _interieur(colonnes, [
    for (final a in o.activites)
      (
        [
          for (final (i, v) in _valeurs(f, a).indexed)
            _cellule(v, _style, centre: _colonneCentree(f, i) ? true : null),
        ],
        null,
      ),
    if (o.activites.isEmpty)
      ([for (final _ in colonnes) _cellule('', _style)], null),
    if (f == FormulaireActivites.bilan && d.moyenneParObjectif)
      (
        [
          _cellule('', _style),
          _cellule('', _style),
          _cellule('Moyenne de l’objectif', _gras, centre: false),
          _cellule(texteTaux(o.tauxMoyen), _gras, centre: true),
        ],
        fondEntete,
      ),
  ]);

  return pw.Table(
    border: bordureTableau(),
    columnWidths: const {
      0: pw.FixedColumnWidth(36),
      1: pw.FlexColumnWidth(2.4),
      2: pw.FlexColumnWidth(9),
    },
    children: [
      pw.TableRow(
        repeat: true,
        decoration: fondEntete,
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          _cellule('N° d’ordre', _gras, centre: true),
          _cellule('Objectifs', _gras, centre: true),
          _interieur(colonnes, [
            (
              [for (final c in colonnes) _cellule(c.$1, _gras, centre: true)],
              null,
            ),
          ]),
        ],
      ),
      for (final (i, o) in d.objectifs.indexed)
        pw.TableRow(
          decoration: fondLigne(i),
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            _cellule('${i + 1}', _style, centre: true),
            _cellule(o.libelle, _style, centre: false),
            activites(o),
          ],
        ),
    ],
  );
}

/// « Fait à … le … », le directeur (nom, signature, cachet) et
/// l'inspecteur, chef de la circonscription (espace laissé vide).
pw.Widget _signatures(DonneesProgramme d) {
  const souligne = pw.TextStyle(
    fontSize: 10.5,
    decoration: pw.TextDecoration.underline,
  );
  final s = d.signataire;
  final lieu = (d.faitA?.trim().isEmpty ?? true) ? _pointilles : d.faitA!;
  final date = d.faitLe == null ? _pointilles : jjmmaaaa(d.faitLe);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 12),
    child: pw.Column(
      children: [
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Fait à $lieu, le $date',
            style: const pw.TextStyle(fontSize: 10.5),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Text(s.titreSignature, style: souligne),
                  pw.Text(
                    '(Nom, signature et cachet)',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 46),
                  pw.Text(s.nom ?? _pointilles, style: souligne),
                  if (s.grade != null)
                    pw.Text(s.grade!, style: const pw.TextStyle(fontSize: 9.5)),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Text(
                    'L’Inspecteur, chef de la circonscription',
                    style: souligne,
                  ),
                  pw.SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
