import 'dart:typed_data';

import 'package:ecoleplus/features/cartes/domain/carte_scolaire.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Cartes scolaires : planches A4 de 10 cartes au format carte bancaire
/// (85,6 × 54 mm), recto puis verso (colonnes inversées pour une
/// impression recto-verso retournée sur le grand côté). Imprimer à
/// l'échelle réelle (100 %, sans « ajuster à la page »).
Future<Uint8List> pdfCartes(
  PolicesPdf polices,
  EcoleCarte ecole,
  List<CarteScolaire> cartes,
) {
  final doc = pw.Document(theme: polices.theme, title: 'Cartes scolaires');
  final logo = ecole.logo == null ? null : pw.MemoryImage(ecole.logo!);
  for (var debut = 0; debut < cartes.length; debut += cartesParPlanche) {
    final planche = cartes.sublist(
      debut,
      debut + cartesParPlanche > cartes.length
          ? cartes.length
          : debut + cartesParPlanche,
    );
    for (final verso in [false, true]) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Stack(
            children: [
              for (final (i, c) in planche.indexed)
                () {
                  final pos = positionCarte(i, verso: verso);
                  return pw.Positioned(
                    left: pos.x * PdfPageFormat.mm,
                    top: pos.y * PdfPageFormat.mm,
                    child: pw.SizedBox(
                      width: largeurCarteMm * PdfPageFormat.mm,
                      height: hauteurCarteMm * PdfPageFormat.mm,
                      child: verso ? _verso(ecole, c) : _recto(ecole, logo, c),
                    ),
                  );
                }(),
            ],
          ),
        ),
      );
    }
  }
  return doc.save();
}

const _gris = PdfColor.fromInt(0xFF9AA4AE);

pw.BoxDecoration get _cadreCoupe => pw.BoxDecoration(
  border: pw.Border.all(color: _gris, width: 0.4),
  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
  color: PdfColors.white,
);

pw.Widget _recto(EcoleCarte e, pw.MemoryImage? logo, CarteScolaire c) {
  final couleur = PdfColor.fromInt(e.couleurArgb);
  const etiquette = pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700);
  pw.Widget champ(
    String l,
    String v, {
    double taille = 7.5,
    bool gras = false,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(l, style: etiquette),
        pw.Text(
          v,
          maxLines: 1,
          style: pw.TextStyle(
            fontSize: taille,
            fontWeight: gras ? pw.FontWeight.bold : null,
          ),
        ),
      ],
    ),
  );
  return pw.Container(
    decoration: _cadreCoupe,
    child: pw.ClipRRect(
      horizontalRadius: 6,
      verticalRadius: 6,
      child: pw.Column(
        children: [
          // Bandeau : logo, école, commune ; « CARTE SCOLAIRE », année.
          pw.Container(
            height: 30,
            color: couleur,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6),
            child: pw.Row(
              children: [
                if (logo != null)
                  pw.Container(
                    width: 22,
                    height: 22,
                    margin: const pw.EdgeInsets.only(right: 5),
                    color: PdfColors.white,
                    child: pw.Image(logo),
                  ),
                pw.Expanded(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        c.ecole,
                        maxLines: 2,
                        style: const pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      if (c.commune != null)
                        pw.Text(
                          c.commune!,
                          style: const pw.TextStyle(
                            fontSize: 5.5,
                            color: PdfColors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'CARTE SCOLAIRE',
                      style: const pw.TextStyle(
                        fontSize: 6.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      c.annee,
                      style: const pw.TextStyle(
                        fontSize: 6,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(6, 5, 6, 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Photo 3:4 (19 × 25 mm environ).
                  pw.Container(
                    width: 54,
                    height: 72,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: _gris, width: 0.5),
                    ),
                    child: c.photo != null
                        ? pw.Image(
                            pw.MemoryImage(c.photo!),
                            fit: pw.BoxFit.cover,
                          )
                        : pw.Center(
                            child: pw.Text(
                              'PHOTO',
                              style: const pw.TextStyle(
                                fontSize: 6,
                                color: PdfColors.grey500,
                              ),
                            ),
                          ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        champ('Nom', c.nom, taille: 8.5, gras: true),
                        champ('Prénom(s)', c.prenoms, taille: 8),
                        champ('Classe', c.classe),
                        champ('Identifiant', c.identifiant),
                      ],
                    ),
                  ),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: c.contenuQr,
                        width: 46,
                        height: 46,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Widget _verso(EcoleCarte e, CarteScolaire c) {
  final couleur = PdfColor.fromInt(e.couleurArgb);
  const petit = pw.TextStyle(fontSize: 6.5);
  return pw.Container(
    decoration: _cadreCoupe,
    padding: const pw.EdgeInsets.all(7),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          e.nom,
          maxLines: 2,
          style: pw.TextStyle(
            fontSize: 7.5,
            fontWeight: pw.FontWeight.bold,
            color: couleur,
          ),
        ),
        if (e.adresse != null || e.commune != null)
          pw.Text([?e.adresse, ?e.commune].join(' — '), style: petit),
        if (e.telephone != null) pw.Text('Tél. : ${e.telephone}', style: petit),
        if (e.email != null) pw.Text(e.email!, style: petit),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.all(3),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: couleur, width: 0.6),
          ),
          child: pw.Text(
            'Si cette carte est trouvée, merci de contacter l’école'
            '${e.telephone == null ? '' : ' au ${e.telephone}'}.',
            style: const pw.TextStyle(fontSize: 6.5),
          ),
        ),
        pw.Spacer(),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Text(
                'Année scolaire ${c.annee}',
                style: const pw.TextStyle(
                  fontSize: 6,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            // Cachet et signature : à la main.
            pw.Container(
              width: 92,
              height: 40,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _gris, width: 0.5),
              ),
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                'Cachet et signature du directeur',
                style: const pw.TextStyle(
                  fontSize: 5,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
