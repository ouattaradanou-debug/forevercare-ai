import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/data/staff_repository.dart';
import 'package:ecoleplus/features/staff/domain/anciennete.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Recherche sans accents ni majuscules.
String cleRecherche(String s) {
  const de = 'àâäáãéèêëíìîïóòôöõúùûüçñÀÂÄÁÃÉÈÊËÍÌÎÏÓÒÔÖÕÚÙÛÜÇÑ';
  const vers = 'aaaaaeeeeiiiiooooouuuucnaaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = de.indexOf(c);
    b.write(i < 0 ? c : vers[i]);
  }
  return b.toString();
}

/// Liste des enseignants (directeur, délégué « registres »).
class TeachersPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends ConsumerState<TeachersPage> {
  String _recherche = '';
  bool _partis = false;

  Future<void> _ajouter(String schoolId) async {
    final nom = TextEditingController();
    final prenoms = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Nouvel enseignant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('nouveau-nom'),
              controller: nom,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Nom *'),
            ),
            TextField(
              key: const Key('nouveau-prenoms'),
              controller: prenoms,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Prénoms *'),
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
            child: const Text('Créer la fiche'),
          ),
        ],
      ),
    );
    if (!(ok ?? false) || !mounted) return;
    if (nom.text.trim().isEmpty || prenoms.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom et les prénoms sont demandés.')),
      );
      return;
    }
    final id = await ref
        .read(staffRepositoryProvider)
        .createTeacher(schoolId, lastName: nom.text, firstNames: prenoms.text);
    if (mounted) await context.push('/enseignants/$id');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = school?.currentSchoolYearId;
    final tous = ref.watch(teachersProvider(session.schoolId)).value ?? [];
    final affectations = {
      for (final a
          in (yearId == null
                  ? null
                  : ref.watch(assignmentsProvider(yearId)).value) ??
              const <TeacherAssignmentRow>[])
        a.teacherId: a,
    };
    final classes = {
      for (final c
          in (yearId == null
                  ? null
                  : ref.watch(classesProvider(yearId)).value) ??
              const <ClassRow>[])
        c.id: c.name,
    };
    final cle = cleRecherche(_recherche.trim());
    final liste = [
      for (final t in tous)
        if ((_partis || t.status != 'parti') &&
            (cle.isEmpty ||
                cleRecherche(
                  '${t.lastName} ${t.firstNames} ${t.matricule ?? ''} '
                  '${t.phone ?? ''}',
                ).contains(cle)))
          t,
    ];
    final partis = tous.where((t) => t.status == 'parti').length;
    return EcoleScaffold(
      title: 'Enseignants',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BigButton(
            icon: Icons.person_add,
            label: 'Ajouter un enseignant',
            onPressed: () => _ajouter(session.schoolId),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Importer un fichier Excel'),
            onPressed: () => context.push('/import/enseignants'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('recherche'),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Rechercher (nom, matricule, téléphone)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _recherche = v),
          ),
          if (partis > 0)
            SwitchListTile(
              title: Text('Afficher aussi les enseignants partis ($partis)'),
              value: _partis,
              onChanged: (v) => setState(() => _partis = v),
            ),
          const SizedBox(height: 8),
          if (tous.isEmpty)
            const InfoMessage(
              'Aucun enseignant pour l’instant. Ajoutez-les un par un, ou '
              'importez un fichier Excel.',
            )
          else if (liste.isEmpty)
            const InfoMessage('Aucun enseignant ne correspond à la recherche.')
          else
            for (final t in liste)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      t.sex == 'F' ? 'F' : (t.sex == 'M' ? 'H' : '?'),
                    ),
                  ),
                  title: Text('${t.lastName} ${t.firstNames}'),
                  subtitle: Text(
                    [
                      if (t.status == 'parti') 'Parti de l’école',
                      if (affectations[t.id]?.classId case final c?)
                        classes[c] ?? '',
                      ?affectations[t.id]?.fonction,
                      if (t.matricule case final m?) 'Mle $m',
                    ].where((x) => x.isNotEmpty).join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/enseignants/${t.id}'),
                ),
              ),
        ],
      ),
    );
  }
}

