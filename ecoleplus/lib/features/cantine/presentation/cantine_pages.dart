import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/export/xlsx_ecriture.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/tableau.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/cantine/pdf/pdf_cantine.dart';
import 'package:ecoleplus/features/cantine/presentation/cantine_providers.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/finances/presentation/finances_gestion_pages.dart'
    show nomMois;
import 'package:ecoleplus/features/finances/presentation/finances_grille_page.dart'
    show lireDateCourte;
import 'package:ecoleplus/features/finances/presentation/finances_pages.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/presentation/classement_page.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Droits de la personne connectée (le directeur a tous les droits).
Set<String> droitsCantine(WidgetRef ref) {
  final s = ref.watch(sessionProvider).value;
  if (s == null) return const {};
  return s.role == 'directeur' ? tousLesDroits : ref.watch(mesDroitsProvider);
}

Widget _chargement(String titre) =>
    EcoleScaffold(title: titre, body: const LinearProgressIndicator());

Widget? _garde(WidgetRef ref, String titre) =>
    gardeCantine(ref, titre, droits: const {'cantine'});

/// Écran affiché quand le module est désactivé, ou sans aucun des [droits].
Widget? gardeCantine(
  WidgetRef ref,
  String titre, {
  Set<String> droits = const {'cantine', 'finances'},
}) {
  final s = ref.watch(sessionProvider).value;
  if (s == null) return _chargement(titre);
  if (!ref.watch(cantineActiveProvider(s.schoolId))) {
    return EcoleScaffold(
      title: titre,
      body: const InfoMessage(
        'La cantine n’est pas activée pour l’école (« Mon école » → '
        '« Options de l’école »).',
      ),
    );
  }
  if (droitsCantine(ref).intersection(droits).isEmpty) {
    return EcoleScaffold(
      title: titre,
      body: const InfoMessage(
        'Le directeur ne vous a pas accordé ce droit.',
        icon: Icons.lock_outline,
      ),
    );
  }
  return null;
}

String _aujourdhui(WidgetRef ref) => ref.read(aujourdhuiProvider);

String _isoDe(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String _decale(String jour, int jours) =>
    _isoDe(DateTime.parse(jour).add(Duration(days: jours)));

/// Effectif et abonnés (repas autorisés) par classe, pour un mois.
List<EffectifCantine> effectifsParClasse(
  List<EleveDansAnnee> eleves,
  List<ClassRow> classes,
  Set<String> abonnes,
) {
  EffectifCantine effectif(String nom, List<EleveDansAnnee> dans) =>
      EffectifCantine(
        nom,
        dans.where((e) => abonnes.contains(e.eleve.id)).length,
        dans.length,
      );
  final sans = eleves.where((e) => e.classe == null).toList();
  return [
    for (final k in classes)
      effectif(k.name, eleves.where((e) => e.classe?.id == k.id).toList()),
    if (sans.isNotEmpty) effectif('Sans classe', sans),
  ];
}

/// Élèves autorisés à manger un mois donné (abonnés).
Set<String> abonnesDuMois(
  Map<String, SituationCantine> situations,
  String mois,
) => {
  for (final MapEntry(key: id, value: s) in situations.entries)
    if (s.duMois(debutMois(mois))?.statut == StatutMois.abonne) id,
};

// ----------------------------------------------------------------------
// Pointage des repas
// ----------------------------------------------------------------------

class PointagePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<PointagePage> createState() => _PointageState();
}

class _PointageState extends ConsumerState<PointagePage> {
  late String _jour = _aujourdhui(ref);
  final _champs = <String, TextEditingController>{};
  String? _chargePour;

  static const _autres = '-';

