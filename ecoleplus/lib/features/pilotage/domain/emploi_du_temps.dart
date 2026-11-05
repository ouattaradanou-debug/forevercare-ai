import 'package:ecoleplus/core/db/app_database.dart';

/// Jours de l'emploi du temps (1 = lundi). Le dimanche n'est pas proposé.
const joursSemaine = {
  1: 'Lundi',
  2: 'Mardi',
  3: 'Mercredi',
  4: 'Jeudi',
  5: 'Vendredi',
  6: 'Samedi',
};

/// « 7h30 », « 07:30 », « 7:30 », « 730 » → « 07:30 » ; null si invalide.
String? heureDepuis(String texte) {
  final t = texte.trim().toLowerCase().replaceAll(' ', '');
  final m =
      RegExp(r'^(\d{1,2})[h:.]?(\d{2})?$').firstMatch(t) ??
      RegExp(r'^(\d{1,2})(\d{2})$').firstMatch(t);
  if (m == null) return null;
  final h = int.parse(m.group(1)!);
  final mn = int.parse(m.group(2) ?? '0');
  if (h > 23 || mn > 59) return null;
  return '${h.toString().padLeft(2, '0')}:${mn.toString().padLeft(2, '0')}';
}

/// « 07:30:00 » (serveur) ou « 07:30 » → minutes depuis minuit.
int minutes(String heure) {
  final p = heure.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

/// « 07:30:00 » → « 07:30 ».
String heureCourte(String heure) =>
    heure.length >= 5 ? heure.substring(0, 5) : heure;

/// « 07:30 – 08:30 ».
String plage(TimetableSlotRow s) =>
    '${heureCourte(s.startsAt)} – ${heureCourte(s.endsAt)}';

/// Intitulé d'un créneau : la matière, sinon l'activité libre.
String intitule(TimetableSlotRow s, Map<String, String> matieres) =>
    (s.subjectId == null ? null : matieres[s.subjectId]) ??
    s.activityLabel ??
    'Activité';

/// Message d'erreur d'un créneau saisi (null : correct). [existants] : les
/// créneaux de la classe (le créneau modifié [id] est ignoré).
String? verifierCreneau({
  required int jour,
  required String debut,
  required String fin,
  required List<TimetableSlotRow> existants,
  String? id,
}) {
  if (!joursSemaine.containsKey(jour)) return 'Choisissez le jour.';
  if (minutes(debut) >= minutes(fin)) {
    return 'L’heure de fin doit être après l’heure de début.';
  }
  for (final s in existants) {
    if (s.id == id || s.weekday != jour || s.deletedAt != null) continue;
    if (minutes(debut) < minutes(s.endsAt) &&
        minutes(s.startsAt) < minutes(fin)) {
      return 'Ce créneau chevauche ${plage(s)} le ${joursSemaine[jour]}.';
    }
  }
  return null;
}

/// Créneaux triés par jour puis par heure.
List<TimetableSlotRow> trierCreneaux(Iterable<TimetableSlotRow> l) =>
    l.where((s) => s.deletedAt == null).toList()..sort(
      (a, b) => a.weekday != b.weekday
          ? a.weekday.compareTo(b.weekday)
          : minutes(a.startsAt).compareTo(minutes(b.startsAt)),
    );

/// Grille de la semaine (impression) : une ligne par plage horaire, une
/// colonne par jour utilisé (lundi à vendredi au moins).
class GrilleSemaine {
  const new(this.jours, this.plages, this.cases);
  final List<int> jours;

  /// (début, fin) en « HH:MM ».
  final List<(String, String)> plages;

  /// Par plage puis par jour : l’intitulé (vide : rien).
  final List<List<String>> cases;
}

GrilleSemaine grilleSemaine(
  List<TimetableSlotRow> creneaux,
  Map<String, String> matieres, {
  Map<String, String> enseignants = const {},
}) {
  final l = trierCreneaux(creneaux);
  final jours = {
    1, 2, 3, 4, 5, //
    for (final s in l) s.weekday,
  }.toList()..sort();
  final plages =
      {for (final s in l) (heureCourte(s.startsAt), heureCourte(s.endsAt))}
          .toList()
        ..sort(
          (a, b) => minutes(a.$1) != minutes(b.$1)
              ? minutes(a.$1).compareTo(minutes(b.$1))
              : minutes(a.$2).compareTo(minutes(b.$2)),
        );
  return GrilleSemaine(jours, plages, [
    for (final (d, f) in plages)
      [
        for (final j in jours)
          [
            for (final s in l)
              if (s.weekday == j &&
                  heureCourte(s.startsAt) == d &&
                  heureCourte(s.endsAt) == f)
                [intitule(s, matieres), ?enseignants[s.teacherId]].join('\n'),
          ].join(' / '),
      ],
  ]);
}

/// Jour de la semaine d'une date « AAAA-MM-JJ » (1 = lundi).
int jourDe(String date) => DateTime.parse(date).weekday;