/// Fiche enseignant : un seul écran défilant, tout est enregistré
/// automatiquement (B1, B3).
class TeacherPage extends ConsumerWidget {
  const new(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teacherProvider(id)).value;
    final session = ref.watch(sessionProvider).value!;
    if (t == null) {
      return const EcoleScaffold(
        title: 'Fiche enseignant',
        body: InfoMessage('Fiche introuvable sur ce téléphone.'),
      );
    }
    final repo = ref.read(staffRepositoryProvider);
    Future<void> save(String col, Object? v) =>
        repo.updateTeacher(t.id, {col: v});
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = school?.currentSchoolYearId;
    final reference = referenceParDefaut(DateTime.now());
    final refTexte = AutoSaveDateField.afficher(
      AutoSaveDateField.iso(reference),
    );

    Widget anciennete(String label, String col, String? valeur) {
      final a = Anciennete.entre(
        valeur == null ? null : DateTime.tryParse(valeur),
        reference,
      );
      return AutoSaveDateField(
        label: label,
        initial: valeur,
        helper: a == null ? null : 'Au $refTexte : ${a.texte}',
        onSave: (v) => save(col, v),
      );
    }

    return EcoleScaffold(
      title: '${t.lastName} ${t.firstNames}',
      body: ListView(
        key: const Key('fiche-enseignant'),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pour modifier ou compléter la fiche, touchez un champ et '
            'changez-le : c’est enregistré tout seul (✓), même sans '
            'Internet.',
          ),
          const SizedBox(height: 16),
          const SectionTitle('Identité'),
          AutoSaveField(
            label: 'Nom *',
            initial: t.lastName,
            onSave: (v) async {
              if (v != null) await save('last_name', v.toUpperCase());
            },
          ),
          AutoSaveField(
            label: 'Prénoms *',
            initial: t.firstNames,
            onSave: (v) async {
              if (v != null) await save('first_names', v);
            },
          ),
          ChoiceField(
            label: 'Sexe',
            value: t.sex,
            options: const {'F': 'Femme', 'M': 'Homme'},
            onChanged: (v) => save('sex', v),
          ),
          AutoSaveField(
            label: 'Matricule',
            initial: t.matricule,
            verifier: (v) => repo.matriculePris(t.schoolId, t.id, v),
            onSave: (v) => save('matricule', v),
          ),
          AutoSaveField(
            label: 'Téléphone (contact)',
            initial: t.phone,
            keyboardType: TextInputType.phone,
            onSave: (v) => save('phone', v),
          ),
          AutoSaveDateField(
            label: 'Date de naissance',
            initial: t.birthDate,
            onSave: (v) => save('birth_date', v),
          ),
          AutoSaveField(
            label: 'Lieu de naissance',
            initial: t.birthPlace,
            onSave: (v) => save('birth_place', v),
          ),
          const SectionTitle('Emploi et poste'),
          AutoSaveField(
            label: 'Emploi',
            initial: t.emploi,
            onSave: (v) => save('emploi', v),
          ),
          AutoSaveField(
            label: 'Catégorie',
            initial: t.categorie,
            onSave: (v) => save('categorie', v),
          ),
          AutoSaveField(
            label: 'Échelon',
            initial: t.echelon,
            onSave: (v) => save('echelon', v),
          ),
          ChoiceField(
            label: 'Titulaire ou stagiaire (T/S)',
            value: t.tenureStatus,
            options: const {'T': 'T (titulaire)', 'S': 'S (stagiaire)'},
            onChanged: (v) => save('tenure_status', v),
          ),
          if (yearId != null)
            _AffectationAnnee(
              teacherId: t.id,
              schoolId: t.schoolId,
              yearId: yearId,
            ),
          const SectionTitle('Anciennetés (fiche B1)'),
          const Text(
            'Saisissez la date de départ de chaque ancienneté : la durée est '
            'calculée automatiquement (années, mois et jours révolus).',
          ),
          const SizedBox(height: 12),
          anciennete(
            'Ancienneté générale : depuis le',
            'seniority_general_from',
            t.seniorityGeneralFrom,
          ),
          anciennete(
            'Ancienneté dans l’emploi : depuis le',
            'seniority_emploi_from',
            t.seniorityEmploiFrom,
          ),
          anciennete(
            'Ancienneté dans la région : depuis le',
            'seniority_region_from',
            t.seniorityRegionFrom,
          ),
          anciennete(
            'Ancienneté dans la fonction : depuis le',
            'seniority_fonction_from',
            t.seniorityFonctionFrom,
          ),
          const SectionTitle('Registre du personnel (B3)'),
          AutoSaveDateField(
            label: 'Date de la nomination dans la commune',
            initial: t.communeNominationDate,
            onSave: (v) => save('commune_nomination_date', v),
          ),
          AutoSaveField(
            label: 'Service antérieur : élève à l’école de',
            initial: t.pupilSchoolName,
            onSave: (v) => save('pupil_school_name', v),
          ),
          AutoSaveDateField(
            label: '… date d’entrée',
            initial: t.pupilSchoolEntryDate,
            onSave: (v) => save('pupil_school_entry_date', v),
          ),
          AutoSaveDateField(
            label: '… date de sortie',
            initial: t.pupilSchoolExitDate,
            onSave: (v) => save('pupil_school_exit_date', v),
          ),
          AutoSaveDateField(
            label: 'Date de la première nomination dans l’enseignement',
            initial: t.firstTeachingNominationDate,
            onSave: (v) => save('first_teaching_nomination_date', v),
          ),
          for (final h in Historique.values)
            _HistoriqueSection(teacher: t, historique: h),
          AutoSaveDateField(
            label: 'Date de cessation de fonctions dans la commune',
            initial: t.communeCessationDate,
            onSave: (v) => save('commune_cessation_date', v),
          ),
          AutoSaveField(
            label: 'Nouveau poste',
            initial: t.newPost,
            onSave: (v) => save('new_post', v),
          ),
          AutoSaveField(
            label: 'Observations',
            initial: t.observations,
            helper: rappelSante,
            maxLines: 4,
            onSave: (v) => save('observations', v),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: Icon(t.status == 'parti' ? Icons.undo : Icons.logout),
            label: Text(
              t.status == 'parti'
                  ? 'Cet enseignant est revenu à l’école'
                  : 'Cet enseignant a quitté l’école',
            ),
            onPressed: () async {
              final parti = t.status != 'parti';
              if (parti &&
                  !await confirmer(
                    context,
                    titre: 'Départ de l’école',
                    message:
                        'La fiche est conservée (registre du personnel) et '
                        'n’apparaît plus dans la liste habituelle.',
                    bouton: 'Confirmer le départ',
                  )) {
                return;
              }
              await repo.setParti(t.id, parti: parti);
            },
          ),
        ],
      ),
    );
  }
}

