import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/staff/domain/anciennete.dart';

/// Données des formulaires B1, B2, B3 : une ligne = une liste de textes dans
/// l'ordre EXACT des colonnes de l'ANNEXE B (R12). Tout vient des fiches
/// (« saisir une fois, réutiliser partout ») ; rien n'est inventé.

String jjmmaaaa(String? iso) {
  final d = iso == null ? null : DateTime.tryParse(iso);
  if (d == null) return '';
  String deux(int n) => n.toString().padLeft(2, '0');
  return '${deux(d.day)}/${deux(d.month)}/${d.year}';
}

String _nom(String nom, String prenoms) => '$nom $prenoms'.trim();

// ------------------------------- B1 -----------------------------------

const enteteB1 = [
  'N° d’ordre',
  'Matricule',
  'Nom et Prénoms',
  'Emploi',
  'Catégorie ; Échelon',
  'Date de naissance',
  'Sexe',
  'Service/classe tenue',
  'Fonction ou poste occupé',
  'Dernier diplôme académique',
  'Générale',
  'Dans l’emploi',
  'Dans la région',
  'Dans la fonction',
  'Contact',
];

/// Lignes de la fiche de renseignement du personnel : enseignants présents
/// (non partis), triés par nom puis prénoms (ordre à confirmer).
List<List<String>> lignesB1({
  required List<TeacherRow> enseignants,
  required List<TeacherAssignmentRow> affectations,
  required List<ClassRow> classes,
  required List<TeacherDiplomaRow> diplomes,
  required DateTime reference,
}) {
  final aff = {for (final a in affectations) a.teacherId: a};
  final nomsClasses = {for (final c in classes) c.id: c.name};
  final presents =
      enseignants
          .where((t) => t.status != 'parti' && t.deletedAt == null)
          .toList()
        ..sort(
          (a, b) => _nom(
            a.lastName,
            a.firstNames,
          ).compareTo(_nom(b.lastName, b.firstNames)),
        );
  String anc(String? depuis) =>
      Anciennete.entre(
        depuis == null ? null : DateTime.tryParse(depuis),
        reference,
      )?.texte ??
      '';
  return [
    for (final (i, t) in presents.indexed)
      () {
        final a = aff[t.id];
        final academiques =
            diplomes
                .where(
                  (d) =>
                      d.teacherId == t.id &&
                      d.isAcademic &&
                      d.deletedAt == null,
                )
                .toList()
              ..sort(
                (x, y) => (y.deliveredOn ?? '').compareTo(x.deliveredOn ?? ''),
              );
        return [
          '${i + 1}',
          t.matricule ?? '',
          _nom(t.lastName, t.firstNames),
          t.emploi ?? '',
          [t.categorie, t.echelon].whereType<String>().join(' ; '),
          jjmmaaaa(t.birthDate),
          t.sex ?? '',
          nomsClasses[a?.classId] ?? a?.serviceLabel ?? '',
          a?.fonction ?? '',
          academiques.firstOrNull?.nature ?? '',
          anc(t.seniorityGeneralFrom),
          anc(t.seniorityEmploiFrom),
          anc(t.seniorityRegionFrom),
          anc(t.seniorityFonctionFrom),
          t.phone ?? '',
        ];
      }(),
  ];
}

// ------------------------------- B2 -----------------------------------

const enteteB2 = [
  'Numéro d’ordre',
  'Noms et prénoms des élèves',
  'Date de naissance',
  'Noms et prénoms des parents ou tuteurs',
  'Profession et domicile des parents ou tuteurs',
  'Date de l’entrée à l’école',
  'Date de l’obtention du C.E.P.',
  'Date de sortie définitive de l’école',
  'Observations',
];

/// Registre matricule : TOUS les élèves admis (y compris sortis), dans
/// l'ordre des numéros d'ordre. Les élèves sans numéro définitif (créés hors
/// ligne, pas encore synchronisés) ne sont pas imprimés : voir [enAttenteB2].
List<List<String>> lignesB2({
  required List<StudentRow> eleves,
  required List<GuardianRow> parents,
  required List<StudentRegistryRow> registres,
}) {
  final reg = {for (final r in registres) r.id: r};
  final numerotes =
      eleves
          .where((s) => s.registryNumber != null && s.deletedAt == null)
          .toList()
        ..sort((a, b) => a.registryNumber!.compareTo(b.registryNumber!));
  return [
    for (final s in numerotes)
      () {
        final ps =
            parents
                .where(
                  (g) =>
                      g.studentId == s.id &&
                      g.deletedAt == null &&
                      g.relation != 'logeur',
                )
                .toList()
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        final r = reg[s.id];
        final observations = [
          if (r?.originSchool case final o?)
            if (!(r?.registryObservations ?? '').contains(o)) 'Venant de : $o',
          ?r?.registryObservations,
        ].join('\n');
        return [
          '${s.registryNumber}',
          _nom(s.lastName, s.firstNames),
          jjmmaaaa(s.birthDate),
          ps.map((g) => g.fullName).join('\n'),
          ps
              .map(
                (g) =>
                    [g.profession, g.domicile].whereType<String>().join(', '),
              )
              .where((x) => x.isNotEmpty)
              .join('\n'),
          jjmmaaaa(s.entryDate),
          jjmmaaaa(r?.cepDate),
          jjmmaaaa(s.exitDate),
          observations,
        ];
      }(),
  ];
}

int enAttenteB2(List<StudentRow> eleves) =>
    eleves.where((s) => s.registryNumber == null && s.deletedAt == null).length;

// ------------------------------- B3 -----------------------------------

