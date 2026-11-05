import 'dart:typed_data';

import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:ecoleplus/features/pilotage/domain/emploi_du_temps.dart';
import 'package:ecoleplus/features/pilotage/domain/rapports.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _gras = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9);
const _normal = pw.TextStyle(fontSize: 9);

pw.Widget _tableau(
  List<String> titres,
  List<List<String>> lignes, {
  List<String>? total,
  Map<int, pw.TableColumnWidth>? largeurs,
}) {
  final centrees = colonnesCentrees(lignes, titres.length);
  return pw.Table(
    border: bordureTableau(),
    columnWidths: largeurs,
    children: [
      ligneEntete(titres, _gras),
      for (final (i, l) in lignes.indexed)
        pw.TableRow(
          decoration: fondLigne(i),
          children: [
            for (final (j, c) in l.indexed)
              caseTableau(
                c,
                _normal,
                centre: j == 0 ? false : (centrees[j] ? true : null),
              ),
          ],
        ),
      if (total != null)
        pw.TableRow(
          decoration: fondEntete,
          children: [
            for (final (j, c) in total.indexed)
              caseTableau(c, _gras, centre: j != 0),
          ],
        ),
    ],
  );
}

pw.Widget _pied(String texte, pw.Context c) => pw.Align(
  alignment: pw.Alignment.centerRight,
  child: pw.Text(
    '$texte — page ${c.pageNumber}/${c.pagesCount}',
    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
  ),
);

/// Emploi du temps d'une classe (A4 paysage) : une ligne par plage
/// horaire, une colonne par jour.
Future<Uint8List> pdfEmploiDuTemps(
  PolicesPdf polices, {
  required String ecole,
  required String annee,
  required String classe,
  required GrilleSemaine grille,
  String? enseignant,
}) {
  final doc = pw.Document(theme: polices.theme)
    ..addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        footer: (c) => _pied('$ecole — emploi du temps $classe', c),
        build: (_) => [
          pw.Text(ecole.toUpperCase(), style: _gras.copyWith(fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Emploi du temps — $classe',
            style: _gras.copyWith(fontSize: 15),
          ),
          pw.Text(
            [
              'Année scolaire $annee',
              if (enseignant != null) 'Enseignant(e) : $enseignant',
            ].join(' • '),
            style: _normal,
          ),
          pw.SizedBox(height: 10),
          if (grille.plages.isEmpty)
            pw.Text('Aucun créneau.', style: _normal)
          else
            _tableau(
              ['Heures', for (final j in grille.jours) joursSemaine[j] ?? '$j'],
              [
                for (final (i, (d, f)) in grille.plages.indexed)
                  ['$d – $f', ...grille.cases[i]],
              ],
              largeurs: {0: const pw.FixedColumnWidth(70)},
            ),
        ],
      ),
    );
  return doc.save();
}

/// Rapport automatique : en-tête de l'école, tableaux, remarques.
Future<Uint8List> pdfRapport(PolicesPdf polices, Rapport r, String edite) {
  final doc = pw.Document(theme: polices.theme)
    ..addPage(
      pw.MultiPage(
        pageFormat: r.paysage ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        footer: (c) => _pied('${r.ecole} — ${r.titre}', c),
        build: (_) => [
          pw.Text(r.ecole.toUpperCase(), style: _gras.copyWith(fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Text(r.titre, style: _gras.copyWith(fontSize: 15)),
          pw.Text(
            [
              'Année scolaire ${r.annee}',
              ?r.periode,
              'édité le $edite',
            ].join(' • '),
            style: _normal,
          ),
          for (final t in r.tableaux) ...[
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
              child: pw.Text(t.titre, style: _gras.copyWith(fontSize: 11)),
            ),
            if (t.lignes.isEmpty)
              pw.Text('Rien à signaler.', style: _normal)
            else
              _tableau(
                t.entete,
                [
                  for (final l in t.lignes) [for (final v in l) texteCase(v)],
                ],
                total: t.total == null
                    ? null
                    : [for (final v in t.total!) texteCase(v)],
              ),
          ],
          if (r.notes.isNotEmpty) pw.SizedBox(height: 10),
          for (final n in r.notes) pw.Text(n, style: _normal),
        ],
      ),
    );
  return doc.save();
}