  @override
  void dispose() {
    for (final c in _champs.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _champ(String k) =>
      _champs.putIfAbsent(k, TextEditingController.new);

  void _charger(List<MealServiceRow> pointages, List<ClassRow> classes) {
    if (_chargePour == _jour) return;
    _chargePour = _jour;
    final duJour = {
      for (final p in pointages)
        if (p.day == _jour) p.classId ?? _autres: p.mealsCount,
    };
    for (final k in [...classes.map((c) => c.id), _autres]) {
      _champ(k).text = duJour.containsKey(k) ? '${duJour[k]}' : '';
    }
  }

  Future<void> _enregistrer(String schoolId, List<ClassRow> classes) async {
    final repo = ref.read(cantineRepositoryProvider);
    final ok = await avecMessage(context, () async {
      var n = 0;
      for (final k in [...classes.map((c) => c.id), _autres]) {
        final t = _champ(k).text.trim();
        if (t.isEmpty) continue;
        final v = int.tryParse(t);
        if (v == null) {
          throw UserMessage('« $t » n’est pas un nombre de repas.');
        }
        await repo.pointer(
          schoolId: schoolId,
          jour: _jour,
          classId: k == _autres ? null : k,
          repas: v,
        );
        n++;
      }
      return n;
    });
    if (ok == null || !mounted) return;
    unawaited(ref.read(syncEngineProvider).syncNow());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok == 0
              ? 'Aucun nombre saisi.'
              : 'Pointage du ${dateCourte(_jour)} enregistré.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final garde = _garde(ref, 'Pointage des repas');
    if (garde != null) return garde;
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Pointage des repas');
    final (ecole, annee) = c;
    final classes = ref.watch(classesProvider(annee.id)).value;
    final pointages = ref.watch(pointagesProvider(ecole.id)).value;
    final eleves = ref.watch(elevesProvider((ecole.id, annee.id, false))).value;
    final situations = ref.watch(
      situationsAbonnementProvider((ecole.id, annee.id)),
    );
    if (classes == null ||
        pointages == null ||
        eleves == null ||
        situations == null) {
      return _chargement('Pointage des repas');
    }
    final b = abonnesDuMois(situations, _jour);
    _charger(pointages, classes);
    final effectifs = {
      for (final (i, e) in effectifsParClasse(eleves, classes, b).indexed)
        if (i < classes.length) classes[i].id: e.beneficiaires,
    };
    final total = [
      for (final k in [...classes.map((c) => c.id), _autres])
        int.tryParse(_champ(k).text.trim()) ?? 0,
    ].fold<int>(0, (s, n) => s + n);
    Widget saisie(String k) => SizedBox(
      width: 90,
      child: TextField(
        key: Key('repas-$k'),
        controller: _champ(k),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.right,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(isDense: true),
      ),
    );
    return EcoleScaffold(
      title: 'Pointage des repas',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Jour précédent',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _jour = _decale(_jour, -1)),
              ),
              Expanded(
                child: Text(
                  '${jourCourt(_jour)} ${_jour.substring(0, 4)}',
                  key: const Key('jour-pointage'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Jour suivant',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _jour = _decale(_jour, 1)),
              ),
            ],
          ),
          const Text(
            'Tapez le nombre de repas servis par classe. Une nouvelle '
            'saisie remplace l’ancienne (jamais d’addition), même depuis '
            'un autre téléphone.',
          ),
          const SizedBox(height: 8),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Classe', flex: 4, largeurMin: 120),
              ColonneTableau('Abonnés du mois', montant: true, largeurMin: 120),
              ColonneTableau('Repas servis', montant: true, largeurMin: 110),
            ],
            lignes: [
              for (final k in classes)
                LigneTableau([
                  Text(k.name),
                  TextButton(
                    key: Key('remplir-${k.id}'),
                    onPressed: () => setState(
                      () => _champ(k.id).text = '${effectifs[k.id] ?? 0}',
                    ),
                    child: Text('${effectifs[k.id] ?? 0}'),
                  ),
                  saisie(k.id),
                ]),
              LigneTableau([
                const Text('Autres (personnel…)'),
                const SizedBox(),
                saisie(_autres),
              ]),
            ],
            total: LigneTableau([
              const Text('Total du jour'),
              const SizedBox(),
              Text(fcfa(total), key: const Key('total-pointage')),
            ]),
          ),
          const SizedBox(height: 4),
          const Text(
            'Touchez le nombre d’abonnés pour le recopier.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          BigButton(
            key: const Key('enregistrer-pointage'),
            icon: Icons.save,
            label: 'Enregistrer le pointage',
            onPressed: () => _enregistrer(ecole.id, classes),
          ),
          const SectionTitle('Derniers jours'),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Jour', flex: 3),
              ColonneTableau('Repas', montant: true),
            ],
            lignes: [
              for (final MapEntry(key: j, value: n) in repasParJour(
                pointages,
              ).entries.toList().reversed.take(10))
                LigneTableau([
                  Text(jourCourt(j)),
                  Text(fcfa(n)),
                ], onTap: () => setState(() => _jour = j)),
            ],
            vide: 'Aucun repas pointé.',
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Stock de vivres
// ----------------------------------------------------------------------

Widget _texteStock(BuildContext context, EtatProduit e, {Key? key}) {
  final c = CouleursFinances.de(context);
  return Text(
    qte(e.stock),
    key: key,
    style: e.negatif || e.alerte
        ? TextStyle(color: c.rouge, fontWeight: FontWeight.w700)
        : null,
  );
}

class StockPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garde = _garde(ref, 'Stock de vivres');
    if (garde != null) return garde;
    final s = ref.watch(sessionProvider).value!;
    final etats = ref.watch(stockProvider(s.schoolId));
    if (etats == null) return _chargement('Stock de vivres');
    return EcoleScaffold(
      title: 'Stock de vivres',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const Key('bouton-entree'),
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Entrée'),
                onPressed: etats.isEmpty
                    ? null
                    : () => saisirMouvement(context, ref, 'entree', etats),
              ),
              FilledButton.icon(
                key: const Key('bouton-sortie'),
                icon: const Icon(Icons.outbox_outlined),
                label: const Text('Sortie'),
                onPressed: etats.isEmpty
                    ? null
                    : () => saisirMouvement(context, ref, 'sortie', etats),
              ),
              OutlinedButton.icon(
                key: const Key('bouton-inventaire'),
                icon: const Icon(Icons.checklist),
                label: const Text('Inventaire'),
                onPressed: etats.isEmpty
                    ? null
                    : () => context.push('/cantine/inventaire'),
              ),
              OutlinedButton.icon(
                key: const Key('nouveau-produit'),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau produit'),
                onPressed: () => modifierProduit(context, ref, s.schoolId),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (etats.any((e) => e.negatif))
            const InfoMessage(
              'Un stock est négatif : des sorties saisies sur deux '
              'téléphones sans Internet dépassent le stock. Faites un '
              'inventaire pour corriger.',
              icon: Icons.warning_amber,
            ),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Produit', flex: 4, largeurMin: 130),
              ColonneTableau('Stock', montant: true),
              ColonneTableau('Unité', largeurMin: 70),
              ColonneTableau('Seuil d’alerte', montant: true, largeurMin: 110),
            ],
            lignes: [
              for (final e in etats)
                LigneTableau(
                  [
                    Row(
                      children: [
                        if (e.alerte || e.negatif)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.warning_amber,
                              size: 18,
                              color: CouleursFinances.de(context).rouge,
                            ),
                          ),
                        Flexible(child: Text(e.produit.name)),
                      ],
                    ),
                    _texteStock(context, e, key: Key('stock-${e.produit.id}')),
                    Text(e.produit.unit),
                    Text(
                      e.produit.alertThreshold == null
                          ? '—'
                          : qte(e.produit.alertThreshold!),
                    ),
                  ],
                  onTap: () => context.push('/cantine/produit/${e.produit.id}'),
                ),
            ],
            vide: 'Aucun produit : ajoutez vos vivres (riz, maïs, huile…).',
          ),
        ],
      ),
    );
  }
}

