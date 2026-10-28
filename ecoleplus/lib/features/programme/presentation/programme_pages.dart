import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/programme/data/programme_repository.dart';
import 'package:ecoleplus/features/programme/domain/programme.dart';
import 'package:ecoleplus/features/programme/pdf/pdf_programme.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

final programmeRepositoryProvider = Provider<ProgrammeRepository>(
  (ref) => ProgrammeRepository(ref.watch(localStoreProvider)),
);

final StreamProviderFamily<List<ObjectifProgramme>, String> objectifsProvider =
    StreamProvider.family(
      (ref, yearId) =>
          ref.watch(programmeRepositoryProvider).watchObjectifs(yearId),
    );

final StreamProviderFamily<List<FormVersionRow>, (String, String)>
versionsProvider = StreamProvider.family(
  (ref, k) => ref.watch(programmeRepositoryProvider).watchVersions(k.$1, k.$2),
);

final StreamProviderFamily<ActivityLineRow?, String> activiteProvider =
    StreamProvider.family(
      (ref, id) => ref.watch(programmeRepositoryProvider).watchActivite(id),
    );

const _messageVerrou =
    'Version finale verrouillée : touchez « Modifier » pour la changer.';

/// Demande un texte, avec des propositions à toucher (modifiables).
Future<String?> demanderTexte(
  BuildContext context, {
  required String titre,
  required String label,
  String initial = '',
  List<String> propositions = const [],
}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(titre),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('texte-dialogue'),
                controller: c,
                autofocus: true,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: label),
              ),
              if (propositions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Propositions (modifiables) :'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final p in propositions)
                      ActionChip(
                        label: Text(p),
                        onPressed: () => setState(() => c.text = p),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final t = c.text.trim();
              Navigator.pop(ctx, t.isEmpty ? null : t);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    ),
  );
}

/// Programme d'activités (B6) ou bilan annuel (B7) de l'année en cours.
class ProgrammePage extends ConsumerStatefulWidget {
  const new(this.code, {super.key});

  /// « B6 » ou « B7 ».
  final String code;

  @override
  ConsumerState<ProgrammePage> createState() => _ProgrammeState();
}

class _ProgrammeState extends ConsumerState<ProgrammePage> {
  bool _occupe = false;

  FormulaireActivites get _f => FormulaireActivites.depuis(widget.code);

