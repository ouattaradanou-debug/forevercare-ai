import 'package:ecoleplus/app/theme.dart';
import 'package:flutter/material.dart';

/// Une colonne d'un tableau : titre, largeur relative, montant (aligné à
/// droite) ou texte (à gauche).
class ColonneTableau {
  const new(
    this.titre, {
    this.flex = 2,
    this.montant = false,
    this.centre = false,
    this.largeurMin = 96,
  });
  final String titre;
  final int flex;

  /// Montant ou nombre : aligné à droite.
  final bool montant;
  final bool centre;

  /// Largeur minimale (au-dessous, le tableau défile horizontalement).
  final double largeurMin;

  Alignment get alignement => montant
      ? Alignment.centerRight
      : centre
      ? Alignment.center
      : Alignment.centerLeft;
}

/// Une ligne : une cellule par colonne ; touchable si [onTap].
class LigneTableau {
  const new(this.cellules, {this.onTap, this.cle});
  final List<Widget> cellules;
  final VoidCallback? onTap;
  final Key? cle;
}

/// Tableau commun de l'application (A24) : en-têtes bien visibles,
/// montants alignés à droite, lignes alternées très discrètes, ligne de
/// total mise en évidence, défilement horizontal sur petit écran sans
/// déformer les colonnes.
class TableauDonnees extends StatelessWidget {
  const new({
    required this.colonnes,
    required this.lignes,
    this.total,
    this.titre,
    this.vide = 'Aucune donnée.',
    super.key,
  });
  final List<ColonneTableau> colonnes;
  final List<LigneTableau> lignes;

  /// Ligne de total (en gras, fond teinté).
  final LigneTableau? total;

  /// Titre du groupe (ex. nom de la classe), au-dessus du tableau.
  final String? titre;
  final String vide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // En-tête bleu marine, texte blanc ; lignes alternées gris très clair.
    final entete = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: cs.onPrimary,
    );
    final largeurMin = colonnes.fold<double>(0, (s, c) => s + c.largeurMin);
    Widget cellule(int i, Widget enfant, {TextStyle? style}) => Container(
      alignment: colonnes[i].alignement,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      child: style == null
          ? enfant
          : DefaultTextStyle.merge(style: style, child: enfant),
    );
    TableRow rangee(LigneTableau l, {Color? fond, TextStyle? style}) =>
        TableRow(
          key: l.cle is LocalKey ? l.cle! as LocalKey : null,
          decoration: BoxDecoration(
            color: fond,
            border: Border(
              bottom: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          children: [
            for (final (i, c) in l.cellules.indexed)
              if (l.onTap == null)
                cellule(i, c, style: style)
              else
                TableRowInkWell(
                  onTap: l.onTap,
                  child: cellule(i, c, style: style),
                ),
          ],
        );
    const alterne = Color(0xFFF6F8FC);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (titre != null)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              titre!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Charte.blanc,
            border: Border.all(color: Charte.bordure),
            borderRadius: BorderRadius.circular(Charte.rayon),
            boxShadow: Charte.ombre,
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, c) {
              final largeur = c.maxWidth.isFinite && c.maxWidth > largeurMin
                  ? c.maxWidth
                  : largeurMin;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: largeur,
                  child: Table(
                    columnWidths: {
                      for (final (i, col) in colonnes.indexed)
                        i: FlexColumnWidth(col.flex.toDouble()),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Charte.marine),
                        children: [
                          for (final (i, col) in colonnes.indexed)
                            cellule(i, Text(col.titre, style: entete)),
                        ],
                      ),
                      for (final (i, l) in lignes.indexed)
                        rangee(l, fond: i.isOdd ? alterne : null),
                      if (lignes.isEmpty)
                        TableRow(
                          children: [
                            cellule(0, Text(vide)),
                            for (var i = 1; i < colonnes.length; i++)
                              const SizedBox(),
                          ],
                        ),
                      if (total != null)
                        rangee(
                          total!,
                          fond: cs.secondaryContainer,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Couleurs des statuts financiers (vert : soldé ; rouge : reste à payer),
/// lisibles en mode clair comme en mode sombre.
class CouleursFinances {
  const new _(this.vert, this.fondVert, this.rouge, this.orange);

  factory de(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const CouleursFinances._(
          Color(0xFF8FD6A1),
          Color(0xFF1E4620),
          Color(0xFFF2A8A5),
          Color(0xFFF3D28A),
        )
      : const CouleursFinances._(
          Charte.vert,
          Charte.vertPale,
          Charte.rouge,
          Charte.ambre,
        );
  final Color vert;
  final Color fondVert;
  final Color rouge;
  final Color orange;
}

/// Mention « SOLDÉ » bien visible, en vert.
class MentionSolde extends StatelessWidget {
  const new({this.texte = 'SOLDÉ', super.key});
  final String texte;

  @override
  Widget build(BuildContext context) {
    final c = CouleursFinances.de(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.fondVert,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texte,
        style: TextStyle(
          color: c.vert,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Rappel discret de la devise, une fois par écran (les montants des
/// tableaux sont affichés sans « FCFA » pour laisser de la place aux
/// chiffres).
class MentionFcfa extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      'Montants en FCFA',
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: Theme.of(context).colorScheme.outline),
    ),
  );
}