/// Nouveau produit ([p] null) ou modification.
Future<void> modifierProduit(
  BuildContext context,
  WidgetRef ref,
  String schoolId, [
  StockProductRow? p,
]) async {
  final nom = TextEditingController(text: p?.name ?? '');
  final unite = TextEditingController(text: p?.unit ?? 'kg');
  final seuil = TextEditingController(
    text: p?.alertThreshold == null ? '' : qte(p!.alertThreshold!),
  );
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(p == null ? 'Nouveau produit' : 'Modifier le produit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('nom-produit'),
                controller: nom,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Produit (ex. riz, maïs, huile)',
                ),
              ),
              TextField(
                key: const Key('unite-produit'),
                controller: unite,
                decoration: const InputDecoration(labelText: 'Unité'),
              ),
              Wrap(
                spacing: 4,
                children: [
                  for (final u in unitesProposees)
                    ActionChip(
                      label: Text(u),
                      onPressed: () => setState(() => unite.text = u),
                    ),
                ],
              ),
              TextField(
                key: const Key('seuil-produit'),
                controller: seuil,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Seuil d’alerte (facultatif)',
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
            key: const Key('valider-produit'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  final repo = ref.read(cantineRepositoryProvider);
  await avecMessage(context, () async {
    final s = seuil.text.trim().isEmpty ? null : lireQte(seuil.text);
    if (seuil.text.trim().isNotEmpty && s == null) {
      throw const UserMessage('Seuil d’alerte : nombre attendu.');
    }
    if (p == null) {
      await repo.ajouterProduit(
        schoolId: schoolId,
        nom: nom.text,
        unite: unite.text,
        seuil: s,
      );
    } else {
      await repo.modifierProduit(p, nom: nom.text, unite: unite.text, seuil: s);
    }
  });
}

/// Saisie d'une entrée ou d'une sortie de vivres.
Future<void> saisirMouvement(
  BuildContext context,
  WidgetRef ref,
  String kind,
  List<EtatProduit> etats, {
  String? produitId,
}) async {
  var produit = produitId ?? etats.first.produit.id;
  var motif = kind == 'entree' ? 'parents' : 'repas';
  final quantite = TextEditingController();
  final date = TextEditingController(text: dateCourte(_aujourdhui(ref)));
  final notes = TextEditingController();
  final entree = kind == 'entree';
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final e = etats.firstWhere((x) => x.produit.id == produit);
        return AlertDialog(
          title: Text(entree ? 'Entrée de vivres' : 'Sortie de vivres'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  key: const Key('choix-produit'),
                  initialValue: produit,
                  decoration: const InputDecoration(labelText: 'Produit'),
                  items: [
                    for (final x in etats)
                      DropdownMenuItem(
                        value: x.produit.id,
                        child: Text(x.produit.name),
                      ),
                  ],
                  onChanged: (v) => setState(() => produit = v ?? produit),
                ),
                Text('En stock : ${qte(e.stock)} ${e.produit.unit}'),
                TextField(
                  key: const Key('quantite-mouvement'),
                  controller: quantite,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Quantité (${e.produit.unit})',
                  ),
                ),
                const SizedBox(height: 8),
                Text(entree ? 'Provenance' : 'Motif'),
                Wrap(
                  spacing: 4,
                  children: [
                    for (final MapEntry(key: k, value: v)
                        in (entree ? provenances : motifsSortie).entries)
                      ChoiceChip(
                        key: Key('motif-$k'),
                        label: Text(v),
                        selected: motif == k,
                        onSelected: (_) => setState(() => motif = k),
                      ),
                  ],
                ),
                TextField(
                  key: const Key('date-mouvement'),
                  controller: date,
                  decoration: const InputDecoration(
                    labelText: 'Date (jj/mm/aaaa)',
                  ),
                ),
                TextField(
                  controller: notes,
                  decoration: InputDecoration(
                    labelText: entree
                        ? 'Précision (ex. nom du donateur)'
                        : 'Précision (facultatif)',
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
              key: const Key('valider-mouvement'),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    ),
  );
  if (ok != true || !context.mounted) return;
  final repo = ref.read(cantineRepositoryProvider);
  final fait = await avecMessage(context, () {
    final q = lireQte(quantite.text);
    if (q == null) throw const UserMessage('Indiquez la quantité.');
    final d = lireDateCourte(date.text);
    if (d == null) throw const UserMessage('Date à écrire jj/mm/aaaa.');
    final jour = _isoDe(d);
    return entree
        ? repo.entree(
            produitId: produit,
            quantite: q,
            provenance: motif,
            date: jour,
            notes: notes.text,
          )
        : repo.sortie(
            produitId: produit,
            quantite: q,
            motif: motif,
            date: jour,
            notes: notes.text,
          );
  });
  if (fait == null || !context.mounted) return;
  unawaited(ref.read(syncEngineProvider).syncNow());
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(entree ? 'Entrée enregistrée.' : 'Sortie enregistrée.'),
    ),
  );
}

