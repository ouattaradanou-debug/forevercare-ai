import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/classes/presentation/classes_pages.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/maternelle/data/maternelle_repository.dart';
import 'package:ecoleplus/features/maternelle/domain/maternelle.dart';
import 'package:ecoleplus/features/maternelle/pdf/pdf_livret.dart';
import 'package:ecoleplus/features/programme/presentation/programme_pages.dart'
    show demanderTexte;
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

final maternelleRepositoryProvider = Provider<MaternelleRepository>(
  (ref) => MaternelleRepository(ref.watch(localStoreProvider)),
);

/// Le module Maternelle est-il actif pour l'école ?
final ProviderFamily<bool, String> maternelleActiveProvider = Provider.family(
  (ref, schoolId) =>
      ref
          .watch(modulesProvider(schoolId))
          .value
          ?.any((m) => m.$1.key == 'maternelle' && m.$2) ??
      false,
);

final StreamProviderFamily<List<LearningDomainRow>, String> domainesProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(maternelleRepositoryProvider).watchDomaines(schoolId),
    );

final StreamProviderFamily<List<NiveauQualitatif>, String> niveauxProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(maternelleRepositoryProvider).watchNiveaux(schoolId),
    );

final StreamProviderFamily<List<StudentRow>, String> enfantsProvider =
    StreamProvider.family(
      (ref, classId) =>
          ref.watch(maternelleRepositoryProvider).watchEnfants(classId),
    );

final StreamProviderFamily<Map<(String, String), String>, String>
evaluationsProvider = StreamProvider.family(
  (ref, periodId) =>
      ref.watch(maternelleRepositoryProvider).watchEvaluations(periodId),
);

final StreamProviderFamily<PreschoolBookletRow?, (String, String)>
livretProvider = StreamProvider.family(
  (ref, k) => ref.watch(maternelleRepositoryProvider).watchLivret(k.$1, k.$2),
);

final StreamProviderFamily<Map<String, String>, (String, String)>
presencesProvider = StreamProvider.family(
  (ref, k) =>
      ref.watch(maternelleRepositoryProvider).watchPresences(k.$1, k.$2),
);

/// Pictogramme à l'écran (même forme que dans le livret).
IconData iconeNiveau(String cle) => switch (Pictogramme.depuis(cle)) {
  Pictogramme.plein => Icons.circle,
  Pictogramme.moitie => Icons.contrast,
  Pictogramme.vide => Icons.circle_outlined,
  Pictogramme.etoile => Icons.star,
};

/// Pastille d'un niveau : pictogramme en couleur et libellé.
class PastilleNiveau extends StatelessWidget {
  const new(this.niveau, {super.key});
  final NiveauQualitatif niveau;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        iconeNiveau(niveau.pictogramme),
        color: Color(niveau.couleurArgb),
        size: 20,
      ),
      const SizedBox(width: 6),
      Flexible(child: Text(niveau.libelle)),
    ],
  );
}

// ------------------------------ Réglages ------------------------------

