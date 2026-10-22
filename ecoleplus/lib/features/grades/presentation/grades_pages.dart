import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/grades/data/grades_repository.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

final gradesRepositoryProvider = Provider<GradesRepository>(
  (ref) => GradesRepository(ref.watch(localStoreProvider)),
);
final StreamProviderFamily<DonneesClasse?, String> donneesClasseProvider =
    StreamProvider.family(
      (ref, classId) =>
          ref.watch(gradesRepositoryProvider).watchDonnees(classId),
    );
final StreamProviderFamily<List<SubjectRow>, String> matieresEcoleProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(gradesRepositoryProvider).watchMatieresEcole(schoolId),
    );
final StreamProviderFamily<List<MentionScaleRow>, String> mentionsProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(gradesRepositoryProvider).watchMentions(schoolId),
    );

/// « 6,5 » → 6.5 (pour les coefficients et barèmes).
double? nombreDepuis(String t) =>
    double.tryParse(t.trim().replaceAll(',', '.'));
String nombreTexte(double v) => centiemesTexte((v * 100).round());

/// Notes : choix de la classe (l'enseignant ne voit que la sienne).
class NotesPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = school?.currentSchoolYearId;
    final classes = yearId == null
        ? const <ClassRow>[]
        : ref.watch(classesProvider(yearId)).value ?? const <ClassRow>[];
    final directeur = session.role == 'directeur';
    return EcoleScaffold(
      title: 'Notes et classement',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Choisissez la classe.'),
          const SizedBox(height: 8),
          if (classes.isEmpty)
            const InfoMessage('Aucune classe pour l’année en cours.'),
          for (final c in classes)
            Card(
              child: ListTile(
                leading: const Icon(Icons.class_),
                title: Text(c.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/notes/${c.id}'),
              ),
            ),
          if (directeur) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Mentions (appréciations selon la moyenne)'),
              onPressed: () => context.push('/mentions'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Une classe : ses compositions, la saisie, le classement, les matières.
class ClasseNotesPage extends ConsumerWidget {
  const new(this.classId, {super.key});
  final String classId;

  Future<void> _nouvelle(
    BuildContext context,
    WidgetRef ref,
    DonneesClasse d,
  ) async {
    final libelle = TextEditingController(
      text: 'Composition ${d.compositions.length + 1}',
    );
    final bareme = TextEditingController(
      text: nombreTexte(d.ecole.gradingScale),
    );
    String? date;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('Nouvelle composition'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TexteDictable(
                  key: const Key('composition-libelle'),
                  controller: libelle,
                  label: 'Nom (ex. Composition 1, Devoir)',
                ),
                TexteDictable(
                  key: const Key('composition-bareme'),
                  controller: bareme,
                  type: TypeDictee.numero,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  label: 'Noté sur (barème)',
                ),
                const SizedBox(height: 12),
                AutoSaveDateField(
                  label: 'Date (facultatif)',
                  initial: date,
                  onSave: (v) async => setState(() => date = v),
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
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
    if (!(ok ?? false) || !context.mounted) return;
    final b = nombreDepuis(bareme.text);
    final id = await avecMessage(context, () async {
      if (b == null) throw const UserMessage('Barème illisible (ex. 10).');
      return await ref
          .read(gradesRepositoryProvider)
          .creerComposition(
            d.classe,
            libelle: libelle.text,
            bareme: b,
            date: date,
          );
    });
    if (id != null && context.mounted) {
      await context.push('/notes/$classId/saisie/$id');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(donneesClasseProvider(classId)).value;
    final session = ref.watch(sessionProvider).value!;
    if (d == null) {
      return const EcoleScaffold(
        title: 'Notes',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final directeur = session.role == 'directeur';
    final attendues = d.eleves.length * d.matieres.length;
    return EcoleScaffold(
      title: 'Notes — ${d.classe.name}',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (d.matieres.isEmpty)
            InfoMessage(
              directeur
                  ? 'Choisissez d’abord les matières de la classe et leurs '
                        'coefficients.'
                  : 'Le directeur doit d’abord choisir les matières de la '
                        'classe.',
            ),
          if (directeur) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.tune),
              label: const Text('Matières et coefficients'),
              onPressed: () => context.push('/notes/$classId/matieres'),
            ),
            const SizedBox(height: 12),
          ],
          BigButton(
            icon: Icons.leaderboard,
            label: 'Classement',
            onPressed: () => context.push('/notes/$classId/classement'),
          ),
          const SectionTitle('Compositions'),
          for (final c in d.compositions)
            Card(
              child: ListTile(
                title: Text(c.label),
                subtitle: Text(
                  'Sur ${nombreTexte(c.maxScore)} · '
                  '${d.notes.where((g) => g.assessmentId == c.id).length}'
                  '/$attendues notes saisies',
                ),
                trailing: const Icon(Icons.edit_note),
                onTap: () => context.push('/notes/$classId/saisie/${c.id}'),
              ),
            ),
          if (d.matieres.isNotEmpty)
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle composition'),
              onPressed: () => _nouvelle(context, ref, d),
            ),
        ],
      ),
    );
  }
}

/// Saisie : composition → matière → une ligne par élève. Le clavier
/// numérique passe à l'élève suivant ; chaque note est enregistrée seule.
class SaisieNotesPage extends ConsumerStatefulWidget {
  const new(this.classId, this.assessmentId, {super.key});
  final String classId;
  final String assessmentId;

  @override
  ConsumerState<SaisieNotesPage> createState() => _SaisieState();
}

class _SaisieState extends ConsumerState<SaisieNotesPage> {
  String? _matiere;

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(donneesClasseProvider(widget.classId)).value;
    final compo = d?.compositions
        .where((c) => c.id == widget.assessmentId)
        .firstOrNull;
    if (d == null || compo == null) {
      return const EcoleScaffold(
        title: 'Saisie des notes',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final matiereId = _matiere ?? d.matieres.firstOrNull?.matiere.id;
    final notes = {
      for (final g in d.notes)
        if (g.assessmentId == compo.id && g.subjectId == matiereId)
          g.studentId: g,
    };
    final (meilleure, minimale) = matiereId == null
        ? (null, null)
        : extremesMatiere(
            [for (final g in d.notes) DonneesClasse.noteDe(g)],
            matiereId,
            compo.id,
          );
    return EcoleScaffold(
      title: '${compo.label} — ${d.classe.name}',
      body: ListView(
        key: const Key('saisie-notes'),
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final m in d.matieres)
                ChoiceChip(
                  label: Text(m.matiere.name),
                  selected: m.matiere.id == matiereId,
                  onSelected: (_) => setState(() => _matiere = m.matiere.id),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Notes sur ${nombreTexte(compo.maxScore)} · '
            '${notes.length}/${d.eleves.length} saisies'
            '${meilleure == null ? '' : ' · meilleure '
                      '${centiemesTexte(meilleure)}, plus faible '
                      '${centiemesTexte(minimale)}'}',
          ),
          const SizedBox(height: 8),
          if (matiereId != null && d.eleves.isNotEmpty)
            BigButton(
              icon: Icons.mic,
              label: 'Saisie vocale guidée',
              onPressed: () => context.push(
                '/notes/${widget.classId}/vocal/${compo.id}/$matiereId',
              ),
            ),
          const SizedBox(height: 12),
          if (matiereId != null)
            for (final (i, s) in d.eleves.indexed)
              ChampNote(
                key: ValueKey('note-${s.id}-$matiereId'),
                eleve: s,
                composition: compo,
                matiereId: matiereId,
                note: notes[s.id],
                dernier: i == d.eleves.length - 1,
              ),
        ],
      ),
    );
  }
}