/// Inventaire : quantité comptée pour chaque produit ; les écarts sont
/// enregistrés comme ajustements motivés.
class InventairePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<InventairePage> createState() => _InventaireState();
}

class _InventaireState extends ConsumerState<InventairePage> {
  final _comptes = <String, TextEditingController>{};
  final _motif = TextEditingController(text: 'Inventaire');

  @override
  void dispose() {
    for (final c in _comptes.values) {
      c.dispose();
    }
    _motif.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final garde = _garde(ref, 'Inventaire');
    if (garde != null) return garde;
    final s = ref.watch(sessionProvider).value!;
    final etats = ref.watch(stockProvider(s.schoolId));
    if (etats == null) return _chargement('Inventaire');
    return EcoleScaffold(
      title: 'Inventaire',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Comptez les vivres et tapez les quantités réelles. Laissez vide '
            'un produit non compté. Chaque écart est enregistré avec le '
            'motif (jamais de suppression).',
          ),
          const SizedBox(height: 8),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Produit', flex: 4, largeurMin: 130),
              ColonneTableau('Calculé', montant: true),
              ColonneTableau('Compté', montant: true, largeurMin: 110),
            ],
            lignes: [
              for (final e in etats)
                LigneTableau([
                  Text('${e.produit.name} (${e.produit.unit})'),
                  _texteStock(context, e),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      key: Key('compte-${e.produit.id}'),
                      controller: _comptes.putIfAbsent(
                        e.produit.id,
                        TextEditingController.new,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                ]),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('motif-inventaire'),
            controller: _motif,
            decoration: const InputDecoration(
              labelText: 'Motif des écarts (perte, erreur de saisie…)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          BigButton(
            key: const Key('valider-inventaire'),
            icon: Icons.save,
            label: 'Enregistrer l’inventaire',
            onPressed: () async {
              final repo = ref.read(cantineRepositoryProvider);
              final n = await avecMessage(context, () async {
                var ecarts = 0;
                for (final e in etats) {
                  final t = _comptes[e.produit.id]?.text.trim() ?? '';
                  if (t.isEmpty) continue;
                  final q = lireQte(t);
                  if (q == null) {
                    throw UserMessage('${e.produit.name} : nombre attendu.');
                  }
                  final m = await repo.inventaire(
                    produitId: e.produit.id,
                    compte: q,
                    motif: _motif.text,
                    date: _aujourdhui(ref),
                  );
                  if (m != null) ecarts++;
                }
                return ecarts;
              });
              if (n == null || !context.mounted) return;
              unawaited(ref.read(syncEngineProvider).syncNow());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    n == 0
                        ? 'Inventaire conforme : aucun écart.'
                        : 'Inventaire enregistré : $n écart(s) corrigé(s).',
                  ),
                ),
              );
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}

class ProduitPage extends ConsumerWidget {
  const new(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garde = _garde(ref, 'Produit');
    if (garde != null) return garde;
    final s = ref.watch(sessionProvider).value!;
    final etats = ref.watch(stockProvider(s.schoolId));
    final mouvements = ref.watch(mouvementsProvider(s.schoolId)).value;
    if (etats == null || mouvements == null) return _chargement('Produit');
    final e = etats.where((x) => x.produit.id == id).firstOrNull;
    if (e == null) {
      return const EcoleScaffold(
        title: 'Produit',
        body: InfoMessage('Produit introuvable.'),
      );
    }
    final siens = [
      for (final m in mouvements)
        if (m.productId == id) m,
    ];
    final annules = {
      for (final m in siens)
        if (m.reversesMovementId != null) m.reversesMovementId!,
    };
    final repo = ref.read(cantineRepositoryProvider);
    return EcoleScaffold(
      title: e.produit.name,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(
                'En stock : ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _texteStock(context, e),
              Text(' ${e.produit.unit}'),
            ],
          ),
          if (e.produit.alertThreshold != null)
            Text(
              'Seuil d’alerte : ${qte(e.produit.alertThreshold!)} '
              '${e.produit.unit}',
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Entrée'),
                onPressed: () => saisirMouvement(
                  context,
                  ref,
                  'entree',
                  etats,
                  produitId: id,
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.outbox_outlined),
                label: const Text('Sortie'),
                onPressed: () => saisirMouvement(
                  context,
                  ref,
                  'sortie',
                  etats,
                  produitId: id,
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Modifier'),
                onPressed: () =>
                    modifierProduit(context, ref, s.schoolId, e.produit),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Retirer de la liste'),
                onPressed: () async {
                  final ok = await confirmer(
                    context,
                    titre: 'Retirer « ${e.produit.name} » ?',
                    message:
                        'Le produit n’apparaîtra plus dans le stock. Son '
                        'historique est conservé.',
                    bouton: 'Retirer',
                  );
                  if (!ok || !context.mounted) return;
                  final fait = await avecMessage(context, () async {
                    await repo.retirerProduit(e.produit);
                    return true;
                  });
                  if (fait == true && context.mounted) context.pop();
                },
              ),
            ],
          ),
          const SectionTitle('Mouvements'),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Date', largeurMin: 90),
              ColonneTableau('Mouvement', flex: 5, largeurMin: 170),
              ColonneTableau('Quantité', montant: true),
              ColonneTableau('', centre: true, largeurMin: 56),
            ],
            lignes: [
              for (final m in siens)
                LigneTableau([
                  Text(dateCourte(m.occurredOn)),
                  Text(
                    libelleMouvement(m) +
                        ((m.notes ?? '').isEmpty ? '' : ' (${m.notes})') +
                        (annules.contains(m.id) ? ' — annulé' : ''),
                    style: annules.contains(m.id)
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          )
                        : null,
                  ),
                  Text(
                    '${m.quantityDelta > 0 ? '+' : ''}${qte(m.quantityDelta)}',
                  ),
                  if (m.kind == 'annulation' || annules.contains(m.id))
                    const SizedBox()
                  else
                    IconButton(
                      key: Key('annuler-${m.id}'),
                      tooltip: 'Annuler ce mouvement',
                      icon: const Icon(Icons.undo),
                      onPressed: () async {
                        final motif = await _motif(context);
                        if (motif == null || !context.mounted) return;
                        final fait = await avecMessage(
                          context,
                          () => repo.annuler(m, motif),
                        );
                        if (fait != null) {
                          unawaited(ref.read(syncEngineProvider).syncNow());
                        }
                      },
                    ),
                ]),
            ],
            vide: 'Aucun mouvement.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Un mouvement n’est jamais supprimé : une erreur se corrige par '
            'une annulation motivée.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

