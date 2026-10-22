import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:flutter_test/flutter_test.dart';

// Matières du CM1 de l'École Test : Dessin à coefficient nul, Histoire sans
// aucune note.
const lecture = Matiere('lec', 'Lecture', 100);
const calcul = Matiere('cal', 'Calcul', 100);
const dictee = Matiere('dic', 'Dictée', 100);
const dessin = Matiere('des', 'Dessin', 0);
const histoire = Matiere('his', 'Histoire', 100);
const List<Matiere> matieres = [lecture, calcul, dictee, dessin, histoire];
const c1 = Composition('c1', 'Composition 1', 1000);
const c2 = Composition('c2', 'Composition 2', 1000);
const aicha = Eleve('a', 'TEST Aïcha', fille: true);
const boukary = Eleve('b', 'TEST Boukary');
const clarisse = Eleve('c', 'TEST Clarisse', fille: true);
const daouda = Eleve('d', 'TEST Daouda');

Note n(Eleve e, Matiere m, num? v, {Composition c = c1, bool abs = false}) =>
    Note(
      eleveId: e.id,
      matiereId: m.id,
      compositionId: c.id,
      valeur: v == null ? null : (v * 100).round(),
      statut: abs ? StatutNote.absent : StatutNote.note,
    );

/// Notes du jeu « École Test » (voir supabase/seed.sql).
final List<Note> notesC1 = [
  n(aicha, lecture, 8), n(aicha, calcul, 7), n(aicha, dictee, 6),
  n(aicha, dessin, 10), //
  n(boukary, lecture, 6), n(boukary, calcul, 6), n(boukary, dictee, 6),
  n(boukary, dessin, 2), //
  n(clarisse, lecture, 7), n(clarisse, calcul, 5), n(clarisse, dictee, 6),
  n(daouda, lecture, 5), n(daouda, calcul, null, abs: true),
  n(daouda, dictee, 6),
];

Classement classer(
  List<Note> notes, {
  List<Composition> compos = const [c1],
  RegleAbsent regle = RegleAbsent.nonCompte,
  List<Matiere> mats = matieres,
  List<Mention> mentions = const [],
}) => calculerClassement(
  eleves: const [aicha, boukary, clarisse, daouda],
  matieres: mats,
  compositions: compos,
  notes: notes,
  regle: regle,
  mentions: mentions,
);

