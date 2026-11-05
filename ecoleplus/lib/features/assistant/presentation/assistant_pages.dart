import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/tableau.dart';
import 'package:ecoleplus/features/assistant/data/assistant_api.dart';
import 'package:ecoleplus/features/assistant/data/assistant_repository.dart';
import 'package:ecoleplus/features/assistant/pdf/pdf_fiche.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

final assistantApiProvider = Provider<AssistantApi>(
  (ref) => SupabaseAssistantApi(ref.watch(supabaseClientProvider)),
);

final assistantRepositoryProvider = Provider<AssistantRepository>(
  (ref) => AssistantRepository(ref.watch(localStoreProvider)),
);

/// Demandes restantes ce mois-ci (null : sans Internet).
final FutureProviderFamily<Restant?, String> restantIaProvider =
    FutureProvider.family((ref, schoolId) async {
      try {
        return await ref.watch(assistantApiProvider).restant(schoolId);
      } on Object {
        return null;
      }
    });

final StreamProviderFamily<List<LessonPrepRow>, String> fichesIaProvider =
    StreamProvider.family(
      (ref, authorId) =>
          ref.watch(assistantRepositoryProvider).watchFiches(authorId),
    );

const _types = {
  'preparation': 'Préparer un cours',
  'exercices': 'Exercices et évaluations',
  'remediation': 'Aider un élève en difficulté',
};

const _actions = {
  'simplifier': 'Simplifier',
  'developper': 'Développer',
  'changer': 'Changer d’approche',
};

/// Texte du compteur : « Il vous reste 22 demandes ce mois-ci ».
String texteRestant(Restant r) {
  if (r.ecole == 0) {
    return 'L’école a utilisé toutes ses demandes de ce mois. Parlez-en au '
        'directeur.';
  }
  if (r.enseignant == 0) {
    return 'Vous avez utilisé vos ${r.limite} demandes de ce mois. Elles '
        'reviennent le 1er du mois prochain.';
  }
  final n = r.disponible;
  return 'Il vous reste $n demande${n > 1 ? 's' : ''} ce mois-ci.';
}

// ----------------------------------------------------------------------
// Accueil de l'assistant
// ----------------------------------------------------------------------

class AssistantPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantState();
}

class _AssistantState extends ConsumerState<AssistantPage> {
  List<Map<String, dynamic>> _attente = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_lireAttente());
  }

  Future<void> _lireAttente() async {
    final l = await ref.read(assistantRepositoryProvider).enAttente();
    if (mounted) setState(() => _attente = l);
  }

  Future<void> _envoyerAttente(Map<String, dynamic> d) async {
    final demande = {
      for (final e in d.entries)
        if (!e.key.startsWith('_')) e.key: e.value,
    };
    final r = await envoyerDemande(context, ref, demande);
    if (r == null || !mounted) return;
    await ref.read(assistantRepositoryProvider).oublier(d);
    await _lireAttente();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider).value;
    if (s == null) {
      return const EcoleScaffold(title: 'Assistant IA', body: SizedBox());
    }
    final restant = ref.watch(restantIaProvider(s.schoolId));
    Widget bouton(IconData i, String t, String route) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BigButton(icon: i, label: t, onPressed: () => context.push(route)),
    );
    return EcoleScaffold(
      title: 'Assistant IA',
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(restantIaProvider(s.schoolId));
          await _lireAttente();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: Text(
                  restant.when(
                    data: (r) => r == null
                        ? 'Sans Internet : vous pouvez préparer une demande, '
                              'elle partira quand le réseau revient.'
                        : texteRestant(r),
                    loading: () => 'Lecture du compteur…',
                    error: (_, _) => '',
                  ),
                  key: const Key('compteur-ia'),
                ),
                subtitle: const Text(
                  'L’assistant propose ; vous relisez et modifiez. Aucun nom '
                  'd’élève n’est envoyé.',
                ),
              ),
            ),
            if (_attente.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.schedule_send),
                      title: Text(
                        '${_attente.length} demande(s) en attente d’Internet',
                      ),
                    ),
                    for (final d in _attente)
                      ListTile(
                        dense: true,
                        title: Text(
                          '${_types[d['kind']] ?? d['kind']} : '
                          '${d['theme'] ?? d['difficultes'] ?? ''}',
                        ),
                        trailing: TextButton(
                          key: const Key('envoyer-attente'),
                          onPressed: () => _envoyerAttente(d),
                          child: const Text('Envoyer'),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            bouton(
              Icons.menu_book,
              _types['preparation']!,
              '/assistant/demande/preparation',
            ),
            bouton(
              Icons.quiz_outlined,
              _types['exercices']!,
              '/assistant/demande/exercices',
            ),
            bouton(
              Icons.support,
              _types['remediation']!,
              '/assistant/demande/remediation',
            ),
            bouton(Icons.folder_open, 'Mes fiches', '/assistant/fiches'),
            if (s.role == 'directeur')
              bouton(
                Icons.bar_chart,
                'Suivi de l’école (directeur)',
                '/assistant/suivi',
              ),
          ],
        ),
      ),
    );
  }
}

