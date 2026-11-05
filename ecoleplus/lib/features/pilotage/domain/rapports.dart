import 'package:ecoleplus/features/classes/data/classes_repository.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:ecoleplus/features/grades/domain/tableau_classement.dart';
import 'package:ecoleplus/features/pilotage/domain/absences.dart';

/// Un tableau d'un rapport, commun au PDF et à Excel (nombres : int ou
/// double ; case vide : null).
class TableauRapport {
  const new(this.titre, this.entete, this.lignes, {this.total});
  final String titre;
  final List<String> entete;
  final List<List<Object?>> lignes;
  final List<Object?>? total;
}

/// Rapport automatique : titre, tableaux, remarques.
class Rapport {
  const new({
    required this.code,
    required this.titre,
    required this.ecole,
    required this.annee,
    required this.tableaux,
    this.periode,
    this.notes = const [],
    this.paysage = false,
  });

  /// Nom de fichier (« Effectifs »).
  final String code;
  final String titre;
  final String ecole;
  final String annee;
  final String? periode;
  final List<TableauRapport> tableaux;
  final List<String> notes;
  final bool paysage;

  /// Toutes les lignes pour Excel (titres de tableaux, lignes vides entre).
  List<List<Object?>> get lignesExcel => [
    [titre],
    [ecole, 'Année scolaire $annee', ?periode],
    for (final t in tableaux) ...[
      [],
      [t.titre],
      t.entete,
      ...t.lignes,
      ?t.total,
    ],
    if (notes.isNotEmpty) [],
    for (final n in notes) [n],
  ];
}

/// Case affichée dans le PDF : 14.5 → « 14,5 », 25000 → « 25 000 ».
String texteCase(Object? v) => switch (v) {
  null => '—',
  final int n => n.abs() >= 10000 ? fcfa(n) : '$n',
  final double d => caseTexte(d),
  _ => '$v',
};

double? _sur100(int? c) => c == null ? null : c / 100;

// ------------------------------ Effectifs ------------------------------

/// Effectifs par classe et par sexe. [classes] : (nom, effectif).
TableauRapport tableauEffectifs(List<(String, Effectif)> classes) {
  final total = classes.fold(const Effectif(), (s, c) => s + c.$2);
  return TableauRapport(
    'Effectifs par classe et par sexe',
    const ['Classe', 'Filles', 'Garçons', 'Non précisé', 'Total'],
    [
      for (final (nom, e) in classes)
        [nom, e.filles, e.garcons, e.autres, e.total],
    ],
    total: ['TOTAL', total.filles, total.garcons, total.autres, total.total],
  );
}

// ------------------------------ Listes ------------------------------

/// Liste d'une classe. [eleves] : (nom, sexe, date de naissance, code).
TableauRapport tableauListe(
  String classe,
  List<(String, String?, String?, String?)> eleves,
) => TableauRapport(
  'Liste de la classe $classe (${eleves.length} élèves)',
  const ['N°', 'Nom et prénom(s)', 'Sexe', 'Né(e) le', 'Matricule'],
  [
    for (final (i, (nom, sexe, naissance, code)) in eleves.indexed)
      [i + 1, nom, sexe ?? '', _date(naissance), code ?? ''],
  ],
);

String _date(String? d) => d == null || d.length < 10
    ? ''
    : '${d.substring(8, 10)}/${d.substring(5, 7)}/${d.substring(0, 4)}';

// ------------------------------ Résultats ------------------------------

/// Résultat d'une classe pour une période (trimestre ou année).
class ResultatsClasse {
  const new(this.classe, this.classement, this.matieres, {required this.seuil});
  final String classe;
  final Classement classement;

  /// (id, nom) des matières (vide pour l'année).
  final List<(String, String)> matieres;

  /// Moyenne minimale de réussite, en centièmes (ex. 1000 = 10/20).
  final int seuil;

  Iterable<Resultat> get _classes =>
      classement.resultats.where((r) => r.moyenne != null);

  int get admis => _classes.where((r) => r.moyenne! >= seuil).length;

  /// Taux de réussite en % (élèves classés) ; null : personne de classé.
  double? get taux {
    final n = _classes.length;
    return n == 0 ? null : admis * 100 / n;
  }

  /// Moyenne de la classe dans une matière (moyenne des élèves notés).
  int? moyenneMatiere(String id) {
    final v = [for (final r in classement.resultats) ?r.moyennesMatieres[id]];
    return v.isEmpty ? null : divArrondi(v.fold(0, (s, x) => s + x), v.length);
  }

