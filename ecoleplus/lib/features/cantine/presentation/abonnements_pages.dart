import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/tableau.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/cantine/pdf/pdf_cantine.dart';
import 'package:ecoleplus/features/cantine/presentation/cantine_pages.dart';
import 'package:ecoleplus/features/cantine/presentation/cantine_providers.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/finances/presentation/finances_gestion_pages.dart'
    show ChampMontant;
import 'package:ecoleplus/features/finances/presentation/finances_pages.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ----------------------------------------------------------------------
// Outils communs
// ----------------------------------------------------------------------

Widget _chargement(String titre) =>
    EcoleScaffold(title: titre, body: const LinearProgressIndicator());

/// Données de la cantine pour l'année en cours (null : en chargement).
class _Cantine {
  const new({
    required this.ecole,
    required this.annee,
    required this.mois,
    required this.situations,
    required this.eleves,
    required this.classes,
  });
  final SchoolRow ecole;
  final SchoolYearRow annee;
  final List<String> mois;
  final Map<String, SituationCantine> situations;

  /// Élèves présents (non sortis).
  final List<EleveDansAnnee> eleves;
  final List<ClassRow> classes;

  EleveDansAnnee? eleve(String id) =>
      eleves.where((e) => e.eleve.id == id).firstOrNull;
}

_Cantine? _cantine(WidgetRef ref) {
  final c = contexteFinances(ref);
  if (c == null) return null;
  final (ecole, annee) = c;
  final mois = ref.watch(moisCantineProvider((ecole.id, annee.id)));
  final situations = ref.watch(
    situationsAbonnementProvider((ecole.id, annee.id)),
  );
  final eleves = ref.watch(elevesProvider((ecole.id, annee.id, false))).value;
  final classes = ref.watch(classesProvider(annee.id)).value;
  if (mois == null || situations == null || eleves == null || classes == null) {
    return null;
  }
  return _Cantine(
    ecole: ecole,
    annee: annee,
    mois: mois,
    situations: situations,
    eleves: eleves,
    classes: classes,
  );
}

String _nom(EleveDansAnnee e) => '${e.eleve.lastName} ${e.eleve.firstNames}';

/// Mois proposé par défaut : le mois en cours s'il fonctionne, sinon le
/// premier mois à venir, sinon le dernier.
String moisCourant(List<String> mois, String aujourdhui) {
  final m = debutMois(aujourdhui);
  if (mois.contains(m)) return m;
  return mois.where((x) => x.compareTo(m) > 0).firstOrNull ??
      (mois.isEmpty ? m : mois.last);
}

/// Pastille de statut : vert (abonné), orange (partiel), neutre.
class PastilleStatut extends StatelessWidget {
  const new(this.statut, {super.key});
  final StatutMois statut;

