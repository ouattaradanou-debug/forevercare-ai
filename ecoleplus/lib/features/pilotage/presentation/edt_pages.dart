import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/pilotage/domain/absences.dart';
import 'package:ecoleplus/features/pilotage/domain/emploi_du_temps.dart';
import 'package:ecoleplus/features/pilotage/pdf/pdf_pilotage.dart';
import 'package:ecoleplus/features/pilotage/presentation/pilotage_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// « jeudi 5 novembre 2026 ».
String jourTexte(String iso) {
  const jours = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];
  const mois = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', //
    'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  final d = DateTime.parse(iso);
  return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]} ${d.year}';
}

Widget _chargement(String titre) =>
    EcoleScaffold(title: titre, body: const LinearProgressIndicator());

/// Choix de la classe (une seule classe : ouverte directement).
class _ChoixClasse extends ConsumerWidget {
  const new({
    required this.titre,
    required this.route,
    required this.sousTitre,
  });
  final String titre;
  final String Function(ClassRow c) route;
  final String? Function(WidgetRef ref, ClassRow c) sousTitre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctx = contexteEcole(ref);
    if (ctx == null) return _chargement(titre);
    final classes = ref.watch(classesProvider(ctx.$2.id)).value;
    if (classes == null) return _chargement(titre);
    if (classes.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.pushReplacement(route(classes.single));
      });
      return _chargement(titre);
    }
    return EcoleScaffold(
      title: titre,
      body: classes.isEmpty
          ? const InfoMessage('Aucune classe pour cette année.')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final c in classes)
                  Card(
                    child: ListTile(
                      key: Key('classe-${c.id}'),
                      leading: const Icon(Icons.class_),
                      title: Text(c.name),
                      subtitle: switch (sousTitre(ref, c)) {
                        final s? => Text(s),
                        null => null,
                      },
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(route(c)),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ---------------------------- Emploi du temps ----------------------------

class EmploiDuTempsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => _ChoixClasse(
    titre: 'Emploi du temps',
    route: (c) => '/emploi-du-temps/${c.id}',
    sousTitre: (ref, c) {
      final n = ref.watch(creneauxProvider(c.id)).value?.length;
      return n == null
          ? null
          : n == 0
          ? 'Aucun créneau'
          : '$n créneau${n > 1 ? 'x' : ''}';
    },
  );
}

/// Semaine d'une classe, jour par jour ; ajout, modification, copie,
/// impression.
class EmploiClassePage extends ConsumerWidget {
  const new(this.classId, {super.key});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctx = contexteEcole(ref);
    if (ctx == null) return _chargement('Emploi du temps');
    final (ecole, annee) = ctx;
    final classes = ref.watch(classesProvider(annee.id)).value ?? const [];
    final classe = classes.where((c) => c.id == classId).firstOrNull;
    final creneaux = ref.watch(creneauxProvider(classId)).value;
    final matieres =
        ref.watch(nomsMatieresProvider(ecole.id)).value ?? const {};
    final enseignants = {
      for (final t
          in ref.watch(teachersProvider(ecole.id)).value ??
              const <TeacherRow>[])
        t.id: '${t.lastName} ${t.firstNames}',
    };
    final modifiable = ref.watch(peutModifierEdtProvider(classId));
    final titre = 'Emploi du temps${classe == null ? '' : ' — ${classe.name}'}';
    if (creneaux == null || classe == null) return _chargement(titre);
    final aujourdhui = jourDe(ref.watch(aujourdhuiProvider));
    return EcoleScaffold(
      title: titre,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (modifiable)
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un créneau'),
                  onPressed: () =>
                      _editer(context, ref, classe, creneaux, null),
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('Imprimer (PDF)'),
                onPressed: creneaux.isEmpty
                    ? null
                    : () => avecMessage(context, () async {
                        final pdf = await pdfEmploiDuTemps(
                          await ref.read(policesPdfProvider.future),
                          ecole: ecole.name,
                          annee: annee.label,
                          classe: classe.name,
                          enseignant: enseignants[classe.mainTeacherId],
                          grille: grilleSemaine(
                            creneaux,
                            matieres,
                            enseignants: enseignants,
                          ),
                        );
                        await ref
                            .read(sortiePdfProvider)
                            .imprimer(
                              pdf,
                              'Emploi_du_temps_${classe.name}.pdf',
                            );
                      }),
              ),
              if (modifiable && classes.length > 1 && creneaux.isNotEmpty)
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copier vers une autre classe'),
                  onPressed: () => _copier(context, ref, classe, classes),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (creneaux.isEmpty)
            InfoMessage(
              modifiable
                  ? 'Aucun créneau. Touchez « Ajouter un créneau » : jour, '
                        'heures, matière.'
                  : 'L’emploi du temps de cette classe n’est pas encore '
                        'rempli.',
            ),
          for (final MapEntry(key: j, value: nom) in joursSemaine.entries)
            if (creneaux.any((s) => s.weekday == j)) ...[
              SectionTitle(j == aujourdhui ? '$nom (aujourd’hui)' : nom),
              for (final s in creneaux.where((s) => s.weekday == j))
                Card(
                  child: ListTile(
                    key: Key('creneau-${s.id}'),
                    leading: const Icon(Icons.schedule),
                    title: Text('${plage(s)}  ${intitule(s, matieres)}'),
                    subtitle: switch (enseignants[s.teacherId]) {
                      final e? => Text(e),
                      null => null,
                    },
                    trailing: modifiable ? const Icon(Icons.edit) : null,
                    onTap: modifiable
                        ? () => _editer(context, ref, classe, creneaux, s)
                        : null,
                  ),
                ),
            ],
        ],
      ),
    );
  }

  Future<void> _editer(
    BuildContext context,
    WidgetRef ref,
    ClassRow classe,
    List<TimetableSlotRow> creneaux,
    TimetableSlotRow? s,
  ) => showDialog<void>(
    context: context,
    builder: (_) =>
        _CreneauDialog(classe: classe, creneaux: creneaux, creneau: s),
  );

  Future<void> _copier(
    BuildContext context,
    WidgetRef ref,
    ClassRow classe,
    List<ClassRow> classes,
  ) async {
    final autres = [
      for (final c in classes)
        if (c.id != classe.id) c,
    ];
    String? cible;
    var remplacer = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: const Text('Copier l’emploi du temps'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('De ${classe.name} vers :'),
              DropdownButton<String>(
                key: const Key('copie-cible'),
                isExpanded: true,
                value: cible,
                hint: const Text('Choisir la classe'),
                items: [
                  for (final a in autres)
                    DropdownMenuItem(value: a.id, child: Text(a.name)),
                ],
                onChanged: (v) => set(() => cible = v),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: remplacer,
                onChanged: (v) => set(() => remplacer = v ?? false),
                title: const Text(
                  'Remplacer l’emploi du temps de cette classe',
                ),
                subtitle: const Text(
                  'Sinon, les créneaux qui chevauchent un créneau existant '
                  'ne sont pas copiés.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: cible == null ? null : () => Navigator.pop(c, true),
              child: const Text('Copier'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || cible == null || !context.mounted) return;
    final n = await avecMessage(
      context,
      () => ref
          .read(pilotageRepositoryProvider)
          .copier(classe.id, cible!, remplacer: remplacer),
    );
    if (n == null || !context.mounted) return;
    final nom = autres.firstWhere((a) => a.id == cible).name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$n créneau(x) copié(s) vers $nom.')),
    );
  }
}

class _CreneauDialog extends ConsumerStatefulWidget {
  const new({required this.classe, required this.creneaux, this.creneau});
  final ClassRow classe;
  final List<TimetableSlotRow> creneaux;
  final TimetableSlotRow? creneau;

  @override
  ConsumerState<_CreneauDialog> createState() => _CreneauState();
}

class _CreneauState extends ConsumerState<_CreneauDialog> {
  late int? _jour = widget.creneau?.weekday;
  late final _debut = TextEditingController(
    text: widget.creneau == null ? '' : heureCourte(widget.creneau!.startsAt),
  );
  late final _fin = TextEditingController(
    text: widget.creneau == null ? '' : heureCourte(widget.creneau!.endsAt),
  );
  late String? _matiere = widget.creneau?.subjectId;
  late final _activite = TextEditingController(
    text: widget.creneau?.activityLabel ?? '',
  );
  late String? _enseignant =
      widget.creneau?.teacherId ?? widget.classe.mainTeacherId;
  String? _erreur;

  @override
  void dispose() {
    _debut.dispose();
    _fin.dispose();
    _activite.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final debut = heureDepuis(_debut.text);
    final fin = heureDepuis(_fin.text);
    final activite = _activite.text.trim();
    final erreur = _jour == null
        ? 'Choisissez le jour.'
        : debut == null || fin == null
        ? 'Écrivez les heures ainsi : 7h30, 08:30.'
        : _matiere == null && activite.isEmpty
        ? 'Choisissez la matière ou écrivez l’activité.'
        : verifierCreneau(
            jour: _jour!,
            debut: debut,
            fin: fin,
            existants: widget.creneaux,
            id: widget.creneau?.id,
          );
    if (erreur != null) {
      setState(() => _erreur = erreur);
      return;
    }
    await ref
        .read(pilotageRepositoryProvider)
        .enregistrerCreneau(
          id: widget.creneau?.id,
          schoolId: widget.classe.schoolId,
          classId: widget.classe.id,
          jour: _jour!,
          debut: debut!,
          fin: fin!,
          matiereId: _matiere,
          activite: activite.isEmpty ? null : activite,
          enseignantId: _enseignant,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ecole = widget.classe.schoolId;
    final matieres = ref.watch(nomsMatieresProvider(ecole)).value ?? const {};
    final enseignants = ref.watch(teachersProvider(ecole)).value ?? const [];
    return AlertDialog(
      title: Text(
        widget.creneau == null ? 'Nouveau créneau' : 'Modifier le créneau',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              key: const Key('creneau-jour'),
              initialValue: _jour,
              decoration: const InputDecoration(labelText: 'Jour'),
              items: [
                for (final MapEntry(key: j, value: n) in joursSemaine.entries)
                  DropdownMenuItem(value: j, child: Text(n)),
              ],
              onChanged: (v) => setState(() => _jour = v),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('creneau-debut'),
                    controller: _debut,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Début',
                      hintText: '7h30',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    key: const Key('creneau-fin'),
                    controller: _fin,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Fin',
                      hintText: '8h30',
                    ),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String?>(
              key: const Key('creneau-matiere'),
              initialValue: _matiere,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Matière'),
              items: [
                const DropdownMenuItem(child: Text('Autre activité')),
                for (final MapEntry(key: id, value: n) in matieres.entries)
                  DropdownMenuItem(value: id, child: Text(n)),
              ],
              onChanged: (v) => setState(() => _matiere = v),
            ),
            if (_matiere == null)
              TextField(
                key: const Key('creneau-activite'),
                controller: _activite,
                decoration: const InputDecoration(
                  labelText: 'Activité',
                  hintText: 'Récréation, sport, chant…',
                ),
              ),
            if (enseignants.isNotEmpty)
              DropdownButtonFormField<String?>(
                initialValue: enseignants.any((t) => t.id == _enseignant)
                    ? _enseignant
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Enseignant(e)'),
                items: [
                  const DropdownMenuItem(child: Text('—')),
                  for (final t in enseignants)
                    DropdownMenuItem(
                      value: t.id,
                      child: Text('${t.lastName} ${t.firstNames}'),
                    ),
                ],
                onChanged: (v) => setState(() => _enseignant = v),
              ),
            if (_erreur != null) ...[
              const SizedBox(height: 8),
              Text(
                _erreur!,
                key: const Key('creneau-erreur'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (widget.creneau != null)
          TextButton(
            onPressed: () async {
              await ref
                  .read(pilotageRepositoryProvider)
                  .retirerCreneau(widget.creneau!.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Retirer'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _enregistrer, child: const Text('Enregistrer')),
      ],
    );
  }
}

// ------------------------------ Appel ------------------------------

class AppelChoixPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => _ChoixClasse(
    titre: 'Faire l’appel',
    route: (c) => '/appel/${c.id}',
    sousTitre: (ref, c) {
      final jour = ref.watch(aujourdhuiProvider);
      final a = ref.watch(appelProvider((c.id, jour))).value;
      if (a == null) return null;
      if (a.isEmpty) return 'Appel d’aujourd’hui à faire';
      final abs = a.values.where((v) => v.$1 == 'absent').length;
      return 'Appel fait • $abs absent(s)';
    },
  );
}

/// Appel du jour : tout le monde est présent par défaut ; on marque les
/// absents et les retards, puis on valide.
class AppelPage extends ConsumerStatefulWidget {
  const new(this.classId, {this.jour, super.key});
  final String classId;
  final String? jour;

  @override
  ConsumerState<AppelPage> createState() => _AppelState();
}

class _AppelState extends ConsumerState<AppelPage> {
  late String _jour = widget.jour ?? ref.read(aujourdhuiProvider);

  /// Statuts modifiés à l'écran (non encore validés).
  final Map<String, (String, String?)> _modifs = {};

  @override
  Widget build(BuildContext context) {
    final ctx = contexteEcole(ref);
    if (ctx == null) return _chargement('Appel');
    final (ecole, annee) = ctx;
    final classe = (ref.watch(classesProvider(annee.id)).value ?? const [])
        .where((c) => c.id == widget.classId)
        .firstOrNull;
    final eleves = ref.watch(
      elevesDeClasseProvider((ecole.id, annee.id, widget.classId)),
    );
    final enregistre = ref.watch(appelProvider((widget.classId, _jour))).value;
    final titre = 'Appel${classe == null ? '' : ' — ${classe.name}'}';
    if (classe == null || eleves == null || enregistre == null) {
      return _chargement(titre);
    }
    (String, String?) statut(String id) =>
        _modifs[id] ?? enregistre[id] ?? ('present', null);
    final fait = enregistre.isNotEmpty;
    final absents = eleves.where((e) => statut(e.id).$1 == 'absent').length;
    final retards = eleves.where((e) => statut(e.id).$1 == 'retard').length;
    final aujourdhui = ref.watch(aujourdhuiProvider);
    return EcoleScaffold(
      title: titre,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.today),
            title: Text(jourTexte(_jour), key: const Key('appel-jour')),
            subtitle: Text(
              fait
                  ? 'Appel déjà fait : vous pouvez le corriger.'
                  : 'Tout le monde est présent par défaut. Touchez les '
                        'absents et les retards.',
            ),
            trailing: TextButton(
              child: const Text('Autre jour'),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_jour),
                  firstDate: DateTime.parse(aujourdhui)
                      .subtract(const Duration(days: 365)),
                  lastDate: DateTime.parse(aujourdhui),
                );
                if (d != null) {
                  setState(() {
                    _jour = d.toIso8601String().substring(0, 10);
                    _modifs.clear();
                  });
                }
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: eleves.isEmpty
                ? const InfoMessage('Aucun élève dans cette classe.')
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      for (final e in eleves)
                        _LigneAppel(
                          key: Key('appel-${e.id}'),
                          nom: '${e.lastName} ${e.firstNames}',
                          statut: statut(e.id),
                          onChanged: (v) => setState(() => _modifs[e.id] = v),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('valider-appel'),
                  icon: const Icon(Icons.check),
                  label: Text(
                    'Valider l’appel • ${eleves.length - absents} présent(s), '
                    '$absents absent(s)'
                    '${retards > 0 ? ', $retards retard(s)' : ''}',
                  ),
                  onPressed: eleves.isEmpty || (fait && _modifs.isEmpty)
                      ? null
                      : () async {
                          await ref
                              .read(pilotageRepositoryProvider)
                              .validerAppel(classe, _jour, {
                                for (final e in eleves) e.id: statut(e.id),
                              });
                          if (!context.mounted) return;
                          setState(_modifs.clear);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Appel enregistré.')),
                          );
                        },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneAppel extends StatelessWidget {
  const new({
    required this.nom,
    required this.statut,
    required this.onChanged,
    super.key,
  });
  final String nom;
  final (String, String?) statut;
  final ValueChanged<(String, String?)> onChanged;

  @override
  Widget build(BuildContext context) {
    final (s, motif) = statut;
    final couleur = switch (s) {
      'absent' => Theme.of(context).colorScheme.errorContainer,
      'retard' => Colors.amber.shade100,
      _ => null,
    };
    return Card(
      color: couleur,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nom, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                for (final MapEntry(key: k, value: v)
                    in statutsPresence.entries)
                  ButtonSegment(value: k, label: Text(v)),
              ],
              selected: {s},
              onSelectionChanged: (v) => onChanged((v.single, motif)),
            ),
            if (s != 'present')
              TextFormField(
                initialValue: motif,
                decoration: const InputDecoration(
                  labelText: 'Motif (facultatif)',
                  helperText: 'Sans détail de santé.',
                ),
                onChanged: (v) =>
                    onChanged((s, v.trim().isEmpty ? null : v.trim())),
              ),
          ],
        ),
      ),
    );
  }
}
