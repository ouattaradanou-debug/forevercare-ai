import 'dart:typed_data';

import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Données du bilan mensuel de la cantine (PDF).
class DonneesBilanCantine {
  const new({
    required this.ecole,
    required this.anneeScolaire,
    required this.periode,
    required this.genereLe,
    required this.bilan,
    required this.repasParJour,
    required this.effectifs,
    this.definition,
    this.mode,
    this.avecCotisations = true,
  });
  final String ecole;
  final String anneeScolaire;
  final String periode;
  final String genereLe;
  final BilanCantine bilan;
  final Map<String, int> repasParJour;
  final List<EffectifCantine> effectifs;
  final String? definition;
  final String? mode;

  /// Faux : mode sans participation, ou droits sans les Finances.
  final bool avecCotisations;
}

/// « 150 », ou « — » sans repas servi.
String texteCout(CoutMoyen c) => c.arrondi == null ? '—' : fcfa(c.arrondi!);

const _gras = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9);
const _normal = pw.TextStyle(fontSize: 9);

pw.Widget _tableau(
  List<String> titres,
  List<List<String>> lignes, {
  Map<int, pw.TableColumnWidth>? largeurs,
  List<String>? total,
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

pw.Widget _titre(String t) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
  child: pw.Text(t, style: _gras.copyWith(fontSize: 11)),
);

/// Bilan mensuel : repas servis, bénéficiaires, coût moyen par repas
/// (formule affichée), cotisations et impayés de cantine, stock.
Future<Uint8List> pdfBilanCantine(PolicesPdf polices, DonneesBilanCantine d) {
  final doc = pw.Document(theme: polices.theme);
  final b = d.bilan;
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      footer: (c) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${d.ecole} — bilan de la cantine — page ${c.pageNumber}/'
          '${c.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ),
      build: (_) => [
        pw.Text(d.ecole.toUpperCase(), style: _gras.copyWith(fontSize: 13)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Bilan de la cantine — ${d.periode}',
          style: _gras.copyWith(fontSize: 14),
        ),
        pw.Text(
          'Année scolaire ${d.anneeScolaire} • édité le ${d.genereLe} • '
          'montants en FCFA',
          style: _normal,
        ),
        if (d.mode != null)
          pw.Text('Fonctionnement : ${d.mode}', style: _normal),
        if ((d.definition ?? '').isNotEmpty)
          pw.Text('Cantine endogène : ${d.definition}', style: _normal),
        _titre('1. Synthèse'),
        _tableau(
          const ['', 'Valeur'],
          [
            ['Repas servis', fcfa(b.repas)],
            ['Jours de service', '${b.joursServis}'],
            ['Moyenne de repas par jour', fcfa(b.moyenneParJour)],
            ['Élèves bénéficiaires', '${b.beneficiaires}'],
            ['Dépenses de cantine', fcfa(b.cout.depenses)],
            ['Coût moyen par repas', texteCout(b.cout)],
            if (d.avecCotisations) ...[
              ['Cotisations de cantine encaissées', fcfa(b.cotisations)],
              ['Impayés de cantine (à ce jour)', fcfa(b.impayes)],
            ],
          ],
          largeurs: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth()},
        ),
        pw.SizedBox(height: 4),
        pw.Text(b.cout.formule, style: _normal),
        _titre('2. Repas servis par jour'),
        if (d.repasParJour.isEmpty)
          pw.Text('Aucun repas pointé ce mois-ci.', style: _normal)
        else
          _tableau(
            const ['Jour', 'Repas servis'],
            [
              for (final MapEntry(key: j, value: n) in d.repasParJour.entries)
                [jourCourt(j), fcfa(n)],
            ],
            total: ['Total', fcfa(b.repas)],
          ),
        _titre('3. Bénéficiaires par classe'),
        _tableau(
          const ['Classe', 'Bénéficiaires', 'Effectif'],
          [
            for (final e in d.effectifs)
              [e.classe, '${e.beneficiaires}', '${e.effectif}'],
          ],
          total: [
            'Total',
            '${d.effectifs.fold<int>(0, (s, e) => s + e.beneficiaires)}',
            '${d.effectifs.fold<int>(0, (s, e) => s + e.effectif)}',
          ],
        ),
        _titre('4. Stock de vivres'),
        if (b.stock.isEmpty)
          pw.Text('Aucun produit enregistré.', style: _normal)
        else
          _tableau(
            const [
              'Produit',
              'Unité',
              'Début',
              'Entrées',
              'Sorties',
              'Inventaire / annul.',
              'Fin',
            ],
            [
              for (final m in b.stock)
                [
                  m.produit.name,
                  m.produit.unit,
                  qte(m.stockDebut),
                  qte(m.entrees),
                  qte(m.sorties),
                  qte(m.ajustements),
                  qte(m.stockFin),
                ],
            ],
            largeurs: const {0: pw.FlexColumnWidth(3)},
          ),
        pw.SizedBox(height: 24),
        pw.Text('Fait à ……………………, le ……………………', style: _normal),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Le responsable de la cantine', style: _normal),
            pw.Text('Le directeur', style: _normal),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

/// Menu de la semaine (affiché et imprimable).
Future<Uint8List> pdfMenu(
  PolicesPdf polices, {
  required String ecole,
  required String semaine,
  required String texte,
}) {
  final doc = pw.Document(theme: polices.theme)
    ..addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(ecole.toUpperCase(), style: _gras.copyWith(fontSize: 13)),
            pw.SizedBox(height: 6),
            pw.Text(
              'Menu de la cantine — $semaine',
              style: _gras.copyWith(fontSize: 18),
            ),
            pw.SizedBox(height: 16),
            pw.Text(texte, style: const pw.TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  return doc.save();
}
