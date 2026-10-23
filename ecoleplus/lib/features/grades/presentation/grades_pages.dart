import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
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

/// Une classe : les trois trimestres, le classement, les matières.
class ClasseNotesPage extends ConsumerWidget {
  const new(this.classId, {super.key});
  final String classId;

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
    final parEpreuve = typesEpreuves(d.type).length;
    final attendues = d.eleves.length * d.matieres.length * parEpreuve;
    int saisies(int t) {
      final ids = {for (final e in d.epreuvesTrimestre(t)) e.id};
      return d.notes.where((g) => ids.contains(g.assessmentId)).length;
    }

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
          Text(
            d.type == TypeEcole.privee
                ? 'École privée : chaque trimestre, une évaluation et une '
                      'composition par matière.'
                : 'École publique : chaque trimestre, une composition par '
                      'matière.',
          ),
          const SizedBox(height: 12),
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
          const SectionTitle('Saisie des notes'),
          for (final t in const [1, 2, 3])
            Card(
              child: ListTile(
                key: Key('trimestre-$t'),
                title: Text(trimestreTexte(t)),
                subtitle: Text('${saisies(t)}/$attendues notes saisies'),
                trailing: const Icon(Icons.edit_note),
                enabled: d.matieres.isNotEmpty,
                onTap: () => context.push('/notes/$classId/trimestre/$t'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Saisie d'un trimestre : matière → une ligne par élève, avec une case
/// (école publique : composition) ou deux (école privée : évaluation et
/// composition). Le clavier « Suivant » passe à la case suivante ; chaque
/// note est enregistrée seule.
class SaisieNotesPage extends ConsumerStatefulWidget {
  const new(this.classId, this.trimestre, {super.key});
  final String classId;
  final int trimestre;

  @override
  ConsumerState<SaisieNotesPage> createState() => _SaisieState();
}

class _SaisieState extends ConsumerState<SaisieNotesPage> {
  String? _matiere;
  bool _preparation = false;

  /// Crée les épreuves du trimestre la première fois.
  void _preparer(DonneesClasse d) {
    if (_preparation) return;
    _preparation = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await avecMessage(
        context,
        () => ref
            .read(gradesRepositoryProvider)
            .preparerTrimestre(d, widget.trimestre),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(donneesClasseProvider(widget.classId)).value;
    final titre = trimestreTexte(widget.trimestre);
    final epreuves = d?.epreuvesTrimestre(widget.trimestre) ?? const [];
    if (d == null || epreuves.length < typesEpreuves(d.type).length) {
      if (d != null) _preparer(d);
      return EcoleScaffold(
        title: titre,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final matiereId = _matiere ?? d.matieres.firstOrNull?.matiere.id;
    final deux = epreuves.length > 1;
    final resultats = {
      for (final r in d.trimestre(widget.trimestre).resultats) r.eleve.id: r,
    };
    GradeRow? noteDe(AssessmentRow e, String eleve) => d.notes
        .where(
          (g) =>
              g.assessmentId == e.id &&
              g.studentId == eleve &&
              g.subjectId == matiereId,
        )
        .firstOrNull;
    return EcoleScaffold(
      title: '$titre — ${d.classe.name}',
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
          if (matiereId != null)
            for (final e in epreuves)
              Text(_resume(d, e, matiereId), key: Key('resume-${e.kind}')),
          const SizedBox(height: 8),
          if (matiereId != null && d.eleves.isNotEmpty)
            BigButton(
              icon: Icons.mic,
              label: 'Saisie vocale guidée',
              onPressed: () => context.push(
                '/notes/${widget.classId}/vocal/${widget.trimestre}/'
                '$matiereId',
              ),
            ),
          const SizedBox(height: 12),
          if (matiereId != null)
            for (final (i, s) in d.eleves.indexed)
              if (!deux)
                ChampNote(
                  key: ValueKey('note-${s.id}-$matiereId-${epreuves[0].id}'),
                  eleve: s,
                  composition: epreuves[0],
                  matiereId: matiereId,
                  note: noteDe(epreuves[0], s.id),
                  dernier: i == d.eleves.length - 1,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${s.lastName} ${s.firstNames}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final (j, e) in epreuves.indexed)
                            Expanded(
                              child: ChampNote(
                                key: ValueKey(
                                  'note-${s.id}-$matiereId-${e.id}',
                                ),
                                eleve: s,
                                composition: e,
                                matiereId: matiereId,
                                note: noteDe(e, s.id),
                                avecNom: false,
                                dernier:
                                    i == d.eleves.length - 1 &&
                                    j == epreuves.length - 1,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _moyenneMatiere(resultats[s.id], matiereId),
                        key: Key('moyenne-${s.id}'),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  static String _resume(DonneesClasse d, AssessmentRow e, String matiereId) {
    final saisies = d.notes
        .where((g) => g.assessmentId == e.id && g.subjectId == matiereId)
        .length;
    final (meilleure, minimale) = extremesMatiere(
      [for (final g in d.notes) DonneesClasse.noteDe(g)],
      matiereId,
      e.id,
    );
    final extremes = meilleure == null
        ? ''
        : ' · meilleure ${centiemesTexte(meilleure)}, plus faible '
              '${centiemesTexte(minimale)}';
    return '${epreuveTexte(e.kind)} sur ${nombreTexte(e.maxScore)} · '
        '$saisies/${d.eleves.length} saisies$extremes';
  }

  static String _moyenneMatiere(Resultat? r, String matiereId) {
    final m = r?.moyennesMatieres[matiereId];
    if (m == null) return 'Moyenne de la matière : —';
    return 'Moyenne de la matière : ${centiemesTexte(m)}'
        '${r!.uneSeuleNote.contains(matiereId) ? ' (une seule note)' : ''}';
  }
}

/// Une case de saisie : nom de l'élève (sauf en école privée, où il est
/// au-dessus des deux cases), note, bouton « Abs. ».
class ChampNote extends ConsumerStatefulWidget {
  const new({
    required this.eleve,
    required this.composition,
    required this.matiereId,
    required this.note,
    required this.dernier,
    this.avecNom = true,
    super.key,
  });
  final StudentRow eleve;
  final AssessmentRow composition;
  final String matiereId;
  final GradeRow? note;
  final bool dernier;
  final bool avecNom;

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
    // Clés : « note-<élève> » (composition), « eval-<élève> » (évaluation).
    final prefixe = widget.composition.kind == 'evaluation' ? 'eval' : 'note';
    final eval = widget.composition.kind == 'evaluation';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.avecNom)
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
              key: Key('$prefixe-${widget.eleve.id}'),
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
                labelText: widget.avecNom ? null : (eval ? 'Éval.' : 'Compo.'),
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
              key: Key(
                eval ? 'abs-eval-${widget.eleve.id}' : 'abs-${widget.eleve.id}',
              ),
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
