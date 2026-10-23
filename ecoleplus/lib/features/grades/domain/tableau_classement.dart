import 'package:ecoleplus/features/grades/domain/calculs.dart';

/// Le classement mis en tableau, commun au PDF et à Excel. Les nombres sont
/// des `double` (14,5 → 14.5) pour qu'Excel puisse les recalculer ; une
/// case vide est null.
class TableauClassement {
  const new(this.entete, this.lignes);
  final List<String> entete;
  final List<List<Object?>> lignes;
}

/// [colonnes] : (identifiant, titre) des colonnes de moyennes — les
/// matières d'un trimestre, ou les trois trimestres pour l'année.
TableauClassement tableauClassement(
  Classement c,
  List<(String, String)> colonnes, {
  bool avecTotal = true,
}) {
  double? n(int? centiemes) => centiemes == null ? null : centiemes / 100;
  return TableauClassement(
    [
      'Rang',
      'Nom et prénom(s)',
      for (final (_, titre) in colonnes) titre,
      if (avecTotal) 'Total',
      'Moyenne',
      'Mention',
    ],
    [
      for (final r in c.resultats)
        [
          r.rangTexte,
          r.eleve.nom,
          for (final (id, _) in colonnes) n(r.moyennesMatieres[id]),
          if (avecTotal) n(r.moyenne == null ? null : r.total),
          n(r.moyenne),
          r.mention,
        ],
    ],
  );
}

/// Colonnes d'un trimestre : « Calcul (coef. 3) ».
List<(String, String)> colonnesMatieres(List<Matiere> matieres) => [
  for (final m in matieres)
    (m.id, '${m.nom} (coef. ${centiemesTexte(m.coefficient)})'),
];

/// Colonnes de l'année.
const List<(String, String)> colonnesAnnee = [
  ('t1', 'Moy. 1er trim.'),
  ('t2', 'Moy. 2e trim.'),
  ('t3', 'Moy. 3e trim.'),
];

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
