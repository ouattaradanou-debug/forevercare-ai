import 'dart:typed_data';

import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Polices des PDF (Roboto : accents et « ’ »). Chargées depuis les assets de
/// l'application, ou depuis des fichiers dans les tests.
class PolicesPdf {
  const new({
    required this.normale,
    required this.grasse,
    required this.italique,
  });
  final ByteData normale;
  final ByteData grasse;
  final ByteData italique;

  pw.ThemeData get theme => pw.ThemeData.withFont(
    base: pw.Font.ttf(normale),
    bold: pw.Font.ttf(grasse),
    italic: pw.Font.ttf(italique),
  );
}

/// Ce qui est imprimé en haut et en bas de chaque formulaire.
class ParametresImpression {
  const new({
    required this.anneeScolaire,
    this.ceb,
    this.ecole,
    this.province,
    this.departement,
    this.commune,
    this.periodeDu,
    this.periodeAu,
    this.faitA,
    this.faitLe,
    this.directeur,
    this.dateReference,
  });

  final String anneeScolaire;
  final String? ceb;
  final String? ecole;
  final String? province;
  final String? departement;
  final String? commune;

  /// B2 : « admis à l'école du … au … » (dates ISO).
  final String? periodeDu;
  final String? periodeAu;
  final String? faitA;
  final String? faitLe;
  final String? directeur;

  /// B1 : date de référence des anciennetés (ISO).
  final String? dateReference;
}

const _pointilles = '………………';
String _ou(String? v) => (v == null || v.trim().isEmpty) ? _pointilles : v;

pw.Widget _signature(ParametresImpression p) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 18),
  child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.end,
    children: [
      pw.Column(
        children: [
          pw.Text(
            'Fait à ${_ou(p.faitA)}, le '
            '${p.faitLe == null ? _pointilles : jjmmaaaa(p.faitLe)}',
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Le Directeur',
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Container(
            width: 190,
            height: 62,
            margin: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Signature et cachet',
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
            ),
          ),
          pw.Text(_ou(p.directeur)),
        ],
      ),
    ],
  ),
);

pw.Widget _tableau(
  List<String> entete,
  List<List<String>> lignes, {
  required Map<int, pw.TableColumnWidth> largeurs,
  bool numerosDeColonnes = false,
  int premierNumero = 1,
  double taille = 7.5,
  List<double>? hauteurs,
}) {
  final style = pw.TextStyle(fontSize: taille);
  final gras = pw.TextStyle(fontSize: taille, fontWeight: pw.FontWeight.bold);
  const padding = pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2.5);
  final centrees = colonnesCentrees(lignes, entete.length);
  pw.Widget cellule(int colonne, String t) => caseTableau(
    t,
    style,
    centre: centrees[colonne] || valeurCourte(t),
    padding: padding,
  );
  return pw.Table(
    border: bordureTableau(),
    columnWidths: largeurs,
    children: [
      if (numerosDeColonnes)
        pw.TableRow(
          repeat: true,
          decoration: fondEntete,
          children: [
            for (var i = 0; i < entete.length; i++)
              caseTableau(
                '${premierNumero + i}',
                gras,
                centre: true,
                padding: padding,
              ),
          ],
        ),
      ligneEntete(entete, gras, padding: padding),
      for (final (i, l) in lignes.indexed)
        pw.TableRow(
          decoration: fondLigne(i),
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            for (final (j, c) in l.indexed)
              if (hauteurs == null)
                cellule(j, c)
              else
                pw.SizedBox(
                  height: hauteurs[i],
                  child: pw.Align(
                    alignment: centrees[j] || valeurCourte(c)
                        ? pw.Alignment.center
                        : pw.Alignment.centerLeft,
                    child: cellule(j, c),
                  ),
                ),
          ],
        ),
      if (lignes.isEmpty)
        pw.TableRow(
          children: [for (final _ in entete) caseTableau(' ', style)],
        ),
    ],
  );
}

pw.Widget _titre(String t) => pw.Center(
  child: pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8),
    child: pw.Text(
      t,
      style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    ),
  ),
);

pw.Widget _piedDePage(pw.Context c, String formulaire) => pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    pw.Text(formulaire, style: const pw.TextStyle(fontSize: 7)),
    pw.Text(
      'Page ${c.pageNumber}/${c.pagesCount}',
      style: const pw.TextStyle(fontSize: 7),
    ),
  ],
);

final PdfPageFormat _paysage = PdfPageFormat.a4.landscape.copyWith(
  marginLeft: 22,
  marginRight: 22,
  marginTop: 22,
  marginBottom: 22,
);

