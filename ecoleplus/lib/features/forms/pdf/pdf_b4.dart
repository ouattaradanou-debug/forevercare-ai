import 'dart:typed_data';

import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:ecoleplus/features/forms/domain/fiche_scolarite.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _pointilles = '……………………';
const _petit = pw.TextStyle(fontSize: 7.5);
const _normal = pw.TextStyle(fontSize: 9);
const _gras = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);

final PdfPageFormat _paysage = PdfPageFormat.a4.landscape.copyWith(
  marginLeft: 24,
  marginRight: 24,
  marginTop: 20,
  marginBottom: 20,
);

/// B4 — Fiche de scolarité (A4 paysage) : page 1 pour l'école, page 2 avec
/// les blocs de suite pour les établissements suivants (mutation).
Future<Uint8List> pdfB4(PolicesPdf polices, FicheScolarite f) {
  final doc = pw.Document(theme: polices.theme, title: 'Fiche de scolarité')
    ..addPage(pw.Page(pageFormat: _paysage, build: (_) => _premierePage(f)))
    ..addPage(pw.Page(pageFormat: _paysage, build: (_) => _suite(f)));
  return doc.save();
}

String _ou(String? v) => v == null || v.trim().isEmpty ? _pointilles : v;

pw.Widget _champ(String libelle, String? valeur, {int flex = 1}) => pw.Expanded(
  flex: flex,
  child: pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(text: '$libelle : ', style: _normal),
        pw.TextSpan(text: _ou(valeur), style: _gras),
      ],
    ),
  ),
);

pw.Widget _ligne(List<pw.Widget> champs) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 3),
  child: pw.Row(children: champs),
);

pw.Widget _cellule(String t, {bool gras = false, bool gauche = false}) =>
    caseTableau(
      t,
      gras ? _gras : _normal,
      centre: !gauche,
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
    );

/// Tableau « Cours suivis » : 6 niveaux × 2 sous-colonnes (1re année et
/// redoublement). [lignes] : titres des lignes et valeur de chaque case.
pw.Widget _coursSuivis(
  Map<(String, int), CoursSuivi> cours,
  List<(String, String Function(CoursSuivi))> lignes,
) {
  const libelle = 3;
  return pw.Column(
    children: [
      pw.Row(
        children: [
          pw.Expanded(
            flex: libelle,
            child: pw.Container(
              height: 16,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5, color: couleurTraitTableau),
                color: couleurEnteteTableau,
              ),
              child: pw.Text('Cours suivis', style: _gras),
            ),
          ),
          for (final n in niveauxB4)
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 16,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5, color: couleurTraitTableau),
                  color: couleurEnteteTableau,
                ),
                child: pw.Text(libellesNiveauxB4[n]!, style: _gras),
              ),
            ),
        ],
      ),
      pw.Table(
        border: bordureTableau(),
        columnWidths: {
          0: const pw.FlexColumnWidth(libelle * 1.0),
          for (var i = 1; i <= 12; i++) i: const pw.FlexColumnWidth(),
        },
        children: [
          for (final (k, (titre, valeur)) in lignes.indexed)
            pw.TableRow(
              decoration: fondLigne(k),
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                _cellule(titre, gras: true, gauche: true),
                for (final n in niveauxB4)
                  for (final e in const [1, 2])
                    _cellule(switch (cours[(n, e)]) {
                      final c? => valeur(c),
                      null => '',
                    }),
              ],
            ),
        ],
      ),
    ],
  );
}

String _date(CoursSuivi c) {
  final d = c.date;
  if (d == null || d.length < 10) return '';
  return '${d.substring(8, 10)}/${d.substring(5, 7)}/${d.substring(0, 4)}';
}

pw.Widget _cadre(String titre, String? texte, {double hauteur = 34}) =>
    pw.Container(
      width: double.infinity,
      constraints: pw.BoxConstraints(minHeight: hauteur),
      margin: const pw.EdgeInsets.only(top: 4),
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titre, style: _gras),
          if (texte != null && texte.trim().isNotEmpty)
            pw.Text(texte, style: _normal),
        ],
      ),
    );

