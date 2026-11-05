import 'dart:typed_data';

import 'package:ecoleplus/features/assistant/data/assistant_api.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Fiche de l'assistant en PDF (A4), avec ses sources.
Future<Uint8List> pdfFicheIa(
  PolicesPdf polices, {
  required String ecole,
  required String auteur,
  required String date,
  required FicheIa fiche,
  required List<SourceIa> sources,
}) {
  const gras = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11);
  const normal = pw.TextStyle(fontSize: 10.5, lineSpacing: 2);
  final doc = pw.Document(theme: polices.theme)
    ..addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (c) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '$ecole — $auteur — $date — page ${c.pageNumber}/${c.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ),
        build: (_) => [
          pw.Text(ecole.toUpperCase(), style: gras),
          pw.SizedBox(height: 6),
          pw.Text(fiche.titre, style: gras.copyWith(fontSize: 16)),
          pw.SizedBox(height: 10),
          for (final s in fiche.sections) ...[
            pw.Text(s.titre, style: gras.copyWith(fontSize: 12)),
            pw.SizedBox(height: 3),
            pw.Text(s.contenu, style: normal),
            pw.SizedBox(height: 9),
          ],
          pw.Divider(color: PdfColors.grey500),
          pw.Text(
            sources.isEmpty
                ? 'Non issu de vos documents.'
                : 'Sources utilisées : '
                      '${sources.map((s) => s.libelle).join(' ; ')}.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            'Proposition de l’assistant IA, relue et modifiée par '
            'l’enseignant.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  return doc.save();
}
