import 'dart:typed_data';

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
  pw.Widget cellule(String t, pw.TextStyle s, {bool gauche = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.all(2.5),
        child: pw.Text(
          t,
          style: s,
          textAlign: gauche ? pw.TextAlign.left : pw.TextAlign.center,
        ),
      );
  final nb = tableau.entete.length;
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
            border: pw.TableBorder.all(width: 0.6),
            columnWidths: {
              0: const pw.FixedColumnWidth(58),
              1: const pw.FlexColumnWidth(3),
              for (var i = 2; i < nb - 1; i++) i: const pw.FlexColumnWidth(),
              nb - 1: const pw.FlexColumnWidth(1.4),
            },
            children: [
              pw.TableRow(
                repeat: true,
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [for (final e in tableau.entete) cellule(e, gras)],
              ),
              for (final l in tableau.lignes)
                pw.TableRow(
                  children: [
                    for (final (i, v) in l.indexed)
                      cellule(
                        v == null && i == nb - 1 ? '' : caseTexte(v),
                        i == nb - 2 ? gras : style,
                        gauche: i == 1,
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
