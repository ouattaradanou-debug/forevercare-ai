import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/classes/data/classes_repository.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:ecoleplus/features/students/presentation/students_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

/// Niveaux que l'école peut ouvrir : primaire si géré, maternelle seulement
/// si le module est actif (R11).
List<LevelRow> niveauxPermis(
  List<LevelRow> niveaux, {
  required bool primaire,
  required bool maternelle,
}) => [
  for (final n in niveaux)
    if ((n.cycle == 'primaire' && primaire) ||
        (n.cycle == 'maternelle' && maternelle))
      n,
];

String texteEffectif(Effectif e) =>
    '${e.total} élève${e.total > 1 ? 's' : ''} '
    '(${e.filles} F, ${e.garcons} G'
    '${e.autres > 0 ? ', ${e.autres} non renseigné' : ''})';

/// Vue des classes de l'année : effectifs, filles/garçons, enseignant.
class ClassesPage extends ConsumerWidget {
  const new({super.key});

  Future<void> _ajouter(
    BuildContext context,
    WidgetRef ref,
    SchoolRow school,
    List<LevelRow> permis,
    List<TeacherRow> enseignants,
  ) async {
    if (permis.isEmpty) return;
    var niveau = permis.first;
    String? enseignant;
    final nom = TextEditingController(text: '${niveau.label} A');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('Nouvelle classe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<LevelRow>(
                key: const Key('niveau-classe'),
                initialValue: niveau,
                decoration: const InputDecoration(labelText: 'Niveau'),
                items: [
                  for (final n in permis)
                    DropdownMenuItem(value: n, child: Text(n.label)),
                ],
                onChanged: (n) => setState(() {
                  niveau = n!;
                  nom.text = '${n.label} A';
                }),
              ),
              TexteDictable(
                key: const Key('nom-classe'),
                controller: nom,
                label: 'Nom de la classe (ex. CM1 A)',
              ),
              // L'enseignant voit sa classe dès qu'il est choisi ici.
              DropdownButtonFormField<String?>(
                key: const Key('enseignant-classe'),
                initialValue: enseignant,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Enseignant responsable',
                ),
                items: [
                  const DropdownMenuItem(child: Text('Plus tard')),
                  for (final t in enseignants)
                    if (t.status != 'parti')
                      DropdownMenuItem(
                        value: t.id,
                        child: Text('${t.lastName} ${t.firstNames}'),
                      ),
                ],
                onChanged: (v) => setState(() => enseignant = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Créer la classe'),
            ),
          ],
        ),
      ),
    );
    if (!(ok ?? false) || nom.text.trim().isEmpty || !context.mounted) return;
    await avecMessage(
      context,
      () => ref
          .read(classesRepositoryProvider)
          .createClass(
            schoolId: school.id,
            yearId: school.currentSchoolYearId!,
            levelCode: niveau.code,
            name: nom.text,
            mainTeacherId: enseignant,
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = school?.currentSchoolYearId;
    if (school == null || yearId == null) {
      return const EcoleScaffold(
        title: 'Classes',
        body: InfoMessage('Choisissez d’abord l’année scolaire en cours.'),
      );
    }
    final classes = ref.watch(classesProvider(yearId)).value ?? [];
    final effectifs = ref.watch(effectifsProvider(yearId)).value ?? {};
    final enseignants = {
      for (final t
          in ref.watch(teachersProvider(school.id)).value ??
              const <TeacherRow>[])
        t.id: '${t.lastName} ${t.firstNames}',
    };
    final maternelle =
        ref
            .watch(modulesProvider(school.id))
            .value
            ?.any((m) => m.$1.key == 'maternelle' && m.$2) ??
        false;
    final permis = niveauxPermis(
      ref.watch(levelsProvider).value ?? [],
      primaire: school.managesPrimary,
      maternelle: maternelle,
    );
    final directeur = session.role == 'directeur';
    final total = classes.fold(
      const Effectif(),
      (e, c) => e + (effectifs[c.id] ?? const Effectif()),
    );
    return EcoleScaffold(
      title: 'Classes',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.groups),
              title: Text(
                '${classes.length} classe${classes.length > 1 ? 's' : ''} · '
                '${total.total} élève${total.total > 1 ? 's' : ''}',
              ),
              subtitle: Text(
                [
                  'Filles : ${total.filles}',
                  'Garçons : ${total.garcons}',
                  if (total.autres > 0) 'Non renseigné : ${total.autres}',
                ].join(' · '),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (directeur)
            BigButton(
              icon: Icons.add,
              label: 'Ajouter une classe',
              onPressed: permis.isEmpty
                  ? null
                  : () => _ajouter(
                      context,
                      ref,
                      school,
                      permis,
                      ref.read(teachersProvider(school.id)).value ??
                          const <TeacherRow>[],
                    ),
            ),
          const SizedBox(height: 12),
          if (classes.isEmpty)
            const InfoMessage('Aucune classe pour l’année en cours.'),
          for (final c in classes)
            Card(
              child: ListTile(
                title: Text(c.name),
                subtitle: Text(
                  [
                    texteEffectif(effectifs[c.id] ?? const Effectif()),
                    if (enseignants[c.mainTeacherId] case final n?)
                      'Enseignant : $n',
                  ].join('\n'),
                ),
                isThreeLine: c.mainTeacherId != null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/classes/${c.id}'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Une classe : son nom, son enseignant responsable et ses élèves.
class ClassPage extends ConsumerWidget {
  const new(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(classProvider(id)).value;
    final session = ref.watch(sessionProvider).value!;
    if (c == null) {
      return const EcoleScaffold(
        title: 'Classe',
        body: InfoMessage('Classe introuvable sur ce téléphone.'),
      );
    }
    final directeur = session.role == 'directeur';
    final droits = ref.watch(mesDroitsProvider);
    final peutInscrire =
        droits.contains('eleves') || droits.contains('registres');
    final eleves = [
      for (final e
          in ref
                  .watch(elevesProvider((c.schoolId, c.schoolYearId, false)))
                  .value ??
              const <EleveDansAnnee>[])
        if (e.classe?.id == c.id) e,
    ];
    final enseignants = ref.watch(teachersProvider(c.schoolId)).value ?? [];
    final effectif = ref.watch(effectifsProvider(c.schoolYearId)).value?[c.id];
    return EcoleScaffold(
      title: c.name,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(texteEffectif(effectif ?? const Effectif())),
          const SizedBox(height: 12),
          if (directeur) ...[
            AutoSaveField(
              label: 'Nom de la classe',
              initial: c.name,
              onSave: (v) async {
                if (v != null) {
                  await ref.read(classesRepositoryProvider).updateClass(c.id, {
                    'name': v,
                  });
                }
              },
            ),
            DropdownButtonFormField<String?>(
              initialValue: c.mainTeacherId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Enseignant responsable',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(child: Text('Pas encore choisi')),
                for (final t in enseignants)
                  if (t.status != 'parti')
                    DropdownMenuItem(
                      value: t.id,
                      child: Text('${t.lastName} ${t.firstNames}'),
                    ),
              ],
              onChanged: (v) => ref.read(classesRepositoryProvider).updateClass(
                c.id,
                {'main_teacher_id': v},
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (peutInscrire)
            BigButton(
              icon: Icons.person_add,
              label: 'Inscrire un élève dans cette classe',
              onPressed: () => nouvelEleve(context, ref, classe: c),
            ),
          const SectionTitle('Élèves'),
          if (eleves.isEmpty) const InfoMessage('Aucun élève dans la classe.'),
          for (final e in eleves) EleveTile(e),
        ],
      ),
    );
  }
}

final StreamProviderFamily<ClassRow?, String> classProvider =
    StreamProvider.family<ClassRow?, String>(
      (ref, id) => ref.watch(classesRepositoryProvider).watchClass(id),
    );
