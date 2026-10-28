import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/staff/presentation/teachers_pages.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Numéro d'ordre du registre : définitif, ou provisoire hors ligne.
String numeroAffiche(StudentRow s) => s.registryNumber != null
    ? 'N° ${s.registryNumber}'
    : (s.registryProvisional != null
          ? 'N° provisoire ${s.registryProvisional}'
          : 'N° en attente');

/// Création d'un élève : nom, prénoms, classe (le strict minimum, R5).
Future<void> nouvelEleve(
  BuildContext context,
  WidgetRef ref, {
  ClassRow? classe,
}) async {
  final session = ref.read(sessionProvider).value!;
  final school = ref.read(schoolProvider(session.schoolId)).value;
  final yearId = school?.currentSchoolYearId;
  final classes = yearId == null
      ? const <ClassRow>[]
      : ref.read(classesProvider(yearId)).value ?? const <ClassRow>[];
  final nom = TextEditingController();
  final prenoms = TextEditingController();
  var choisie = classe;
  String? sexe;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => AlertDialog(
        title: const Text('Nouvel élève'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TexteDictable(
                key: const Key('eleve-nom'),
                controller: nom,
                textCapitalization: TextCapitalization.characters,
                label: 'Nom *',
              ),
              TexteDictable(
                key: const Key('eleve-prenoms'),
                controller: prenoms,
                textCapitalization: TextCapitalization.words,
                label: 'Prénoms *',
              ),
              const SizedBox(height: 12),
              ChoiceField(
                label: 'Sexe',
                value: sexe,
                options: const {'F': 'Fille', 'M': 'Garçon'},
                onChanged: (v) => setState(() => sexe = v),
              ),
              DropdownButtonFormField<ClassRow?>(
                key: const Key('eleve-classe'),
                initialValue: choisie,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Classe'),
                items: [
                  const DropdownMenuItem(child: Text('Plus tard')),
                  for (final c in classes)
                    DropdownMenuItem(value: c, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => choisie = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Créer la fiche'),
          ),
        ],
      ),
    ),
  );
  if (!(ok ?? false) || !context.mounted) return;
  if (nom.text.trim().isEmpty || prenoms.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Le nom et les prénoms sont demandés.')),
    );
    return;
  }
  final id = await ref
      .read(studentsRepositoryProvider)
      .creer(
        schoolId: session.schoolId,
        lastName: nom.text,
        firstNames: prenoms.text,
        sex: sexe,
        classe: choisie,
      );
  if (context.mounted) await context.push('/eleves/$id');
}

class EleveTile extends StatelessWidget {
  const new(this.e, {this.avecClasse = false, super.key});
  final EleveDansAnnee e;
  final bool avecClasse;

  @override
  Widget build(BuildContext context) {
    final s = e.eleve;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(s.sex == 'F' ? 'F' : (s.sex == 'M' ? 'G' : '?')),
        ),
        title: Text('${s.lastName} ${s.firstNames}'),
        subtitle: Text(
          [
            if (avecClasse) e.classe?.name ?? 'Sans classe',
            numeroAffiche(s),
            if (s.archivedAt != null) 'Sorti de l’école',
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/eleves/${s.id}'),
      ),
    );
  }
}