  @override
  Widget build(BuildContext context) {
    final c = CouleursFinances.de(context);
    final cs = Theme.of(context).colorScheme;
    final (fond, texte) = switch (statut) {
      StatutMois.abonne => (c.fondVert, c.vert),
      StatutMois.partiel => (cs.errorContainer, c.rouge),
      StatutMois.nonAbonne => (cs.surfaceContainerHighest, cs.outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        libelleStatutMois(statut),
        style: TextStyle(
          color: texte,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Choix du mois et de la classe (ou toute l'école).
class _Choix extends StatelessWidget {
  const new({
    required this.mois,
    required this.moisChoisi,
    required this.onMois,
    required this.classes,
    required this.classe,
    required this.onClasse,
  });
  final List<String> mois;
  final String moisChoisi;
  final ValueChanged<String> onMois;
  final List<ClassRow> classes;
  final String? classe;
  final ValueChanged<String?> onClasse;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      DropdownButton<String>(
        key: const Key('choix-mois'),
        value: mois.contains(moisChoisi) ? moisChoisi : null,
        hint: const Text('Mois'),
        items: [
          for (final m in mois)
            DropdownMenuItem(value: m, child: Text(libelleMoisCantine(m))),
        ],
        onChanged: (v) {
          if (v != null) onMois(v);
        },
      ),
      DropdownButton<String?>(
        key: const Key('choix-classe'),
        value: classe,
        items: [
          const DropdownMenuItem(child: Text('Toute l’école')),
          for (final k in classes)
            DropdownMenuItem(value: k.id, child: Text(k.name)),
        ],
        onChanged: onClasse,
      ),
    ],
  );
}

/// Élèves d'une classe (ou de toute l'école), triés par classe puis nom.
List<EleveDansAnnee> _eleves(_Cantine c, String? classe) {
  final ordre = {for (final (i, k) in c.classes.indexed) k.id: i};
  return [
    for (final e in c.eleves)
      if (classe == null || e.classe?.id == classe) e,
  ]..sort((a, b) {
    final k = (ordre[a.classe?.id] ?? 999).compareTo(
      ordre[b.classe?.id] ?? 999,
    );
    return k != 0 ? k : _nom(a).compareTo(_nom(b));
  });
}

// ----------------------------------------------------------------------
// Accueil « Cantine scolaire »
// ----------------------------------------------------------------------

class CantinePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garde = gardeCantine(ref, 'Cantine scolaire');
    if (garde != null) return garde;
    final c = _cantine(ref);
    if (c == null) return _chargement('Cantine scolaire');
    final droits = droitsCantine(ref);
    final mois = moisCourant(c.mois, ref.watch(aujourdhuiProvider));
    final autorises = abonnesDuMois(c.situations, mois).length;
    final tarifs = ref.watch(tarifsProvider(c.annee.id)).value ?? const [];
    final stock = ref.watch(stockProvider(c.ecole.id)) ?? const [];
    final bas = stock.where((e) => e.alerte || e.negatif).length;
    Widget espace(IconData i, String t, String route, {Key? key}) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        key: key,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: Icon(i),
        label: Text(t, style: const TextStyle(fontSize: 16)),
        onPressed: () => context.push(route),
      ),
    );
    return EcoleScaffold(
      title: 'Cantine scolaire',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${libelleMoisCantine(mois)} : $autorises élève(s) autorisé(s)',
            key: const Key('autorises-du-mois'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (tarifs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Commencez par fixer le tarif mensuel (Réglages, en bas).',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 12),
          BigButton(
            key: const Key('abonner-encaisser'),
            icon: Icons.point_of_sale,
            label: 'ABONNER ET ENCAISSER',
            onPressed: () => context.push('/cantine/encaisser'),
          ),
          const SizedBox(height: 16),
          espace(Icons.dashboard_outlined, 'Tableau de bord', '/cantine/bord'),
          espace(
            Icons.how_to_reg_outlined,
            'Abonnements',
            '/cantine/abonnements',
          ),
          espace(Icons.receipt_long, 'Encaissements', '/cantine/encaissements'),
          espace(
            Icons.history,
            'Situation et historique',
            '/cantine/situations',
          ),
          if (droits.contains('cantine'))
            espace(
              Icons.restaurant,
              bas == 0
                  ? 'Vivres et repas'
                  : 'Vivres et repas (stock bas : $bas)',
              '/cantine/vivres',
            ),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const Key('reglages-cantine'),
            icon: const Icon(Icons.tune),
            label: const Text('Réglages (tarif, mois, exonérations)'),
            onPressed: () => context.push('/cantine/reglages'),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Tableau de bord
// ----------------------------------------------------------------------

class TableauBordCantinePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<TableauBordCantinePage> createState() => _BordState();
}

class _BordState extends ConsumerState<TableauBordCantinePage> {
  String? _mois;
  String? _classe;

  @override
  Widget build(BuildContext context) {
    final garde = gardeCantine(ref, 'Tableau de bord');
    if (garde != null) return garde;
    final c = _cantine(ref);
    if (c == null) return _chargement('Tableau de bord');
    final mois = _mois ?? moisCourant(c.mois, ref.watch(aujourdhuiProvider));
    final eleves = _eleves(c, _classe);
    final lignes = [
      for (final e in eleves) (e, c.situations[e.eleve.id]?.duMois(mois)),
    ];
    final t = TableauBordCantine.depuis([for (final (_, m) in lignes) ?m]);
    final couleurs = CouleursFinances.de(context);
    return EcoleScaffold(
      title: 'Tableau de bord',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Choix(
            mois: c.mois,
            moisChoisi: mois,
            onMois: (m) => setState(() => _mois = m),
            classes: c.classes,
            classe: _classe,
            onClasse: (k) => setState(() => _classe = k),
          ),
          const MentionFcfa(),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Indicateur', flex: 5, largeurMin: 190),
              ColonneTableau('Valeur', flex: 3, montant: true, largeurMin: 110),
            ],
            lignes: [
              LigneTableau([
                const Text('Élèves abonnés'),
                Text(
                  '${t.abonnes}',
                  key: const Key('nb-abonnes'),
                  style: TextStyle(
                    color: couleurs.vert,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]),
              if (t.partiels > 0)
                LigneTableau([
                  const Text('Paiements partiels (avances)'),
                  Text('${t.partiels}', key: const Key('nb-partiels')),
                ]),
              LigneTableau([
                const Text('Élèves non abonnés'),
                Text('${t.nonAbonnes}', key: const Key('nb-non-abonnes')),
              ]),
              LigneTableau([
                const Text('Montant total attendu'),
                Text(fcfa(t.attendu), key: const Key('attendu')),
              ]),
              LigneTableau([
                const Text('Montant total encaissé'),
                Text(fcfa(t.encaisse), key: const Key('encaisse')),
              ]),
              LigneTableau([
                const Text('Montant restant à recouvrer'),
                montantRestant(context, t.restant, key: const Key('restant')),
              ]),
              LigneTableau([
                const Text('Taux de recouvrement'),
                Text(texteTaux(t.taux), key: const Key('taux')),
              ]),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Les élèves non abonnés ne doivent rien : ils ne comptent ni '
            'dans l’attendu ni dans le restant.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Nom et prénom', flex: 5, largeurMin: 170),
              ColonneTableau('Classe', largeurMin: 80),
              ColonneTableau('Montant dû', montant: true),
              ColonneTableau('Montant payé', montant: true, largeurMin: 110),
              ColonneTableau('Statut', flex: 3, centre: true, largeurMin: 150),
            ],
            lignes: [
              for (final (e, m) in lignes)
                LigneTableau([
                  Text(_nom(e)),
                  Text(e.classe?.name ?? '—'),
                  Text(fcfa(m?.du ?? 0)),
                  Text(fcfa(m?.encaisse ?? 0)),
                  PastilleStatut(
                    m?.statut ?? StatutMois.nonAbonne,
                    key: Key('statut-${e.eleve.id}'),
                  ),
                ], onTap: () => context.push('/cantine/eleve/${e.eleve.id}')),
            ],
            total: LigneTableau([
              const Text('Total'),
              const SizedBox(),
              Text(fcfa(t.attendu)),
              Text(fcfa(t.encaisse)),
              const SizedBox(),
            ]),
            vide: 'Aucun élève.',
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Abonnements (statuts du mois, abonnement groupé, liste des autorisés)
// ----------------------------------------------------------------------

class AbonnementsCantinePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AbonnementsCantinePage> createState() => _AbonnementsState();
}

class _AbonnementsState extends ConsumerState<AbonnementsCantinePage> {
  String? _mois;
  String? _classe;
  final _coches = <String>{};
  bool _occupe = false;

  Future<void> _imprimer(_Cantine c, String mois) async {
    final abonnes = abonnesDuMois(c.situations, mois);
    final groupes = [
      for (final k in [...c.classes, null])
        (
          k?.name ?? 'Sans classe',
          [
            for (final e in _eleves(c, null))
              if (e.classe?.id == k?.id && abonnes.contains(e.eleve.id))
                _nom(e),
          ],
        ),
    ];
    await avecMessage(context, () async {
      final pdf = await pdfAutorises(
        await ref.read(policesPdfProvider.future),
        ecole: c.ecole.name,
        mois: libelleMoisCantine(mois),
        classes: groupes,
      );
      await ref
          .read(sortiePdfProvider)
          .partager(pdf, 'Cantine_autorises_${mois.substring(0, 7)}.pdf');
    });
  }

  /// Abonnement groupé : un reçu par élève (mois payé en entier), même
  /// mode de paiement ; les élèves exonérés sont abonnés sans reçu.
  Future<void> _abonnerGroupe(_Cantine c, String mois) async {
    final choisis = [
      for (final id in _coches)
        if (c.situations[id]?.duMois(mois) case final m?)
          if (m.payable) (id, m),
    ];
    if (choisis.isEmpty) return;
    final total = choisis.fold<int>(0, (s, x) => s + x.$2.aVerser);
    var mode = 'especes';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Abonner ${choisis.length} élève(s)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${libelleMoisCantine(mois)} — total ${fcfaTexte(total)}. '
                'Un reçu par élève, mois payé en entier.',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  for (final MapEntry(key: k, value: v)
                      in modesPaiement.entries)
                    if (k != 'autre')
                      ChoiceChip(
                        label: Text(v),
                        selected: mode == k,
                        onSelected: (_) => setState(() => mode = k),
                      ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              key: const Key('valider-groupe'),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('VALIDER LE PAIEMENT'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _occupe = true);
    final repo = ref.read(cantineRepositoryProvider);
    final finances = ref.read(financesRepositoryProvider);
    final n = await avecMessage(context, () async {
      var recus = 0;
      for (final (id, m) in choisis) {
        final r = await repo.abonnerEtEncaisser(
          finances: finances,
          schoolId: c.ecole.id,
          yearId: c.annee.id,
          studentId: id,
          classId: c.eleve(id)?.classe?.id,
          mois: [m],
          recu: m.aVerser,
          mode: mode,
        );
        if (r != null) recus++;
      }
      return recus;
    });
    if (!mounted) return;
    setState(() {
      _occupe = false;
      if (n != null) _coches.clear();
    });
    if (n == null) return;
    unawaited(ref.read(syncEngineProvider).syncNow());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${choisis.length} élève(s) abonné(s) ; $n reçu(s) dans '
          '« Encaissements ».',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final garde = gardeCantine(ref, 'Abonnements');
    if (garde != null) return garde;
    final c = _cantine(ref);
    if (c == null) return _chargement('Abonnements');
    final mois = _mois ?? moisCourant(c.mois, ref.watch(aujourdhuiProvider));
    final eleves = _eleves(c, _classe);
    MoisEleve? m(EleveDansAnnee e) => c.situations[e.eleve.id]?.duMois(mois);
    final cochables = [
      for (final e in eleves)
        if (m(e)?.payable ?? false) e.eleve.id,
    ];
    _coches.removeWhere((id) => !cochables.contains(id));
    final abonnes = eleves
        .where((e) => m(e)?.statut == StatutMois.abonne)
        .length;
    return EcoleScaffold(
      title: 'Abonnements',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Choix(
            mois: c.mois,
            moisChoisi: mois,
            onMois: (x) => setState(() {
              _mois = x;
              _coches.clear();
            }),
            classes: c.classes,
            classe: _classe,
            onClasse: (k) => setState(() {
              _classe = k;
              _coches.clear();
            }),
          ),
          Text(
            '$abonnes abonné(s) sur ${eleves.length} élève(s)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('', centre: true, largeurMin: 52),
              ColonneTableau('Nom et prénom', flex: 5, largeurMin: 170),
              ColonneTableau('Classe', largeurMin: 80),
              ColonneTableau(
                'Statut du mois',
                flex: 3,
                centre: true,
                largeurMin: 150,
              ),
            ],
            lignes: [
              for (final e in eleves)
                LigneTableau([
                  Checkbox(
                    key: Key('cocher-${e.eleve.id}'),
                    value: _coches.contains(e.eleve.id),
                    onChanged: cochables.contains(e.eleve.id)
                        ? (v) => setState(
                            () => v == true
                                ? _coches.add(e.eleve.id)
                                : _coches.remove(e.eleve.id),
                          )
                        : null,
                  ),
                  Text(_nom(e)),
                  Text(e.classe?.name ?? '—'),
                  PastilleStatut(m(e)?.statut ?? StatutMois.nonAbonne),
                ], onTap: () => context.push('/cantine/eleve/${e.eleve.id}')),
            ],
            vide: 'Aucun élève.',
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('tout-cocher'),
              icon: const Icon(Icons.done_all),
              label: const Text('Tout cocher (non abonnés)'),
              onPressed: () => setState(() => _coches.addAll(cochables)),
            ),
          ),
          const SizedBox(height: 8),
          BigButton(
            key: const Key('abonner-selection'),
            icon: Icons.point_of_sale,
            label: _coches.isEmpty
                ? 'Cochez des élèves à abonner'
                : 'ABONNER ET ENCAISSER (${_coches.length})',
            onPressed: _coches.isEmpty || _occupe
                ? null
                : () => _abonnerGroupe(c, mois),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('liste-autorises'),
            icon: const Icon(Icons.print),
            label: const Text(
              'Liste des élèves autorisés (imprimer, partager)',
            ),
            onPressed: () => _imprimer(c, mois),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Abonner et encaisser (un élève, un ou plusieurs mois, un seul reçu)
// ----------------------------------------------------------------------

class AbonnerEncaisserPage extends ConsumerStatefulWidget {
  const new({this.eleveId, super.key});
  final String? eleveId;

  @override
  ConsumerState<AbonnerEncaisserPage> createState() => _AbonnerState();
}

class _AbonnerState extends ConsumerState<AbonnerEncaisserPage> {
  late String? _eleve = widget.eleveId;
  String? _classe;
  final _recherche = TextEditingController();
  final _mois = <String>{};
  final _recu = TextEditingController();
  final _payeur = TextEditingController();
  final _reference = TextEditingController();
  final _libelleMode = TextEditingController();
  String _mode = 'especes';
  bool _montantSaisi = false;
  bool _occupe = false;

  @override
  void dispose() {
    for (final c in [_recherche, _recu, _payeur, _reference, _libelleMode]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _ligneRecap(MoisEleve m, int part) {
    final mois = libelleMoisCantine(m.mois);
    if (m.aVerser == 0) return '$mois : exonéré';
    final avance = part < m.aVerser ? ' (avance sur ${fcfa(m.aVerser)})' : '';
    return '$mois : ${fcfa(part)}$avance';
  }

  void _majMontant(int total) {
    if (!_montantSaisi) _recu.text = total == 0 ? '' : '$total';
  }

  Future<void> _valider(_Cantine c, List<MoisEleve> choisis) async {
    final total = choisis.fold<int>(0, (s, m) => s + m.aVerser);
    final recu = total == 0 ? 0 : (lireMontant(_recu.text) ?? -1);
    if (recu < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquez le montant reçu.')),
      );
      return;
    }
    final e = c.eleve(_eleve!)!;
    final parts = {for (final (m, p) in repartir(recu, choisis)) m.mois: p};
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vérifiez avant de valider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_nom(e)} — ${e.classe?.name ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              for (final m in choisis) Text(_ligneRecap(m, parts[m.mois] ?? 0)),
              const Divider(),
              Text(
                '${choisis.length} mois — total ${fcfaTexte(recu)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (total > 0)
                Text(
                  'Mode : ${libelleMode(_mode, _libelleMode.text)}'
                  '${_payeur.text.trim().isEmpty ? '' : ' — payé par '}'
                  '${_payeur.text.trim()}',
                ),
              if (recu < total)
                Text(
                  'Paiement partiel : ${fcfa(total - recu)} restent à '
                  'verser. Un mois payé en partie ne donne pas droit aux '
                  'repas.',
                  style: TextStyle(color: CouleursFinances.de(ctx).rouge),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Modifier'),
          ),
          FilledButton(
            key: const Key('valider-paiement'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(total == 0 ? 'VALIDER' : 'VALIDER LE PAIEMENT'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _occupe = true);
    final r = await avecMessage(
      context,
      () async => (
        recu: await ref
            .read(cantineRepositoryProvider)
            .abonnerEtEncaisser(
              finances: ref.read(financesRepositoryProvider),
              schoolId: c.ecole.id,
              yearId: c.annee.id,
              studentId: e.eleve.id,
              classId: e.classe?.id,
              mois: choisis,
              recu: recu,
              mode: _mode,
              libelleMode: _libelleMode.text,
              reference: _reference.text,
              payeur: _payeur.text,
            ),
      ),
    );
    if (!mounted) return;
    setState(() => _occupe = false);
    if (r == null) return;
    unawaited(ref.read(syncEngineProvider).syncNow());
    final recuFait = r.recu;
    if (recuFait == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Élève exonéré : abonné sans paiement.')),
      );
      context.pop();
    } else {
      context.pushReplacement('/finances/recu/${recuFait.id}');
    }
  }

  Widget _choixEleve(_Cantine c) {
    final t = sansAccentsRubrique(_recherche.text.trim().toLowerCase());
    final liste = [
      for (final e in _eleves(c, _classe))
        if (t.isEmpty || sansAccentsRubrique(_nom(e).toLowerCase()).contains(t))
          e,
    ];
    final mois = moisCourant(c.mois, ref.watch(aujourdhuiProvider));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('recherche-eleve'),
                controller: _recherche,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Nom de l’élève',
                ),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String?>(
              value: _classe,
              items: [
                const DropdownMenuItem(child: Text('Toutes')),
                for (final k in c.classes)
                  DropdownMenuItem(value: k.id, child: Text(k.name)),
              ],
              onChanged: (k) => setState(() => _classe = k),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TableauDonnees(
          colonnes: [
            const ColonneTableau('Nom et prénom', flex: 5, largeurMin: 170),
            const ColonneTableau('Classe', largeurMin: 80),
            ColonneTableau(
              libelleMoisCantine(mois),
              flex: 3,
              centre: true,
              largeurMin: 150,
            ),
          ],
          lignes: [
            for (final e in liste)
              LigneTableau(
                [
                  Text(_nom(e), key: Key('choisir-${e.eleve.id}')),
                  Text(e.classe?.name ?? '—'),
                  PastilleStatut(
                    c.situations[e.eleve.id]?.duMois(mois)?.statut ??
                        StatutMois.nonAbonne,
                  ),
                ],
                onTap: () => setState(() {
                  _eleve = e.eleve.id;
                  _mois.clear();
                  _montantSaisi = false;
                }),
              ),
          ],
          vide: 'Aucun élève trouvé.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final garde = gardeCantine(ref, 'Abonner et encaisser');
    if (garde != null) return garde;
    final c = _cantine(ref);
    if (c == null) return _chargement('Abonner et encaisser');
    final e = _eleve == null ? null : c.eleve(_eleve!);
    if (e == null) {
      return EcoleScaffold(title: 'Abonner et encaisser', body: _choixEleve(c));
    }
    final situation = c.situations[e.eleve.id]!;
    final choisis = [
      for (final m in situation.mois)
        if (_mois.contains(m.mois) && m.payable) m,
    ];
    final total = choisis.fold<int>(0, (s, m) => s + m.aVerser);
    _majMontant(total);
    final couleurs = CouleursFinances.de(context);
    return EcoleScaffold(
      title: 'Abonner et encaisser',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _nom(e),
              key: const Key('eleve-choisi'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(e.classe?.name ?? 'Sans classe'),
            trailing: widget.eleveId == null
                ? TextButton(
                    onPressed: () => setState(() => _eleve = null),
                    child: const Text('Changer'),
                  )
                : null,
          ),
          const MentionFcfa(),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('', centre: true, largeurMin: 52),
              ColonneTableau('Mois', flex: 3, largeurMin: 130),
              ColonneTableau('Tarif', montant: true),
              ColonneTableau('Statut', flex: 3, centre: true, largeurMin: 150),
            ],
            lignes: [
              for (final m in situation.mois)
                LigneTableau(
                  [
                    Checkbox(
                      key: Key('mois-${m.mois.substring(0, 7)}'),
                      value:
                          m.statut == StatutMois.abonne ||
                          _mois.contains(m.mois),
                      onChanged: m.payable
                          ? (v) => setState(() {
                              v == true
                                  ? _mois.add(m.mois)
                                  : _mois.remove(m.mois);
                              _montantSaisi = false;
                            })
                          : null,
                    ),
                    Text(libelleMoisCantine(m.mois)),
                    Text(
                      m.tarif == null && m.abonnement == null
                          ? '—'
                          : m.statut == StatutMois.partiel
                          ? 'reste ${fcfa(m.aVerser)}'
                          : (m.montant == 0 ? 'exonéré' : fcfa(m.montant)),
                    ),
                    PastilleStatut(m.statut),
                  ],
                  onTap: m.payable
                      ? () => setState(() {
                          _mois.contains(m.mois)
                              ? _mois.remove(m.mois)
                              : _mois.add(m.mois);
                          _montantSaisi = false;
                        })
                      : null,
                ),
            ],
            total: LigneTableau([
              const SizedBox(),
              Text('${choisis.length} mois'),
              Text(fcfa(total), key: const Key('total-a-payer')),
              const SizedBox(),
            ]),
          ),
          const SizedBox(height: 12),
          if (total > 0) ...[
            TextField(
              key: const Key('montant-recu'),
              controller: _recu,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() => _montantSaisi = true),
              decoration: const InputDecoration(
                labelText: 'Montant reçu (FCFA)',
                helperText:
                    'Moins que le total : avance ; le mois n’est pas encore '
                    'payé en entier.',
                border: OutlineInputBorder(),
              ),
            ),
            if ((lireMontant(_recu.text) ?? 0) > total)
              Text(
                'Le montant reçu dépasse le total (${fcfa(total)}).',
                style: TextStyle(color: couleurs.rouge),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final MapEntry(key: k, value: v) in modesPaiement.entries)
                  ChoiceChip(
                    key: Key('mode-$k'),
                    label: Text(v),
                    selected: _mode == k,
                    onSelected: (_) => setState(() => _mode = k),
                  ),
              ],
            ),
            if (_mode == 'autre')
              TextField(
                controller: _libelleMode,
                decoration: const InputDecoration(
                  labelText: 'Préciser (ex. Wave)',
                ),
              ),
            TextField(
              key: const Key('payeur'),
              controller: _payeur,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom et prénom du payeur',
              ),
            ),
            if (_mode != 'especes')
              TextField(
                controller: _reference,
                decoration: const InputDecoration(
                  labelText: 'Référence de la transaction (facultatif)',
                ),
              ),
            const SizedBox(height: 16),
          ],
          BigButton(
            key: const Key('valider-abonnement'),
            icon: Icons.check_circle_outline,
            label: choisis.isEmpty
                ? 'Cochez les mois à payer'
                : total == 0
                ? 'ABONNER (exonéré)'
                : 'ABONNER ET ENCAISSER ${fcfa(lireMontant(_recu.text) ?? 0)}',
            onPressed: choisis.isEmpty || _occupe
                ? null
                : () => _valider(c, choisis),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Encaissements (reçus de cantine)
// ----------------------------------------------------------------------

class EncaissementsCantinePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garde = gardeCantine(ref, 'Encaissements');
    if (garde != null) return garde;
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Encaissements');
    final (ecole, annee) = c;
    final paiements = [
      for (final p
          in ref.watch(paiementsProvider(annee.id)).value ??
              const <PaymentRow>[])
        if (p.rubric == rubriqueCantine) p,
    ];
    final details =
        ref.watch(detailsProvider(annee.id)).value ??
        const <PaymentAllocationRow>[];
    final noms = {
      for (final e
          in ref.watch(elevesProvider((ecole.id, annee.id, true))).value ??
              const <EleveDansAnnee>[])
        e.eleve.id: _nom(e),
    };
    String mois(PaymentRow p) => [
      for (final a in details)
        if (a.paymentId == p.id) (a.label ?? '').replaceFirst('Cantine — ', ''),
    ].join(', ');
    final total = paiements.fold<int>(0, (s, p) => s + p.amount);
    return EcoleScaffold(
      title: 'Encaissements',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MentionFcfa(),
          Text(
            'Total encaissé (annulations déduites) : ${fcfa(total)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          BigButton(
            icon: Icons.point_of_sale,
            label: 'ABONNER ET ENCAISSER',
            onPressed: () => context.push('/cantine/encaisser'),
          ),
          const SizedBox(height: 12),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Date', largeurMin: 90),
              ColonneTableau('N° du reçu', flex: 3, largeurMin: 130),
              ColonneTableau('Élève', flex: 4, largeurMin: 150),
              ColonneTableau('Mois', flex: 4, largeurMin: 150),
              ColonneTableau('Montant', montant: true),
            ],
            lignes: [
              for (final p in paiements)
                LigneTableau([
                  Text(dateCourte(p.paidAt)),
                  Text(p.receiptNumber),
                  Text(noms[p.studentId] ?? ''),
                  Text(p.estAnnulation ? 'Annulation' : mois(p)),
                  Text(fcfa(p.amount)),
                ], onTap: () => context.push('/finances/recu/${p.id}')),
            ],
            vide: 'Aucun encaissement de cantine.',
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Situation et historique
// ----------------------------------------------------------------------

class SituationsCantinePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SituationsCantinePage> createState() => _SituationsState();
}

class _SituationsState extends ConsumerState<SituationsCantinePage> {
  final _recherche = TextEditingController();
  String? _classe;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final garde = gardeCantine(ref, 'Situation et historique');
    if (garde != null) return garde;
    final c = _cantine(ref);
    if (c == null) return _chargement('Situation et historique');
    final t = sansAccentsRubrique(_recherche.text.trim().toLowerCase());
    final liste = [
      for (final e in _eleves(c, _classe))
        if (t.isEmpty || sansAccentsRubrique(_nom(e).toLowerCase()).contains(t))
          e,
    ];
    return EcoleScaffold(
      title: 'Situation et historique',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('recherche-situation'),
                  controller: _recherche,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Nom de l’élève',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: _classe,
                items: [
                  const DropdownMenuItem(child: Text('Toutes')),
                  for (final k in c.classes)
                    DropdownMenuItem(value: k.id, child: Text(k.name)),
                ],
                onChanged: (k) => setState(() => _classe = k),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const MentionFcfa(),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Nom et prénom', flex: 5, largeurMin: 170),
              ColonneTableau('Classe', largeurMin: 80),
              ColonneTableau('Mois abonnés', montant: true, largeurMin: 110),
              ColonneTableau('Encaissé', montant: true),
              ColonneTableau('À compléter', montant: true, largeurMin: 110),
            ],
            lignes: [
              for (final e in liste)
                LigneTableau([
                  Text(_nom(e)),
                  Text(e.classe?.name ?? '—'),
                  Text('${c.situations[e.eleve.id]?.moisAbonnes ?? 0}'),
                  Text(fcfa(c.situations[e.eleve.id]?.encaisse ?? 0)),
                  montantRestant(context, c.situations[e.eleve.id]?.reste ?? 0),
                ], onTap: () => context.push('/cantine/eleve/${e.eleve.id}')),
            ],
            vide: 'Aucun élève trouvé.',
          ),
        ],
      ),
    );
  }
}

class SituationEleveCantinePage extends ConsumerWidget {
  const new(this.id, {super.key});
  final String id;

  Future<void> _fiche(
    BuildContext context,
    WidgetRef ref,
    _Cantine c,
    CanteenBeneficiaryRow? fiche,
  ) async {
    var exo = exonere(fiche);
    final reduction = TextEditingController(
      text: fiche?.monthlyReduction == null ? '' : '${fiche!.monthlyReduction}',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Réduction ou exonération'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                key: const Key('exonere'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Exonéré (ne paie pas la cantine)'),
                value: exo,
                onChanged: (v) => setState(() => exo = v),
              ),
              if (!exo)
                ChampMontant(
                  key: const Key('reduction'),
                  controller: reduction,
                  label: 'Réduction par mois (FCFA)',
                ),
              const SizedBox(height: 8),
              const Text(
                'S’applique aux prochains abonnements ; les mois déjà '
                'abonnés gardent leur montant.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              key: const Key('valider-fiche'),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    await avecMessage(context, () async {
      final r = reduction.text.trim().isEmpty
          ? null
          : lireMontant(reduction.text);
      if (reduction.text.trim().isNotEmpty && r == null) {
        throw const UserMessage('Réduction : nombre attendu.');
      }
      await ref
          .read(cantineRepositoryProvider)
          .definirFiche(
            schoolId: c.ecole.id,
            yearId: c.annee.id,
            studentId: id,
            exonere: exo,
            reduction: exo ? null : r,
          );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garde = gardeCantine(ref, 'Situation de l’élève');
    if (garde != null) return garde;
    final c = _cantine(ref);
    if (c == null) return _chargement('Situation de l’élève');
    final s = c.situations[id];
    final eleve = ref
        .watch(elevesProvider((c.ecole.id, c.annee.id, true)))
        .value
        ?.where((e) => e.eleve.id == id)
        .firstOrNull;
    if (s == null || eleve == null) return _chargement('Situation de l’élève');
    final fiche = ref.watch(beneficiairesProvider(c.annee.id)).value?[id];
    final recus = [
      for (final p
          in ref.watch(paiementsProvider(c.annee.id)).value ??
              const <PaymentRow>[])
        if (p.rubric == rubriqueCantine && p.studentId == id) p,
    ];
    final sorti = eleve.eleve.archivedAt != null;
    return EcoleScaffold(
      title: _nom(eleve),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${eleve.classe?.name ?? 'Sans classe'}'
            '${sorti ? ' — élève sorti (historique conservé)' : ''}',
          ),
          Text(
            exonere(fiche)
                ? 'Exonéré'
                : (fiche?.monthlyReduction ?? 0) > 0
                ? 'Réduction : ${fcfa(fiche!.monthlyReduction!)} par mois'
                : 'Tarif normal',
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('modifier-fiche'),
              icon: const Icon(Icons.percent),
              onPressed: () => _fiche(context, ref, c, fiche),
              label: const Text('Réduction / exonération'),
            ),
          ),
          const MentionFcfa(),
          TableauDonnees(
            titre: 'SITUATION DE L’ABONNEMENT À LA CANTINE',
            colonnes: const [
              ColonneTableau('Mois', flex: 3, largeurMin: 130),
              ColonneTableau('Montant dû', montant: true),
              ColonneTableau('Montant payé', montant: true, largeurMin: 110),
              ColonneTableau('Statut', flex: 3, centre: true, largeurMin: 150),
            ],
            lignes: [
              for (final m in s.mois)
                LigneTableau([
                  Text(libelleMoisCantine(m.mois)),
                  Text(fcfa(m.du)),
                  Text(fcfa(m.paye < 0 ? 0 : m.paye)),
                  PastilleStatut(
                    m.statut,
                    key: Key('statut-mois-${m.mois.substring(0, 7)}'),
                  ),
                ]),
            ],
            total: LigneTableau([
              const Text('Total'),
              Text(fcfa(s.du)),
              Text(fcfa(s.encaisse)),
              const SizedBox(),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            '${s.moisAbonnes} mois abonné(s) • ${s.moisNonAbonnes} mois non '
            'abonné(s) • encaissé ${fcfa(s.encaisse)}'
            '${s.reste > 0 ? ' • reste à compléter ${fcfa(s.reste)}' : ''}',
            key: const Key('resume-eleve'),
          ),
          if (s.mois.any((m) => m.tropPercu > 0))
            Text(
              'Trop-perçu : un mois a été payé deux fois (deux téléphones '
              'sans Internet) ; annulez l’un des reçus.',
              style: TextStyle(color: CouleursFinances.de(context).rouge),
            ),
          const SizedBox(height: 12),
          if (!sorti)
            BigButton(
              icon: Icons.point_of_sale,
              label: 'ABONNER ET ENCAISSER',
              onPressed: () => context.push('/cantine/encaisser?eleve=$id'),
            ),
          const SectionTitle('Reçus'),
          TableauDonnees(
            colonnes: const [
              ColonneTableau('Date', largeurMin: 90),
              ColonneTableau('N° du reçu', flex: 3, largeurMin: 130),
              ColonneTableau('Montant', montant: true),
            ],
            lignes: [
              for (final p in recus)
                LigneTableau([
                  Text(dateCourte(p.paidAt)),
                  Text(p.receiptNumber),
                  Text(fcfa(p.amount)),
                ], onTap: () => context.push('/finances/recu/${p.id}')),
            ],
            vide: 'Aucun reçu de cantine.',
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Vivres et repas
// ----------------------------------------------------------------------

class VivresRepasPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garde = gardeCantine(
      ref,
      'Vivres et repas',
      droits: const {'cantine'},
    );
    if (garde != null) return garde;
    Widget bouton(IconData i, String t, String route) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BigButton(icon: i, label: t, onPressed: () => context.push(route)),
    );
    return EcoleScaffold(
      title: 'Vivres et repas',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          bouton(
            Icons.fact_check_outlined,
            'Pointage des repas',
            '/cantine/pointage',
          ),
          bouton(Icons.inventory_outlined, 'Stock de vivres', '/cantine/stock'),
          bouton(
            Icons.menu_book_outlined,
            'Menus de la semaine',
            '/cantine/menus',
          ),
          bouton(
            Icons.shopping_basket_outlined,
            'Dépenses de cantine',
            '/cantine/depenses',
          ),
          bouton(
            Icons.summarize_outlined,
            'Rapports et bilan mensuel',
            '/cantine/rapports',
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Réglages
// ----------------------------------------------------------------------

class ReglagesCantinePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ReglagesCantinePage> createState() => _ReglagesState();
}

class _ReglagesState extends ConsumerState<ReglagesCantinePage> {
  final _tarif = TextEditingController();
  final _jour = TextEditingController();
  final _definition = TextEditingController();
  late Set<String> _mois;
  String? _aPartirDe;
  bool _charge = false;

  @override
  void dispose() {
    _tarif.dispose();
    _jour.dispose();
    _definition.dispose();
    super.dispose();
  }

  /// Les 12 mois de l'année scolaire (septembre à août).
  List<String> _douzeMois(String annee) {
    final d = int.tryParse(annee.substring(0, 4)) ?? DateTime.now().year;
    return [
      for (final m in [9, 10, 11, 12]) '$d-${m.toString().padLeft(2, '0')}-01',
      for (final m in [1, 2, 3, 4, 5, 6, 7, 8])
        '${d + 1}-${m.toString().padLeft(2, '0')}-01',
    ];
  }

  Future<void> _enregistrer(_Cantine c) async {
    final ok = await avecMessage(context, () async {
      final repo = ref.read(cantineRepositoryProvider);
      final jour = _jour.text.trim().isEmpty ? null : int.tryParse(_jour.text);
      if (_jour.text.trim().isNotEmpty && jour == null) {
        throw const UserMessage('Jour limite : un nombre de 1 à 31.');
      }
      await repo.enregistrerAnnee(
        schoolId: c.ecole.id,
        yearId: c.annee.id,
        mois: _mois.toList(),
        jourLimite: jour,
      );
      if (_tarif.text.trim().isNotEmpty) {
        final t = lireMontant(_tarif.text);
        if (t == null) throw const UserMessage('Tarif : nombre attendu.');
        final tarifs = ref.read(tarifsProvider(c.annee.id)).value ?? const [];
        final depuis = _aPartirDe ?? (_mois.toList()..sort()).first;
        if (tarifDuMois(tarifs, depuis) != t) {
          await repo.fixerTarif(
            schoolId: c.ecole.id,
            yearId: c.annee.id,
            aPartirDe: depuis,
            montant: t,
          );
        }
      }
      await repo.enregistrerReglages(
        schoolId: c.ecole.id,
        mode: 'avec_participation',
        definition: _definition.text,
      );
      return true;
    });
    if (ok != true || !mounted) return;
    unawaited(ref.read(syncEngineProvider).syncNow());
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Réglages enregistrés.')));
  }

  @override
  Widget build(BuildContext context) {
    final garde = gardeCantine(ref, 'Réglages de la cantine');
    if (garde != null) return garde;
    final c = _cantine(ref);
    final tarifs = c == null
        ? null
        : ref.watch(tarifsProvider(c.annee.id)).value;
    final annee = c == null
        ? null
        : ref.watch(anneeCantineProvider(c.annee.id));
    final reglages = c == null
        ? null
        : ref.watch(reglagesCantineProvider(c.ecole.id));
    if (c == null ||
        tarifs == null ||
        annee == null ||
        !annee.hasValue ||
        reglages == null ||
        !reglages.hasValue) {
      return _chargement('Réglages de la cantine');
    }
    final douze = _douzeMois(c.annee.label);
    if (!_charge) {
      _charge = true;
      _mois = {...c.mois};
      _jour.text = annee.value?.dueDay == null ? '' : '${annee.value!.dueDay}';
      _definition.text = reglages.value?.localDefinition ?? '';
      final courant = moisCourant(c.mois, ref.read(aujourdhuiProvider));
      final t = tarifDuMois(tarifs, courant);
      _tarif.text = t == null ? '' : '$t';
      _aPartirDe = tarifs.isEmpty ? null : courant;
    }
    final choix = _mois.toList()..sort();
    return EcoleScaffold(
      title: 'Réglages de la cantine',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Année scolaire ${c.annee.label}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ChampMontant(
            key: const Key('tarif-mensuel'),
            controller: _tarif,
            label: 'Tarif mensuel (FCFA)',
          ),
          if (choix.isNotEmpty)
            DropdownButton<String>(
              key: const Key('tarif-depuis'),
              isExpanded: true,
              value: choix.contains(_aPartirDe) ? _aPartirDe : choix.first,
              items: [
                for (final m in choix)
                  DropdownMenuItem(
                    value: m,
                    child: Text('Applicable dès ${libelleMoisCantine(m)}'),
                  ),
              ],
              onChanged: (v) => setState(() => _aPartirDe = v),
            ),
          if (tarifs.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Tarifs : ${tarifs.map((t) => '${fcfa(t.amount)} dès '
                  '${libelleMoisCantine(t.fromMonth)}').join(' ; ')}. '
              'Les mois déjà abonnés gardent leur montant.',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          const SectionTitle('Mois de fonctionnement'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final m in douze)
                FilterChip(
                  key: Key('fonctionne-${m.substring(0, 7)}'),
                  label: Text(libelleMoisCantine(m, annee: false)),
                  selected: _mois.contains(m),
                  onSelected: (v) =>
                      setState(() => v ? _mois.add(m) : _mois.remove(m)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('jour-limite'),
            controller: _jour,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Jour limite de paiement (facultatif, ex. 5)',
              helperText: 'Le mois se paie avant ce jour du mois.',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('definition-cantine'),
            controller: _definition,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ce que l’école appelle « cantine endogène »',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Réductions et exonérations : « Situation et historique » → '
            'l’élève → « Réduction / exonération ».',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          BigButton(
            key: const Key('enregistrer-reglages'),
            icon: Icons.save,
            label: 'Enregistrer',
            onPressed: () => _enregistrer(c),
          ),
        ],
      ),
    );
  }
}