  Future<void> _sortir(
    SchoolRow ecole,
    SchoolYearRow annee,
    DonneesProgramme? fige, {
    required bool partager,
  }) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final repo = ref.read(programmeRepositoryProvider);
      final d = fige ?? await repo.donnees(_f, ecole, annee.id);
      final pdf = await pdfProgramme(
        await ref.read(policesPdfProvider.future),
        d,
      );
      final nom = '${widget.code}_${annee.label}.pdf';
      final sortie = ref.read(sortiePdfProvider);
      await (partager ? sortie.partager : sortie.imprimer)(pdf, nom);
      final forms = ref.read(formsRepositoryProvider);
      final actuel = await forms.watchFormulaire(annee.id, widget.code).first;
      if (actuel?.status != 'signe_archive') {
        await forms.enregistrer(ecole.id, annee.id, widget.code, {
          'status': 'imprime',
        });
      }
    });
    if (mounted) setState(() => _occupe = false);
  }

  Future<void> _valider(SchoolRow ecole, SchoolYearRow annee) async {
    final ok = await confirmer(
      context,
      titre: 'Valider la version finale ?',
      message:
          'Le ${_f.titre.toLowerCase()} sera verrouillé tel qu’il est. '
          'Pour le changer ensuite, il faudra toucher « Modifier » : une '
          'nouvelle version sera créée et celle-ci restera conservée.',
      bouton: 'Valider',
    );
    if (!ok || !mounted) return;
    final n = await avecMessage(
      context,
      () => ref
          .read(programmeRepositoryProvider)
          .validerVersionFinale(_f, ecole, annee.id),
    );
    if (n != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Version finale $n validée et verrouillée.')),
      );
    }
  }

  Future<void> _modifier(SchoolRow ecole, SchoolYearRow annee, int n) async {
    final ok = await confirmer(
      context,
      titre: 'Modifier ?',
      message:
          'Le formulaire redevient modifiable. La version finale $n reste '
          'conservée : vous pourrez toujours la réimprimer.',
      bouton: 'Modifier',
    );
    if (!ok || !mounted) return;
    await avecMessage(
      context,
      () => ref
          .read(programmeRepositoryProvider)
          .deverrouiller(ecole.id, annee.id, widget.code),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final ecole = ref.watch(schoolProvider(session.schoolId)).value;
    final annees = ref.watch(yearsProvider(session.schoolId)).value ?? [];
    final annee = annees
        .where((y) => y.id == ecole?.currentSchoolYearId)
        .firstOrNull;
    final f = _f;
    if (ecole == null || annee == null) {
      return EcoleScaffold(
        title: f.titre,
        body: const InfoMessage('Année scolaire introuvable.'),
      );
    }
    final form = ref.watch(formulaireProvider((annee.id, f.code))).value;
    final objectifs = ref.watch(objectifsProvider(annee.id)).value ?? [];
    final versions =
        ref.watch(versionsProvider((annee.id, f.code))).value ?? [];
    final verrou = form?.lockedVersion;
    final fige = verrou == null
        ? null
        : versions.where((v) => v.versionNo == verrou).firstOrNull;
    final modifiable = verrou == null;
    final repo = ref.read(programmeRepositoryProvider);
    final forms = ref.read(formsRepositoryProvider);
    Future<void> save(String col, Object? v) =>
        forms.enregistrer(ecole.id, annee.id, f.code, {col: v});
    final programme = f == FormulaireActivites.programme;

    return EcoleScaffold(
      title: '${f.code} — ${f.titre}',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Année scolaire ${annee.label}'),
          const SizedBox(height: 8),
          if (!modifiable)
            Card(
              key: const Key('verrou'),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Version finale $verrou verrouillée',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pour changer quoi que ce soit, touchez « Modifier » : '
                      'une nouvelle version sera créée, celle-ci reste '
                      'conservée.',
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                      onPressed: () => _modifier(ecole, annee, verrou),
                    ),
                  ],
                ),
              ),
            ),
          if (!programme)
            const InfoMessage(
              'Les objectifs et les activités viennent du programme (B6) : '
              'rien à retaper. Touchez une activité pour saisir le résultat '
              'atteint et le taux de réussite.',
            ),
          if (!programme && objectifs.isEmpty)
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_note),
              label: const Text('Saisir d’abord le programme (B6)'),
              onPressed: () => context.push('/programme/B6'),
            ),
          for (final (i, o) in objectifs.indexed)
            _CarteObjectif(
              numero: i + 1,
              objectif: o,
              formulaire: f,
              modifiable: modifiable,
              onRenommer: () async {
                final t = await demanderTexte(
                  context,
                  titre: 'Objectif ${i + 1}',
                  label: 'Objectif',
                  initial: o.libelle,
                );
                if (t != null) await repo.renommerObjectif(o.id, t);
              },
              onDeplacer: (sens) => repo.deplacerObjectif(annee.id, o.id, sens),
              onSupprimer: () async {
                final ok = await confirmer(
                  context,
                  titre: 'Supprimer l’objectif ${i + 1} ?',
                  message:
                      '« ${o.libelle} » et ses ${o.activites.length} '
                      'activité(s) seront retirés du programme et du bilan.',
                  bouton: 'Supprimer',
                );
                if (ok) await repo.supprimerObjectif(o.id);
              },
              onAjouterActivite: () async {
                final t = await demanderTexte(
                  context,
                  titre: 'Nouvelle activité',
                  label: 'Activité prévue',
                  propositions: [
                    for (final s in suggestionsPour(o.libelle))
                      if (!o.activites.any((a) => a.activite == s)) s,
                  ],
                );
                if (t == null) return;
                final id = await repo.ajouterActivite(ecole.id, o.id, t);
                if (context.mounted) {
                  unawaited(context.push('/programme/${f.code}/activite/$id'));
                }
              },
            ),
          if (programme && modifiable) ...[
            const SizedBox(height: 8),
            BigButton(
              icon: Icons.add,
              label: 'Ajouter un objectif',
              onPressed: () async {
                final t = await demanderTexte(
                  context,
                  titre: 'Objectif ${objectifs.length + 1}',
                  label: 'Objectif',
                  propositions: [
                    for (final s in suggestionsProgramme.keys)
                      if (!objectifs.any((o) => o.libelle == s)) s,
                  ],
                );
                if (t != null) {
                  await repo.ajouterObjectif(ecole.id, annee.id, t);
                }
              },
            ),
          ],
          const SectionTitle('Avant d’imprimer'),
          if (modifiable) ...[
            AutoSaveField(
              key: ValueKey('fait-a-${form?.id}'),
              label: 'Fait à',
              initial: form?.signedPlace ?? ecole.commune,
              onSave: (v) => save('signed_place', v),
            ),
            AutoSaveDateField(
              label: 'Le',
              initial: form?.signedOn,
              onSave: (v) => save('signed_on', v),
            ),
            AutoSaveField(
              key: ValueKey('directeur-${form?.id}'),
              label: 'Nom du directeur',
              initial: form?.directorName ?? ecole.directorName,
              onSave: (v) => save('director_name', v),
            ),
            if (!programme)
              SwitchListTile(
                key: const Key('moyenne-objectif'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Imprimer la moyenne de chaque objectif'),
                value: form?.showObjectiveAverage ?? false,
                onChanged: (v) => save('show_objective_average', v),
              ),
            const SizedBox(height: 8),
            BigButton(
              icon: Icons.verified,
              label: 'Valider la version finale',
              onPressed: _occupe || objectifs.isEmpty
                  ? null
                  : () => _valider(ecole, annee),
            ),
          ] else
            Text(
              'Fait à ${form?.signedPlace ?? '…'}, le '
              '${form?.signedOn == null ? '…' : jjmmaaaa(form!.signedOn)}',
            ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.print,
            label: 'Aperçu et impression',
            onPressed: _occupe
                ? null
                : () => _sortir(
                    ecole,
                    annee,
                    fige == null ? null : ProgrammeRepository.instantane(fige),
                    partager: false,
                  ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Partager le PDF (WhatsApp, e-mail…)'),
            onPressed: _occupe
                ? null
                : () => _sortir(
                    ecole,
                    annee,
                    fige == null ? null : ProgrammeRepository.instantane(fige),
                    partager: true,
                  ),
          ),
          if (_occupe) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],
          if (versions.isNotEmpty) ...[
            const SectionTitle('Versions finales conservées'),
            for (final v in versions)
              Card(
                child: ListTile(
                  key: Key('version-${v.versionNo}'),
                  leading: Icon(
                    v.versionNo == verrou ? Icons.lock : Icons.history,
                  ),
                  title: Text('Version ${v.versionNo}'),
                  subtitle: Text(
                    'Validée le ${jjmmaaaa(v.createdAt?.substring(0, 10))}'
                    '${v.versionNo == verrou ? ' • en vigueur' : ''}',
                  ),
                  trailing: const Icon(Icons.print_outlined),
                  onTap: _occupe
                      ? null
                      : () => _sortir(
                          ecole,
                          annee,
                          ProgrammeRepository.instantane(v),
                          partager: false,
                        ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _CarteObjectif extends StatelessWidget {
  const new({
    required this.numero,
    required this.objectif,
    required this.formulaire,
    required this.modifiable,
    required this.onRenommer,
    required this.onDeplacer,
    required this.onSupprimer,
    required this.onAjouterActivite,
  });

  final int numero;
  final ObjectifProgramme objectif;
  final FormulaireActivites formulaire;
  final bool modifiable;
  final VoidCallback onRenommer;
  final ValueChanged<int> onDeplacer;
  final VoidCallback onSupprimer;
  final VoidCallback onAjouterActivite;

  @override
  Widget build(BuildContext context) {
    final programme = formulaire == FormulaireActivites.programme;
    final o = objectif;
    final moyenne = o.tauxMoyen;
    return Card(
      key: Key('objectif-$numero'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$numero. ${o.libelle}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (programme && modifiable)
                  PopupMenuButton<String>(
                    key: Key('menu-objectif-$numero'),
                    onSelected: (v) => switch (v) {
                      'renommer' => onRenommer(),
                      'monter' => onDeplacer(-1),
                      'descendre' => onDeplacer(1),
                      _ => onSupprimer(),
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'renommer', child: Text('Modifier')),
                      PopupMenuItem(value: 'monter', child: Text('Monter')),
                      PopupMenuItem(
                        value: 'descendre',
                        child: Text('Descendre'),
                      ),
                      PopupMenuItem(
                        value: 'supprimer',
                        child: Text('Supprimer'),
                      ),
                    ],
                  ),
              ],
            ),
            if (!programme && moyenne != null)
              Text('Moyenne de l’objectif : ${texteTaux(moyenne)} %'),
            for (final a in o.activites)
              ListTile(
                key: Key('activite-${a.id}'),
                dense: true,
                contentPadding: const EdgeInsets.only(left: 8, right: 8),
                title: Text(a.activite),
                subtitle: Text(
                  programme
                      ? [
                          if (a.echeance.isNotEmpty) 'Échéance : ${a.echeance}',
                          if ((a.attendu ?? '').isNotEmpty)
                            'Attendu : ${a.attendu}',
                        ].join('\n')
                      : [
                          'Attendu : ${a.attendu ?? '—'}',
                          [
                            'Atteint : ${a.atteint ?? '—'}',
                            if (a.taux != null) '${texteTaux(a.taux)} %',
                          ].join(' • '),
                        ].join('\n'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/programme/${formulaire.code}/activite/${a.id}',
                ),
              ),
            if (o.activites.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Aucune activité pour l’instant.'),
              ),
            if (programme && modifiable)
              TextButton.icon(
                key: Key('ajouter-activite-$numero'),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une activité'),
                onPressed: onAjouterActivite,
              ),
          ],
        ),
      ),
    );
  }
}

/// Une activité : colonnes du programme (B6) ou du bilan (B7).
class ActivitePage extends ConsumerWidget {
  const new(this.code, this.id, {super.key});
  final String code;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final ecole = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = ecole?.currentSchoolYearId;
    final a = ref.watch(activiteProvider(id)).value;
    final f = FormulaireActivites.depuis(code);
    if (yearId == null || a == null) {
      return const EcoleScaffold(
        title: 'Activité',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final form = ref.watch(formulaireProvider((yearId, code))).value;
    final modifiable = form?.lockedVersion == null;
    final repo = ref.read(programmeRepositoryProvider);
    Future<void> save(String col, Object? v) =>
        repo.modifierActivite(id, {col: v});
    final programme = f == FormulaireActivites.programme;
    Widget lecture(String label, String? v) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text((v ?? '').isEmpty ? '—' : v!),
    );
    final b6 = programme && modifiable;
    return EcoleScaffold(
      title: programme ? 'Activité du programme' : 'Résultat de l’activité',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!modifiable) const InfoMessage(_messageVerrou, icon: Icons.lock),
          if (b6) ...[
            AutoSaveField(
              key: ValueKey('activite-$id'),
              label: 'Activité prévue',
              initial: a.plannedActivity,
              maxLines: 3,
              onSave: (v) async {
                if ((v ?? '').trim().isNotEmpty) {
                  await save('planned_activity', v!.trim());
                }
              },
            ),
            AutoSaveDateField(
              label: 'Échéance (date)',
              initial: a.deadlineOn,
              onSave: (v) => save('deadline_on', v),
            ),
            AutoSaveField(
              key: ValueKey('echeance-$id'),
              label: 'ou échéance en toutes lettres',
              hint: 'Ex. : Toute l’année, 1er trimestre',
              helper: 'Si rempli, ce texte est imprimé à la place de la date.',
              initial: a.deadlineText,
              onSave: (v) => save('deadline_text', v),
            ),
            AutoSaveField(
              key: ValueKey('contrainte-$id'),
              label: 'Contrainte de réalisation',
              initial: a.constraintText,
              maxLines: 2,
              onSave: (v) => save('constraint_text', v),
            ),
            AutoSaveField(
              key: ValueKey('attendu-$id'),
              label: 'Résultats attendus',
              initial: a.expectedResult,
              maxLines: 3,
              onSave: (v) => save('expected_result', v),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Supprimer cette activité'),
              onPressed: () async {
                final ok = await confirmer(
                  context,
                  titre: 'Supprimer l’activité ?',
                  message:
                      '« ${a.plannedActivity} » sera retirée du programme '
                      'et du bilan.',
                  bouton: 'Supprimer',
                );
                if (!ok) return;
                await repo.supprimerActivite(id);
                if (context.mounted) context.pop();
              },
            ),
          ] else ...[
            lecture('Activité prévue', a.plannedActivity),
            if (programme) ...[
              lecture(
                'Échéance',
                ActiviteProgramme(
                  activite: '',
                  echeanceDate: a.deadlineOn,
                  echeanceTexte: a.deadlineText,
                ).echeance,
              ),
              lecture('Contrainte de réalisation', a.constraintText),
            ],
            lecture('Résultats attendus', a.expectedResult),
          ],
          if (!programme) ...[
            if (modifiable) ...[
              AutoSaveField(
                key: ValueKey('atteint-$id'),
                label: 'Résultats atteints',
                initial: a.achievedResult,
                maxLines: 3,
                onSave: (v) => save('achieved_result', v),
              ),
              AutoSaveField(
                key: ValueKey('taux-$id'),
                label: 'Taux de réussite (%)',
                hint: 'Ex. : 75 ou 66,67',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                initial: texteTaux(a.successRate),
                verifier: (v) async {
                  try {
                    lireTaux(v);
                    return null;
                  } on FormatException {
                    return 'Un nombre entre 0 et 100.';
                  }
                },
                onSave: (v) => save('success_rate', lireTaux(v)),
              ),
            ] else ...[
              lecture('Résultats atteints', a.achievedResult),
              lecture(
                'Taux de réussite',
                a.successRate == null ? null : '${texteTaux(a.successRate)} %',
              ),
            ],
          ],
        ],
      ),
    );
  }
}