Future<String?> _motif(BuildContext context) {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Annuler ce mouvement'),
      content: TextField(
        key: const Key('motif-annulation'),
        controller: c,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Motif (obligatoire)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Retour'),
        ),
        FilledButton(
          key: const Key('valider-annulation'),
          onPressed: () => Navigator.pop(ctx, c.text),
          child: const Text('Annuler le mouvement'),
        ),
      ],
    ),
  );
}

// ----------------------------------------------------------------------
// Menus de la semaine
// ----------------------------------------------------------------------

class MenusPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<MenusPage> createState() => _MenusState();
}

class _MenusState extends ConsumerState<MenusPage> {
  late String _semaine = lundi(_aujourdhui(ref));
  final _texte = TextEditingController();
  String? _chargePour;

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  String _intitule(String l) =>
      'semaine du ${dateCourte(l)} au ${dateCourte(_decale(l, 4))}';

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider).value;
    if (s == null) return _chargement('Menus de la semaine');
    if (!ref.watch(cantineActiveProvider(s.schoolId))) {
      return _garde(ref, 'Menus de la semaine')!;
    }
    final menus = ref.watch(menusProvider(s.schoolId)).value;
    final ecole = contexteFinances(ref)?.$1;
    if (menus == null || ecole == null) {
      return _chargement('Menus de la semaine');
    }
    final modifiable = droitsCantine(ref).contains('cantine');
    final courant = menus.where((m) => m.weekStart == _semaine).firstOrNull;
    if (_chargePour != _semaine) {
      _chargePour = _semaine;
      _texte.text =
          courant?.content ??
          [for (final j in joursSemaine(_semaine)) '${jourCourt(j)} : ']
              .join('\n');
    }
    return EcoleScaffold(
      title: 'Menus de la semaine',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Semaine précédente',
                icon: const Icon(Icons.chevron_left),
                onPressed: () =>
                    setState(() => _semaine = _decale(_semaine, -7)),
              ),
              Expanded(
                child: Text(
                  _intitule(_semaine),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Semaine suivante',
                icon: const Icon(Icons.chevron_right),
                onPressed: () =>
                    setState(() => _semaine = _decale(_semaine, 7)),
              ),
            ],
          ),
          TextField(
            key: const Key('texte-menu'),
            controller: _texte,
            readOnly: !modifiable,
            maxLines: 8,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          if (modifiable)
            BigButton(
              key: const Key('enregistrer-menu'),
              icon: Icons.save,
              label: 'Enregistrer le menu',
              onPressed: () async {
                final ok = await avecMessage(context, () async {
                  await ref
                      .read(cantineRepositoryProvider)
                      .enregistrerMenu(
                        schoolId: s.schoolId,
                        jour: _semaine,
                        texte: _texte.text,
                      );
                  return true;
                });
                if (ok != true || !context.mounted) return;
                unawaited(ref.read(syncEngineProvider).syncNow());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu enregistré.')),
                );
              },
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Imprimer ou partager le menu'),
            onPressed: () => avecMessage(context, () async {
              final pdf = await pdfMenu(
                await ref.read(policesPdfProvider.future),
                ecole: ecole.name,
                semaine: _intitule(_semaine),
                texte: _texte.text,
              );
              await ref
                  .read(sortiePdfProvider)
                  .partager(pdf, 'Menu_cantine_$_semaine.pdf');
            }),
          ),
          if (menus.isNotEmpty) ...[
            const SectionTitle('Menus enregistrés'),
            for (final m in menus.take(8))
              ListTile(
                dense: true,
                title: Text(_intitule(m.weekStart)),
                subtitle: Text(
                  m.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => setState(() => _semaine = m.weekStart),
              ),
          ],
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Dépenses de cantine
// ----------------------------------------------------------------------

class DepensesCantinePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garde = _garde(ref, 'Dépenses de cantine');
    if (garde != null) return garde;
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Dépenses de cantine');
    final (_, annee) = c;
    final depenses = [
      for (final d
          in ref.watch(depensesProvider(annee.id)).value ??
              const <ExpenseRow>[])
        if (d.category == categorieCantine) d,
    ];
    final mois = ref.watch(aujourdhuiProvider).substring(0, 7);
    return EcoleScaffold(
      title: 'Dépenses de cantine',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MentionFcfa(),
          Text(
            'Ce mois-ci : ${fcfa(depensesCantine(depenses, mois: mois))}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          BigButton(
            key: const Key('nouvelle-depense-cantine'),
            icon: Icons.add,
            label: 'Nouvelle dépense de cantine',
            onPressed: () => context.push('/cantine/depense/nouvelle'),
          ),
          const SizedBox(height: 12),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Date', largeurMin: 90),
              ColonneTableau('N°', flex: 3, largeurMin: 120),
              ColonneTableau('Objet', flex: 4, largeurMin: 150),
              ColonneTableau('Montant', montant: true),
            ],
            lignes: [
              for (final d in depenses)
                LigneTableau([
                  Text(dateCourte(d.spentOn)),
                  Text(d.voucherNumber ?? ''),
                  Text(
                    d.reversesExpenseId != null
                        ? 'Annulation : ${d.reversalReason ?? ''}'
                        : d.label + (d.justificationPath == null ? '' : ' 📎'),
                  ),
                  Text(fcfa(d.amount)),
                ], onTap: () => context.push('/finances/depense/${d.id}')),
            ],
            total: depenses.isEmpty
                ? null
                : LigneTableau([
                    const Text('Total de l’année'),
                    const SizedBox(),
                    const SizedBox(),
                    Text(fcfa(depensesCantine(depenses))),
                  ]),
            vide: 'Aucune dépense de cantine.',
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Rapports et bilan mensuel
// ----------------------------------------------------------------------

class RapportsCantinePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RapportsCantinePage> createState() => _RapportsCantineState();
}

