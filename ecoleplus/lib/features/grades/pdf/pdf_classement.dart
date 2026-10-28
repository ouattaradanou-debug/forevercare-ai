import 'dart:typed_data';

import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:ecoleplus/features/grades/domain/tableau_classement.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Classement d'une classe (une composition ou le cumul), A4 paysage.
Future<Uint8List> pdfClassement(
  PolicesPdf polices, {
  required String ecole,
  required String classe,
  required String annee,
  required String periode,
  required TableauClassement tableau,
  required List<String> statistiques,
}) {
  const taille = 8.0;
  const style = pw.TextStyle(fontSize: taille);
  const gras = pw.TextStyle(fontSize: taille, fontWeight: pw.FontWeight.bold);
  final nb = tableau.entete.length;
  // Mention absente : case vide (pas de tiret).
  String texte(int i, Object? v) =>
      v == null && i == nb - 1 ? '' : caseTexte(v);
  final textes = [
    for (final l in tableau.lignes)
      [for (final (i, v) in l.indexed) texte(i, v)],
  ];
  final centrees = colonnesCentrees(textes, nb);
  final doc = pw.Document(theme: polices.theme, title: 'Classement $classe')
    ..addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape.copyWith(
          marginLeft: 22,
          marginRight: 22,
          marginTop: 22,
          marginBottom: 22,
        ),
        footer: (c) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Classement — $classe — $periode',
              style: const pw.TextStyle(fontSize: 7),
            ),
            pw.Text(
              'Page ${c.pageNumber}/${c.pagesCount}',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ],
        ),
        build: (c) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [pw.Text(ecole), pw.Text('Année scolaire $annee')],
          ),
          pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Text(
                'CLASSEMENT — $classe — $periode',
                style: const pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.Table(
            border: bordureTableau(),
            columnWidths: {
              0: const pw.FixedColumnWidth(58),
              1: const pw.FlexColumnWidth(3),
              for (var i = 2; i < nb - 1; i++) i: const pw.FlexColumnWidth(),
              nb - 1: const pw.FlexColumnWidth(1.4),
            },
            children: [
              ligneEntete(tableau.entete, gras),
              for (final (k, l) in textes.indexed)
                pw.TableRow(
                  decoration: fondLigne(k),
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    for (final (i, v) in l.indexed)
                      caseTableau(
                        v,
                        i == nb - 2 ? gras : style,
                        centre: centrees[i] || valeurCourte(v),
                      ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 8),
          for (final s in statistiques)
            pw.Text(s, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  return doc.save();
}
