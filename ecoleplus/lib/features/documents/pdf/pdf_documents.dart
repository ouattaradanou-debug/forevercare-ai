import 'dart:typed_data';

import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _pointilles = '……………………………';
const _etoiles = '**********************';

/// Documents du directeur (A17). Page entière (A4 portrait) : attestation
/// de prise de service, certificat de scolarité, attestation de niveau.
/// Demi-page (A5 paysage) : certificat de non redevance, certificat de
/// scolarité court.
Future<Uint8List> pdfDocumentDirecteur(
  PolicesPdf polices,
  DocumentDirecteur d,
) {
  final demiPage =
      d.code == CodeDocument.nonRedevance ||
      (d.code == CodeDocument.certificatScolarite && d.court);
  final format = demiPage
      ? PdfPageFormat.a5.landscape.copyWith(
          marginLeft: 30,
          marginRight: 30,
          marginTop: 22,
          marginBottom: 18,
        )
      : PdfPageFormat.a4.copyWith(
          marginLeft: 48,
          marginRight: 48,
          marginTop: 40,
          marginBottom: 40,
        );
  final doc = pw.Document(theme: polices.theme, title: d.code.titre)
    ..addPage(
      pw.Page(
        pageFormat: format,
        build: (_) => switch (d.code) {
          CodeDocument.priseService => _priseService(d),
          CodeDocument.attestationNiveau => _attestationNiveau(d),
          CodeDocument.nonRedevance => _nonRedevance(d),
          CodeDocument.certificatScolarite =>
            d.court ? _certificatCourt(d) : _certificatLong(d),
        },
      ),
    );
  return doc.save();
}

// ------------------------------ Éléments ------------------------------

const _texte = pw.TextStyle(fontSize: 12, lineSpacing: 7);
const _texteCourt = pw.TextStyle(fontSize: 11, lineSpacing: 5);
const _gras = pw.TextStyle(fontWeight: pw.FontWeight.bold);

/// Texte courant : chaînes normales, valeurs en gras, valeur manquante en
/// pointillés.
pw.Widget _paragraphe(
  List<Object?> morceaux, {
  pw.TextStyle style = _texte,
  double retrait = 0,
}) => pw.Padding(
  padding: pw.EdgeInsets.only(left: retrait, bottom: 6),
  child: pw.RichText(
    textAlign: pw.TextAlign.left,
    text: pw.TextSpan(
      style: style,
      children: [
        for (final m in morceaux)
          switch (m) {
            _Valeur(:final texte) => pw.TextSpan(
              text: texte == null || texte.trim().isEmpty ? _pointilles : texte,
              style: _gras,
            ),
            final String t => pw.TextSpan(text: t),
            _ => const pw.TextSpan(text: ''),
          },
      ],
    ),
  ),
);

/// Valeur imprimée en gras (ou pointillés si absente).
class _Valeur {
  const new(this.texte);
  final String? texte;
}

_Valeur _v(String? t) => _Valeur(t);

/// Grand en-tête (ministère … école | pays, devise) : documents et B6/B7.
pw.Widget enteteLongPdf(EnteteDocument e) {
  const petit = pw.TextStyle(fontSize: 9.5);
  final lignes = e.lignesLongues;
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Expanded(
        flex: 3,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final (i, l) in lignes.indexed) ...[
              pw.Text(l, style: petit),
              if (i < lignes.length - 1)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 24, bottom: 2),
                  child: pw.Text(_etoiles, style: petit),
                ),
            ],
          ],
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        flex: 2,
        child: pw.Column(
          children: [
            pw.Text(e.pays, style: petit),
            pw.Text('*******', style: petit),
            if (e.devise != null)
              pw.Text(e.devise!, style: petit, textAlign: pw.TextAlign.center),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _enteteCourt(EnteteDocument e) {
  const petit = pw.TextStyle(fontSize: 10);
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [for (final l in e.lignesCourtes) pw.Text(l, style: petit)],
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(e.pays, style: petit),
          if (e.devise != null) pw.Text(e.devise!, style: petit),
          pw.SizedBox(height: 4),
          pw.Text(
            'Année scolaire : ${e.anneeScolaire ?? '20…/20…'}',
            style: petit,
          ),
        ],
      ),
    ],
  );
}

