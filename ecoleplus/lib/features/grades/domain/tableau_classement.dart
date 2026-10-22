import 'package:ecoleplus/features/grades/domain/calculs.dart';

/// Le classement mis en tableau, commun au PDF et à Excel. Les nombres sont
/// des `double` (14,5 → 14.5) pour qu'Excel puisse les recalculer ; une
/// case vide est null.
class TableauClassement {
  const new(this.entete, this.lignes);
  final List<String> entete;
  final List<List<Object?>> lignes;
}

TableauClassement tableauClassement(Classement c, List<Matiere> matieres) {
  double? n(int? centiemes) => centiemes == null ? null : centiemes / 100;
  return TableauClassement(
    [
      'Rang',
      'Nom et prénom(s)',
      for (final m in matieres)
        '${m.nom} (coef. ${centiemesTexte(m.coefficient)})',
      'Total',
      'Moyenne',
      'Mention',
    ],
    [
      for (final r in c.resultats)
        [
          r.rangTexte,
          r.eleve.nom,
          for (final m in matieres) n(r.moyennesMatieres[m.id]),
          n(r.moyenne == null ? null : r.total),
          n(r.moyenne),
          r.mention,
        ],
    ],
  );
}

/// Lignes de statistiques sous le tableau.
List<String> statistiquesTexte(Statistiques s) => [
  'Effectif : ${s.effectif} · classés : ${s.classes}',
  'Meilleure moyenne : ${centiemesTexte(s.meilleure)}',
  'Plus faible moyenne : ${centiemesTexte(s.plusFaible)}',
  'Moyenne de la classe : ${centiemesTexte(s.moyenneClasse)}',
];

/// Case affichée (PDF, écran) : 14.5 → « 14,5 », null → « — ».
String caseTexte(Object? v) => switch (v) {
  null => '—',
  final double d => centiemesTexte((d * 100).round()),
  _ => '$v',
};