/// B1 — Fiche de renseignement du personnel par école (A4 paysage).
Future<Uint8List> pdfB1(
  PolicesPdf polices,
  ParametresImpression p,
  List<List<String>> lignes,
) {
  final doc = pw.Document(theme: polices.theme, title: 'Fiche B1')
    ..addPage(
      pw.MultiPage(
        pageFormat: _paysage,
        footer: (c) => _piedDePage(c, 'Fiche de renseignement du personnel'),
        build: (c) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('CEB de ${_ou(p.ceb)}'),
              pw.Text('Année scolaire ${_ou(p.anneeScolaire)}'),
              pw.Text('École de ${_ou(p.ecole)}'),
            ],
          ),
          _titre('FICHE DE RENSEIGNEMENT DU PERSONNEL PAR ÉCOLE'),
          if (p.dateReference != null)
            pw.Text(
              'Anciennetés calculées au ${jjmmaaaa(p.dateReference)}.',
              style: const pw.TextStyle(fontSize: 8),
            ),
          pw.SizedBox(height: 4),
          // En-tête à deux niveaux : groupe « Ancienneté » au-dessus des
          // colonnes 11 à 14 (même largeur que ces quatre colonnes).
          pw.Row(
            children: [
              pw.Expanded(flex: _flexB1(0, 10), child: pw.SizedBox()),
              pw.Expanded(
                flex: _flexB1(10, 14),
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 0.5,
                      color: couleurTraitTableau,
                    ),
                    color: couleurEnteteTableau,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Ancienneté',
                      style: const pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              pw.Expanded(flex: _flexB1(14, 15), child: pw.SizedBox()),
            ],
          ),
          _tableau(enteteB1, lignes, largeurs: _largeursB1),
          _signature(p),
        ],
      ),
    );
  return doc.save();
}

int _flexB1(int de, int a) {
  var total = 0.0;
  for (var i = de; i < a; i++) {
    total += _largeursB1[i]!.flex;
  }
  return (total * 100).round();
}

const _largeursB1 = {
  0: pw.FlexColumnWidth(0.8),
  1: pw.FlexColumnWidth(1.2),
  2: pw.FlexColumnWidth(2.2),
  3: pw.FlexColumnWidth(1.5),
  4: pw.FlexColumnWidth(),
  5: pw.FlexColumnWidth(1.1),
  6: pw.FlexColumnWidth(0.5),
  7: pw.FlexColumnWidth(1.2),
  8: pw.FlexColumnWidth(1.2),
  9: pw.FlexColumnWidth(1.4),
  10: pw.FlexColumnWidth(1.1),
  11: pw.FlexColumnWidth(1.1),
  12: pw.FlexColumnWidth(1.1),
  13: pw.FlexColumnWidth(1.1),
  14: pw.FlexColumnWidth(1.1),
};

/// Rappel imprimé sous la colonne « Observations » du registre matricule.
/// Libellé reconstitué depuis l'ANNEXE B : le texte EXACT du scan reste à
/// reprendre (à confirmer avec le directeur).
const rappelObservationsB2 =
    'Indiquer notamment : le succès de l’élève, ses aptitudes, sa conduite, '
    'la carrière embrassée à la fin des études, l’école d’origine s’il vient '
    'd’une autre école, et où et comment il complète son instruction s’il '
    'quitte l’école avant 14 ans ou sans C.E.P.';