/// Envoie une demande ; affiche la fiche, ou garde la demande sans
/// Internet. Renvoie la réponse (null : rien d'affiché).
Future<ReponseIa?> envoyerDemande(
  BuildContext context,
  WidgetRef ref,
  Map<String, Object?> demande, {
  bool remplacer = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('L’assistant prépare sa proposition…')),
          ],
        ),
      ),
    ),
  );
  ReponseIa? r;
  String? erreur;
  var horsLigne = false;
  try {
    r = await ref.read(assistantApiProvider).demander(demande);
  } on HorsLigneIa {
    horsLigne = true;
  } on UserMessage catch (e) {
    erreur = e.message;
  } on Object {
    erreur = 'L’assistant n’a pas pu répondre. Réessayez.';
  }
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  final s = ref.read(sessionProvider).value;
  if (s != null) ref.invalidate(restantIaProvider(s.schoolId));
  if (horsLigne) {
    if (demande['action'] == null) {
      await ref.read(assistantRepositoryProvider).garder(demande);
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          demande['action'] == null
              ? 'Pas d’Internet : votre demande est gardée. Elle pourra être '
                    'envoyée depuis l’accueil de l’assistant quand le réseau '
                    'revient.'
              : 'Pas d’Internet : réessayez quand le réseau revient.',
        ),
      ),
    );
    return null;
  }
  if (erreur != null) {
    messenger.showSnackBar(SnackBar(content: Text(erreur)));
    return null;
  }
  final extra = ResultatArgs(demande: demande, reponse: r!);
  ResultatsIa.dernier = extra;
  if (remplacer) {
    unawaited(router.pushReplacement('/assistant/resultat', extra: extra));
  } else {
    unawaited(router.push('/assistant/resultat', extra: extra));
  }
  return r;
}

// ----------------------------------------------------------------------
// Demande
// ----------------------------------------------------------------------

class DemandeIaPage extends ConsumerStatefulWidget {
  const new(this.kind, {super.key});
  final String kind;

  @override
  ConsumerState<DemandeIaPage> createState() => _DemandeState();
}

class _DemandeState extends ConsumerState<DemandeIaPage> {
  final _c = <String, TextEditingController>{};
  bool _bibliotheque = true;
  Set<String>? _documents;