/// Liste des élèves de l'école : recherche rapide, filtre par classe.
class StudentsPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends ConsumerState<StudentsPage> {
  final _rechercheCtrl = TextEditingController();
  String _recherche = '';

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  String? _classe;
  bool _sortis = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = school?.currentSchoolYearId;
    if (yearId == null) {
      return const EcoleScaffold(
        title: 'Élèves',
        body: InfoMessage('Choisissez d’abord l’année scolaire en cours.'),
      );
    }
    final droits = ref.watch(mesDroitsProvider);
    final peutCreer = droits.contains('eleves') || droits.contains('registres');
    final tous =
        ref.watch(elevesProvider((session.schoolId, yearId, _sortis))).value ??
        [];
    final classes = ref.watch(classesProvider(yearId)).value ?? [];
    final cle = cleRecherche(_recherche.trim());
    final liste = [
      for (final e in tous)
        if ((_classe == null ||
                (_classe == '' ? e.classe == null : e.classe?.id == _classe)) &&
            (cle.isEmpty ||
                cleRecherche(
                  '${e.eleve.lastName} ${e.eleve.firstNames} '
                  '${e.eleve.studentCode ?? ''} '
                  '${e.eleve.registryNumber ?? ''}',
                ).contains(cle)))
          e,
    ];
    return EcoleScaffold(
      title: 'Élèves',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (peutCreer) ...[
            BigButton(
              icon: Icons.person_add,
              label: 'Ajouter un élève',
              onPressed: () => nouvelEleve(context, ref),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Importer un fichier Excel'),
              onPressed: () => context.push('/import/eleves'),
            ),
            const SizedBox(height: 12),
          ],
          TexteDictable(
            key: const Key('recherche'),
            controller: _rechercheCtrl,
            prefixIcon: const Icon(Icons.search),
            label: 'Rechercher (nom, identifiant, numéro)',
            border: true,
            onChanged: (v) => setState(() => _recherche = v),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Toutes les classes'),
                selected: _classe == null,
                onSelected: (_) => setState(() => _classe = null),
              ),
              for (final c in classes)
                ChoiceChip(
                  label: Text(c.name),
                  selected: _classe == c.id,
                  onSelected: (_) => setState(() => _classe = c.id),
                ),
              ChoiceChip(
                label: const Text('Sans classe'),
                selected: _classe == '',
                onSelected: (_) => setState(() => _classe = ''),
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Afficher aussi les élèves sortis'),
            value: _sortis,
            onChanged: (v) => setState(() => _sortis = v),
          ),
          Text('${liste.length} élève${liste.length > 1 ? 's' : ''}'),
          const SizedBox(height: 8),
          if (tous.isEmpty)
            const InfoMessage(
              'Aucun élève pour l’instant. Ajoutez-les un par un, ou '
              'importez un fichier Excel.',
            )
          else if (liste.isEmpty)
            const InfoMessage('Aucun élève ne correspond à la recherche.'),
          for (final e in liste) EleveTile(e, avecClasse: true),
        ],
      ),
    );
  }
}