/// B2 — Registre matricule des élèves (« Mod. 557 ») : couverture puis
/// tableau à 9 colonnes numérotées.
Future<Uint8List> pdfB2(
  PolicesPdf polices,
  ParametresImpression p,
  List<List<String>> lignes,
) {
  final doc = pw.Document(theme: polices.theme, title: 'Registre B2');
  String annee(String? iso) =>
      iso == null ? '20…' : (DateTime.tryParse(iso)?.year.toString() ?? '20…');
  doc
    ..addPage(
      pw.Page(
        pageFormat: _paysage,
        build: (c) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Align(
              alignment: pw.Alignment.topRight,
              child: pw.Text('Mod. 557'),
            ),
            pw.SizedBox(height: 30),
            pw.Text('Province de ${_ou(p.province)}'),
            pw.Text('Département de ${_ou(p.departement)}'),
            pw.Text('Commune de ${_ou(p.commune)}'),
            pw.Text('École ${_ou(p.ecole)}'),
            pw.Spacer(),
            pw.Center(
              child: pw.Text(
                'REGISTRE MATRICULE',
                style: const pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'des élèves admis à l’école du 1er janvier '
                '${annee(p.periodeDu)} au '
                '${p.periodeAu == null ? _pointilles : jjmmaaaa(p.periodeAu)}',
                style: const pw.TextStyle(fontSize: 13),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                '(Instruction primaire)',
                style: const pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),
            ),
            pw.Spacer(flex: 2),
          ],
        ),
      ),
    )
    ..addPage(
      pw.MultiPage(
        pageFormat: _paysage,
        footer: (c) => _piedDePage(c, 'Registre matricule des élèves'),
        build: (c) => [
          _tableau(
            enteteB2,
            lignes,
            numerosDeColonnes: true,
            largeurs: const {
              0: pw.FlexColumnWidth(0.7),
              1: pw.FlexColumnWidth(2.2),
              2: pw.FlexColumnWidth(1.1),
              3: pw.FlexColumnWidth(2.2),
              4: pw.FlexColumnWidth(2.2),
              5: pw.FlexColumnWidth(1.1),
              6: pw.FlexColumnWidth(1.1),
              7: pw.FlexColumnWidth(1.1),
              8: pw.FlexColumnWidth(3),
            },
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Observations — $rappelObservationsB2',
            style: const pw.TextStyle(
              fontSize: 7,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          _signature(p),
        ],
      ),
    );
  return doc.save();
}

/// B3 — Registre du personnel enseignant (double page) : pour chaque groupe
/// de lignes, la page de gauche porte les colonnes 1 à 7 et la page de
/// droite les colonnes 8 à 13, dans le même ordre de lignes.
Future<Uint8List> pdfB3(
  PolicesPdf polices,
  ParametresImpression p,
  List<LigneB3> lignes, {
  int lignesParDoublePage = 8,
}) {
  final doc = pw.Document(theme: polices.theme, title: 'Registre B3');
  final paquets = <List<LigneB3>>[
    for (var i = 0; i < lignes.length; i += lignesParDoublePage)
      lignes.sublist(i, (i + lignesParDoublePage).clamp(0, lignes.length)),
  ];
  if (paquets.isEmpty) paquets.add(const []);
  for (final (n, paquet) in paquets.indexed) {
    final dernier = n == paquets.length - 1;
    // Même hauteur pour une ligne sur les deux pages : l'enseignant reste en
    // face de lui-même d'une page à l'autre.
    final hauteurs = [
      for (final l in paquet)
        [
                  for (final (i, t) in l.gauche.indexed)
                    _lignesEstimees(t, _b3g[i]!),
                  for (final (i, t) in l.droite.indexed)
                    _lignesEstimees(t, _b3d[i]!),
                ].reduce((a, b) => a > b ? a : b) *
                9.0 +
            6,
    ];
    doc
      ..addPage(
        pw.Page(
          pageFormat: _paysage,
          build: (c) => pw.Column(
            children: [
              if (n == 0)
                _titre('REGISTRE DU PERSONNEL ENSEIGNANT')
              else
                pw.SizedBox(height: 4),
              _tableau(
                enteteB3Gauche,
                [for (final l in paquet) l.gauche],
                numerosDeColonnes: true,
                taille: 7,
                hauteurs: hauteurs,
                largeurs: _b3g,
              ),
              pw.Spacer(),
              _piedDePage(c, 'Registre du personnel — page de gauche'),
            ],
          ),
        ),
      )
      ..addPage(
        pw.Page(
          pageFormat: _paysage,
          build: (c) => pw.Column(
            children: [
              pw.SizedBox(height: n == 0 ? 33 : 4),
              _tableau(
                enteteB3Droite,
                [for (final l in paquet) l.droite],
                numerosDeColonnes: true,
                premierNumero: 8,
                taille: 7,
                hauteurs: hauteurs,
                largeurs: _b3d,
              ),
              if (dernier) _signature(p),
              pw.Spacer(),
              _piedDePage(c, 'Registre du personnel — page de droite'),
            ],
          ),
        ),
      );
  }
  return doc.save();
}

const _b3g = {
  0: pw.FlexColumnWidth(2),
  1: pw.FlexColumnWidth(1.6),
  2: pw.FlexColumnWidth(1.2),
  3: pw.FlexColumnWidth(0.8),
  4: pw.FlexColumnWidth(0.9),
  5: pw.FlexColumnWidth(2),
  6: pw.FlexColumnWidth(1.3),
};
const _b3d = {
  0: pw.FlexColumnWidth(2),
  1: pw.FlexColumnWidth(1.6),
  2: pw.FlexColumnWidth(1.2),
  3: pw.FlexColumnWidth(1.8),
  4: pw.FlexColumnWidth(1.5),
  5: pw.FlexColumnWidth(1.5),
};

/// Nombre de lignes qu'occupera un texte dans une colonne (estimation
/// prudente : ~4 caractères par point de largeur relative).
int _lignesEstimees(String texte, pw.FlexColumnWidth largeur) {
  final parLigne = (largeur.flex * 11).floor().clamp(4, 200);
  var n = 0;
  for (final l in texte.split('\n')) {
    n += (l.length / parLigne).ceil().clamp(1, 1000);
  }
  return n;
}
