import 'dart:typed_data';

import 'package:ecoleplus/features/bulletins/domain/bulletin.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Bulletins (module 7), A4 portrait, une page par élève : un seul élève ou
/// toute la classe dans le même fichier.
Future<Uint8List> pdfBulletins(
  PolicesPdf polices,
  ModeleBulletin modele,
  List<Bulletin> bulletins,
) {
  final doc = pw.Document(theme: polices.theme, title: 'Bulletins');
  for (final b in bulletins) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 28,
          marginRight: 28,
          marginTop: 24,
          marginBottom: 24,
        ),
        build: (_) => _page(modele, b),
      ),
    );
  }
  return doc.save();
}

const _petit = pw.TextStyle(fontSize: 8.5);
const _normal = pw.TextStyle(fontSize: 9.5);
const _gras = pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold);

pw.Widget _cellule(String t, {bool gras = false, bool gauche = false}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2.5),
      child: pw.Text(
        t,
        style: gras ? _gras : _normal,
        textAlign: gauche ? pw.TextAlign.left : pw.TextAlign.center,
      ),
    );

pw.Widget _cadre(String titre, String? texte, {double hauteur = 46}) =>
    pw.Container(
      width: double.infinity,
      constraints: pw.BoxConstraints(minHeight: hauteur),
      padding: const pw.EdgeInsets.all(5),
      margin: const pw.EdgeInsets.only(top: 6),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titre, style: _gras),
          pw.SizedBox(height: 3),
          pw.Text(texte ?? '', style: _normal),
        ],
      ),
    );

pw.Widget _page(ModeleBulletin m, Bulletin b) {
  final r = b.resultat;
  final sur = centiemesTexte(b.echelle);
  final avecPoints = !b.annuel && m.afficherCoefficients;
  final seule = b.lignes.any((l) => l.uneSeuleNote);
  final moyenne = r.moyenne == null
      ? 'non calculée'
      : '${centiemesTexte(r.moyenne)} / $sur';
  final entete = [
    'Matière',
    ...b.titresCases,
    if (b.annuel) 'Moy. de l’année' else 'Moyenne',
    if (m.afficherCoefficients && !b.annuel) 'Coef.',
    if (avecPoints) 'Points',
  ];
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final l in b.entete) pw.Text(l, style: _petit),
              pw.Text(b.ecole, style: _gras),
            ],
          ),
          pw.Text('Année scolaire ${b.annee}', style: _normal),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          '${m.titre} — ${b.periode}',
          style: const pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Container(
        padding: const pw.EdgeInsets.all(5),
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Élève : ${b.eleve}', style: _gras),
                pw.Text(
                  [
                    if (b.sexe != null) b.sexe!,
                    if (b.neLe != null) 'né(e) le ${b.neLe}',
                  ].join(' · '),
                  style: _normal,
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Classe : ${b.classe}', style: _gras),
                if (b.matricule != null)
                  pw.Text('N° matricule : ${b.matricule}', style: _normal),
                pw.Text(
                  'Effectif : ${b.statistiques.effectif}',
                  style: _normal,
                ),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Table(
        border: pw.TableBorder.all(width: 0.6),
        columnWidths: {0: const pw.FlexColumnWidth(3)},
        defaultColumnWidth: const pw.FlexColumnWidth(),
        children: [
          pw.TableRow(
            repeat: true,
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: [for (final e in entete) _cellule(e, gras: true)],
          ),
          for (final l in b.lignes)
            pw.TableRow(
              children: [
                _cellule(
                  l.uneSeuleNote ? '${l.matiere} *' : l.matiere,
                  gauche: true,
                ),
                for (final c in l.cases) _cellule(c),
                _cellule(centiemesTexte(l.moyenne), gras: true),
                if (m.afficherCoefficients && !b.annuel)
                  _cellule(centiemesTexte(l.coefficient)),
                if (avecPoints)
                  _cellule(l.coefficient == 0 ? '—' : centiemesTexte(l.points)),
              ],
            ),
        ],
      ),
      if (seule)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Text(
            '* une seule des deux notes : elle fait la moyenne de la matière.',
            style: _petit,
          ),
        ),
      pw.SizedBox(height: 8),
      pw.Container(
        padding: const pw.EdgeInsets.all(5),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.6),
          color: PdfColors.grey100,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (b.annuel)
              pw.Text(
                'Moyennes des trimestres : '
                '${centiemesTexte(r.moyennesMatieres['t1'])} · '
                '${centiemesTexte(r.moyennesMatieres['t2'])} · '
                '${centiemesTexte(r.moyennesMatieres['t3'])}',
                style: _normal,
              ),
            if (!b.annuel && m.afficherTotal)
              pw.Text(
                'Total des points : ${centiemesTexte(r.total)}',
                style: _normal,
              ),
            pw.Text(
              '${b.annuel ? 'Moyenne annuelle' : 'Moyenne'} : $moyenne',
              style: _gras,
            ),
            if (m.afficherRang) pw.Text('Rang : ${b.rang}', style: _gras),
            if (m.afficherMention && r.mention != null)
              pw.Text('Mention : ${r.mention}', style: _normal),
            if (m.afficherStatistiques)
              pw.Text(
                'Moyenne de la classe : '
                '${centiemesTexte(b.statistiques.moyenneClasse)} · '
                'meilleure : ${centiemesTexte(b.statistiques.meilleure)} · '
                'plus faible : ${centiemesTexte(b.statistiques.plusFaible)}',
                style: _petit,
              ),
          ],
        ),
      ),
      _cadre('Appréciation de l’enseignant(e)', b.appreciation),
      _cadre('Observations du directeur', b.observation),
      if (b.annuel || b.decision != null)
        _cadre('Décision', b.decision, hauteur: 24),
      pw.Spacer(),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          for (final s in [
            m.libelleEnseignant,
            m.libelleDirecteur,
            if (m.signatureParents) 'Les parents',
          ])
            pw.Column(
              children: [
                pw.Text(s, style: _gras),
                pw.SizedBox(height: 40),
              ],
            ),
        ],
      ),
      if (m.piedDePage.isNotEmpty)
        pw.Center(child: pw.Text(m.piedDePage, style: _petit)),
    ],
  );
}
