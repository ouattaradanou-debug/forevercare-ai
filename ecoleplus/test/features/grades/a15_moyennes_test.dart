import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:flutter_test/flutter_test.dart';

// Évolution A15 : méthode de calcul selon le type d'école (« Mon école »).
const fr = Matiere('fr', 'Français', 100);
const ma = Matiere('ma', 'Mathématiques', 100);
const sc = Matiere('sc', 'Sciences', 100);
const hg = Matiere('hg', 'Histoire-Géographie', 100);
const ali = Eleve('ali', 'TEST Ali');
const bintou = Eleve('bin', 'TEST Bintou', fille: true);

Composition compo(int t) =>
    Composition('c$t', 'Composition T$t', 1000, trimestre: t);
Composition eval(int t) => Composition(
  'e$t',
  'Évaluation T$t',
  1000,
  trimestre: t,
  type: TypeEpreuve.evaluation,
);
final List<Composition> epreuves = [
  for (final t in const [1, 2, 3]) ...[eval(t), compo(t)],
];

Note n(Eleve e, Matiere m, Composition c, num? v, {bool abs = false}) => Note(
  eleveId: e.id,
  matiereId: m.id,
  compositionId: c.id,
  valeur: v == null ? null : (v * 100).round(),
  statut: abs ? StatutNote.absent : StatutNote.note,
);

Resultat trimestre(
  TypeEcole type,
  int t,
  List<Note> notes, {
  List<Matiere> matieres = const [fr, ma, sc, hg],
  List<Eleve> eleves = const [ali],
}) => classementTrimestre(
  type: type,
  trimestre: t,
  eleves: eleves,
  matieres: matieres,
  compositions: epreuves,
  notes: notes,
  regle: RegleAbsent.nonCompte,
).resultats.firstWhere((r) => r.eleve.id == eleves.first.id);

Resultat annee(TypeEcole type, List<Note> notes) => classementAnnuel(
  type: type,
  eleves: const [ali],
  matieres: const [fr, ma, sc, hg],
  compositions: epreuves,
  notes: notes,
  regle: RegleAbsent.nonCompte,
).resultats.single;

/// Notes de composition d'un trimestre (école publique).
List<Note> publique(int t, List<num?> v) => [
  for (final (i, m) in const [fr, ma, sc, hg].indexed)
    if (v[i] != null) n(ali, m, compo(t), v[i]),
];