/// Classe tenue (ou service) et fonction pour l'année en cours (B1).
class _AffectationAnnee extends ConsumerWidget {
  const new({
    required this.teacherId,
    required this.schoolId,
    required this.yearId,
  });
  final String teacherId;
  final String schoolId;
  final String yearId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(assignmentProvider((teacherId, yearId))).value;
    final classes = ref.watch(classesProvider(yearId)).value ?? [];
    final repo = ref.read(staffRepositoryProvider);
    Future<void> save(Map<String, Object?> f) => repo.setAssignment(
      schoolId: schoolId,
      yearId: yearId,
      teacherId: teacherId,
      fields: f,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String?>(
            key: ValueKey('classe-${a?.classId}'),
            initialValue: a?.classId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Classe tenue cette année',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(child: Text('Aucune (autre service)')),
              for (final c in classes)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => save({'class_id': v}),
          ),
        ),
        if (a?.classId == null)
          AutoSaveField(
            key: ValueKey('service-${a?.id}'),
            label: 'Service (si pas de classe)',
            initial: a?.serviceLabel,
            onSave: (v) => save({'service_label': v}),
          ),
        AutoSaveField(
          key: ValueKey('fonction-${a?.id}'),
          label: 'Fonction ou poste occupé (ex. Adjoint, Directeur)',
          initial: a?.fonction,
          onSave: (v) => save({'fonction': v}),
        ),
      ],
    );
  }
}

/// Historique du registre B3 : plusieurs lignes, ajout et retrait simples.
class _HistoriqueSection extends ConsumerWidget {
  const new({required this.teacher, required this.historique});
  final TeacherRow teacher;
  final Historique historique;