  TextEditingController _champ(String k) =>
      _c.putIfAbsent(k, TextEditingController.new);

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _choisirDocuments(String schoolId) async {
    List<DocumentIa> docs;
    try {
      docs = await ref.read(assistantApiProvider).documents(schoolId);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion à Internet nécessaire pour la liste.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    final choisis = {...?_documents};
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Documents à utiliser'),
          content: SizedBox(
            width: double.maxFinite,
            child: docs.isEmpty
                ? const Text(
                    'Aucun document de la bibliothèque n’est disponible pour '
                    'l’assistant.',
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final d in docs)
                        CheckboxListTile(
                          key: Key('doc-${d.id}'),
                          value: choisis.contains(d.id),
                          title: Text(d.titre),
                          subtitle: d.indexe
                              ? null
                              : const Text('Texte pas encore lu'),
                          onChanged: (v) => setState(
                            () => v == true
                                ? choisis.add(d.id)
                                : choisis.remove(d.id),
                          ),
                        ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Utiliser ces documents'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      setState(() => _documents = choisis.isEmpty ? null : choisis);
    }
  }

  Widget _texte(String k, String label, {String? aide, int lignes = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: lignes > 1
            ? TextField(
                key: Key('ia-$k'),
                controller: _champ(k),
                maxLines: lignes,
                decoration: InputDecoration(
                  labelText: label,
                  helperText: aide,
                  helperMaxLines: 2,
                  border: const OutlineInputBorder(),
                  suffixIcon: MicButton(
                    compact: true,
                    ajouter: true,
                    texteActuel: () => _champ(k).text,
                    inserer: (t) => _champ(k).text = t,
                  ),
                ),
              )
            : TexteDictable(
                key: Key('ia-$k'),
                controller: _champ(k),
                label: label,
                helper: aide,
              ),
      );

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider).value;
    if (s == null) {
      return const EcoleScaffold(title: 'Assistant IA', body: SizedBox());
    }
    final titre = _types[widget.kind] ?? 'Assistant IA';
    final champs = switch (widget.kind) {
      'exercices' => [
        _texte('niveau', 'Classe ou niveau (ex. CM1)'),
        _texte('matiere', 'Matière'),
        _texte('theme', 'Thème'),
        _texte(
          'type_exercice',
          'Type (exercices, problèmes, dictée, évaluation…)',
        ),
        _texte('difficulte', 'Difficulté (facile, moyen, difficile)'),
        _texte('nb_questions', 'Nombre de questions'),
      ],
      'remediation' => [
        _texte('niveau', 'Classe ou niveau (ex. CE1)'),
        _texte('matiere', 'Matière'),
        _texte(
          'difficultes',
          'La difficulté, avec vos mots',
          aide:
              'Ex. : il confond les dizaines et les unités. N’écrivez pas '
              'le nom de l’élève.',
          lignes: 3,
        ),
      ],
      _ => [
        _texte('niveau', 'Classe ou niveau (ex. CM1, grande section)'),
        _texte('matiere', 'Matière'),
        _texte('theme', 'Thème'),
        _texte('duree', 'Durée (ex. 45 min)'),
        _texte('objectif', 'Objectif', lignes: 2),
        _texte('nb_eleves', 'Nombre d’élèves (facultatif)'),
        _texte(
          'difficultes',
          'Difficultés particulières (facultatif)',
          aide: 'N’écrivez pas de nom d’élève.',
          lignes: 2,
        ),
      ],
    };
    return EcoleScaffold(
      title: titre,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...champs,
          SwitchListTile(
            key: const Key('ia-bibliotheque'),
            contentPadding: EdgeInsets.zero,
            title: const Text('S’appuyer sur la bibliothèque de l’école'),
            subtitle: Text(
              !_bibliotheque
                  ? 'Réponse sans vos documents.'
                  : _documents == null
                  ? 'Les documents utiles sont choisis automatiquement.'
                  : '${_documents!.length} document(s) choisi(s).',
            ),
            value: _bibliotheque,
            onChanged: (v) => setState(() => _bibliotheque = v),
          ),
          if (_bibliotheque)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.checklist),
                label: const Text('Choisir les documents'),
                onPressed: () => _choisirDocuments(s.schoolId),
              ),
            ),
          const SizedBox(height: 12),
          BigButton(
            key: const Key('ia-generer'),
            icon: Icons.auto_awesome,
            label: 'Demander à l’assistant',
            onPressed: () async {
              final demande = <String, Object?>{
                'school_id': s.schoolId,
                'kind': widget.kind,
                for (final MapEntry(key: k, value: c) in _c.entries)
                  if (c.text.trim().isNotEmpty) k: c.text.trim(),
                if (!_bibliotheque) 'sans_bibliotheque': true,
                if (_bibliotheque && _documents != null)
                  'documents': _documents!.toList(),
              };
              if (demande['theme'] == null && demande['difficultes'] == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.kind == 'remediation'
                          ? 'Décrivez la difficulté de l’élève.'
                          : 'Indiquez le thème.',
                    ),
                  ),
                );
                return;
              }
              await envoyerDemande(context, ref, demande, remplacer: true);
            },
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Résultat (relire, retoucher, enregistrer, PDF)
// ----------------------------------------------------------------------