class _RapportsCantineState extends ConsumerState<RapportsCantinePage> {
  late String _mois = _aujourdhui(ref).substring(0, 7);

  DonneesBilanCantine? _donnees() {
    final c = contexteFinances(ref);
    if (c == null) return null;
    final (ecole, annee) = c;
    final pointages = ref.read(pointagesProvider(ecole.id)).value;
    final produits = ref.read(produitsProvider(ecole.id)).value;
    final mouvements = ref.read(mouvementsProvider(ecole.id)).value;
    final eleves = ref.read(elevesProvider((ecole.id, annee.id, false))).value;
    final classes = ref.read(classesProvider(annee.id)).value;
    final situations = ref.read(
      situationsAbonnementProvider((ecole.id, annee.id)),
    );
    final depenses = ref.read(depensesProvider(annee.id)).value;
    if (pointages == null ||
        produits == null ||
        mouvements == null ||
        eleves == null ||
        classes == null ||
        situations == null ||
        depenses == null) {
      return null;
    }
    final b = abonnesDuMois(situations, _mois);
    final finances =
        droitsCantine(ref).contains('finances') ||
        droitsCantine(ref).contains('cantine');
    final paiements =
        ref.read(paiementsProvider(annee.id)).value ?? const <PaymentRow>[];
    final details =
        ref.read(detailsProvider(annee.id)).value ??
        const <PaymentAllocationRow>[];
    // Restant à compléter : mois payés en partie (avances).
    final aCompleter = [
      for (final sc in situations.values)
        for (final m in sc.mois)
          if (m.mois.startsWith(_mois)) m.reste,
    ].fold<int>(0, (x, y) => x + y);
    final parJour = repasParJour(pointages, mois: _mois);
    final effectifs = effectifsParClasse(eleves, classes, b);
    return DonneesBilanCantine(
      ecole: ecole.name,
      anneeScolaire: annee.label,
      periode: nomMois(_mois),
      genereLe: dateCourte(_aujourdhui(ref)),
      definition: ref
          .read(reglagesCantineProvider(ecole.id))
          .value
          ?.localDefinition,
      avecCotisations: finances,
      repasParJour: parJour,
      effectifs: effectifs,
      bilan: BilanCantine(
        mois: _mois,
        repas: parJour.values.fold(0, (s, n) => s + n),
        joursServis: parJour.values.where((n) => n > 0).length,
        beneficiaires: effectifs.fold(0, (s, e) => s + e.beneficiaires),
        cout: CoutMoyen(
          depensesCantine(depenses, mois: _mois),
          parJour.values.fold(0, (s, n) => s + n),
        ),
        cotisations: cotisationsCantine(paiements, details, mois: _mois),
        impayes: aCompleter,
        stock: mouvementsDuMois(produits, mouvements, _mois),
      ),
    );
  }

