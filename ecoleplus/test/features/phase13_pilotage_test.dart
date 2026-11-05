import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/features/classes/data/classes_repository.dart';
import 'package:ecoleplus/features/pilotage/domain/absences.dart';
import 'package:ecoleplus/features/pilotage/domain/accueil.dart';
import 'package:ecoleplus/features/pilotage/domain/emploi_du_temps.dart';
import 'package:ecoleplus/features/pilotage/domain/notifications.dart';
import 'package:ecoleplus/features/pilotage/domain/rapports.dart';
import 'package:ecoleplus/features/pilotage/domain/recherche.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'phase10_finances_test.dart' show saisir, texte;
import 'phase8_cartes_test.dart' show accueil, retour, tap;
import 'phase9_bibliotheque_test.dart' show calme;

TimetableSlotRow creneau(
  String id,
  int jour,
  String debut,
  String fin, {
  String classe = 'c',
  String? matiere,
  String? activite,
}) => TimetableSlotRow(
  id: id,
  schoolId: 's',
  classId: classe,
  weekday: jour,
  startsAt: debut,
  endsAt: fin,
  subjectId: matiere,
  activityLabel: activite,
  updatedAt: '',
);

AttendanceRow presence(
  String eleve,
  String jour,
  String statut, {
  String classe = 'c',
}) => AttendanceRow(
  id: '$eleve$jour',
  schoolId: 's',
  classId: classe,
  studentId: eleve,
  day: jour,
  status: statut,
  updatedAt: '',
);