void main() {
  group('école publique', () {
    test('exemple : (8 + 7 + 9 + 6) ÷ 4 = 7,5', () {
      final r = trimestre(TypeEcole.publique, 1, publique(1, [8, 7, 9, 6]));
      expect(r.moyenne, 750);
      expect(r.total, 3000);
    });

    test('exemple annuel : (7,5 + 8 + 9) ÷ 3 = 8,17', () {
      final notes = [
        ...publique(1, [8, 7, 9, 6]), // 7,5
        ...publique(2, [8, 8, 8, 8]), // 8
        ...publique(3, [9, 9, 9, 9]), // 9
      ];
      final r = annee(TypeEcole.publique, notes);
      expect(r.moyennesMatieres, {'t1': 750, 't2': 800, 't3': 900});
      expect(r.moyenne, 817);
      expect(r.rangTexte, '1er');
    });

    test('matière sans note : ni zéro ni comptée ; un 0 saisi compte', () {
      expect(
        trimestre(TypeEcole.publique, 1, publique(1, [8, 7, 9, null])).moyenne,
        800, // (8 + 7 + 9) ÷ 3
      );
      expect(
        trimestre(TypeEcole.publique, 1, publique(1, [8, 7, 9, 0])).moyenne,
        600, // (8 + 7 + 9 + 0) ÷ 4
      );
    });

    test('aucune note : pas de moyenne (pas de division par zéro)', () {
      final r = trimestre(TypeEcole.publique, 1, const []);
      expect(r.moyenne, isNull);
      expect(r.rangTexte, 'Non classé');
    });

    test('les évaluations (école passée de privée à publique) restent '
        'enregistrées mais ne comptent pas', () {
      final r = trimestre(TypeEcole.publique, 1, [
        ...publique(1, [8, 7, 9, 6]),
        n(ali, fr, eval(1), 2),
      ]);
      expect(r.moyenne, 750);
    });
  });

  group('école privée', () {
    final t1 = [
      n(ali, fr, eval(1), 8), n(ali, fr, compo(1), 6), // 7
      n(ali, ma, eval(1), 7), n(ali, ma, compo(1), 9), // 8
      n(ali, sc, eval(1), 8), n(ali, sc, compo(1), 10), // 9
    ];

    test('exemple : matières 7, 8 et 9 → (7 + 8 + 9) ÷ 3 = 8', () {
      final r = trimestre(TypeEcole.privee, 1, t1);
      expect(
        [
          for (final m in const ['fr', 'ma', 'sc']) r.moyennesMatieres[m],
        ],
        [700, 800, 900],
      );
      expect(r.moyennesMatieres['hg'], isNull, reason: 'aucune note : exclue');
      expect(r.moyenne, 800);
      expect(r.uneSeuleNote, isEmpty);
    });

    test('exemple annuel : (8 + 7,5 + 8,5) ÷ 3 = 8', () {
      List<Note> partout(int t, num v) => [
        for (final m in const [fr, ma, sc]) ...[
          n(ali, m, eval(t), v),
          n(ali, m, compo(t), v),
        ],
      ];
      final r = annee(TypeEcole.privee, [
        ...t1, // 8
        ...partout(2, 7.5),
        ...partout(3, 8.5),
      ]);
      expect(r.moyennesMatieres, {'t1': 800, 't2': 750, 't3': 850});
      expect(r.moyenne, 800);
    });

    test('une seule des deux notes : elle fait la moyenne de la matière '
        '(jamais un zéro) et la matière est signalée', () {
      final r = trimestre(TypeEcole.privee, 1, [
        ...t1,
        n(ali, hg, eval(1), 6), // composition non saisie
      ]);
      expect(r.moyennesMatieres['hg'], 600);
      expect(r.uneSeuleNote, {'hg'});
      expect(r.moyenne, 750); // (7 + 8 + 9 + 6) ÷ 4
    });

    test('une note de 0 est un vrai 0', () {
      final r = trimestre(
        TypeEcole.privee,
        1,
        [n(ali, fr, eval(1), 0), n(ali, fr, compo(1), 8)],
        matieres: const [fr],
      );
      expect(r.moyenne, 400);
      expect(r.uneSeuleNote, isEmpty);
    });

    test('note modifiée : tout est recalculé', () {
      final notes = [...t1];
      notes[1] = n(ali, fr, compo(1), 10); // Français : (8 + 10) ÷ 2 = 9
      expect(trimestre(TypeEcole.privee, 1, notes).moyenne, 867); // 26 ÷ 3
    });
  });

  test('moyenne annuelle seulement avec les trois trimestres', () {
    final r = annee(TypeEcole.publique, [
      ...publique(1, [8, 7, 9, 6]),
      ...publique(2, [8, 8, 8, 8]),
    ]);
    expect(r.moyennesMatieres, {'t1': 750, 't2': 800, 't3': null});
    expect(r.moyenne, isNull);
    expect(r.rangTexte, 'Non classé');
  });

  test('calcul exact, arrondi seulement à l’affichage : (6,666… + 6,666… '
      '+ 7) ÷ 3 = 61/9 = 6,78', () {
    List<Note> trois(int t, List<num> v) => [
      for (final (i, m) in const [fr, ma, sc].indexed)
        n(ali, m, compo(t), v[i]),
    ];
    final r = classementAnnuel(
      type: TypeEcole.publique,
      eleves: const [ali],
      matieres: const [fr, ma, sc],
      compositions: epreuves,
      notes: [
        ...trois(1, [6, 7, 7]), // 20 ÷ 3 = 6,666… (affiché 6,67)
        ...trois(2, [6, 7, 7]),
        ...trois(3, [7, 7, 7]),
      ],
      regle: RegleAbsent.nonCompte,
    ).resultats.single;
    // Exact : (20/3 + 20/3 + 7) ÷ 3 = 61/9 = 6,777… → 6,78.
    // En arrondissant d'abord : (6,67 + 6,67 + 7) ÷ 3 = 6,78 aussi ; la
    // valeur exacte est gardée dans tous les cas.
    expect(r.moyenne, 678);
    expect((r.exacte!.num, r.exacte!.den), (6100, 9)); // 61/9, en centièmes
  });

  test('changement de type d’école : mêmes notes, aucune perte, méthode '
      'appliquée aussitôt', () {
    final notes = [n(ali, fr, eval(1), 4), n(ali, fr, compo(1), 8)];
    expect(trimestre(TypeEcole.publique, 1, notes).moyenne, 800);
    expect(trimestre(TypeEcole.privee, 1, notes).moyenne, 600);
  });

  test('rang sur la moyenne affichée : 7,5 et 7,5 ex-aequo', () {
    final c = classementTrimestre(
      type: TypeEcole.publique,
      trimestre: 1,
      eleves: const [ali, bintou],
      matieres: const [fr, ma],
      compositions: epreuves,
      notes: [
        n(ali, fr, compo(1), 8),
        n(ali, ma, compo(1), 7),
        n(bintou, fr, compo(1), 7),
        n(bintou, ma, compo(1), 8),
      ],
      regle: RegleAbsent.nonCompte,
    );
    expect(
      [for (final r in c.resultats) r.rangTexte],
      ['1er ex-aequo', '1re ex-aequo'],
    );
  });
}
