import 'dart:math' as math;
import 'dart:typed_data';

import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:ecoleplus/features/documents/pdf/pdf_documents.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:ecoleplus/features/maternelle/domain/maternelle.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Livret d'évaluation de maternelle (A4 portrait, une page par enfant) :
/// domaines en lignes, niveaux en colonnes ; le niveau atteint est marqué de
/// son pictogramme en couleur. Aucune note chiffrée.
Future<Uint8List> pdfLivrets(PolicesPdf polices, List<LivretMaternelle> l) {
  final doc = pw.Document(theme: polices.theme, title: 'Livret d’évaluation');
  for (final livret in l) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 36,
          marginRight: 36,
          marginTop: 30,
          marginBottom: 30,
        ),
        build: (_) => _page(livret),
      ),
    );
  }
  return doc.save();
}

const _normal = pw.TextStyle(fontSize: 10);
const _gras = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
const _petit = pw.TextStyle(fontSize: 8, color: PdfColors.grey700);

/// Pictogramme dessiné (rond plein, demi-rond, rond vide, étoile).
pw.Widget pictogrammePdf(NiveauQualitatif n, {double taille = 11}) {
  final couleur = PdfColor.fromInt(n.couleurArgb);
  return pw.CustomPaint(
    size: PdfPoint(taille, taille),
    painter: (canvas, size) {
      final r = size.x / 2 - 0.6;
      final cx = size.x / 2;
      final cy = size.y / 2;
      canvas
        ..setStrokeColor(couleur)
        ..setFillColor(couleur)
        ..setLineWidth(1.1);
      switch (Pictogramme.depuis(n.pictogramme)) {
        case Pictogramme.plein:
          canvas
            ..drawEllipse(cx, cy, r, r)
            ..fillPath();
        case Pictogramme.vide:
          canvas
            ..drawEllipse(cx, cy, r, r)
            ..strokePath();
        case Pictogramme.moitie:
          canvas
            ..drawEllipse(cx, cy, r, r)
            ..strokePath()
            ..moveTo(cx, cy + r)
            ..bezierArc(cx, cy + r, r, r, cx, cy - r, sweep: true)
            ..closePath()
            ..fillPath();
        case Pictogramme.etoile:
          for (var i = 0; i < 10; i++) {
            final a = math.pi / 2 + i * math.pi / 5;
            final rayon = i.isEven ? r : r * 0.45;
            final x = cx + rayon * math.cos(a);
            final y = cy + rayon * math.sin(a);
            i == 0 ? canvas.moveTo(x, y) : canvas.lineTo(x, y);
          }
          canvas
            ..closePath()
            ..fillPath();
      }
    },
  );
}

pw.Widget _cadre(String titre, String? texte, {double hauteur = 54}) =>
    pw.Container(
      width: double.infinity,
      constraints: pw.BoxConstraints(minHeight: hauteur),
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5, color: couleurTraitTableau),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titre, style: _gras),
          if (texte != null && texte.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text(texte, style: _normal),
            ),
        ],
      ),
    );

pw.Widget _page(LivretMaternelle l) {
  final niveaux = l.niveaux;
  final evalues = l.lignes.where((x) => x.niveau != null).length;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      enteteLongPdf(l.entete),
      pw.SizedBox(height: 10),
      pw.Center(
        child: pw.Text(
          'LIVRET D’ÉVALUATION — MATERNELLE',
          style: const pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
        ),
      ),
      pw.Center(
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3, bottom: 10),
          child: pw.Text(
            '${l.periode} — année scolaire '
            '${l.entete.anneeScolaire ?? '20…-20…'}',
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.5, color: couleurTraitTableau),
          color: couleurLigneAlternee,
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Enfant : ${l.enfant}', style: _gras),
                pw.Text(
                  [
                    if (l.sexe == 'F') 'Fille',
                    if (l.sexe == 'M') 'Garçon',
                    if (l.neLe != null) 'né(e) le ${l.neLe}',
                  ].join(' · '),
                  style: _normal,
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Classe : ${l.classe}', style: _gras),
                if (l.enseignant != null)
                  pw.Text('Enseignant(e) : ${l.enseignant}', style: _normal),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Table(
        border: bordureTableau(),
        columnWidths: {
          0: const pw.FlexColumnWidth(3),
          for (var i = 1; i <= niveaux.length; i++)
            i: const pw.FlexColumnWidth(1.3),
        },
        children: [
          pw.TableRow(
            decoration: fondEntete,
            verticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              caseTableau('Domaines d’apprentissage', _gras, centre: true),
              for (final n in niveaux)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Column(
                    children: [
                      pictogrammePdf(n),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        n.libelle,
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(n.couleurArgb),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          for (final (i, ligne) in l.lignes.indexed)
            pw.TableRow(
              decoration: fondLigne(i),
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                caseTableau(
                  ligne.domaine,
                  _normal,
                  centre: false,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 7,
                  ),
                ),
                for (final n in niveaux)
                  pw.Center(
                    child: ligne.niveau?.id == n.id
                        ? pictogrammePdf(n, taille: 14)
                        : pw.SizedBox(),
                  ),
              ],
            ),
        ],
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 4),
        child: pw.Text(
          '$evalues domaine(s) évalué(s) sur ${l.lignes.length}. '
          'Évaluation sans note chiffrée.',
          style: _petit,
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        [
          'Présences : ${l.absences} absence(s), ${l.retards} retard(s)',
          if (l.rang != null && l.effectif != null)
            'Rang : ${texteRang(l.rang!, l.effectif!)}',
        ].join('     '),
        style: _normal,
      ),
      _cadre('Appréciation de l’enseignant(e)', l.appreciation),
      _cadre('Observations du directeur', l.observation),
      pw.Spacer(),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          for (final s in [
            'L’enseignant(e)',
            l.signataire.titreSignature,
            'Les parents',
          ])
            pw.Column(
              children: [
                pw.Text(
                  s,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.SizedBox(height: 46),
              ],
            ),
        ],
      ),
    ],
  );
}