/// Fiche élève (B2, B4) : un seul écran défilant, enregistrement automatique.
/// L'enseignant la consulte sans la modifier et ne voit jamais le registre.
class StudentPage extends ConsumerWidget {
  const new(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(eleveProvider(id)).value;
    if (s == null) {
      return const EcoleScaffold(
        title: 'Fiche élève',
        body: InfoMessage('Fiche introuvable sur ce téléphone.'),
      );
    }
    final droits = ref.watch(mesDroitsProvider);
    final modifiable =
        droits.contains('eleves') || droits.contains('registres');
    final registre = droits.contains('registres');
    final repo = ref.read(studentsRepositoryProvider);
    Future<void> save(String col, Object? v) => repo.modifier(s.id, {col: v});
    final school = ref.watch(schoolProvider(s.schoolId)).value;
    final yearId = school?.currentSchoolYearId;
    final parcours = ref.watch(parcoursProvider(s.id)).value ?? [];
    final classeActuelle = [
      for (final (e, c) in parcours)
        if (e.schoolYearId == yearId && e.endsOn == null) c,
    ].firstOrNull;

    Widget texte(String label, String? valeur, String col, {int lignes = 1}) =>
        modifiable
        ? AutoSaveField(
            label: label,
            initial: valeur,
            maxLines: lignes,
            onSave: (v) => save(col, v),
          )
        : _Lecture(label, valeur);

    Widget date(String label, String? valeur, String col) => modifiable
        ? AutoSaveDateField(
            label: label,
            initial: valeur,
            onSave: (v) => save(col, v),
          )
        : _Lecture(label, AutoSaveDateField.afficher(valeur));

    return EcoleScaffold(
      title: '${s.lastName} ${s.firstNames}',
      body: ListView(
        key: const Key('fiche-eleve'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            [
              numeroAffiche(s),
              classeActuelle?.name ?? 'Sans classe cette année',
              if (s.archivedAt != null) 'Sorti de l’école',
            ].join(' · '),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (s.registryNumber == null && s.registryProvisional != null)
            const Text(
              'Le numéro d’ordre définitif sera attribué à la prochaine '
              'synchronisation.',
            ),
          const SizedBox(height: 8),
          if (modifiable)
            const Text(
              'Pour modifier ou compléter la fiche, touchez un champ et '
              'changez-le : c’est enregistré tout seul (✓), même sans '
              'Internet.',
            ),
          const SectionTitle('Identité'),
          if (modifiable) ...[
            AutoSaveField(
              label: 'Nom *',
              initial: s.lastName,
              onSave: (v) async {
                if (v != null) await save('last_name', v.toUpperCase());
              },
            ),
            AutoSaveField(
              label: 'Prénoms *',
              initial: s.firstNames,
              onSave: (v) async {
                if (v != null) await save('first_names', v);
              },
            ),
            ChoiceField(
              label: 'Sexe',
              value: s.sex,
              options: const {'F': 'Fille', 'M': 'Garçon'},
              onChanged: (v) => save('sex', v),
            ),
          ] else
            _Lecture('Sexe', switch (s.sex) {
              'F' => 'Fille',
              'M' => 'Garçon',
              _ => null,
            }),
          date('Né(e) le', s.birthDate, 'birth_date'),
          texte('À (lieu de naissance)', s.birthPlace, 'birth_place'),
          if (modifiable)
            AutoSaveField(
              key: const Key('identifiant-eleve'),
              label: 'Identifiant de l’élève',
              initial: s.studentCode,
              helper: 'Unique dans l’école (sert aux cartes scolaires).',
              verifier: (v) => repo.identifiantPris(s.schoolId, s.id, v),
              onSave: (v) => save('student_code', v),
            )
          else
            _Lecture('Identifiant de l’élève', s.studentCode),
          texte('Domicilié à', s.domicile, 'domicile'),
          const SectionTitle('Classe'),
          if (modifiable && yearId != null)
            _ChangerClasse(eleve: s, yearId: yearId, actuelle: classeActuelle),
          if (modifiable)
            for (final (e, _) in parcours)
              if (e.schoolYearId == yearId && e.endsOn == null)
                SwitchListTile(
                  key: const Key('redouble'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Redouble cette classe'),
                  subtitle: const Text(
                    'Même niveau qu’une année précédente : seconde colonne '
                    'du niveau sur la fiche de scolarité.',
                  ),
                  value: e.isRepeat,
                  onChanged: (v) => ref
                      .read(studentsRepositoryProvider)
                      .marquerRedoublement(e.id, redouble: v),
                ),
          for (final (e, c) in parcours) Text(_ligneParcours(e, c)),
          _Parents(eleve: s, modifiable: modifiable),
          const SectionTitle('Scolarité'),
          date('Date de l’entrée à l’école', s.entryDate, 'entry_date'),
          if (s.exitDate != null)
            _Lecture(
              'Sortie définitive',
              AutoSaveDateField.afficher(s.exitDate),
            ),
          if (registre)
            _Registre(
              eleve: s,
              raceReligion: school?.showRaceReligion ?? false,
            ),
          // Fiche de scolarité : primaire seulement.
          if (registre && (school?.managesPrimary ?? true))
            OutlinedButton.icon(
              key: const Key('ouvrir-b4'),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Fiche de scolarité (B4)'),
              onPressed: () => context.push('/eleves/${s.id}/fiche'),
            ),
          const SectionTitle('Observations'),
          if (modifiable)
            AutoSaveField(
              key: const Key('observations'),
              label: 'Observations',
              initial: s.observations,
              helper: rappelSanteEleve,
              maxLines: 4,
              onSave: (v) => save('observations', v),
            )
          else
            _Lecture('Observations', s.observations),
          if (modifiable) ...[
            const SizedBox(height: 16),
            if (s.archivedAt == null)
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sortie définitive de l’école'),
                onPressed: () => _sortie(context, ref, s, registre: registre),
              )
            else
              OutlinedButton.icon(
                icon: const Icon(Icons.undo),
                label: const Text('Annuler la sortie (élève revenu)'),
                onPressed: () => repo.reintegrer(s.id),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _sortie(
    BuildContext context,
    WidgetRef ref,
    StudentRow s, {
    required bool registre,
  }) async {
    var date = AutoSaveDateField.iso(DateTime.now());
    final allant = TextEditingController();
    final motif = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('Sortie définitive'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'La fiche est conservée (registre, notes, paiements). '
                  'L’élève n’apparaît plus dans les listes de classe.',
                ),
                const SizedBox(height: 12),
                AutoSaveDateField(
                  label: 'Date de sortie',
                  initial: date,
                  onSave: (v) async {
                    if (v != null) setState(() => date = v);
                  },
                ),
                if (registre) ...[
                  TexteDictable(controller: allant, label: 'Allant à'),
                  TexteDictable(controller: motif, label: 'Motif du départ'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Confirmer la sortie'),
            ),
          ],
        ),
      ),
    );
    if (!(ok ?? false)) return;
    String? vide(String t) => t.trim().isEmpty ? null : t.trim();
    await ref
        .read(studentsRepositoryProvider)
        .sortir(
          s,
          dateSortie: date,
          allantA: vide(allant.text),
          motif: vide(motif.text),
        );
  }
}

String _ligneParcours(EnrollmentRow e, ClassRow? c) {
  final debut = AutoSaveDateField.afficher(e.startsOn) ?? '?';
  final fin = AutoSaveDateField.afficher(e.endsOn);
  return '${c?.name ?? e.levelCode} : du $debut'
      '${fin == null ? '' : ' au $fin (${e.endReason ?? ''})'}';
}

class _Lecture extends StatelessWidget {
  const new(this.label, this.valeur);
  final String label;
  final String? valeur;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(valeur ?? '—'),
  );
}

class _ChangerClasse extends ConsumerWidget {
  const new({required this.eleve, required this.yearId, this.actuelle});
  final StudentRow eleve;
  final String yearId;
  final ClassRow? actuelle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(classesProvider(yearId)).value ?? [];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String?>(
        key: Key('changer-classe-${actuelle?.id}'),
        initialValue: actuelle?.id,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Classe cette année',
          border: OutlineInputBorder(),
        ),
        items: [
          if (actuelle == null)
            const DropdownMenuItem(child: Text('Choisir une classe')),
          for (final c in classes)
            DropdownMenuItem(value: c.id, child: Text(c.name)),
        ],
        onChanged: (v) async {
          final c = classes.where((x) => x.id == v).firstOrNull;
          if (c == null) return;
          if (actuelle != null &&
              !await confirmer(
                context,
                titre: 'Changer de classe ?',
                message:
                    '${eleve.firstNames} passe de ${actuelle!.name} à '
                    '${c.name}. L’historique est conservé.',
                bouton: 'Changer',
              )) {
            return;
          }
          await ref
              .read(studentsRepositoryProvider)
              .changerDeClasse(eleve.id, c);
        },
      ),
    );
  }
}