  Future<void> _pdf({required bool partager}) async {
    final d = _donnees();
    if (d == null) return;
    await avecMessage(context, () async {
      final pdf = await pdfBilanCantine(
        await ref.read(policesPdfProvider.future),
        d,
      );
      final sortie = ref.read(sortiePdfProvider);
      await (partager ? sortie.partager : sortie.imprimer)(
        pdf,
        'Bilan_cantine_$_mois.pdf',
      );
    });
  }

  Future<void> _excel() async {
    final d = _donnees();
    if (d == null) return;
    final b = d.bilan;
    final octets = ecrireXlsx('Cantine $_mois', [
      ['Bilan de la cantine', d.periode],
      [],
      ['Repas servis', b.repas],
      ['Jours de service', b.joursServis],
      ['Élèves abonnés', b.beneficiaires],
      ['Dépenses de cantine (FCFA)', b.cout.depenses],
      ['Coût moyen par repas (FCFA)', b.cout.arrondi ?? ''],
      ['Formule', b.cout.formule],
      if (d.avecCotisations) ...[
        ['Abonnements encaissés (FCFA)', b.cotisations],
        ['Impayés de cantine (FCFA)', b.impayes],
      ],
      [],
      ['Jour', 'Repas servis'],
      for (final MapEntry(key: j, value: n) in d.repasParJour.entries)
        [dateCourte(j), n],
      [],
      ['Classe', 'Abonnés', 'Effectif'],
      for (final e in d.effectifs) [e.classe, e.beneficiaires, e.effectif],
      [],
      ['Produit', 'Unité', 'Début', 'Entrées', 'Sorties', 'Inventaire', 'Fin'],
      for (final m in b.stock)
        [
          m.produit.name,
          m.produit.unit,
          m.stockDebut,
          m.entrees,
          m.sorties,
          m.ajustements,
          m.stockFin,
        ],
    ]);
    if (!mounted) return;
    await avecMessage(
      context,
      () => ref.read(sortieFichierProvider)(
        octets,
        'Bilan_cantine_$_mois.xlsx',
        typeXlsx,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final garde = _garde(ref, 'Rapports de la cantine');
    if (garde != null) return garde;
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Rapports de la cantine');
    final (ecole, annee) = c;
    // Abonnements (les données sont lues au moment du rapport).
    final pointages = ref.watch(pointagesProvider(ecole.id)).value ?? const [];
    ref
      ..watch(produitsProvider(ecole.id))
      ..watch(mouvementsProvider(ecole.id))
      ..watch(elevesProvider((ecole.id, annee.id, false)))
      ..watch(classesProvider(annee.id))
      ..watch(situationsAbonnementProvider((ecole.id, annee.id)))
      ..watch(depensesProvider(annee.id))
      ..watch(paiementsProvider(annee.id))
      ..watch(detailsProvider(annee.id));
    final mois = {
      for (final p in pointages) p.day.substring(0, 7),
      _aujourdhui(ref).substring(0, 7),
    }.toList()..sort((a, b) => b.compareTo(a));
    final d = _donnees();
    return EcoleScaffold(
      title: 'Rapports de la cantine',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MentionFcfa(),
          Wrap(
            spacing: 6,
            children: [
              for (final m in mois)
                ChoiceChip(
                  label: Text(nomMois(m)),
                  selected: _mois == m,
                  onSelected: (_) => setState(() => _mois = m),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (d == null)
            const LinearProgressIndicator()
          else ...[
            TableauDonnees(
              titre: 'Bilan de ${d.periode}',
              colonnes: const [
                ColonneTableau('', flex: 5, largeurMin: 200),
                ColonneTableau('Valeur', montant: true),
              ],
              lignes: [
                LigneTableau([
                  const Text('Repas servis'),
                  Text(fcfa(d.bilan.repas), key: const Key('bilan-repas')),
                ]),
                LigneTableau([
                  const Text('Jours de service'),
                  Text('${d.bilan.joursServis}'),
                ]),
                LigneTableau([
                  const Text('Élèves abonnés'),
                  Text('${d.bilan.beneficiaires}'),
                ]),
                LigneTableau([
                  const Text('Dépenses de cantine'),
                  Text(fcfa(d.bilan.cout.depenses)),
                ]),
                LigneTableau([
                  const Text('Coût moyen par repas'),
                  Text(
                    d.bilan.cout.arrondi == null
                        ? '—'
                        : fcfa(d.bilan.cout.arrondi!),
                    key: const Key('cout-moyen'),
                  ),
                ]),
                if (d.avecCotisations) ...[
                  LigneTableau([
                    const Text('Abonnements encaissés'),
                    Text(fcfa(d.bilan.cotisations)),
                  ]),
                  LigneTableau([
                    const Text('Avances à compléter'),
                    montantRestant(context, d.bilan.impayes),
                  ]),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              d.bilan.cout.formule,
              key: const Key('formule-cout'),
              style: const TextStyle(fontSize: 12),
            ),
            TableauDonnees(
              titre: 'Stock de vivres',
              colonnes: const [
                ColonneTableau('Produit', flex: 3, largeurMin: 120),
                ColonneTableau('Entrées', montant: true, largeurMin: 80),
                ColonneTableau('Sorties', montant: true, largeurMin: 80),
                ColonneTableau('Fin du mois', montant: true, largeurMin: 100),
              ],
              lignes: [
                for (final m in d.bilan.stock)
                  LigneTableau([
                    Text('${m.produit.name} (${m.produit.unit})'),
                    Text(qte(m.entrees)),
                    Text(qte(m.sorties)),
                    Text(qte(m.stockFin)),
                  ]),
              ],
              vide: 'Aucun produit.',
            ),
          ],
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.picture_as_pdf,
            label: 'Bilan mensuel (PDF)',
            onPressed: () => _pdf(partager: false),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Partager le bilan PDF'),
            onPressed: () => _pdf(partager: true),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('export-excel-cantine'),
            icon: const Icon(Icons.table_chart),
            label: const Text('Bilan (Excel)'),
            onPressed: _excel,
          ),
        ],
      ),
    );
  }
}