/// Réglages de la maternelle (directeur) : domaines, niveaux, classement.
class MaternelleReglagesPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final ecole = ref.watch(schoolProvider(session.schoolId)).value;
    final domaines = ref.watch(domainesProvider(session.schoolId)).value ?? [];
    final niveaux = ref.watch(niveauxProvider(session.schoolId)).value ?? [];
    final repo = ref.read(maternelleRepositoryProvider);
    if (!ref.watch(maternelleActiveProvider(session.schoolId))) {
      return const EcoleScaffold(
        title: 'Réglages de la maternelle',
        body: InfoMessage('Activez d’abord la maternelle dans « Options ».'),
      );
    }
    return EcoleScaffold(
      title: 'Réglages de la maternelle',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('Domaines d’apprentissage'),
          const InfoMessage(
            'Liste proposée, à comparer avec le programme officiel du '
            'préscolaire : renommez, retirez ou ajoutez des domaines.',
          ),
          if (domaines.isEmpty)
            OutlinedButton.icon(
              icon: const Icon(Icons.playlist_add),
              label: const Text('Mettre la liste proposée'),
              onPressed: () => repo.assurerParDefaut(session.schoolId),
            ),
          for (final (i, d) in domaines.indexed)
            Card(
              child: ListTile(
                key: Key('domaine-${i + 1}'),
                title: Text('${i + 1}. ${d.name}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    switch (v) {
                      case 'renommer':
                        final t = await demanderTexte(
                          context,
                          titre: 'Domaine',
                          label: 'Nom du domaine',
                          initial: d.name,
                        );
                        if (t != null) await repo.renommerDomaine(d.id, t);
                      case 'monter':
                        await repo.deplacerDomaine(session.schoolId, d.id, -1);
                      case 'descendre':
                        await repo.deplacerDomaine(session.schoolId, d.id, 1);
                      default:
                        if (!context.mounted) return;
                        final ok = await confirmer(
                          context,
                          titre: 'Retirer « ${d.name} » ?',
                          message:
                              'Il ne sera plus évalué. Les évaluations déjà '
                              'faites restent conservées.',
                          bouton: 'Retirer',
                        );
                        if (ok) await repo.retirerDomaine(d.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'renommer', child: Text('Renommer')),
                    PopupMenuItem(value: 'monter', child: Text('Monter')),
                    PopupMenuItem(value: 'descendre', child: Text('Descendre')),
                    PopupMenuItem(value: 'retirer', child: Text('Retirer')),
                  ],
                ),
              ),
            ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un domaine'),
            onPressed: () async {
              final t = await demanderTexte(
                context,
                titre: 'Nouveau domaine',
                label: 'Nom du domaine',
                propositions: [
                  for (final p in domainesParDefaut)
                    if (!domaines.any((d) => d.name == p)) p,
                ],
              );
              if (t != null) await repo.ajouterDomaine(session.schoolId, t);
            },
          ),
          const SectionTitle('Niveaux d’évaluation'),
          const Text(
            'Chaque niveau a une couleur ET un pictogramme : lisible même '
            'imprimé en noir et blanc.',
          ),
          for (final n in niveaux)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PastilleNiveau(n),
                    AutoSaveField(
                      key: ValueKey('niveau-${n.id}'),
                      label: 'Libellé',
                      initial: n.libelle,
                      micro: false,
                      onSave: (v) async {
                        if ((v ?? '').trim().isNotEmpty) {
                          await repo.modifierNiveau(n.id, {'label': v!.trim()});
                        }
                      },
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final MapEntry(key: hex, value: nom)
                            in couleursProposees.entries)
                          ChoiceChip(
                            avatar: Icon(
                              Icons.circle,
                              color: Color(
                                0xFF000000 |
                                    int.parse(hex.substring(1), radix: 16),
                              ),
                            ),
                            label: Text(nom),
                            selected: n.couleur.toUpperCase() == hex,
                            onSelected: (_) =>
                                repo.modifierNiveau(n.id, {'color_hex': hex}),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final p in Pictogramme.values)
                          ChoiceChip(
                            avatar: Icon(iconeNiveau(p.cle)),
                            label: Text(p.libelle),
                            selected: Pictogramme.depuis(n.pictogramme) == p,
                            onSelected: (_) =>
                                repo.modifierNiveau(n.id, {'icon_key': p.cle}),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SectionTitle('Classement des enfants'),
          SwitchListTile(
            key: const Key('classement-maternelle'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Classer les enfants (déconseillé)'),
            subtitle: const Text(
              'Désactivé par défaut. Avantage : repère rapide pour la '
              'classe. Inconvénients : compare de très jeunes enfants, '
              'peut décourager et ne reflète pas les progrès de chacun. '
              'Si activé, le rang apparaît sur le livret.',
            ),
            value: ecole?.preschoolRanking ?? false,
            onChanged: (v) => ref.read(schoolRepositoryProvider).updateSchool(
              session.schoolId,
              {'preschool_ranking': v},
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------ Classe ------------------------------

/// Une classe de maternelle : trimestres, enfants, présences, livrets.
class ClasseMaternellePage extends ConsumerStatefulWidget {
  const new(this.classId, {super.key});
  final String classId;

  @override
  ConsumerState<ClasseMaternellePage> createState() => _ClasseState();
}

class _ClasseState extends ConsumerState<ClasseMaternellePage> {
  int _trimestre = 1;
  String? _periodId;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _choisir(1));
  }

  Future<void> _choisir(int t) async {
    final repo = ref.read(maternelleRepositoryProvider);
    final c = await repo.classe(widget.classId);
    if (c == null) return;
    final id = await repo.assurerTrimestre(c, t);
    if (mounted) {
      setState(() {
        _trimestre = t;
        _periodId = id;
      });
    }
  }

  Future<void> _livrets() async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final l = await ref
          .read(maternelleRepositoryProvider)
          .livrets(widget.classId, _trimestre);
      final pdf = await pdfLivrets(
        await ref.read(policesPdfProvider.future),
        l,
      );
      final c = ref.read(classProvider(widget.classId)).value;
      await ref
          .read(sortiePdfProvider)
          .imprimer(pdf, 'Livrets_${c?.name ?? 'classe'}_T$_trimestre.pdf');
    });
    if (mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(classProvider(widget.classId)).value;
    final session = ref.watch(sessionProvider).value!;
    final ecole = ref.watch(schoolProvider(session.schoolId)).value;
    final enfants = ref.watch(enfantsProvider(widget.classId)).value ?? [];
    final domaines = ref.watch(domainesProvider(session.schoolId)).value ?? [];
    final evals = _periodId == null
        ? const <(String, String), String>{}
        : ref.watch(evaluationsProvider(_periodId!)).value ?? const {};
    final niveaux = ref.watch(niveauxProvider(session.schoolId)).value ?? [];
    if (c == null) {
      return const EcoleScaffold(
        title: 'Maternelle',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final ids = {for (final d in domaines) d.id};
    int faits(String eleve) =>
        evals.keys.where((k) => k.$1 == eleve && ids.contains(k.$2)).length;
    final index = {for (final (i, n) in niveaux.indexed) n.id: i};
    final rangs = (ecole?.preschoolRanking ?? false)
        ? classerEnfants({
            for (final e in enfants)
              e.id: [
                for (final MapEntry(key: (en, d), value: n) in evals.entries)
                  if (en == e.id && ids.contains(d) && index[n] != null)
                    pointsNiveau(index[n]!, niveaux.length),
              ],
          })
        : const <String, int>{};
    return EcoleScaffold(
      title: 'Maternelle — ${c.name}',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final (i, t) in trimestresMaternelle.indexed)
                ChoiceChip(
                  key: Key('trimestre-${i + 1}'),
                  label: Text(t),
                  selected: _trimestre == i + 1,
                  onSelected: (_) => _choisir(i + 1),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (domaines.isEmpty)
            const InfoMessage(
              'Aucun domaine d’apprentissage : le directeur les règle dans '
              '« Réglages de la maternelle ».',
            ),
          if (enfants.isEmpty)
            const InfoMessage('Aucun enfant inscrit dans cette classe.'),
          for (final e in enfants)
            Card(
              child: ListTile(
                key: Key('enfant-${e.id}'),
                leading: Icon(
                  faits(e.id) == domaines.length && domaines.isNotEmpty
                      ? Icons.task_alt
                      : Icons.child_care,
                ),
                title: Text('${e.lastName} ${e.firstNames}'),
                subtitle: Text(
                  [
                    '${faits(e.id)}/${domaines.length} domaines évalués',
                    if (rangs[e.id] != null)
                      'rang ${texteRang(rangs[e.id]!, rangs.length)}',
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _periodId == null
                    ? null
                    : () => context.push(
                        '/maternelle/classe/${c.id}/t/$_trimestre/enfant/${e.id}',
                      ),
              ),
            ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.fact_check_outlined,
            label: 'Présences',
            onPressed: () =>
                context.push('/maternelle/classe/${c.id}/presences'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Livrets de toute la classe (PDF)'),
            onPressed: _occupe || enfants.isEmpty ? null : _livrets,
          ),
          if (_occupe) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

// ------------------------------ Enfant ------------------------------

/// Évaluation d'un enfant pour un trimestre : un niveau par domaine,
/// appréciation (dictable), observation du directeur, livret.
class EvaluationEnfantPage extends ConsumerStatefulWidget {
  const new(this.classId, this.trimestre, this.studentId, {super.key});
  final String classId;
  final int trimestre;
  final String studentId;

  @override
  ConsumerState<EvaluationEnfantPage> createState() => _EnfantState();
}

class _EnfantState extends ConsumerState<EvaluationEnfantPage> {
  bool _occupe = false;

  String get _periodId =>
      MaternelleRepository.idPeriode(widget.classId, widget.trimestre);

  Future<void> _livret(String nom) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final l = await ref
          .read(maternelleRepositoryProvider)
          .livrets(
            widget.classId,
            widget.trimestre,
            studentId: widget.studentId,
          );
      final pdf = await pdfLivrets(
        await ref.read(policesPdfProvider.future),
        l,
      );
      await ref
          .read(sortiePdfProvider)
          .imprimer(
            pdf,
            'Livret_${nom.replaceAll(' ', '_')}_T${widget.trimestre}.pdf',
          );
    });
    if (mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final directeur = session.role == 'directeur';
    final enfants = ref.watch(enfantsProvider(widget.classId)).value ?? [];
    final e = enfants.where((x) => x.id == widget.studentId).firstOrNull;
    final domaines = ref.watch(domainesProvider(session.schoolId)).value ?? [];
    final niveaux = ref.watch(niveauxProvider(session.schoolId)).value ?? [];
    final evals = ref.watch(evaluationsProvider(_periodId)).value ?? const {};
    final livret = ref
        .watch(livretProvider((_periodId, widget.studentId)))
        .value;
    final repo = ref.read(maternelleRepositoryProvider);
    if (e == null) {
      return const EcoleScaffold(
        title: 'Évaluation',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final nom = '${e.lastName} ${e.firstNames}';
    final i = enfants.indexOf(e);
    final suivant = i + 1 < enfants.length ? enfants[i + 1] : null;
    Future<void> saveLivret(String col, Object? v) =>
        repo.enregistrerLivret(e.schoolId, _periodId, e.id, {col: v});
    return EcoleScaffold(
      title: nom,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${trimestresMaternelle[widget.trimestre - 1]} — touchez le '
            'niveau atteint dans chaque domaine (touchez-le encore pour '
            'l’enlever).',
          ),
          for (final d in domaines)
            Card(
              key: Key('domaine-eval-${d.id}'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final n in niveaux)
                          ChoiceChip(
                            key: Key('niveau-${d.id}-${n.code}'),
                            avatar: Icon(
                              iconeNiveau(n.pictogramme),
                              color: Color(n.couleurArgb),
                            ),
                            label: Text(n.libelle),
                            selected: evals[(e.id, d.id)] == n.id,
                            selectedColor: Color(n.couleurArgb)
                                .withValues(alpha: 0.18),
                            onSelected: (choisi) => repo.evaluer(
                              schoolId: e.schoolId,
                              periodId: _periodId,
                              studentId: e.id,
                              domainId: d.id,
                              levelId: choisi ? n.id : null,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SectionTitle('Livret'),
          AutoSaveField(
            key: ValueKey('appreciation-$_periodId-${e.id}'),
            label: 'Appréciation de l’enseignant(e)',
            initial: livret?.teacherAppreciation,
            maxLines: 3,
            onSave: (v) => saveLivret('teacher_appreciation', v),
          ),
          if (directeur)
            AutoSaveField(
              key: ValueKey('observation-$_periodId-${e.id}'),
              label: 'Observations du directeur',
              initial: livret?.observation,
              maxLines: 3,
              onSave: (v) => saveLivret('observation', v),
            )
          else if ((livret?.observation ?? '').isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Observations du directeur'),
              subtitle: Text(livret!.observation!),
            ),
          const SizedBox(height: 8),
          BigButton(
            icon: Icons.print,
            label: 'Livret de l’enfant (PDF)',
            onPressed: _occupe ? null : () => _livret(nom),
          ),
          if (suivant != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                'Enfant suivant : ${suivant.lastName} ${suivant.firstNames}',
              ),
              onPressed: () => context.pushReplacement(
                '/maternelle/classe/${widget.classId}/t/${widget.trimestre}/enfant/${suivant.id}',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ------------------------------ Présences ------------------------------

const statutsPresence = {
  'present': 'Présent',
  'absent': 'Absent',
  'retard': 'Retard',
};

/// Appel du jour : présent, absent ou en retard.
class PresencesPage extends ConsumerStatefulWidget {
  const new(this.classId, {super.key});
  final String classId;

  @override
  ConsumerState<PresencesPage> createState() => _PresencesState();
}

class _PresencesState extends ConsumerState<PresencesPage> {
  late String _jour = AutoSaveDateField.iso(
    ref.read(localStoreProvider).clock.now().toLocal(),
  );

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(classProvider(widget.classId)).value;
    final enfants = ref.watch(enfantsProvider(widget.classId)).value ?? [];
    final presences =
        ref.watch(presencesProvider((widget.classId, _jour))).value ?? const {};
    final repo = ref.read(maternelleRepositoryProvider);
    if (c == null) {
      return const EcoleScaffold(
        title: 'Présences',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final absents = presences.values.where((s) => s == 'absent').length;
    final retards = presences.values.where((s) => s == 'retard').length;
    return EcoleScaffold(
      title: 'Présences — ${c.name}',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Le ${jjmmaaaa(_jour)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text('Autre jour'),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.parse(_jour),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) {
                    setState(() => _jour = AutoSaveDateField.iso(d));
                  }
                },
              ),
            ],
          ),
          Text(
            '${enfants.length - absents} présent(s) sur ${enfants.length} · '
            '$absents absent(s) · $retards retard(s)',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('tous-presents'),
            icon: const Icon(Icons.done_all),
            label: const Text('Tous les autres sont présents'),
            onPressed: () async {
              for (final e in enfants) {
                if (!presences.containsKey(e.id)) {
                  await repo.marquer(c, e.id, _jour, 'present');
                }
              }
            },
          ),
          for (final e in enfants)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e.lastName} ${e.firstNames}'),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final MapEntry(key: s, value: libelle)
                            in statutsPresence.entries)
                          ChoiceChip(
                            key: Key('presence-${e.id}-$s'),
                            label: Text(libelle),
                            selected: presences[e.id] == s,
                            onSelected: (_) => repo.marquer(c, e.id, _jour, s),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