void main() {
  test('6.2 / 6.3 — École Test, CM1, Composition 1 : 1er, deux 2e ex-aequo, '
      'puis 4e (même résultat que le contrôle SQL de la phase 0)', () {
    final r = classer(notesC1).resultats;
    expect(
      [for (final x in r) x.eleve.nom],
      ['TEST Aïcha', 'TEST Boukary', 'TEST Clarisse', 'TEST Daouda'],
    );
    expect([for (final x in r) x.total], [2100, 1800, 1800, 1100]);
    expect([for (final x in r) x.moyenne], [700, 600, 600, 550]);
    expect(
      [for (final x in r) x.rangTexte],
      ['1re', '2e ex-aequo', '2e ex-aequo', '4e'],
    );
  });

  test('coefficient nul : la note de Dessin ne change ni le total ni la '
      'moyenne', () {
    final sans = classer([
      for (final x in notesC1)
        if (x.matiereId != 'des') x,
    ]).resultats.first;
    final avec = classer(notesC1).resultats.first;
    expect((avec.total, avec.moyenne), (sans.total, sans.moyenne));
    expect(avec.moyennesMatieres['des'], 1000, reason: 'note affichée');
  });

  test('matière sans aucune note (Histoire) : exclue du calcul, pas comptée '
      'à zéro', () {
    final r = classer(notesC1).resultats.first;
    expect(r.moyennesMatieres['his'], isNull);
    expect(r.moyenne, 700);
  });

  test('élève absent : règle « non comptée » (défaut) ou « zéro »', () {
    final nonCompte = classer(notesC1).resultats.last;
    expect(nonCompte.moyennesMatieres['cal'], isNull);
    expect((nonCompte.total, nonCompte.moyenne), (1100, 550));
    final zero = classer(notesC1, regle: RegleAbsent.zero).resultats.last;
    expect(zero.moyennesMatieres['cal'], 0);
    expect((zero.total, zero.moyenne), (1100, 367)); // 11 / 3 = 3,666…
  });

  test('absent à toute la composition : non classé, compté dans '
      'l’effectif', () {
    final c = classer(
      [n(aicha, lecture, 8), n(boukary, lecture, null, abs: true)],
      mats: const [lecture],
    );
    expect(c.resultats.last.rangTexte, 'Non classé');
    expect(c.statistiques.classes, 1);
    expect(c.statistiques.effectif, 4);
  });

  test('deux 3e ex-aequo : le suivant est 5e (rang réel)', () {
    final notes = [
      for (final (e, v) in [
        (aicha, 9),
        (boukary, 8),
        (clarisse, 7),
        (daouda, 7),
      ])
        n(e, lecture, v),
    ];
    final cinq = calculerClassement(
      eleves: const [aicha, boukary, clarisse, daouda, Eleve('e', 'Z')],
      matieres: const [lecture],
      compositions: const [c1],
      notes: [...notes, n(const Eleve('e', 'Z'), lecture, 5)],
      regle: RegleAbsent.nonCompte,
    ).resultats;
    expect(
      [for (final x in cinq) x.rangTexte],
      ['1re', '2e', '3e ex-aequo', '3e ex-aequo', '5e'],
    );
  });

  test('moyenne générale arrondie à 2 décimales (au plus proche)', () {
    // (7 + 6 + 6) / 3 = 6,333… → 6,33 ; (7 + 7 + 6) / 3 = 6,666… → 6,67
    expect(
      classer([n(aicha, lecture, 7), n(aicha, calcul, 6), n(aicha, dictee, 6)])
          .resultats
          .first
          .moyenne,
      633,
    );
    expect(
      classer([n(aicha, lecture, 7), n(aicha, calcul, 7), n(aicha, dictee, 6)])
          .resultats
          .first
          .moyenne,
      667,
    );
  });

  test('coefficients différents : Σ(moyenne × coef) / Σ coef', () {
    final c = classer(
      [n(aicha, lecture, 8), n(aicha, calcul, 5)],
      mats: const [Matiere('lec', 'Lecture', 200), calcul],
    ).resultats.first;
    // (8 × 2 + 5 × 1) = 21 ; 21 / 3 = 7
    expect((c.total, c.moyenne), (2100, 700));
  });

  test('cumul : moyenne par matière sur les compositions, recalcul après '
      'modification d’une note', () {
    final notes = [
      n(aicha, lecture, 8),
      n(aicha, lecture, 6, c: c2),
      n(aicha, calcul, 5, c: c2),
    ];
    var r = classer(notes, compos: const [c1, c2]).resultats.first;
    expect(r.moyennesMatieres['lec'], 700);
    expect(r.moyenne, 600); // (7 + 5) / 2
    // La note de Calcul est corrigée : tout est recalculé.
    notes[2] = n(aicha, calcul, 9, c: c2);
    r = classer(notes, compos: const [c1, c2]).resultats.first;
    expect(r.moyenne, 800);
  });

  test('barème différent : une note sur 20 ramenée sur 10', () {
    final r = calculerClassement(
      eleves: const [aicha],
      matieres: const [lecture],
      compositions: const [Composition('c20', 'Devoir', 2000)],
      notes: [
        n(aicha, lecture, 13, c: const Composition('c20', 'Devoir', 2000)),
      ],
      regle: RegleAbsent.nonCompte,
    ).resultats.first;
    expect(r.moyenne, 650);
  });

  test('statistiques : meilleure, plus faible, moyenne de la classe ; '
      'meilleure et plus faible note d’une matière', () {
    final s = classer(notesC1).statistiques;
    expect((s.meilleure, s.plusFaible), (700, 550));
    expect(s.moyenneClasse, 613); // (7 + 6 + 6 + 5,5) / 4 = 6,125 → 6,13
    expect(extremesMatiere(notesC1, 'lec', 'c1'), (800, 500));
  });

  test('mentions de l’école (paramétrées) appliquées à la moyenne', () {
    final r = classer(
      notesC1,
      mentions: const [
        Mention(0, 599, 'À encourager'),
        Mention(600, 1000, 'Bien'),
      ],
    ).resultats;
    expect(
      [for (final x in r) x.mention],
      ['Bien', 'Bien', 'Bien', 'À encourager'],
    );
  });

  test('lecture et affichage des notes', () {
    expect(centiemesDepuis('14,5'), 1450);
    expect(centiemesDepuis('7'), 700);
    expect(centiemesDepuis('6.25'), 625);
    expect(centiemesDepuis('6,255'), isNull);
    expect(centiemesDepuis('-1'), isNull);
    expect(centiemesTexte(1450), '14,5');
    expect(centiemesTexte(633), '6,33');
    expect(centiemesTexte(700), '7');
    expect(centiemesTexte(null), '—');
  });
}