/// Dernier résultat ouvert (la page se reconstruit sans perdre la fiche
/// quand le routeur se rafraîchit, par exemple après une synchronisation).
abstract final class ResultatsIa {
  static ResultatArgs? dernier;
}

class ResultatArgs {
  const new({required this.demande, required this.reponse, this.ficheId});
  final Map<String, Object?> demande;
  final ReponseIa reponse;

  /// Fiche déjà enregistrée (mise à jour plutôt que copie).
  final String? ficheId;
}

class ResultatIaPage extends ConsumerStatefulWidget {
  const new(this.args, {super.key});
  final ResultatArgs args;

  @override
  ConsumerState<ResultatIaPage> createState() => _ResultatState();
}

class _ResultatState extends ConsumerState<ResultatIaPage> {
  late final _titre = TextEditingController(
    text: widget.args.reponse.fiche.titre,
  );
  late final List<(TextEditingController, TextEditingController)> _sections = [
    for (final s in widget.args.reponse.fiche.sections)
      (
        TextEditingController(text: s.titre),
        TextEditingController(text: s.contenu),
      ),
  ];
  bool _modifier = false;
  late String? _ficheId = widget.args.ficheId;

  @override
  void dispose() {
    _titre.dispose();
    for (final (a, b) in _sections) {
      a.dispose();
      b.dispose();
    }
    super.dispose();
  }

  FicheIa get _fiche => FicheIa(_titre.text.trim(), [
    for (final (a, b) in _sections) SectionIa(a.text.trim(), b.text.trim()),
  ]);