AppDatabase base(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
        .read(databaseProvider);

void main() {
  group('emploi du temps', () {
    test('heures écrites librement', () {
      expect(heureDepuis('7h30'), '07:30');
      expect(heureDepuis('07:30'), '07:30');
      expect(heureDepuis('8h'), '08:00');
      expect(heureDepuis('1330'), '13:30');
      expect(heureDepuis('25h'), isNull);
      expect(heureDepuis('midi'), isNull);
      expect(heureCourte('07:30:00'), '07:30');
    });

    test('chevauchements refusés, créneaux voisins acceptés', () {
      final l = [creneau('a', 1, '07:30:00', '08:30:00')];
      expect(
        verifierCreneau(jour: 1, debut: '08:00', fin: '09:00', existants: l),
        'Ce créneau chevauche 07:30 – 08:30 le Lundi.',
      );
      expect(
        verifierCreneau(jour: 1, debut: '08:30', fin: '09:00', existants: l),
        isNull,
      );
      expect(
        verifierCreneau(jour: 2, debut: '08:00', fin: '09:00', existants: l),
        isNull,
      );
      expect(
        verifierCreneau(
          jour: 1,
          debut: '07:30',
          fin: '08:00',
          existants: l,
          id: 'a',
        ),
        isNull,
        reason: 'le créneau modifié ne se chevauche pas lui-même',
      );
      expect(
        verifierCreneau(jour: 1, debut: '09:00', fin: '08:00', existants: l),
        'L’heure de fin doit être après l’heure de début.',
      );
    });

    test('grille de la semaine (impression)', () {
      final g = grilleSemaine(
        [
          creneau('a', 1, '07:30', '08:30', matiere: 'm1'),
          creneau('b', 3, '07:30', '08:30', activite: 'Sport'),
          creneau('c', 1, '08:30', '09:30', activite: 'Récréation'),
        ],
        {'m1': 'Lecture'},
      );
      expect(g.jours, [1, 2, 3, 4, 5]);
      expect(g.plages, [('07:30', '08:30'), ('08:30', '09:30')]);
      expect(g.cases[0], ['Lecture', '', 'Sport', '', '']);
      expect(g.cases[1], ['Récréation', '', '', '', '']);
    });
  });

  group('absences', () {
    test('par classe et par élève, taux de présence', () {
      final l = [
        presence('e1', '2026-11-02', 'present'),
        presence('e2', '2026-11-02', 'absent'),
        presence('e1', '2026-11-03', 'retard'),
        presence('e2', '2026-11-03', 'absent'),
        presence('x', '2026-11-03', 'absent', classe: 'autre'),
      ];
      final c = absencesParClasse(l, [('c', 'CM1 A', 2)]).single;
      expect((c.joursAppel, c.absences, c.retards), (2, 2, 1));
      expect(pourcent(c.taux), '50 %');
      final e = absencesParEleve(l, {
        'e1': ('TEST Aïcha', 'CM1 A'),
        'e2': ('TEST Boukary', 'CM1 A'),
      });
      expect(
        [for (final x in e) (x.nom, x.absences, x.retards)],
        [('TEST Boukary', 2, 0), ('TEST Aïcha', 0, 1)],
      );
      expect(pourcent(200 / 3), '66,7 %');
      expect(pourcent(null), '—');
    });

    test('périodes', () {
      // Jeudi 5 novembre 2026.
      expect(Periode.jour.bornes('2026-11-05'), ('2026-11-05', '2026-11-05'));
      expect(Periode.semaine.bornes('2026-11-05'), (
        '2026-11-02',
        '2026-11-05',
      ));
      expect(Periode.mois.bornes('2026-11-05'), ('2026-11-01', '2026-11-05'));
      expect(Periode.annee.bornes('2026-11-05'), ('2026-09-01', '2026-11-05'));
      expect(Periode.annee.bornes('2027-03-01', rentree: '2026-10-01'), (
        '2026-10-01',
        '2027-03-01',
      ));
    });
  });

  group('accueil par thèmes', () {
    test('8 gros boutons au plus, dans l’ordre choisi ; modules '
        'désactivés absents', () {
      final d = themesAccueil(
        const ProfilAccueil(
          role: 'directeur',
          droits: {
            'finances',
            'cartes',
            'eleves',
            'registres',
            'formulaires',
            'archives',
            'cantine',
          },
        ),
      );
      expect(
        [for (final t in d) t.label],
        [
          'Élèves et classes',
          'Pédagogie',
          'Administration',
          'Finances',
          'Rapports',
          'Bibliothèque et IA',
          'Mon école',
        ],
      );
      String routes(List<ThemeAccueil> l) => [
        for (final t in l)
          for (final e in t.entrees) e.route,
      ].join(' ');
      expect(routes(d), isNot(contains('/cantine')));
      expect(routes(d), isNot(contains('/maternelle')));
      final avec = themesAccueil(
        const ProfilAccueil(
          role: 'directeur',
          droits: {'finances', 'registres'},
          cantine: true,
          maternelle: true,
        ),
      );
      expect(
        routes(avec),
        allOf(contains('/cantine'), contains('/maternelle')),
      );

      final e = themesAccueil(
        const ProfilAccueil(role: 'enseignant', droits: {}),
      );
      expect(
        [for (final t in e) t.label],
        [
          'Ma classe',
          'Notes et bulletins',
          'Assistant IA et mes fiches',
          'Bibliothèque',
          'Mon compte',
        ],
      );
      expect(e.first.route, '/theme/classe');
      expect(
        e[1].route,
        '/notes',
        reason: 'une seule entrée : ouverte directement',
      );

      // Délégué « cantine » : pas de rapports, pas de finances scolaires.
      final c = themesAccueil(
        const ProfilAccueil(
          role: 'delegue',
          droits: {'cantine'},
          cantine: true,
        ),
      );
      expect(
        [for (final t in c) t.label],
        ['Pédagogie', 'Cantine scolaire', 'Bibliothèque et IA', 'Mon compte'],
      );
      expect(c[1].route, '/cantine');
      for (final p in [d, e, c, avec]) {
        expect(p.length, lessThanOrEqualTo(8));
      }
    });
  });

  test('recherche sans accents, par début de mot', () {
    expect(normaliser('Aïcha ÉCOLE-Test'), 'aicha ecole test');
    expect(correspond('aich', ['TEST', 'Aïcha']), isTrue);
    expect(correspond('test aich', ['TEST Aïcha']), isTrue);
    expect(correspond('cha', ['TEST Aïcha']), isFalse);
    expect(correspond('a', ['']), isFalse);
  });

  test('notifications : non lues et importantes d’abord', () {
    const a = NotificationEcole(id: 'a', titre: 'A', route: '/');
    const b = NotificationEcole(
      id: 'b',
      titre: 'B',
      route: '/',
      importante: true,
    );
    const c = NotificationEcole(id: 'c', titre: 'C', route: '/');
    expect(
      [
        for (final n in trierNotifications([a, b, c], {'b'})) n.id,
      ],
      ['a', 'c', 'b'],
    );
  });

  test('rapports : effectifs F/G avec total, Excel en lignes', () {
    final t = tableauEffectifs([
      ('CM1 A', const Effectif(filles: 2, garcons: 1)),
      ('CE1 A', const Effectif(garcons: 1, autres: 1)),
    ]);
    expect(t.total, ['TOTAL', 2, 2, 1, 5]);
    final r = Rapport(
      code: 'Effectifs',
      titre: 'Effectifs',
      ecole: 'École Test',
      annee: '2025-2026',
      tableaux: [t],
    );
    expect(r.lignesExcel.first, ['Effectifs']);
    expect(r.lignesExcel, contains(equals(['CM1 A', 2, 1, 0, 3])));
    expect(texte(texteCase(25000)), '25 000');
    expect(texteCase(14.5), '14,5');
    expect(texteCase(null), '—');
  });

  testWidgets('directeur : accueil par thèmes (8 boutons au plus), tableau '
      'de bord, emploi du temps (créneau, chevauchement, copie, PDF), '
      'recherche, notifications, rapports', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await calme(tester);

    // Accueil : tableau de bord et recherche, puis 7 thèmes.
    expect(find.byType(BigButton), findsNWidgets(7));
    expect(find.text('Tableau de bord'), findsOne);
    expect(find.text('Rechercher'), findsOne);
    expect(find.byKey(const Key('cloche')), findsOne);

    // Tableau de bord : l'essentiel en un clic.
    await tap(tester, find.text('Tableau de bord'));
    expect(
      tester.widget<Text>(find.byKey(const Key('bord-total'))).data,
      '4 élèves',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('bord-fg'))).data,
      '2 filles • 2 garçons',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('bord-appels'))).data,
      'Appel fait : 0 classe(s) sur 2',
    );
    expect(find.byKey(const Key('bord-finances')), findsOne);
    expect(
      find.byKey(const Key('bord-cantine')),
      findsNothing,
      reason: 'cantine désactivée : jamais au tableau de bord',
    );
    await retour(tester);

    // Emploi du temps : Pédagogie → Emploi du temps → CM1 A.
    await tap(tester, find.text('Pédagogie'));
    await tap(tester, find.text('Emploi du temps'));
    await tap(tester, find.byKey(const Key('classe-c-cm1')));
    await tap(tester, find.text('Ajouter un créneau'));
    await tap(tester, find.byKey(const Key('creneau-jour')));
    await tap(tester, find.text('Lundi').last);
    await saisir(tester, 'creneau-debut', '7h30');
    await saisir(tester, 'creneau-fin', '8h30');
    await saisir(tester, 'creneau-activite', 'Lecture');
    await tap(tester, find.text('Enregistrer'));
    expect(find.text('07:30 – 08:30'), findsOne);
    expect(find.text('Lecture'), findsOne);

    // Un créneau qui chevauche est refusé.
    await tap(tester, find.text('Ajouter un créneau'));
    await tap(tester, find.byKey(const Key('creneau-jour')));
    await tap(tester, find.text('Lundi').last);
    await saisir(tester, 'creneau-debut', '8h');
    await saisir(tester, 'creneau-fin', '9h');
    await saisir(tester, 'creneau-activite', 'Calcul');
    await tap(tester, find.text('Enregistrer'));
    expect(
      tester.widget<Text>(find.byKey(const Key('creneau-erreur'))).data,
      'Ce créneau chevauche 07:30 – 08:30 le Lundi.',
    );
    await tap(tester, find.text('Annuler'));

    // Copie vers le CE1 A.
    await tap(tester, find.text('Copier vers une autre classe'));
    await tap(tester, find.byKey(const Key('copie-cible')));
    await tap(tester, find.text('CE1 A').last);
    await tap(tester, find.text('Copier'));
    await calme(tester);
    final db = base(tester);
    final copies = await (db.select(
      db.timetableSlots,
    )..where((s) => s.classId.equals('c-ce1'))).get();
    expect(
      [for (final c in copies) (c.weekday, c.startsAt, c.activityLabel)],
      [(1, '07:30', 'Lecture')],
    );

    // Impression.
    await tap(tester, find.text('Imprimer (PDF)'));
    await AppHarness.settle(tester);
    expect(h.pdfSortis.keys, contains('Emploi_du_temps_CM1 A.pdf'));
    await accueil(tester);

    // Recherche rapide : « aich » trouve l'élève et ses résultats.
    await tap(tester, find.text('Rechercher'));
    await tester.enterText(find.byKey(const Key('recherche')), 'aich');
    await AppHarness.settle(tester);
    expect(find.text('TEST Aïcha'), findsOne);
    expect(find.text('Résultats de TEST Aïcha'), findsOne);
    await tester.enterText(find.byKey(const Key('recherche')), 'appel');
    await AppHarness.settle(tester);
    expect(find.text('Faire l’appel'), findsOne, reason: 'les écrans aussi');
    await accueil(tester);

    // Notifications (jour de classe : appel à faire).
    await tap(tester, find.byKey(const Key('cloche')));
    if (DateTime.now().weekday <= 5) {
      expect(find.text('Appel à faire : CM1 A'), findsOne);
      await tap(tester, find.text('Tout marquer comme lu'));
      expect(find.text('Tout marquer comme lu'), findsNothing);
    }
    await accueil(tester);

    // Rapports : PDF et Excel.
    await tap(tester, find.text('Rapports'));
    await tap(tester, find.byKey(const Key('pdf-Effectifs')));
    await AppHarness.settle(tester);
    expect(h.pdfSortis.keys, contains('Effectifs_2025-2026.pdf'));
    await tap(tester, find.byKey(const Key('excel-Absences')));
    await AppHarness.settle(tester);
    expect(h.fichiersSortis.keys, contains('Absences_2025-2026.xlsx'));
    await tap(tester, find.byKey(const Key('pdf-Synthese')));
    await AppHarness.settle(tester);
    expect(h.pdfSortis.keys, contains('Synthese_2025-2026.pdf'));
    expect(find.text('Rapports de la cantine'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('enseignant : « Ma journée », appel (tous présents par défaut, '
      'un absent), statistiques ; l’emploi du temps d’une autre classe '
      'n’est pas modifiable', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    // Le serveur n'envoie à l'enseignant que sa classe (RLS).
    h.server.visible = (t, r) =>
        !((t == 'classes' && r['id'] == 'c-ce1') ||
            (t == 'enrollments' && r['class_id'] == 'c-ce1') ||
            (t == 'students' && r['id'] == 'e-3'));
    await h.pump(tester);
    await h.login(tester, '70112233');
    await calme(tester);

    expect(find.byKey(const Key('ma-journee')), findsOne);
    expect(find.text('Ma classe'), findsOne);
    expect(find.text('Rapports'), findsNothing);
    expect(find.byType(BigButton).evaluate().length, lessThanOrEqualTo(8));

    await tap(tester, find.byKey(const Key('faire-appel-c-cm1')));
    expect(find.textContaining('3 présent(s), 0 absent(s)'), findsOne);
    await tap(
      tester,
      find.descendant(
        of: find.byKey(const Key('appel-e-1')),
        matching: find.text('Absent'),
      ),
    );
    expect(find.textContaining('2 présent(s), 1 absent(s)'), findsOne);
    await tap(tester, find.byKey(const Key('valider-appel')));
    await calme(tester);
    final db = base(tester);
    final l = await db.select(db.attendance).get();
    expect(
      {for (final a in l) a.studentId: a.status},
      {'e-0': 'present', 'e-1': 'absent', 'e-2': 'present'},
    );
    await h.synchroniser(tester);
    expect(h.server.table('attendance').length, 3, reason: 'envoyé au serveur');
    await accueil(tester);
    expect(find.byKey(const Key('appel-fait-c-cm1')), findsOne);
    expect(
      texte(
        tester.widget<Text>(find.byKey(const Key('appel-fait-c-cm1'))).data,
      ),
      'Appel fait (CM1 A) : 1 absent(s).',
    );

    // Absences : la statistique du mois.
    await tap(tester, find.text('Ma classe'));
    await tap(tester, find.text('Absences'));
    expect(find.text('TEST Boukary'), findsOne);
    await accueil(tester);

    // Tableau de bord de l'enseignant.
    await tap(tester, find.text('Mon tableau de bord'));
    expect(
      tester.widget<Text>(find.byKey(const Key('bord-absents'))).data,
      '1 absent(s) aujourd’hui',
    );
    expect(find.byKey(const Key('bord-finances')), findsNothing);
    await h.dispose(tester);
  });

  test('base : un créneau de l’emploi du temps se lit en « HH:MM »', () {
    expect(plage(creneau('a', 1, '07:30:00', '08:30:00')), '07:30 – 08:30');
  });
}