const _relations = {
  'pere': 'Père',
  'mere': 'Mère',
  'tuteur': 'Tuteur',
  'logeur': 'Logeur',
  'autre': 'Autre',
};

class _Parents extends ConsumerWidget {
  const new({required this.eleve, required this.modifiable});
  final StudentRow eleve;
  final bool modifiable;

  Future<void> _editer(
    BuildContext context,
    WidgetRef ref, [
    GuardianRow? g,
  ]) async {
    var relation = g?.relation ?? 'pere';
    final nom = TextEditingController(text: g?.fullName);
    final profession = TextEditingController(text: g?.profession);
    final domicile = TextEditingController(text: g?.domicile);
    final adresse = TextEditingController(text: g?.address);
    final tel = TextEditingController(text: g?.phone);
    var logeur = g?.isLodger ?? false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('Parent ou tuteur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceField(
                  label: 'Lien avec l’élève',
                  value: relation,
                  options: _relations,
                  onChanged: (v) => setState(() => relation = v ?? relation),
                ),
                TexteDictable(
                  key: const Key('parent-nom'),
                  controller: nom,
                  label: 'Nom et prénoms *',
                ),
                TexteDictable(controller: profession, label: 'Profession'),
                TexteDictable(controller: domicile, label: 'Domicile'),
                TexteDictable(
                  controller: tel,
                  type: TypeDictee.numero,
                  label: 'Téléphone',
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Loge l’élève (logeur)'),
                  value: logeur,
                  onChanged: (v) => setState(() => logeur = v ?? false),
                ),
                if (logeur)
                  TexteDictable(
                    controller: adresse,
                    label: 'Adresse du logeur',
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (!(ok ?? false) || nom.text.trim().isEmpty) return;
    String? vide(TextEditingController t) =>
        t.text.trim().isEmpty ? null : t.text.trim();
    await ref
        .read(studentsRepositoryProvider)
        .enregistrerParent(
          eleve.schoolId,
          eleve.id,
          id: g?.id,
          fields: {
            'relation': relation,
            'full_name': nom.text.trim(),
            'profession': vide(profession),
            'domicile': vide(domicile),
            'address': vide(adresse),
            'phone': vide(tel),
            'is_lodger': logeur,
          },
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parents = ref.watch(parentsProvider(eleve.id)).value ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Parents ou tuteurs'),
        if (parents.isEmpty) const Text('Aucun parent ou tuteur enregistré.'),
        for (final g in parents)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${_relations[g.relation] ?? g.relation} : ${g.fullName}',
            ),
            subtitle: Text(
              [
                ?g.profession,
                ?g.domicile,
                ?g.phone,
                if (g.isLodger)
                  'logeur${g.address == null ? '' : ', ${g.address}'}',
              ].join(' · '),
            ),
            onTap: modifiable ? () => _editer(context, ref, g) : null,
            trailing: modifiable
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Modifier',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editer(context, ref, g),
                      ),
                      IconButton(
                        tooltip: 'Retirer',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (await confirmer(
                            context,
                            titre: 'Retirer ce parent ?',
                            message: g.fullName,
                            bouton: 'Retirer',
                          )) {
                            await ref
                                .read(studentsRepositoryProvider)
                                .retirerParent(g.id);
                          }
                        },
                      ),
                    ],
                  )
                : null,
          ),
        if (modifiable)
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un parent ou tuteur'),
            onPressed: () => _editer(context, ref),
          ),
      ],
    );
  }
}