  (String, String, String, String?) get _textes => switch (historique) {
    Historique.communes => (
      'Communes successives (avec date de nomination)',
      'commune',
      'nominated_on',
      null,
    ),
    Historique.interruptions => (
      'Interruptions de service (causes et durées)',
      'cause',
      'starts_on',
      rappelSante,
    ),
    Historique.recompenses => (
      'Récompenses obtenues',
      'label',
      'awarded_on',
      null,
    ),
    Historique.diplomes => (
      'Titres de capacité (diplômes et date de délivrance)',
      'nature',
      'delivered_on',
      null,
    ),
  };

  Future<void> _editer(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? ligne,
  ]) async {
    final (titre, colTexte, colDate, rappel) = _textes;
    final texte = TextEditingController(text: ligne?[colTexte] as String?);
    final duree = TextEditingController(
      text: ligne?['duration_text'] as String?,
    );
    var date = ligne?[colDate] as String?;
    var fin = ligne?['ends_on'] as String?;
    // SQLite renvoie les booléens sous forme de 0 / 1.
    var academique =
        ligne?['is_academic'] == true || ligne?['is_academic'] == 1;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: Text(titre),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('historique-texte'),
                  controller: texte,
                  decoration: InputDecoration(
                    labelText: switch (historique) {
                      Historique.communes => 'Commune *',
                      Historique.interruptions => 'Cause *',
                      Historique.recompenses => 'Récompense *',
                      Historique.diplomes => 'Diplôme ou titre *',
                    },
                    helperText: rappel,
                  ),
                ),
                const SizedBox(height: 12),
                AutoSaveDateField(
                  label: switch (historique) {
                    Historique.communes => 'Date de nomination',
                    Historique.interruptions => 'Du',
                    Historique.recompenses => 'Date',
                    Historique.diplomes => 'Date de délivrance',
                  },
                  initial: date,
                  onSave: (v) async => setState(() => date = v),
                ),
                if (historique == Historique.interruptions) ...[
                  AutoSaveDateField(
                    label: 'Au',
                    initial: fin,
                    onSave: (v) async => setState(() => fin = v),
                  ),
                  TextField(
                    controller: duree,
                    decoration: const InputDecoration(
                      labelText: 'Durée (si pas de dates précises)',
                    ),
                  ),
                ],
                if (historique == Historique.diplomes)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Diplôme académique (pour la fiche B1)'),
                    value: academique,
                    onChanged: (v) => setState(() => academique = v ?? false),
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
    if (!(ok ?? false) || texte.text.trim().isEmpty) return;
    await ref
        .read(staffRepositoryProvider)
        .saveHistorique(
          historique,
          schoolId: teacher.schoolId,
          teacherId: teacher.id,
          id: ligne?['id'] as String?,
          fields: {
            colTexte: texte.text.trim(),
            colDate: date,
            if (historique == Historique.interruptions) ...{
              'ends_on': fin,
              'duration_text': duree.text.trim().isEmpty
                  ? null
                  : duree.text.trim(),
            },
            if (historique == Historique.diplomes) 'is_academic': academique,
          },
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (titre, colTexte, colDate, _) = _textes;
    final lignes =
        ref.watch(historiqueProvider((historique, teacher.id))).value ?? [];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre, style: Theme.of(context).textTheme.titleMedium),
              if (lignes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Rien d’enregistré.'),
                ),
              for (final l in lignes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l[colTexte] as String? ?? ''),
                  subtitle: Text(
                    [
                      AutoSaveDateField.afficher(l[colDate] as String?),
                      if (AutoSaveDateField.afficher(l['ends_on'] as String?)
                          case final fin?)
                        'au $fin',
                      l['duration_text'] as String?,
                      if (l['is_academic'] == true || l['is_academic'] == 1)
                        'académique',
                    ].whereType<String>().join(' · '),
                  ),
                  onTap: () => _editer(context, ref, l),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Modifier',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editer(context, ref, l),
                      ),
                      IconButton(
                        tooltip: 'Retirer',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (await confirmer(
                            context,
                            titre: 'Retirer cette ligne ?',
                            message: l[colTexte] as String? ?? '',
                            bouton: 'Retirer',
                          )) {
                            await ref
                                .read(staffRepositoryProvider)
                                .removeHistorique(
                                  historique,
                                  l['id'] as String,
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              TextButton.icon(
                key: Key('ajouter-${historique.name}'),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une ligne'),
                onPressed: () => _editer(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