/// Page de gauche (colonnes 1 à 7) puis page de droite (8 à 13) : le
/// registre est sur une double page (interprétation à confirmer).
const enteteB3Gauche = [
  'Noms et prénoms',
  'Date et lieu de naissance',
  'Date de la nomination dans la commune',
  'Titulaire ou stagiaire (T ou S)',
  'Classe',
  'Service antérieur — Élève à l’école de (dates d’entrée et de sortie)',
  'Service antérieur — Date de la première nomination dans l’enseignement',
];
const _b3c8 =
    'Communes dans lesquelles il a fonctionné successivement (donner la date '
    'de chaque nomination)';
const _b3c11 =
    'Titres de capacité (nature de chacun des diplômes et date de leur '
    'délivrance)';
const _b3c12 =
    'Date de cessation de fonctions dans la commune et indication du nouveau '
    'poste';
const List<String> enteteB3Droite = [
  _b3c8,
  'Interruptions de service (causes et durées)',
  'Récompenses obtenues',
  _b3c11,
  _b3c12,
  'Observations',
];

class LigneB3 {
  const new(this.gauche, this.droite);
  final List<String> gauche;
  final List<String> droite;
}

/// Registre du personnel : tous les enseignants (y compris partis), dans
/// l'ordre de nomination dans la commune puis par nom.
List<LigneB3> lignesB3({
  required List<TeacherRow> enseignants,
  required List<TeacherAssignmentRow> affectations,
  required List<ClassRow> classes,
  required List<TeacherPostingRow> communes,
  required List<TeacherInterruptionRow> interruptions,
  required List<TeacherAwardRow> recompenses,
  required List<TeacherDiplomaRow> diplomes,
}) {
  final aff = {for (final a in affectations) a.teacherId: a};
  final nomsClasses = {for (final c in classes) c.id: c.name};
  final liste = enseignants.where((t) => t.deletedAt == null).toList()
    ..sort((a, b) {
      final c = (a.communeNominationDate ?? '9999').compareTo(
        b.communeNominationDate ?? '9999',
      );
      return c != 0
          ? c
          : _nom(
              a.lastName,
              a.firstNames,
            ).compareTo(_nom(b.lastName, b.firstNames));
    });
  List<T> de<T>(List<T> l, String Function(T) id, String tid) =>
      l.where((x) => id(x) == tid).toList();
  String entreSortie(TeacherRow t) {
    final dates = [
      if (t.pupilSchoolEntryDate != null)
        'entrée le ${jjmmaaaa(t.pupilSchoolEntryDate)}',
      if (t.pupilSchoolExitDate != null)
        'sortie le ${jjmmaaaa(t.pupilSchoolExitDate)}',
    ].join(', ');
    return [
      t.pupilSchoolName,
      if (dates.isNotEmpty) '($dates)',
    ].whereType<String>().join(' ');
  }

  return [
    for (final t in liste)
      LigneB3(
        [
          _nom(t.lastName, t.firstNames),
          [
            jjmmaaaa(t.birthDate),
            if (t.birthPlace != null) 'à ${t.birthPlace}',
          ].where((x) => x.isNotEmpty).join(' '),
          jjmmaaaa(t.communeNominationDate),
          t.tenureStatus ?? '',
          nomsClasses[aff[t.id]?.classId] ?? aff[t.id]?.serviceLabel ?? '',
          entreSortie(t),
          jjmmaaaa(t.firstTeachingNominationDate),
        ],
        [
          (de(
                communes.where((c) => c.deletedAt == null).toList(),
                (c) => c.teacherId,
                t.id,
              )..sort(
                (a, b) => a.sortOrder != b.sortOrder
                    ? a.sortOrder.compareTo(b.sortOrder)
                    : (a.nominatedOn ?? '').compareTo(b.nominatedOn ?? ''),
              ))
              .map(
                (c) => [
                  c.commune,
                  if (c.nominatedOn != null) '(${jjmmaaaa(c.nominatedOn)})',
                ].join(' '),
              )
              .join('\n'),
          de(
                interruptions.where((x) => x.deletedAt == null).toList(),
                (x) => x.teacherId,
                t.id,
              )
              .map((x) {
                final periode = [
                  if (x.startsOn != null) 'du ${jjmmaaaa(x.startsOn)}',
                  if (x.endsOn != null) 'au ${jjmmaaaa(x.endsOn)}',
                  ?x.durationText,
                ].join(' ');
                return periode.isEmpty ? x.cause : '${x.cause} : $periode';
              })
              .join('\n'),
          de(
                recompenses.where((x) => x.deletedAt == null).toList(),
                (x) => x.teacherId,
                t.id,
              )
              .map(
                (x) => [
                  x.label,
                  if (x.awardedOn != null) '(${jjmmaaaa(x.awardedOn)})',
                ].join(' '),
              )
              .join('\n'),
          (de(
                diplomes.where((x) => x.deletedAt == null).toList(),
                (x) => x.teacherId,
                t.id,
              )..sort(
                (a, b) => (a.deliveredOn ?? '').compareTo(b.deliveredOn ?? ''),
              ))
              .map(
                (x) => [
                  x.nature,
                  if (x.deliveredOn != null) '(${jjmmaaaa(x.deliveredOn)})',
                ].join(' '),
              )
              .join('\n'),
          [
            jjmmaaaa(t.communeCessationDate),
            if (t.newPost != null) 'Nouveau poste : ${t.newPost}',
          ].where((x) => x.isNotEmpty).join('\n'),
          t.observations ?? '',
        ],
      ),
  ];
}