/// Champs du registre matricule (B2) et de la fiche de scolarité (B4) :
/// directeur et délégué « registres » uniquement.
class _Registre extends ConsumerWidget {
  const new({required this.eleve, required this.raceReligion});
  final StudentRow eleve;
  final bool raceReligion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(registreProvider(eleve.id)).value;
    Future<void> save(String col, Object? v) => ref
        .read(studentsRepositoryProvider)
        .modifierRegistre(eleve.id, eleve.schoolId, {col: v});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AutoSaveField(
          key: ValueKey('venant-${r?.id}'),
          label: 'Venant de (école d’origine)',
          initial: r?.originSchool,
          onSave: (v) => save('origin_school', v),
        ),
        AutoSaveDateField(
          label: 'Date de l’obtention du C.E.P.',
          initial: r?.cepDate,
          onSave: (v) => save('cep_date', v),
        ),
        AutoSaveField(
          key: ValueKey('diplomes-${r?.id}'),
          label: 'Diplômes obtenus et date d’obtention',
          initial: r?.diplomas,
          onSave: (v) => save('diplomas', v),
        ),
        if (eleve.exitDate != null) ...[
          AutoSaveField(
            key: ValueKey('allant-${r?.id}'),
            label: 'Allant à',
            initial: r?.destination,
            onSave: (v) => save('destination', v),
          ),
          AutoSaveField(
            key: ValueKey('motif-${r?.id}'),
            label: 'Motif du départ',
            initial: r?.exitReason,
            onSave: (v) => save('exit_reason', v),
          ),
        ],
        AutoSaveField(
          key: ValueKey('obs-registre-${r?.id}'),
          label: 'Observations du registre matricule',
          hint:
              'Succès, aptitudes, conduite, carrière embrassée, école '
              'd’origine…',
          helper: rappelSanteEleve,
          initial: r?.registryObservations,
          maxLines: 4,
          onSave: (v) => save('registry_observations', v),
        ),
        AutoSaveField(
          key: ValueKey('obs-directeur-${r?.id}'),
          label: 'Observations du Directeur (fiche de scolarité)',
          helper: rappelSanteEleve,
          initial: r?.directorObservations,
          maxLines: 4,
          onSave: (v) => save('director_observations', v),
        ),
        if (raceReligion) ...[
          AutoSaveField(
            key: ValueKey('race-${r?.id}'),
            label: 'Race (facultatif)',
            initial: r?.race,
            onSave: (v) => save('race', v),
          ),
          AutoSaveField(
            key: ValueKey('religion-${r?.id}'),
            label: 'Religion (facultatif)',
            initial: r?.religion,
            onSave: (v) => save('religion', v),
          ),
        ],
      ],
    );
  }
}

/// Les données de santé n'existent que dans le dossier médico-scolaire.
const rappelSanteEleve =
    'N’indiquez pas d’informations médicales (réservées au dossier '
    'médico-scolaire).';
