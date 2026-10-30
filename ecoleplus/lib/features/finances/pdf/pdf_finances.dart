import 'dart:typed_data';

import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Ce qui est imprimé sur un reçu.
class DonneesRecu {
  const new({
    required this.ecole,
    required this.numero,
    required this.date,
    required this.montant,
    required this.mode,
    required this.rubrique,
    this.commune,
    this.telephone,
    this.logo,
    this.eleve,
    this.classe,
    this.reference,
    this.payeur,
    this.recuPar,
    this.resteApres,
    this.annule,
    this.motif,
    this.anneeScolaire,
  });
  final String ecole;
  final String? commune;
  final String? telephone;
  final Uint8List? logo;
  final String numero;

  /// « 12/10/2026 à 09:15 ».
  final String date;

  /// Négatif pour une annulation.
  final int montant;
  final String mode;
  final String rubrique;
  final String? eleve;
  final String? classe;
  final String? reference;
  final String? payeur;
  final String? recuPar;

  /// Reste à payer pour l'élève après ce reçu.
  final int? resteApres;

  /// Numéro du reçu annulé (pour une annulation).
  final String? annule;
  final String? motif;
  final String? anneeScolaire;
}

/// Reçu A5, partageable (WhatsApp…) ou imprimable.
Future<Uint8List> pdfRecu(PolicesPdf polices, DonneesRecu r) {
  final doc = pw.Document(theme: polices.theme);
  const bleu = PdfColor.fromInt(0xFF1F4E79);
  const gras = pw.TextStyle(fontWeight: pw.FontWeight.bold);
  final annulation = r.montant < 0;
  pw.Widget ligne(String libelle, String valeur, {bool fort = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 110,
              child: pw.Text(libelle, style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Expanded(
              child: pw.Text(
                valeur,
                style: fort ? gras.copyWith(fontSize: 11) : null,
              ),
            ),
          ],
        ),
      );
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            children: [
              if (r.logo != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 10),
                  child: pw.Image(pw.MemoryImage(r.logo!), width: 46),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      r.ecole.toUpperCase(),
                      style: gras.copyWith(fontSize: 13, color: bleu),
                    ),
                    if ((r.commune ?? '').isNotEmpty) pw.Text(r.commune!),
                    if ((r.telephone ?? '').isNotEmpty)
                      pw.Text('Tél. ${r.telephone}'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            color: annulation ? PdfColors.red50 : PdfColors.blue50,
            child: pw.Text(
              annulation ? 'ANNULATION N° ${r.numero}' : 'REÇU N° ${r.numero}',
              textAlign: pw.TextAlign.center,
              style: gras.copyWith(
                fontSize: 15,
                color: annulation ? PdfColors.red800 : bleu,
              ),
            ),
          ),
          if (r.anneeScolaire != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                'Année scolaire ${r.anneeScolaire}',
                textAlign: pw.TextAlign.center,
              ),
            ),
          pw.SizedBox(height: 12),
          ligne('Date', r.date),
          if (r.eleve != null)
            ligne(
              'Élève',
              r.classe == null ? r.eleve! : '${r.eleve} — ${r.classe}',
              fort: true,
            ),
          ligne('Objet', r.rubrique),
          if (annulation && r.annule != null)
            ligne('Reçu annulé', r.annule!, fort: true),
          if (annulation && r.motif != null) ligne('Motif', r.motif!),
          ligne('Montant', fcfa(r.montant), fort: true),
          ligne('En lettres', _majuscule(enLettres(r.montant))),
          ligne(
            'Mode de paiement',
            (r.reference ?? '').isEmpty
                ? r.mode
                : '${r.mode} — réf. ${r.reference}',
          ),
          if ((r.payeur ?? '').isNotEmpty) ligne('Versé par', r.payeur!),
          if ((r.recuPar ?? '').isNotEmpty) ligne('Reçu par', r.recuPar!),
          if (r.resteApres != null)
            ligne(
              'Reste à payer',
              r.resteApres == 0 ? 'Rien : à jour' : fcfa(r.resteApres!),
            ),
          pw.Spacer(),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Reçu numéroté, enregistré sans possibilité de '
                  'modification. Une erreur se corrige par une annulation '
                  'motivée. Conservez ce reçu.',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Container(
                width: 130,
                height: 64,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600, width: 0.6),
                ),
                child: pw.Text(
                  'Cachet et signature',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

String _ouTiret(int montant) => montant == 0 ? '—' : fcfa(montant);

String _majuscule(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Données du rapport financier (période choisie).
class RapportFinances {
  const new({
    required this.ecole,
    required this.anneeScolaire,
    required this.periode,
    required this.recettes,
    required this.depenses,
    required this.classes,
    required this.impayes,
    required this.soldeEspeces,
    required this.genereLe,
  });
  final String ecole;
  final String anneeScolaire;

  /// « Octobre 2026 » ou « Année 2025-2026 ».
  final String periode;

  /// (rubrique, encaissé, annulé) ; net = encaissé + annulé (négatif).
  final List<(String, int, int)> recettes;

  /// (catégorie, montant net).
  final List<(String, int)> depenses;

  /// (classe, dû, payé, reste).
  final List<(String, int, int, int)> classes;

  /// (élève, classe, impayé échu).
  final List<(String, String, int)> impayes;
  final int soldeEspeces;
  final String genereLe;

  int get totalRecettes => recettes.fold(0, (s, r) => s + r.$2 + r.$3);
  int get totalDepenses => depenses.fold(0, (s, d) => s + d.$2);
}

/// Rapport financier A4 : recettes, dépenses, solde, recouvrement par
/// classe, état des impayés.
Future<Uint8List> pdfRapportFinances(PolicesPdf polices, RapportFinances r) {
  final doc = pw.Document(theme: polices.theme);
  const gras = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9);
  const normal = pw.TextStyle(fontSize: 9);
  pw.Widget tableau(
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
        ligneEntete(titres, gras),
        for (final (i, l) in lignes.indexed)
          pw.TableRow(
            decoration: fondLigne(i),
            children: [
              for (final (j, c) in l.indexed)
                caseTableau(
                  c,
                  normal,
                  centre: j == 0 ? false : (centrees[j] ? true : null),
                ),
            ],
          ),
        if (total != null)
          pw.TableRow(
            decoration: fondEntete,
            children: [
              for (final (j, c) in total.indexed)
                caseTableau(c, gras, centre: j != 0),
            ],
          ),
      ],
    );
  }

  String taux(int paye, int du) =>
      du == 0 ? '—' : '${(paye * 100 / du).toStringAsFixed(0)} %';
  final duTotal = r.classes.fold<int>(0, (s, c) => s + c.$2);
  final payeTotal = r.classes.fold<int>(0, (s, c) => s + c.$3);
  final resteTotal = r.classes.fold<int>(0, (s, c) => s + c.$4);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      footer: (c) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${r.ecole} — rapport financier — page ${c.pageNumber}/'
          '${c.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ),
      build: (_) => [
        pw.Text(r.ecole.toUpperCase(), style: gras.copyWith(fontSize: 13)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Rapport financier — ${r.periode}',
          style: gras.copyWith(fontSize: 14),
        ),
        pw.Text(
          'Année scolaire ${r.anneeScolaire} • édité le ${r.genereLe} • '
          'montants en FCFA',
          style: normal,
        ),
        pw.SizedBox(height: 12),
        pw.Text('1. Synthèse', style: gras.copyWith(fontSize: 11)),
        pw.SizedBox(height: 4),
        tableau(
          const ['', 'Montant'],
          [
            ['Recettes (annulations déduites)', fcfa(r.totalRecettes)],
            ['Dépenses (annulations déduites)', fcfa(r.totalDepenses)],
            ['Solde de la période', fcfa(r.totalRecettes - r.totalDepenses)],
            ['Solde de la caisse (espèces)', fcfa(r.soldeEspeces)],
          ],
          largeurs: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth()},
        ),
        pw.SizedBox(height: 12),
        pw.Text('2. Recettes par rubrique', style: gras.copyWith(fontSize: 11)),
        pw.SizedBox(height: 4),
        tableau(
          const ['Rubrique', 'Encaissé', 'Annulé', 'Net'],
          [
            for (final (n, e, a) in r.recettes)
              [n, fcfa(e), _ouTiret(a), fcfa(e + a)],
          ],
          total: [
            'Total',
            fcfa(r.recettes.fold(0, (s, x) => s + x.$2)),
            fcfa(r.recettes.fold(0, (s, x) => s + x.$3)),
            fcfa(r.totalRecettes),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          '3. Dépenses par catégorie',
          style: gras.copyWith(fontSize: 11),
        ),
        pw.SizedBox(height: 4),
        if (r.depenses.isEmpty)
          pw.Text('Aucune dépense.', style: normal)
        else
          tableau(
            const ['Catégorie', 'Montant'],
            [
              for (final (n, m) in r.depenses) [n, fcfa(m)],
            ],
            total: ['Total', fcfa(r.totalDepenses)],
            largeurs: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth()},
          ),
        pw.SizedBox(height: 12),
        pw.Text(
          '4. Recouvrement par classe (année)',
          style: gras.copyWith(fontSize: 11),
        ),
        pw.SizedBox(height: 4),
        tableau(
          const ['Classe', 'Dû', 'Payé', 'Reste', 'Taux'],
          [
            for (final (n, du, paye, reste) in r.classes)
              [n, fcfa(du), fcfa(paye), fcfa(reste), taux(paye, du)],
          ],
          total: [
            'École',
            fcfa(duTotal),
            fcfa(payeTotal),
            fcfa(resteTotal),
            taux(payeTotal, duTotal),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          '5. Impayés (échéances dépassées)',
          style: gras.copyWith(fontSize: 11),
        ),
        pw.SizedBox(height: 4),
        if (r.impayes.isEmpty)
          pw.Text('Aucun impayé.', style: normal)
        else
          tableau(
            const ['Élève', 'Classe', 'Impayé'],
            [
              for (final (e, c, m) in r.impayes) [e, c, fcfa(m)],
            ],
            total: [
              '${r.impayes.length} élève(s)',
              '',
              fcfa(r.impayes.fold(0, (s, x) => s + x.$3)),
            ],
            largeurs: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(),
              2: pw.FlexColumnWidth(1.4),
            },
          ),
      ],
    ),
  );
  return doc.save();
}
