import 'package:ecoleplus/core/db/app_database.dart';

/// Libellés des présences.
const statutsPresence = {
  'present': 'Présent',
  'absent': 'Absent',
  'retard': 'En retard',
};

/// Compte des absences et retards d'un élève sur une période.
class AbsencesEleve {
  const new(this.studentId, this.nom, this.classe, this.absences, this.retards);
  final String studentId;
  final String nom;
  final String classe;
  final int absences;
  final int retards;
}

/// Statistiques d'une classe sur une période.
class AbsencesClasse {
  const new({
    required this.classId,
    required this.classe,
    required this.effectif,
    required this.joursAppel,
    required this.presences,
    required this.absences,
    required this.retards,
  });
  final String classId;
  final String classe;
  final int effectif;

  /// Jours où l'appel a été fait.
  final int joursAppel;
  final int presences;
  final int absences;
  final int retards;

  /// Taux de présence en % (présents + retards / appels) ; null sans appel.
  double? get taux {
    final n = presences + absences + retards;
    return n == 0 ? null : (presences + retards) * 100 / n;
  }
}

/// Présences de la période [du]–[au] (dates incluses, « AAAA-MM-JJ »).
Iterable<AttendanceRow> dansPeriode(
  Iterable<AttendanceRow> l,
  String du,
  String au,
) => l.where(
  (a) =>
      a.deletedAt == null &&
      a.day.compareTo(du) >= 0 &&
      a.day.compareTo(au) <= 0,
);

/// Statistiques par classe. [classes] : (id, nom, effectif).
List<AbsencesClasse> absencesParClasse(
  Iterable<AttendanceRow> presences,
  List<(String, String, int)> classes,
) => [
  for (final (id, nom, effectif) in classes)
    () {
      final l = presences.where((a) => a.classId == id).toList();
      int n(String s) => l.where((a) => a.status == s).length;
      return AbsencesClasse(
        classId: id,
        classe: nom,
        effectif: effectif,
        joursAppel: {for (final a in l) a.day}.length,
        presences: n('present'),
        absences: n('absent'),
        retards: n('retard'),
      );
    }(),
];

/// Élèves ayant au moins une absence ou un retard, les plus absents
/// d'abord. [eleves] : id → (nom, classe).
List<AbsencesEleve> absencesParEleve(
  Iterable<AttendanceRow> presences,
  Map<String, (String, String)> eleves,
) {
  final abs = <String, int>{};
  final ret = <String, int>{};
  for (final a in presences) {
    if (!eleves.containsKey(a.studentId)) continue;
    if (a.status == 'absent') abs[a.studentId] = (abs[a.studentId] ?? 0) + 1;
    if (a.status == 'retard') ret[a.studentId] = (ret[a.studentId] ?? 0) + 1;
  }
  final ids = {...abs.keys, ...ret.keys};
  return [
    for (final id in ids)
      AbsencesEleve(
        id,
        eleves[id]!.$1,
        eleves[id]!.$2,
        abs[id] ?? 0,
        ret[id] ?? 0,
      ),
  ]..sort(
    (a, b) => a.absences != b.absences
        ? b.absences.compareTo(a.absences)
        : a.retards != b.retards
        ? b.retards.compareTo(a.retards)
        : a.nom.compareTo(b.nom),
  );
}

/// Période choisie à l'écran.
enum Periode {
  jour('Aujourd’hui'),
  semaine('Cette semaine'),
  mois('Ce mois-ci'),
  annee('Depuis la rentrée');

  new(this.libelle);
  final String libelle;

  /// (du, au) pour [aujourdhui] ; [rentree] : début de l'année scolaire.
  (String, String) bornes(String aujourdhui, {String? rentree}) {
    final d = DateTime.parse(aujourdhui);
    String f(DateTime x) => x.toIso8601String().substring(0, 10);
    return switch (this) {
      Periode.jour => (aujourdhui, aujourdhui),
      Periode.semaine => (
        f(d.subtract(Duration(days: d.weekday - 1))),
        aujourdhui,
      ),
      Periode.mois => ('${aujourdhui.substring(0, 7)}-01', aujourdhui),
      Periode.annee => (
        rentree ?? '${d.month >= 9 ? d.year : d.year - 1}-09-01',
        aujourdhui,
      ),
    };
  }
}

/// « 92 % », « 87,5 % », « — ».
String pourcent(double? p) {
  if (p == null) return '—';
  final r = (p * 10).round() / 10;
  final t = r == r.roundToDouble()
      ? '${r.round()}'
      : r.toString().replaceAll('.', ',');
  return '$t %';
}

/// Totaux d'une période calculés par la base du téléphone.
class TotauxPresences {
  const new(this.classes, this.eleves);

  /// Classe → jours d'appel, présents, absents, retards.
  final Map<String, ({int jours, int presents, int absents, int retards})>
  classes;

  /// Élève → (absences, retards), seulement s'il en a.
  final Map<String, (int, int)> eleves;

  /// Statistiques par classe. [classes] : (id, nom, effectif).
  List<AbsencesClasse> parClasse(List<(String, String, int)> liste) => [
    for (final (id, nom, effectif) in liste)
      AbsencesClasse(
        classId: id,
        classe: nom,
        effectif: effectif,
        joursAppel: classes[id]?.jours ?? 0,
        presences: classes[id]?.presents ?? 0,
        absences: classes[id]?.absents ?? 0,
        retards: classes[id]?.retards ?? 0,
      ),
  ];

  /// Élèves absents ou en retard, les plus absents d'abord.
  /// [noms] : id → (nom, classe) ; les autres élèves sont ignorés.
  List<AbsencesEleve> parEleve(Map<String, (String, String)> noms) =>
      [
        for (final MapEntry(key: id, value: (a, r)) in eleves.entries)
          if (noms[id] case (final nom, final classe))
            AbsencesEleve(id, nom, classe, a, r),
      ]..sort(
        (x, y) => x.absences != y.absences
            ? y.absences.compareTo(x.absences)
            : x.retards != y.retards
            ? y.retards.compareTo(x.retards)
            : x.nom.compareTo(y.nom),
      );
}