pw.Widget _titre(String t, {double taille = 15}) => pw.Center(
  child: pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 14),
    child: pw.Text(
      t,
      style: pw.TextStyle(
        fontSize: taille,
        fontWeight: pw.FontWeight.bold,
        decoration: pw.TextDecoration.underline,
      ),
    ),
  ),
);

/// « Fait à …, le … », « La Directrice », nom, grade.
pw.Widget _signature(
  DocumentDirecteur d, {
  bool grade = true,
  bool faitA = true,
  double espace = 48,
}) {
  final s = d.signataire;
  const souligne = pw.TextStyle(decoration: pw.TextDecoration.underline);
  return pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Column(
      children: [
        pw.Text(
          '${faitA ? 'Fait à ' : ''}${d.lieu ?? _pointilles}, le '
          '${d.date ?? _pointilles}',
        ),
        pw.SizedBox(height: 12),
        pw.Text(s.titreSignature, style: souligne),
        pw.SizedBox(height: espace),
        if (s.nom != null) pw.Text(s.nom!, style: souligne),
        if (grade && s.grade != null) pw.Text(s.grade!),
      ],
    ),
  );
}

List<Object?> _jeSoussigne(DocumentDirecteur d, {bool virgule = false}) {
  final s = d.signataire;
  return [
    'Je ${s.soussigne}${virgule ? ',' : ''} ',
    '${s.civiliteTexte} ',
    _v(s.nom),
    ', ${s.fonction} ${deLEcole(d.entete.ecole)}',
  ];
}

// ----------------------------- Documents ------------------------------

pw.Widget _priseService(DocumentDirecteur d) {
  final e = d.enseignant!;
  final a = e.accords;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      enteteLongPdf(d.entete),
      pw.SizedBox(height: 20),
      _titre('ATTESTATION DE PRISE DE SERVICE', taille: 17),
      pw.SizedBox(height: 10),
      _paragraphe([..._jeSoussigne(d, virgule: true), ','], retrait: 24),
      _paragraphe([
        'Atteste que ${a.appel} ',
        _v(e.nom),
        ', matricule ',
        _v(e.matricule),
        ', ',
        _v(e.emploi),
        ', ${a.affecte} à l’${d.entete.ecole} suivant décision N° ',
        _v(e.decisionNumero),
        ' du ',
        _v(e.decisionDate),
        ', a effectivement pris service le ',
        _v(e.priseDeService),
        '.',
      ]),
      pw.SizedBox(height: 14),
      _paragraphe([
        'En foi de quoi, la présente attestation est établie pour servir et ',
        'valoir ce que de droit.',
      ], retrait: 24),
      pw.SizedBox(height: 28),
      _signature(d),
    ],
  );
}

pw.Widget _attestationNiveau(DocumentDirecteur d) {
  final e = d.eleve!;
  final a = e.accords;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      enteteLongPdf(d.entete),
      pw.SizedBox(height: 20),
      _titre('ATTESTATION DE NIVEAU'),
      pw.SizedBox(height: 6),
      _paragraphe([
        ..._jeSoussigne(d),
        ' atteste que ',
        _v(e.nom),
        ' ${a.ne} le ',
        _v(e.neLe),
        ', ${a.filsFille} de ',
        _v(e.pere),
        ' et de ',
        _v(e.mere),
        ', a le niveau de la classe de ',
        _v(d.niveau ?? e.niveau),
        '.',
      ], retrait: 24),
      pw.SizedBox(height: 10),
      _paragraphe([
        'En foi de quoi la présente attestation lui est délivrée pour valoir ',
        'et servir ce que de droit.',
      ], retrait: 24),
      pw.SizedBox(height: 28),
      _signature(d),
    ],
  );
}

