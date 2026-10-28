import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Présentation commune de tous les tableaux imprimés (A19) : en-tête
/// teinté en gras, lignes alternées très claires, contenu centré en hauteur ;
/// le texte s'aligne à gauche, les valeurs courtes (tirets, nombres, dates,
/// rangs, codes) sont centrées.

/// Fond de l'en-tête (gris bleuté, lisible aussi en noir et blanc).
const couleurEnteteTableau = PdfColor.fromInt(0xFFDDE3EA);

/// Fond d'une ligne sur deux.
const couleurLigneAlternee = PdfColor.fromInt(0xFFF4F6F8);

/// Traits du tableau.
const couleurTraitTableau = PdfColor.fromInt(0xFF5A6470);

pw.TableBorder bordureTableau() =>
    pw.TableBorder.all(width: 0.5, color: couleurTraitTableau);

/// Traits intérieurs seulement (tableau imbriqué dans une case).
const traitInterieur = pw.BorderSide(width: 0.5, color: couleurTraitTableau);

pw.BoxDecoration? fondLigne(int i) =>
    i.isOdd ? const pw.BoxDecoration(color: couleurLigneAlternee) : null;

const fondEntete = pw.BoxDecoration(color: couleurEnteteTableau);

final _court = [
  RegExp(r'^[-–—_./…*×xX✓]+$'), // tirets, croix, coches
  RegExp(r'^[+-]?\d[\d\s]*([.,]\d+)?\s*%?$'), // nombres, pourcentages
  RegExp(r'^\d+([.,]\d+)?\s*/\s*\d+([.,]\d+)?$'), // 7/10, 12,5/20
  RegExp(r'^\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4}$'), // dates
  RegExp(r'^\d{4}-\d{2}-\d{2}$'),
  RegExp(r'^\d{4}\s*[-/]\s*\d{4}$'), // années scolaires
  RegExp(r'^\d+\s*(e|er|re|ère|ème)(\s*ex(-?aequo)?)?(\s*/\s*\d+)?$'), // rangs
];

/// Valeur courte à centrer : vide, tiret, nombre, date, rang, code de
/// trois caractères au plus (« M », « F », « T », « CM1 »).
bool valeurCourte(String texte) {
  final t = texte.trim();
  if (t.length <= 3) return true;
  return _court.any((r) => r.hasMatch(t));
}

/// Colonnes à centrer entièrement : toutes leurs valeurs sont courtes, ou
/// ce sont des codes de même longueur avec des chiffres (matricules).
List<bool> colonnesCentrees(List<List<String>> lignes, int nbColonnes) => [
  for (var c = 0; c < nbColonnes; c++)
    () {
      final valeurs = [
        for (final l in lignes)
          if (c < l.length && l[c].trim().isNotEmpty) l[c].trim(),
      ];
      if (valeurs.isEmpty) return true;
      if (valeurs.every(valeurCourte)) return true;
      // Codes de même longueur (matricules) : avec au moins un chiffre.
      final n = valeurs.first.length;
      return valeurs.length > 1 &&
          n <= 16 &&
          valeurs.every(
            (v) =>
                v.length == n && !v.contains(' ') && v.contains(RegExp(r'\d')),
          );
    }(),
];

/// Une case : centrée si [centre] (ou valeur courte), sinon à gauche.
pw.Widget caseTableau(
  String texte,
  pw.TextStyle style, {
  bool? centre,
  pw.EdgeInsets padding = const pw.EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 3,
  ),
}) {
  final c = centre ?? valeurCourte(texte);
  return pw.Padding(
    padding: padding,
    child: pw.Text(
      texte,
      style: style,
      textAlign: c ? pw.TextAlign.center : pw.TextAlign.left,
    ),
  );
}

/// Ligne d'en-tête : gras, centrée, fond teinté, répétée à chaque page.
pw.TableRow ligneEntete(
  List<String> titres,
  pw.TextStyle gras, {
  pw.EdgeInsets padding = const pw.EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 4,
  ),
}) => pw.TableRow(
  repeat: true,
  decoration: fondEntete,
  verticalAlignment: pw.TableCellVerticalAlignment.middle,
  children: [
    for (final t in titres)
      caseTableau(t, gras, centre: true, padding: padding),
  ],
);