pw.Widget _premierePage(FicheScolarite f) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [for (final l in f.entete) pw.Text(l, style: _petit)],
        ),
        pw.Column(
          children: [
            pw.Text(f.pays, style: _gras),
            if (f.devise != null) pw.Text(f.devise!, style: _petit),
          ],
        ),
      ],
    ),
    pw.SizedBox(height: 4),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          'FICHE DE SCOLARITÉ',
          style: const pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (f.copieConforme) ...[
          pw.SizedBox(width: 16),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.2)),
            child: pw.Text('COPIE CONFORME', style: _gras),
          ),
        ],
      ],
    ),
    pw.SizedBox(height: 6),
    _ligne([_champ('Nom', f.nom, flex: 3), _champ('Sexe', f.sexe)]),
    _ligne([
      _champ('né(e) le', f.neLe, flex: 2),
      _champ('à', f.lieuNaissance, flex: 2),
    ]),
    _ligne([
      _champ('Fils ou fille de', f.pere, flex: 2),
      _champ('Profession', f.professionPere, flex: 2),
    ]),
    _ligne([
      _champ('et de', f.mere, flex: 2),
      _champ('Profession', f.professionMere, flex: 2),
    ]),
    _ligne([_champ('Domicilié(e) à', f.domicile)]),
    if (f.raceReligion)
      _ligne([_champ('Race', f.race), _champ('Religion', f.religion)]),
    _ligne([_champ('N° Mle', f.matricule), _champ('École', f.ecole, flex: 3)]),
    _ligne([_champ('Nom et adresse du logeur (Père ou Tuteur)', f.logeur)]),
    _ligne([
      _champ('Entré le', f.entreLe),
      _champ('Venant de', f.venantDe, flex: 3),
    ]),
    _ligne([
      _champ('Sorti le', f.sortiLe),
      _champ('allant à', f.allantA, flex: 3),
    ]),
    _ligne([_champ('Motif du départ', f.motifDepart)]),
    pw.SizedBox(height: 4),
    _coursSuivis(f.cours, [
      ('Date', _date),
      ('Moyenne générale', (c) => c.moyenneTexte),
      ('Classement (1)', (c) => c.classement),
    ]),
    pw.Text(
      '(1) Le classement s’écrit sous forme de fraction (exemple : 7e/39). '
      'Pour chaque cours, la seconde colonne sert en cas de redoublement.',
      style: _petit,
    ),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _cadre('Diplômes obtenus et date d’obtention', f.diplomes),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(child: _cadre('Observations du Directeur', f.observations)),
        pw.SizedBox(width: 6),
        pw.Expanded(child: _cadre('Signature du Directeur', null)),
      ],
    ),
    pw.Spacer(),
    if (f.copieConforme)
      pw.Text(
        'Copie conforme à l’original, délivrée le '
        '${f.dateCopie ?? _pointilles}. '
        'Le Directeur.',
        style: _gras,
      ),
    for (final o in observationsGeneralesB4) pw.Text(o, style: _petit),
  ],
);

/// Blocs de suite : remplis à la main par les établissements suivants.
pw.Widget _suite(FicheScolarite f) {
  pw.Widget bloc(int n) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    padding: const pw.EdgeInsets.all(6),
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8)),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Établissement suivant n° $n', style: _gras),
        pw.SizedBox(height: 3),
        _ligne([_champ('N° Mle', null), _champ('École', null, flex: 3)]),
        _ligne([_champ('Nom et adresse du logeur (Père ou Tuteur)', null)]),
        _ligne([_champ('Entré le', null), _champ('Venant de', null, flex: 3)]),
        _ligne([_champ('Sorti le', null), _champ('allant à', null, flex: 3)]),
        _ligne([_champ('Motif du départ', null)]),
        _coursSuivis(const {}, [
          ('Date', (_) => ''),
          ('Classement', (_) => ''),
        ]),
        pw.Row(
          children: [
            pw.Expanded(
              child: _cadre(
                'Diplômes obtenus et date d’obtention',
                null,
                hauteur: 24,
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: _cadre('Observations du Directeur', null, hauteur: 24),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: _cadre('Signature du Directeur', null, hauteur: 24),
            ),
          ],
        ),
      ],
    ),
  );
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('FICHE DE SCOLARITÉ — ${f.nom} (suite)', style: _gras),
      pw.SizedBox(height: 6),
      bloc(1),
      bloc(2),
    ],
  );
}