/// Une ligne de saisie : nom de l'élève, note, bouton « Abs ».
class ChampNote extends ConsumerStatefulWidget {
  const new({
    required this.eleve,
    required this.composition,
    required this.matiereId,
    required this.note,
    required this.dernier,
    super.key,
  });
  final StudentRow eleve;
  final AssessmentRow composition;
  final String matiereId;
  final GradeRow? note;
  final bool dernier;

  @override
  ConsumerState<ChampNote> createState() => _ChampNoteState();
}

class _ChampNoteState extends ConsumerState<ChampNote> {
  late final _ctrl = TextEditingController(text: _texte(widget.note));
  final _focus = FocusNode();
  Timer? _timer;
  String? _erreur;

  static String _texte(GradeRow? g) => g == null || g.status != 'note'
      ? ''
      : centiemesTexte((g.score! * 100).round());

  @override
  void didUpdateWidget(ChampNote old) {
    super.didUpdateWidget(old);
    final t = _texte(widget.note);
    if (!_focus.hasFocus && _ctrl.text != t && widget.note?.status == 'note') {
      _ctrl.text = t;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer(
    String v, {
    StatutNote statut = StatutNote.note,
  }) async {
    final bareme = (widget.composition.maxScore * 100).round();
    int? c;
    if (statut == StatutNote.note && v.trim().isNotEmpty) {
      c = centiemesDepuis(v);
      if (c == null) {
        setState(() => _erreur = 'Note illisible (ex. 14,5)');
        return;
      }
      if (c > bareme) {
        setState(
          () => _erreur =
              'Hors barème : la note ne peut pas dépasser '
              '${centiemesTexte(bareme)}',
        );
        return;
      }
    }
    setState(() => _erreur = null);
    await ref
        .read(gradesRepositoryProvider)
        .enregistrerNote(
          composition: widget.composition,
          studentId: widget.eleve.id,
          subjectId: widget.matiereId,
          centiemes: c,
          statut: statut,
        );
  }

  @override
  Widget build(BuildContext context) {
    final absent = widget.note?.status == 'absent';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                '${widget.eleve.lastName} ${widget.eleve.firstNames}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              key: Key('note-${widget.eleve.id}'),
              controller: _ctrl,
              focusNode: _focus,
              enabled: !absent,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
              ],
              textInputAction: widget.dernier
                  ? TextInputAction.done
                  : TextInputAction.next,
              onChanged: (v) {
                _timer?.cancel();
                _timer = Timer(
                  const Duration(milliseconds: 600),
                  () => _enregistrer(v),
                );
              },
              onSubmitted: (v) {
                _timer?.cancel();
                unawaited(_enregistrer(v));
              },
              decoration: InputDecoration(
                hintText: absent
                    ? 'Abs.'
                    : '/${nombreTexte(widget.composition.maxScore)}',
                errorText: _erreur,
                errorMaxLines: 2,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Hors du parcours « Suivant » du clavier : on passe directement
          // à la note de l'élève suivant.
          ExcludeFocus(
            child: FilterChip(
              key: Key('abs-${widget.eleve.id}'),
              label: const Text('Abs.'),
              selected: absent,
              onSelected: (on) {
                _timer?.cancel();
                if (on) _ctrl.clear();
                unawaited(
                  _enregistrer(
                    '',
                    statut: on ? StatutNote.absent : StatutNote.note,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Matières de la classe et coefficients (directeur).
class MatieresClassePage extends ConsumerWidget {
  const new(this.classId, {super.key});
  final String classId;

  Future<void> _ajouter(
    BuildContext context,
    WidgetRef ref,
    DonneesClasse d,
    List<SubjectRow> ecole,
  ) async {
    final dejaLa = {for (final m in d.matieres) m.matiere.id};
    final nom = TextEditingController();
    final coef = TextEditingController(text: '1');
    String? choisie;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('Ajouter une matière'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  children: [
                    for (final s in ecole)
                      if (!dejaLa.contains(s.id))
                        ChoiceChip(
                          label: Text(s.name),
                          selected: choisie == s.id,
                          onSelected: (on) => setState(() {
                            choisie = on ? s.id : null;
                            if (on) nom.text = s.name;
                          }),
                        ),
                  ],
                ),
                TexteDictable(
                  key: const Key('matiere-nom'),
                  controller: nom,
                  label: 'Ou une nouvelle matière (ex. Lecture)',
                  onChanged: (_) => setState(() => choisie = null),
                ),
                TexteDictable(
                  key: const Key('matiere-coef'),
                  controller: coef,
                  type: TypeDictee.numero,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  label: 'Coefficient',
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
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
    if (!(ok ?? false) || !context.mounted) return;
    await avecMessage(context, () async {
      final c = nombreDepuis(coef.text);
      if (c == null) throw const UserMessage('Coefficient illisible (ex. 1).');
      if (choisie == null && nom.text.trim().isEmpty) {
        throw const UserMessage('Choisissez ou écrivez une matière.');
      }
      final repo = ref.read(gradesRepositoryProvider);
      final id =
          choisie ?? await repo.creerMatiere(d.classe.schoolId, nom.text);
      await repo.definirCoefficient(d.classe, id, c);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(donneesClasseProvider(classId)).value;
    if (d == null) {
      return const EcoleScaffold(
        title: 'Matières',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final ecole =
        ref.watch(matieresEcoleProvider(d.classe.schoolId)).value ?? [];
    final repo = ref.read(gradesRepositoryProvider);
    return EcoleScaffold(
      title: 'Matières — ${d.classe.name}',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Coefficient 1 par défaut. Un coefficient 0 garde la matière '
            'sur le relevé sans changer la moyenne.',
          ),
          const SizedBox(height: 12),
          for (final m in d.matieres)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.matiere.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: AutoSaveField(
                        key: ValueKey('coef-${m.lien.id}'),
                        label: 'Coefficient',
                        initial: nombreTexte(m.lien.coefficient),
                        keyboardType: TextInputType.phone,
                        micro: false,
                        verifier: (v) async =>
                            v == null || nombreDepuis(v) == null
                            ? 'Nombre attendu'
                            : null,
                        onSave: (v) => repo.definirCoefficient(
                          d.classe,
                          m.matiere.id,
                          nombreDepuis(v!)!,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Retirer de la classe',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        if (await confirmer(
                          context,
                          titre: 'Retirer ${m.matiere.name} ?',
                          message:
                              'Les notes déjà saisies sont conservées ; '
                              'la matière ne compte plus dans les moyennes.',
                          bouton: 'Retirer',
                        )) {
                          await repo.retirerMatiere(m.lien.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          BigButton(
            icon: Icons.add,
            label: 'Ajouter une matière',
            onPressed: () => _ajouter(context, ref, d, ecole),
          ),
        ],
      ),
    );
  }
}

/// Mentions de l'école : libellé selon la moyenne (directeur). Aucune
/// mention n'est imposée : l'école choisit les siennes.
class MentionsPage extends ConsumerWidget {
  const new({super.key});

  Future<void> _editer(
    BuildContext context,
    WidgetRef ref,
    String schoolId, [
    MentionScaleRow? m,
  ]) async {
    final min = TextEditingController(
      text: m == null ? '' : nombreTexte(m.minAverage),
    );
    final max = TextEditingController(
      text: m == null ? '' : nombreTexte(m.maxAverage),
    );
    final libelle = TextEditingController(text: m?.label);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Mention'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TexteDictable(
                key: const Key('mention-min'),
                controller: min,
                type: TypeDictee.numero,
                label: 'De la moyenne',
              ),
              TexteDictable(
                key: const Key('mention-max'),
                controller: max,
                type: TypeDictee.numero,
                label: 'À la moyenne (comprise)',
              ),
              TexteDictable(
                key: const Key('mention-libelle'),
                controller: libelle,
                label: 'Mention (ex. Bien)',
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
    );
    if (!(ok ?? false) || !context.mounted) return;
    await avecMessage(context, () async {
      final a = nombreDepuis(min.text);
      final b = nombreDepuis(max.text);
      if (a == null || b == null || libelle.text.trim().isEmpty) {
        throw const UserMessage('Remplissez les deux moyennes et la mention.');
      }
      await ref
          .read(gradesRepositoryProvider)
          .enregistrerMention(
            schoolId,
            id: m?.id,
            min: a,
            max: b,
            libelle: libelle.text,
          );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final mentions = ref.watch(mentionsProvider(session.schoolId)).value ?? [];
    return EcoleScaffold(
      title: 'Mentions',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'La mention s’affiche dans le classement selon la moyenne '
            'générale. Exemple : de 7 à 8,99 → « Bien ».',
          ),
          const SizedBox(height: 12),
          if (mentions.isEmpty) const InfoMessage('Aucune mention.'),
          for (final m in mentions)
            Card(
              child: ListTile(
                title: Text(m.label),
                subtitle: Text(
                  'De ${nombreTexte(m.minAverage)} à '
                  '${nombreTexte(m.maxAverage)}',
                ),
                onTap: () => _editer(context, ref, session.schoolId, m),
                trailing: IconButton(
                  tooltip: 'Retirer',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      ref.read(gradesRepositoryProvider).retirerMention(m.id),
                ),
              ),
            ),
          BigButton(
            icon: Icons.add,
            label: 'Ajouter une mention',
            onPressed: () => _editer(context, ref, session.schoolId),
          ),
        ],
      ),
    );
  }
}