  Future<void> _enregistrer() async {
    final s = ref.read(sessionProvider).value!;
    final id = await avecMessage(
      context,
      () => ref
          .read(assistantRepositoryProvider)
          .enregistrer(
            id: _ficheId,
            schoolId: s.schoolId,
            authorId: s.userId,
            kind: '${widget.args.demande['kind']}',
            demande: widget.args.demande,
            fiche: _fiche,
            sources: widget.args.reponse.sources,
          ),
    );
    if (id == null || !mounted) return;
    setState(() => _ficheId = id);
    unawaited(ref.read(syncEngineProvider).syncNow());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fiche enregistrée dans « Mes fiches ».')),
    );
  }

  Future<void> _pdf() async {
    final s = ref.read(sessionProvider).value!;
    final ecole = ref.read(schoolProvider(s.schoolId)).value;
    await avecMessage(context, () async {
      final pdf = await pdfFicheIa(
        await ref.read(policesPdfProvider.future),
        ecole: ecole?.name ?? '',
        auteur: s.displayName,
        date: DateTime.now().toIso8601String().substring(0, 10),
        fiche: _fiche,
        sources: widget.args.reponse.sources,
      );
      await ref
          .read(sortiePdfProvider)
          .partager(pdf, 'Fiche_${_titre.text}.pdf');
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.args.reponse;
    final cs = Theme.of(context).colorScheme;
    return EcoleScaffold(
      title: 'Proposition de l’assistant',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_modifier)
            TextField(
              controller: _titre,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: const InputDecoration(labelText: 'Titre'),
            )
          else
            Text(
              _titre.text,
              key: const Key('ia-titre'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          const SizedBox(height: 8),
          Container(
            key: const Key('ia-sources'),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: r.horsDocuments
                  ? cs.surfaceContainerHighest
                  : cs.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              r.horsDocuments
                  ? 'Non issu de vos documents.'
                  : 'Sources utilisées : '
                        '${r.sources.map((s) => s.libelle).join(' ; ')}',
            ),
          ),
          if (r.extraitsRetires > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Un long extrait recopié d’un document a été retiré « […] ».',
                style: TextStyle(color: cs.outline, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          for (final (i, (t, c)) in _sections.indexed) ...[
            if (_modifier) ...[
              TextField(
                controller: t,
                decoration: const InputDecoration(
                  labelText: 'Titre de la partie',
                ),
              ),
              TextField(
                key: Key('ia-section-$i'),
                controller: c,
                maxLines: null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ] else ...[
              Text(t.text, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              SelectableText(c.text),
            ],
            const SizedBox(height: 14),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('ia-modifier'),
                icon: Icon(_modifier ? Icons.check : Icons.edit),
                label: Text(_modifier ? 'Terminer' : 'Modifier'),
                onPressed: () => setState(() => _modifier = !_modifier),
              ),
              for (final MapEntry(key: k, value: v) in _actions.entries)
                OutlinedButton(
                  key: Key('ia-$k'),
                  onPressed: () => envoyerDemande(context, ref, {
                    ...widget.args.demande,
                    'action': k,
                    'precedent': _fiche.toJson(),
                  }, remplacer: true),
                  child: Text(v),
                ),
            ],
          ),
          const SizedBox(height: 12),
          BigButton(
            key: const Key('ia-enregistrer'),
            icon: Icons.save,
            label: _ficheId == null
                ? 'Enregistrer la fiche'
                : 'Enregistrer les modifications',
            onPressed: _enregistrer,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Exporter en PDF'),
            onPressed: _pdf,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copier le texte'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _fiche.texte));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Texte copié.')));
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Proposition de l’assistant (${r.modele}) : relisez-la avant de '
            'l’utiliser en classe.',
            style: TextStyle(color: cs.outline, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Mes fiches
// ----------------------------------------------------------------------

class FichesIaPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider).value;
    if (s == null) {
      return const EcoleScaffold(title: 'Mes fiches', body: SizedBox());
    }
    final fiches = ref.watch(fichesIaProvider(s.userId)).value;
    return EcoleScaffold(
      title: 'Mes fiches',
      body: fiches == null
          ? const LinearProgressIndicator()
          : fiches.isEmpty
          ? const InfoMessage(
              'Aucune fiche enregistrée. Demandez une préparation à '
              'l’assistant, puis « Enregistrer la fiche ».',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TableauDonnees(
                  colonnes: const [
                    ColonneTableau('Fiche', flex: 5, largeurMin: 170),
                    ColonneTableau('Type', flex: 3, largeurMin: 110),
                    ColonneTableau('Modifiée le'),
                    ColonneTableau('', flex: 1, centre: true, largeurMin: 52),
                  ],
                  lignes: [
                    for (final f in fiches)
                      LigneTableau(
                        onTap: () => context.push(
                          '/assistant/resultat',
                          extra: ResultatsIa.dernier = ResultatArgs(
                            ficheId: f.id,
                            demande: AssistantRepository.demandeDe(f),
                            reponse: ReponseIa(
                              fiche: AssistantRepository.ficheDe(f),
                              sources: AssistantRepository.sourcesDe(f),
                              restant: const Restant(enseignant: 0, ecole: 0),
                              modele: 'fiche enregistrée',
                            ),
                          ),
                        ),
                        [
                          Text(
                            AssistantRepository.ficheDe(f).titre,
                            key: Key('fiche-${f.id}'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(_types[f.kind] ?? f.kind),
                          Text(
                            '${f.updatedAt.substring(8, 10)}/'
                            '${f.updatedAt.substring(5, 7)}/'
                            '${f.updatedAt.substring(0, 4)}',
                          ),
                          IconButton(
                            tooltip: 'Retirer',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final ok = await confirmer(
                                context,
                                titre: 'Retirer cette fiche ?',
                                message: 'Elle disparaîtra de « Mes fiches ».',
                                bouton: 'Retirer',
                              );
                              if (ok) {
                                await ref
                                    .read(assistantRepositoryProvider)
                                    .retirer(f.id);
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ----------------------------------------------------------------------
// Suivi de l'école (directeur)
// ----------------------------------------------------------------------

class SuiviIaPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SuiviIaPage> createState() => _SuiviState();
}

class _SuiviState extends ConsumerState<SuiviIaPage> {
  Future<UsageEcole>? _usage;

  void _charger(String schoolId) {
    _usage = ref.read(assistantApiProvider).usageEcole(schoolId);
  }

  Future<void> _limite(String schoolId, UsageIa u) async {
    final c = TextEditingController(text: '${u.limite}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Limite de ${u.nom}'),
        content: TextField(
          key: const Key('limite-ia'),
          controller: c,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Demandes par mois'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('valider-limite'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final fait = await avecMessage(context, () async {
      await ref
          .read(assistantRepositoryProvider)
          .fixerLimite(
            schoolId: schoolId,
            membershipId: u.membershipId,
            limite: int.tryParse(c.text) ?? -1,
          );
      return true;
    });
    if (fait != true || !mounted) return;
    await ref.read(syncEngineProvider).syncNow();
    setState(() => _charger(schoolId));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider).value;
    if (s == null || s.role != 'directeur') {
      return const EcoleScaffold(
        title: 'Suivi de l’assistant',
        body: InfoMessage('Réservé au directeur.'),
      );
    }
    _usage ??= ref.read(assistantApiProvider).usageEcole(s.schoolId);
    return EcoleScaffold(
      title: 'Suivi de l’assistant',
      body: FutureBuilder<UsageEcole>(
        future: _usage,
        builder: (context, snap) {
          if (snap.hasError) {
            return const InfoMessage(
              'Connexion à Internet nécessaire pour le suivi.',
              icon: Icons.cloud_off,
            );
          }
          final u = snap.data;
          if (u == null) return const LinearProgressIndicator();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Ce mois-ci : ${u.demandes} demande(s) sur ${u.limite} ; '
                'coût ${(u.coutMicroUsd / 1000000).toStringAsFixed(2)} \$ '
                'sur ${(u.budgetMicroUsd / 1000000).toStringAsFixed(2)} \$',
                key: const Key('usage-ecole'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TableauDonnees(
                colonnes: const [
                  ColonneTableau('Personne', flex: 5, largeurMin: 160),
                  ColonneTableau('Utilisées', montant: true),
                  ColonneTableau('Limite', montant: true),
                  ColonneTableau('', centre: true, largeurMin: 56),
                ],
                lignes: [
                  for (final l in u.lignes)
                    LigneTableau([
                      Text(l.nom),
                      Text('${l.demandes}'),
                      Text('${l.limite}', key: Key('limite-${l.membershipId}')),
                      IconButton(
                        key: Key('changer-limite-${l.membershipId}'),
                        tooltip: 'Changer la limite',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _limite(s.schoolId, l),
                      ),
                    ]),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Le total de l’école (demandes et budget) est fixé par le '
                'porteur du projet. Le compteur repart à zéro le 1er du mois.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}