pw.Widget _certificatLong(DocumentDirecteur d) {
  final e = d.eleve!;
  final a = e.accords;
  pw.Widget ligne(
    String libelle,
    String? valeur,
    String libelle2,
    String? v2,
  ) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      children: [
        pw.Expanded(flex: 3, child: _paragraphe([libelle, _v(valeur)])),
        pw.Expanded(flex: 2, child: _paragraphe([libelle2, _v(v2)])),
      ],
    ),
  );
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      enteteLongPdf(d.entete),
      pw.SizedBox(height: 20),
      _titre('CERTIFICAT DE SCOLARITÉ', taille: 17),
      pw.SizedBox(height: 6),
      _paragraphe(_jeSoussigne(d)),
      _paragraphe(['Certifie que l’élève ', _v(e.nom)]),
      ligne('${a.filsFille} de : ', e.pere, 'Profession : ', e.professionPere),
      ligne('Et de : ', e.mere, 'Profession : ', e.professionMere),
      ligne(
        '${a.ne == 'né' ? 'Né' : (a.ne == 'née' ? 'Née' : 'Né(e)')} : ',
        e.neLe,
        'À : ',
        e.lieuNaissance,
      ),
      _paragraphe([
        'Est ${a.inscrit} au registre matricule sous le numéro ',
        _v(e.matricule),
        ' et fréquente régulièrement depuis le ',
        _v(e.entreLe),
        ' où ${a.il} est élève de la classe du ',
        _v(e.classe),
        '.',
      ]),
      pw.SizedBox(height: 28),
      _signature(d),
    ],
  );
}

pw.Widget _certificatCourt(DocumentDirecteur d) {
  final e = d.eleve!;
  final a = e.accords;
  final s = d.signataire;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _enteteCourt(d.entete),
      _titre('CERTIFICAT DE SCOLARITÉ', taille: 13),
      _paragraphe([
        '${s.titreSignature} ${deLEcole(d.entete.ecole)} ${s.soussigne} ',
        'certifie que l’élève ',
        _v(e.nom),
        ' de la classe de ',
        _v(e.classe),
        ', ${a.ne} le ',
        _v(e.neLe),
        ' à ',
        _v(e.lieuNaissance),
        ', de ',
        _v(e.pere),
        ' et de ',
        _v(e.mere),
        ', fréquente régulièrement son établissement où ${a.il} est ',
        '${a.inscrit} sous le numéro matricule ',
        _v(e.matricule),
        '.',
      ], style: _texteCourt),
      _paragraphe([
        'En foi de quoi le présent certificat lui est délivré ',
        'pour servir et ',
        'valoir ce que de droit.',
      ], style: _texteCourt),
      pw.SizedBox(height: 6),
      _signature(d, grade: false, faitA: false, espace: 30),
    ],
  );
}

pw.Widget _nonRedevance(DocumentDirecteur d) {
  final e = d.eleve!;
  final a = e.accords;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _enteteCourt(d.entete),
      _titre('CERTIFICAT DE NON REDEVANCE', taille: 13),
      _paragraphe(
        [
          ..._jeSoussigne(d, virgule: true),
          ' certifie que l’élève ',
          _v(e.nom),
          ' ${a.ne} le ',
          _v(e.neLe),
          ' à ',
          _v(e.lieuNaissance),
          ', ${a.filsFille.toLowerCase()} de ',
          _v(e.pere),
          ' et de ',
          _v(e.mere),
          ', de la classe de ',
          _v(e.classe),
          ', ne doit rien à l’établissement. ',
          'Par conséquent ${a.il} nous quitte ',
          'libre de tout engagement.',
        ],
        style: _texteCourt,
        retrait: 16,
      ),
      _paragraphe(
        [
          'En foi de quoi le présent certificat lui est délivré ',
          'pour servir et ',
          'valoir ce que de droit.',
        ],
        style: _texteCourt,
        retrait: 16,
      ),
      pw.SizedBox(height: 6),
      _signature(d, grade: false, espace: 30),
    ],
  );
}
