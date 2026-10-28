import 'dart:typed_data';

import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/documents/pdf/pdf_documents.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:ecoleplus/features/medical/domain/fiche_medicale.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Identité imprimée en tête de la fiche B5.
class IdentiteB5 {
  const new({
    required this.nom,
    this.sexe,
    this.neLe,
    this.lieuNaissance,
    this.classe,
  });
  final String nom;
  final String? sexe;
  final String? neLe;
  final String? lieuNaissance;
  final String? classe;
}

const _pointilles = '……………………';
const _normal = pw.TextStyle(fontSize: 9.5);
const _gras = pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold);
const _serre = pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2);
const _section = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);

/// Fiche médico-scolaire (B5), A4 portrait. Document confidentiel.
Future<Uint8List> pdfB5(
  PolicesPdf polices, {
  required EnteteDocument entete,
  required IdentiteB5 eleve,
  required DossierMedical dossier,
  String? aptitudeDeLAnnee,
}) {
  final doc = pw.Document(theme: polices.theme, title: 'Fiche médico-scolaire')
    ..addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 36,
          marginRight: 36,
          marginTop: 22,
          marginBottom: 20,
        ),
        footer: (c) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Document confidentiel — données de santé — réservé au directeur',
              style: const pw.TextStyle(
                fontSize: 7.5,
                color: PdfColors.grey700,
              ),
            ),
            pw.Text(
              'Page ${c.pageNumber}/${c.pagesCount}',
              style: const pw.TextStyle(fontSize: 7.5),
            ),
          ],
        ),
        build: (_) => [
          enteteLongPdf(entete),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              'FICHE MÉDICO-SCOLAIRE',
              style: const pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          _identite(eleve),
          pw.SizedBox(height: 4),
          pw.Text('A) ANTÉCÉDENTS', style: _section),
          _sousTitre('I — Familiaux'),
          _champs(antecedentsFamiliaux, dossier.fiche),
          _sousTitre('II — Personnels : a) médicaux'),
          _champs(antecedentsMedicaux, dossier.fiche),
          _sousTitre('Vaccinations'),
          _champs(vaccinations, dossier.fiche),
          _sousTitre('b) chirurgicaux'),
          _champs(antecedentsChirurgicaux, dossier.fiche, hauteur: 22),
          pw.SizedBox(height: 6),
          pw.Text('B) EXAMEN CLINIQUE', style: _section),
          _sousTitre('I — Constantes'),
          _constantes(dossier.examens),
          _sousTitre('II — Examen physique'),
          _examenPhysique(dossier.examens),
          pw.SizedBox(height: 6),
          pw.Text('OBSERVATIONS', style: _section),
          pw.SizedBox(height: 4),
          pw.Wrap(
            spacing: 18,
            runSpacing: 4,
            children: [
              for (final MapEntry(key: code, value: libelle)
                  in aptitudes.entries)
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.8),
                      ),
                      child: aptitudeDeLAnnee == code
                          ? pw.Text('X', style: const pw.TextStyle(fontSize: 8))
                          : null,
                    ),
                    pw.SizedBox(width: 4),
                    pw.Text(libelle, style: _normal),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  return doc.save();
}

pw.Widget _sousTitre(String t) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 6, bottom: 3),
  child: pw.Text(t, style: _gras),
);

pw.Widget _identite(IdentiteB5 e) => pw.Container(
  padding: const pw.EdgeInsets.all(6),
  decoration: pw.BoxDecoration(
    border: pw.Border.all(width: 0.5, color: couleurTraitTableau),
    color: couleurLigneAlternee,
  ),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Nom et prénoms : ${e.nom}', style: _gras),
      pw.Text(
        [
          'Sexe : ${e.sexe ?? _pointilles}',
          'né(e) le ${e.neLe ?? _pointilles}',
          'à ${e.lieuNaissance ?? _pointilles}',
          'Classe : ${e.classe ?? _pointilles}',
        ].join('     '),
        style: _normal,
      ),
    ],
  ),
);

/// Libellé | valeur, deux paires par ligne.
pw.Widget _champs(
  List<ChampMedical> champs,
  Map<String, String?> valeurs, {
  double? hauteur,
}) {
  final paires = <List<ChampMedical>>[
    for (var i = 0; i < champs.length; i += 2)
      champs.sublist(i, i + 2 > champs.length ? champs.length : i + 2),
  ];
  return pw.Table(
    border: bordureTableau(),
    columnWidths: const {
      0: pw.FlexColumnWidth(2.7),
      1: pw.FlexColumnWidth(2.3),
      2: pw.FlexColumnWidth(2.7),
      3: pw.FlexColumnWidth(2.3),
    },
    children: [
      for (final (i, p) in paires.indexed)
        pw.TableRow(
          decoration: fondLigne(i),
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            for (final (c, libelle) in p) ...[
              pw.Container(
                constraints: hauteur == null
                    ? null
                    : pw.BoxConstraints(minHeight: hauteur),
                child: caseTableau(
                  libelle,
                  _gras,
                  centre: false,
                  padding: _serre,
                ),
              ),
              caseTableau(valeurs[c] ?? '', _normal, padding: _serre),
            ],
            if (p.length == 1) ...[pw.SizedBox(), pw.SizedBox()],
          ],
        ),
    ],
  );
}

/// Constantes : une colonne « 20… » par année (huit sur le modèle).
pw.Widget _constantes(List<ExamenAnnuel> examens) {
  final annees = [
    ...examens,
    for (var i = examens.length; i < anneesSurLeModele; i++) null,
  ];
  return pw.Table(
    border: bordureTableau(),
    columnWidths: {
      0: const pw.FlexColumnWidth(2.2),
      for (var i = 1; i <= annees.length; i++) i: const pw.FlexColumnWidth(),
    },
    children: [
      ligneEntete([
        '',
        for (final a in annees) a?.annee ?? '20…',
      ], const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
      for (final (i, (c, libelle)) in constantes.indexed)
        pw.TableRow(
          decoration: fondLigne(i),
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            caseTableau(libelle, _gras, centre: false, padding: _serre),
            for (final a in annees)
              caseTableau(
                a?.valeurs[c] ?? '',
                const pw.TextStyle(fontSize: 8.5),
                centre: true,
                padding: _serre,
              ),
          ],
        ),
    ],
  );
}

/// Examen physique : une ligne par année.
pw.Widget _examenPhysique(List<ExamenAnnuel> examens) => pw.Table(
  border: bordureTableau(),
  columnWidths: const {0: pw.FixedColumnWidth(70), 1: pw.FlexColumnWidth()},
  children: [
    for (var i = 0; i < anneesSurLeModele; i++)
      pw.TableRow(
        decoration: fondLigne(i),
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          caseTableau(
            i < examens.length ? examens[i].annee : '20…',
            _gras,
            centre: true,
            padding: _serre,
          ),
          pw.Container(
            constraints: const pw.BoxConstraints(minHeight: 13),
            child: caseTableau(
              i < examens.length ? examens[i].examenPhysique ?? '' : '',
              _normal,
              centre: false,
              padding: _serre,
            ),
          ),
        ],
      ),
  ],
);