  /// Élèves classés sous le seuil, du plus faible au plus fort.
  List<Resultat> get enDifficulte =>
      _classes.where((r) => r.moyenne! < seuil).toList()
        ..sort((a, b) => a.moyenne!.compareTo(b.moyenne!));
}

/// Résultats par classe : effectif, classés, moyenne, réussite.
TableauRapport tableauResultats(List<ResultatsClasse> classes, String seuil) =>
    TableauRapport(
      'Résultats par classe',
      [
        'Classe',
        'Effectif',
        'Classés',
        'Moyenne de la classe',
        'Meilleure',
        'Plus faible',
        'Moyenne ≥ $seuil',
        'Taux de réussite',
      ],
      [
        for (final c in classes)
          [
            c.classe,
            c.classement.statistiques.effectif,
            c.classement.statistiques.classes,
            _sur100(c.classement.statistiques.moyenneClasse),
            _sur100(c.classement.statistiques.meilleure),
            _sur100(c.classement.statistiques.plusFaible),
            c.admis,
            pourcent(c.taux),
          ],
      ],
    );

/// Moyenne de chaque matière, une ligne par classe et par matière.
TableauRapport tableauMatieres(List<ResultatsClasse> classes) => TableauRapport(
  'Résultats par classe et par matière',
  const ['Classe', 'Matière', 'Moyenne de la classe'],
  [
    for (final c in classes)
      for (final (id, nom) in c.matieres)
        [c.classe, nom, _sur100(c.moyenneMatiere(id))],
  ],
);

/// Classement d'une classe (rang, nom, moyenne, mention).
TableauRapport tableauClassementRapport(ResultatsClasse c) {
  final t = tableauClassement(c.classement, const [], avecTotal: false);
  return TableauRapport('Classement — ${c.classe}', t.entete, t.lignes);
}

/// Élèves en difficulté (moyenne sous le seuil).
TableauRapport tableauDifficulte(List<ResultatsClasse> classes, String seuil) =>
    TableauRapport(
      'Élèves dont la moyenne est inférieure à $seuil',
      const ['Classe', 'Nom et prénom(s)', 'Moyenne', 'Rang'],
      [
        for (final c in classes)
          for (final r in c.enDifficulte)
            [c.classe, r.eleve.nom, _sur100(r.moyenne), r.rangTexte],
      ],
    );

// ------------------------------ Absences ------------------------------

TableauRapport tableauAbsencesClasses(List<AbsencesClasse> l) {
  final abs = l.fold<int>(0, (s, c) => s + c.absences);
  final ret = l.fold<int>(0, (s, c) => s + c.retards);
  return TableauRapport(
    'Absences par classe',
    const [
      'Classe',
      'Effectif',
      'Jours d’appel',
      'Absences',
      'Retards',
      'Présence',
    ],
    [
      for (final c in l)
        [
          c.classe,
          c.effectif,
          c.joursAppel,
          c.absences,
          c.retards,
          pourcent(c.taux),
        ],
    ],
    total: [
      'TOTAL',
      l.fold<int>(0, (s, c) => s + c.effectif),
      '',
      abs,
      ret,
      '',
    ],
  );
}

TableauRapport tableauAbsencesEleves(List<AbsencesEleve> l) => TableauRapport(
  'Élèves absents ou en retard',
  const ['Nom et prénom(s)', 'Classe', 'Absences', 'Retards'],
  [
    for (final e in l) [e.nom, e.classe, e.absences, e.retards],
  ],
);

// ------------------------------ Finances ------------------------------

/// Situation financière par classe (scolarité et frais, hors cantine).
TableauRapport tableauFinances(List<(String, Synthese)> classes) {
  final t = classes.fold(
    (0, 0, 0, 0),
    (s, c) => (
      s.$1 + c.$2.du,
      s.$2 + c.$2.encaisse,
      s.$3 + c.$2.nbImpayes,
      s.$4 + c.$2.nbEleves,
    ),
  );
  return TableauRapport(
    'Recettes et impayés par classe (FCFA)',
    const [
      'Classe',
      'Élèves',
      'Dû',
      'Encaissé',
      'Reste à payer',
      'Élèves avec impayé',
      'Recouvrement',
    ],
    [
      for (final (nom, s) in classes)
        [
          nom,
          s.nbEleves,
          s.du,
          s.encaisse,
          s.restant,
          s.nbImpayes,
          texteTaux(s.taux),
        ],
    ],
    total: [
      'TOTAL',
      t.$4,
      t.$1,
      t.$2,
      t.$1 - t.$2,
      t.$3,
      texteTaux(t.$1 == 0 ? null : t.$2 * 100 / t.$1),
    ],
  );
}
