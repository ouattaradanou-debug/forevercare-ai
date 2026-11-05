import 'dart:async';
import 'dart:io';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/app/theme.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/tableau.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart'
    show rubriqueCantine;
import 'package:ecoleplus/features/cantine/presentation/cantine_providers.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/finances/pdf/pdf_finances.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/presentation/classement_page.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

/// Partage d'un texte (relance) : WhatsApp, SMS… choisis par la personne ;
/// jamais envoyé automatiquement. Remplacé dans les tests.
final partagerTexteProvider = Provider<Future<void> Function(String texte)>(
  (ref) => (texte) async {
    await SharePlus.instance.share(ShareParams(text: texte));
  },
);

/// École et année en cours (null tant qu'elles ne sont pas chargées).
(SchoolRow, SchoolYearRow)? contexteFinances(WidgetRef ref) {
  final session = ref.watch(sessionProvider).value;
  if (session == null) return null;
  final ecole = ref.watch(schoolProvider(session.schoolId)).value;
  final annees = ref.watch(yearsProvider(session.schoolId)).value;
  final annee = annees
      ?.where((y) => y.id == ecole?.currentSchoolYearId)
      .firstOrNull;
  if (ecole == null || annee == null) return null;
  return (ecole, annee);
}

Widget _chargement(String titre) =>
    EcoleScaffold(title: titre, body: const LinearProgressIndicator());

/// Lit un montant tapé (« 25 000 », « 25000 ») ; null si invalide.
int? lireMontant(String texte) =>
    int.tryParse(texte.replaceAll(RegExp(r'[\s .]'), ''));

/// « 12/10/2026 à 09:15 » (heure du téléphone).
String dateHeure(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return iso;
  String z(int n) => n.toString().padLeft(2, '0');
  return '${z(d.day)}/${z(d.month)}/${d.year} à ${z(d.hour)}:${z(d.minute)}';
}

String dateCourte(String iso) {
  final d = iso.length >= 10 ? iso.substring(0, 10).split('-') : null;
  return d == null || d.length < 3 ? iso : '${d[2]}/${d[1]}/${d[0]}';
}

// ----------------------------------------------------------------------
// Présentation en tableaux (A24)
// ----------------------------------------------------------------------

/// Élèves regroupés par classe, dans l'ordre des classes (les élèves sans
/// classe à la fin).
List<(String, List<LigneEleve>)> parClasse(
  List<LigneEleve> eleves,
  List<ClassRow> classes,
) {
  final groupes = <(String, List<LigneEleve>)>[
    for (final k in classes)
      (
        k.name,
        [
          for (final l in eleves)
            if (l.eleve.classe?.id == k.id) l,
        ],
      ),
  ];
  final sans = [
    for (final l in eleves)
      if (l.eleve.classe == null ||
          !classes.any((k) => k.id == l.eleve.classe!.id))
        l,
  ];
  return [
    for (final g in groupes)
      if (g.$2.isNotEmpty) g,
    if (sans.isNotEmpty) ('Sans classe', sans),
  ];
}

/// Montant restant : en rouge s'il reste à payer.
Widget montantRestant(BuildContext context, int reste, {Key? key}) => Text(
  fcfa(reste),
  key: key,
  style: reste > 0
      ? TextStyle(
          color: CouleursFinances.de(context).rouge,
          fontWeight: FontWeight.w700,
        )
      : null,
);

/// Montant restant, ou « SOLDÉ » en vert quand tout est payé.
Widget restantOuSolde(BuildContext context, int reste, int du, {Key? key}) {
  if (du == 0) {
    return Text(
      'Aucun frais',
      key: key,
      style: TextStyle(color: Theme.of(context).colorScheme.outline),
    );
  }
  return reste == 0
      ? MentionSolde(key: key)
      : montantRestant(context, reste, key: key);
}

/// Statut d'un élève : « SOLDÉ » (vert), « Partiellement payé »,
/// « Impayé » (rouge).
Widget statutEleve(BuildContext context, StatutEleve s, {Key? key}) {
  final c = CouleursFinances.de(context);
  return switch (s) {
    StatutEleve.solde => MentionSolde(key: key),
    StatutEleve.partiel => Text(
      'Partiellement payé',
      key: key,
      style: TextStyle(color: c.orange, fontWeight: FontWeight.w600),
    ),
    StatutEleve.impaye => Text(
      'Impayé',
      key: key,
      style: TextStyle(color: c.rouge, fontWeight: FontWeight.w600),
    ),
    StatutEleve.aucunFrais => Text(
      'Aucun frais',
      key: key,
      style: TextStyle(color: Theme.of(context).colorScheme.outline),
    ),
  };
}

/// Tableau de synthèse : montant dû, encaissé, restant, élèves impayés,
/// taux de recouvrement.
class TableauSynthese extends StatelessWidget {
  const new(this.s, {this.titre, super.key});
  final Synthese s;
  final String? titre;

  @override
  Widget build(BuildContext context) => TableauDonnees(
    titre: titre,
    colonnes: const [
      ColonneTableau('Montant dû', montant: true, largeurMin: 110),
      ColonneTableau('Montant encaissé', montant: true, largeurMin: 120),
      ColonneTableau('Montant restant', montant: true, largeurMin: 116),
      ColonneTableau('Élèves impayés', montant: true, largeurMin: 104),
      ColonneTableau('Taux de recouvrement', montant: true, largeurMin: 124),
    ],
    lignes: [
      LigneTableau([
        Text(fcfa(s.du), key: const Key('synthese-du')),
        Text(fcfa(s.encaisse), key: const Key('synthese-encaisse')),
        montantRestant(context, s.restant, key: const Key('synthese-restant')),
        Text(
          '${s.nbImpayes} élève${s.nbImpayes > 1 ? 's' : ''}',
          key: const Key('synthese-impayes'),
        ),
        Text(texteTaux(s.taux), key: const Key('synthese-taux')),
      ]),
    ],
  );
}

// ----------------------------------------------------------------------
// Accueil des finances
// ----------------------------------------------------------------------

class FinancesPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Finances');
    final (ecole, annee) = c;
    final jour = ref.watch(aujourdhuiProvider);
    final paiements = ref.watch(paiementsProvider(annee.id)).value ?? const [];
    final depenses = ref.watch(depensesProvider(annee.id)).value ?? const [];
    final situations = ref.watch(situationsProvider((ecole.id, annee.id)));
    final duJour = paiements
        .where((x) => x.paidAt.startsWith(jour) || _jourLocal(x) == jour)
        .fold<int>(0, (s, x) => s + x.amount);
    final mois = jour.substring(0, 7);
    final journal = journalCaisse(
      paiements: paiements,
      depenses: depenses,
      nomEleve: (_) => '',
    );
    final impayes =
        situations?.where((l) => l.situation.impaye > 0).toList() ?? const [];
    Widget chiffre(String titre, String valeur, {Key? key}) => Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                valeur,
                key: key,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
    Widget bouton(IconData i, String t, String route) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BigButton(icon: i, label: t, onPressed: () => context.push(route)),
    );
    return EcoleScaffold(
      title: 'Finances',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Année scolaire ${annee.label} • montants en FCFA'),
          const SizedBox(height: 8),
          Row(
            children: [
              chiffre(
                'Encaissé aujourd’hui',
                fcfa(duJour),
                key: const Key('encaisse-jour'),
              ),
              chiffre(
                'Caisse (espèces)',
                fcfa(solde(journal, mode: 'especes')),
                key: const Key('solde-especes'),
              ),
            ],
          ),
          Row(
            children: [
              chiffre(
                'Encaissé ce mois',
                fcfa(
                  paiements
                      .where((x) => _jourLocal(x).startsWith(mois))
                      .fold<int>(0, (s, x) => s + x.amount),
                ),
              ),
              chiffre(
                'Impayés (${impayes.length} élève'
                '${impayes.length > 1 ? 's' : ''})',
                fcfa(impayes.fold<int>(0, (s, l) => s + l.situation.impaye)),
                key: const Key('total-impayes'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          bouton(Icons.point_of_sale, 'Encaisser', '/finances/encaisser'),
          bouton(
            Icons.people_outline,
            'Situation des élèves',
            '/finances/eleves',
          ),
          bouton(
            Icons.warning_amber,
            'Impayés et relances',
            '/finances/impayes',
          ),
          bouton(Icons.receipt_long, 'Reçus', '/finances/recus'),
          bouton(
            Icons.shopping_cart_outlined,
            'Dépenses',
            '/finances/depenses',
          ),
          bouton(
            Icons.account_balance_wallet,
            'Caisse et clôture',
            '/finances/caisse',
          ),
          bouton(
            Icons.summarize_outlined,
            'Rapports (PDF, Excel)',
            '/finances/rapports',
          ),
          const SectionTitle('Paramétrage'),
          bouton(
            Icons.table_chart_outlined,
            'Grille des frais',
            '/finances/grille',
          ),
          bouton(Icons.percent, 'Remises', '/finances/remises'),
          const InfoMessage(
            'Un reçu ou une dépense n’est jamais modifié ni supprimé : une '
            'erreur se corrige par une annulation motivée, visible dans le '
            'journal d’activité.',
            icon: Icons.verified_user_outlined,
          ),
        ],
      ),
    );
  }
}

String _jourLocal(PaymentRow x) {
  final d = DateTime.tryParse(x.paidAt)?.toLocal();
  return d == null ? x.paidAt : d.toIso8601String().substring(0, 10);
}

// ----------------------------------------------------------------------
// Encaissement
// ----------------------------------------------------------------------

/// Couleurs discrètes des statuts (payé, partiel, impayé).
(Color, Color, String) couleursStatut(BuildContext context, Statut s) {
  final sombre = Theme.of(context).brightness == Brightness.dark;
  return switch (s) {
    Statut.paye => (
      sombre ? const Color(0xFF1E4620) : Charte.vertPale,
      sombre ? const Color(0xFFA8DAB5) : Charte.vert,
      'Payé',
    ),
    Statut.partiel => (
      sombre ? const Color(0xFF4A3B12) : Charte.ambrePale,
      sombre ? const Color(0xFFF3D28A) : Charte.ambre,
      'Partiel',
    ),
    Statut.impaye => (
      sombre ? const Color(0xFF4A1F1F) : Charte.rougePale,
      sombre ? const Color(0xFFF2B8B5) : Charte.rouge,
      'Impayé',
    ),
  };
}

Widget pastilleStatut(BuildContext context, Statut s) {
  final (fond, texte, libelle) = couleursStatut(context, s);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: fond,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      libelle,
      style: TextStyle(color: texte, fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );
}

/// Encaissement en un seul tableau (A23) : choix de l'élève (classe,
/// recherche), rubriques à cocher, montant proposé = reste dû (jamais
/// plus), mode et payeur, récapitulatif puis « Valider l'encaissement ».
class EncaissementPage extends ConsumerStatefulWidget {
  const new({this.eleveId, super.key});
  final String? eleveId;

  @override
  ConsumerState<EncaissementPage> createState() => _EncaissementState();
}

class _EncaissementState extends ConsumerState<EncaissementPage> {
  String? _eleve;
  String? _classe;
  String _mode = 'especes';
  final _modeLibre = TextEditingController();
  final _reference = TextEditingController();
  final _payeur = TextEditingController();
  final _telephone = TextEditingController();
  final _recherche = TextEditingController();
  final _montantLibre = TextEditingController();

  /// Rubriques cochées : clé du versement → montant à encaisser.
  final _coches = <String, TextEditingController>{};
  List<String> _modesConnus = const [];
  bool _occupe = false;

  /// Recette sans élève (fonds de caisse, don, location…).
  bool get _sansEleve => _eleve == '';

  @override
  void initState() {
    super.initState();
    _eleve = widget.eleveId;
    unawaited(() async {
      final m = await ref.read(financesRepositoryProvider).modesLibres();
      if (mounted) setState(() => _modesConnus = m);
    }());
  }

  @override
  void dispose() {
    for (final c in [
      _modeLibre,
      _reference,
      _payeur,
      _telephone,
      _recherche,
      _montantLibre,
      ..._coches.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _choisirEleve(String? id) => setState(() {
    _eleve = id;
    for (final c in _coches.values) {
      c.dispose();
    }
    _coches.clear();
  });

  void _cocher(VersementSituation v, bool oui) => setState(() {
    if (oui) {
      _coches[v.cle] = TextEditingController(text: '${v.reste}')
        ..addListener(() => setState(() {}));
    } else {
      _coches.remove(v.cle)?.dispose();
    }
  });

  int _montant(String cle) => lireMontant(_coches[cle]?.text ?? '') ?? 0;

  int get _totalCoche => _coches.keys.fold(0, (s, k) => s + _montant(k));

  String get _libelleModeChoisi =>
      _mode == 'autre' ? _modeLibre.text.trim() : libelleMode(_mode);

  Future<void> _valider(
    SchoolRow ecole,
    SchoolYearRow annee,
    LigneEleve l,
  ) async {
    final choix = [
      for (final v in l.situation.versements)
        if (_coches.containsKey(v.cle)) (v, _montant(v.cle)),
    ];
    // Contrôles avant le récapitulatif (les mêmes sont refaits à
    // l'enregistrement).
    String? erreur;
    if (choix.isEmpty) erreur = 'Cochez au moins une rubrique.';
    for (final (v, m) in choix) {
      if (m <= 0) erreur ??= '« ${v.libelle} » : montant à indiquer.';
      if (m > v.reste) {
        erreur ??=
            '« ${v.libelle} » : ${fcfa(m)} dépasse le reste dû '
            '(${fcfa(v.reste)}).';
      }
      if (!v.partielAutorise && m != v.reste) {
        erreur ??= '« ${v.libelle} » se règle en une fois : ${fcfa(v.reste)}.';
      }
    }
    if (_mode == 'autre' && _modeLibre.text.trim().isEmpty) {
      erreur ??= 'Précisez le mode de paiement.';
    }
    if (erreur != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(erreur)));
      return;
    }
    final total = choix.fold<int>(0, (s, c) => s + c.$2);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Récapitulatif'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.nom, style: Theme.of(ctx).textTheme.titleMedium),
              Text(l.classe),
              const Divider(),
              for (final (v, m) in choix)
                Row(
                  children: [
                    Expanded(child: Text(_libelleLigne(v))),
                    Text(fcfa(m)),
                  ],
                ),
              const Divider(),
              Row(
                children: [
                  const Expanded(child: Text('Total encaissé')),
                  Text(
                    fcfa(total),
                    key: const Key('recap-total'),
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Mode : $_libelleModeChoisi'),
              if (_payeur.text.trim().isNotEmpty)
                Text('Payeur : ${_payeur.text.trim()}'),
              Text('Date : ${dateHeure(ref.read(clockProvider).nowIso())}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Corriger'),
          ),
          FilledButton(
            key: const Key('valider-encaissement'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('VALIDER L’ENCAISSEMENT'),
          ),
        ],
      ),
    );
    if (!(ok ?? false) || !mounted) return;
    setState(() => _occupe = true);
    final r = await avecMessage(
      context,
      () => ref
          .read(financesRepositoryProvider)
          .encaisserRubriques(
            schoolId: ecole.id,
            yearId: annee.id,
            studentId: l.eleve.eleve.id,
            choix: choix,
            mode: _mode,
            libelleMode: _modeLibre.text,
            reference: _reference.text,
            payeur: _payeur.text,
            telephone: _telephone.text,
          ),
    );
    if (!mounted) return;
    setState(() => _occupe = false);
    if (r == null) return;
    unawaited(ref.read(syncEngineProvider).syncNow());
    context.pushReplacement('/finances/recu/${r.id}');
  }

  Future<void> _encaisserSansEleve(SchoolRow ecole, SchoolYearRow annee) async {
    final montant = lireMontant(_montantLibre.text);
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tapez le montant en chiffres.')),
      );
      return;
    }
    setState(() => _occupe = true);
    final r = await avecMessage(
      context,
      () => ref
          .read(financesRepositoryProvider)
          .encaisser(
            schoolId: ecole.id,
            yearId: annee.id,
            studentId: null,
            rubric: rubriqueAutre,
            feeItemId: null,
            montant: montant,
            mode: _mode,
            reference: _reference.text,
            payeur: _payeur.text,
          ),
    );
    if (!mounted) return;
    setState(() => _occupe = false);
    if (r == null) return;
    unawaited(ref.read(syncEngineProvider).syncNow());
    context.pushReplacement('/finances/recu/${r.id}');
  }

  static String _libelleLigne(VersementSituation v) =>
      v.tranche == null || v.libelle == v.ligne.label
      ? v.ligne.label
      : v.ligne.rubric == 'scolarite'
      ? v.libelle
      : '${v.ligne.label} — ${v.libelle}';

  @override
  Widget build(BuildContext context) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Encaisser');
    final (ecole, annee) = c;
    final lignes = ref.watch(situationsProvider((ecole.id, annee.id)));
    if (lignes == null) return _chargement('Encaisser');
    final eleve = lignes.where((l) => l.eleve.eleve.id == _eleve).firstOrNull;
    return EcoleScaffold(
      title: 'Encaisser',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MentionFcfa(),
          if (_sansEleve)
            ..._sansEleveVue(ecole, annee)
          else if (eleve == null)
            ..._choixEleve(lignes, annee)
          else ...[
            _enteteEleve(context, eleve),
            const SizedBox(height: 8),
            _tableau(context, eleve),
            const SizedBox(height: 8),
            ..._infosPaiement(context),
            const SizedBox(height: 12),
            BigButton(
              icon: Icons.point_of_sale,
              label: 'Encaisser ${fcfa(_totalCoche)}',
              onPressed: _occupe ? null : () => _valider(ecole, annee, eleve),
            ),
            const SizedBox(height: 6),
            const Text(
              'Le numéro du reçu est définitif tout de suite, même sans '
              'Internet.',
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _choixEleve(List<LigneEleve> lignes, SchoolYearRow annee) {
    final classes = ref.watch(classesProvider(annee.id)).value ?? const [];
    final q = _recherche.text.trim().toLowerCase();
    final visibles = [
      for (final l in lignes)
        if ((_classe == null || l.eleve.classe?.id == _classe) &&
            (q.isEmpty || l.nom.toLowerCase().contains(q)))
          l,
    ];
    return [
      const Text('Classe'),
      Wrap(
        spacing: 6,
        children: [
          ChoiceChip(
            key: const Key('encaisser-toutes'),
            label: const Text('Toutes les classes'),
            selected: _classe == null,
            onSelected: (_) => setState(() => _classe = null),
          ),
          for (final k in classes)
            ChoiceChip(
              key: Key('encaisser-classe-${k.id}'),
              label: Text(k.name),
              selected: _classe == k.id,
              onSelected: (_) => setState(() => _classe = k.id),
            ),
        ],
      ),
      const SizedBox(height: 8),
      TextField(
        key: const Key('recherche-eleve'),
        controller: _recherche,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Nom ou prénom de l’élève',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 8),
      for (final (classe, groupe) in parClasse(visibles, classes))
        TableauDonnees(
          titre: classe,
          colonnes: const [
            ColonneTableau(
              'Nom et prénom de l’élève',
              flex: 5,
              largeurMin: 170,
            ),
            ColonneTableau('Reste à payer', flex: 3, montant: true),
            ColonneTableau('Statut', flex: 3, centre: true, largeurMin: 130),
          ],
          lignes: [
            for (final l in groupe)
              LigneTableau([
                Text(l.nom, key: Key('choisir-${l.eleve.eleve.id}')),
                montantRestant(context, l.situation.reste),
                statutEleve(context, l.situation.statut),
              ], onTap: () => _choisirEleve(l.eleve.eleve.id)),
          ],
        ),
      if (visibles.isEmpty) const Text('Aucun élève.'),
      const Divider(),
      TextButton(
        onPressed: () => _choisirEleve(''),
        child: const Text(
          'Recette sans élève (fonds de caisse, don, location…)',
        ),
      ),
    ];
  }

  Widget _enteteEleve(BuildContext context, LigneEleve l) {
    final s = l.situation;
    final t = Theme.of(context).textTheme;
    Widget chiffre(String titre, int m, {Key? key, Color? couleur}) => Expanded(
      child: Column(
        children: [
          Text(titre, style: t.labelMedium),
          Text(
            fcfa(m),
            key: key,
            style: t.titleMedium?.copyWith(color: couleur),
          ),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.nom, style: t.titleMedium),
                      Text(l.classe),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _choisirEleve(null),
                  child: const Text('Changer'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                chiffre('Total des frais', s.du, key: const Key('frais-eleve')),
                chiffre('Déjà payé', s.paye, key: const Key('paye-eleve')),
                chiffre(
                  'Reste à payer',
                  s.reste,
                  key: const Key('reste-encaisser'),
                  couleur: s.reste == 0 ? null : Charte.rouge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableau(BuildContext context, LigneEleve l) {
    final versements = [
      for (final v in l.situation.versements)
        if (v.du > 0 || v.paye > 0) v,
    ];
    if (versements.isEmpty) {
      return const InfoMessage(
        'Aucun frais pour la classe de cet élève : complétez la grille des '
        'frais.',
      );
    }
    final large = MediaQuery.sizeOf(context).width >= 720;
    final t = Theme.of(context).textTheme;
    Widget montantChamp(VersementSituation v) {
      final ctl = _coches[v.cle];
      return TextField(
        key: Key('a-encaisser-${v.cle}'),
        controller: ctl,
        enabled: ctl != null && v.partielAutorise,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          hintText: ctl == null ? '—' : null,
          helperText: ctl != null && !v.partielAutorise ? 'En une fois' : null,
          errorText: ctl != null && _montant(v.cle) > v.reste
              ? 'Max ${fcfa(v.reste)}'
              : null,
        ),
      );
    }

    Widget ligne(VersementSituation v) {
      final paye = v.statut == Statut.paye;
      final case_ = Checkbox(
        key: Key('cocher-${v.cle}'),
        value: _coches.containsKey(v.cle),
        onChanged: paye ? null : (x) => _cocher(v, x ?? false),
      );
      final nom = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_libelleLigne(v), style: t.titleSmall),
          Row(
            children: [
              pastilleStatut(context, v.statut),
              if (v.echeance != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'avant le ${dateCourte(v.echeance!)}',
                    style: t.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      );
      if (large) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 48, child: case_),
              Expanded(flex: 4, child: nom),
              Expanded(flex: 2, child: Text(fcfa(v.du))),
              Expanded(flex: 2, child: Text(fcfa(v.paye))),
              Expanded(
                flex: 2,
                child: Text(
                  fcfa(v.reste),
                  style: t.titleSmall?.copyWith(
                    color: v.reste == 0 ? null : Charte.rouge,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: paye ? const Text('—') : montantChamp(v),
              ),
            ],
          ),
        );
      }
      return Card(
        key: Key('ligne-encaisser-${v.cle}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 10, 8),
          child: Column(
            children: [
              Row(
                children: [
                  case_,
                  Expanded(child: nom),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Dû ${fcfa(v.du)}\nPayé ${fcfa(v.paye)}\n'
                        'Reste ${fcfa(v.reste)}',
                        style: t.bodySmall,
                      ),
                    ),
                    if (!paye) SizedBox(width: 140, child: montantChamp(v)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (large)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(flex: 4, child: Text('Rubrique', style: t.labelLarge)),
                Expanded(
                  flex: 2,
                  child: Text('Montant dû', style: t.labelLarge),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Déjà payé', style: t.labelLarge),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Reste à payer', style: t.labelLarge),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Montant à encaisser', style: t.labelLarge),
                ),
              ],
            ),
          ),
        for (final v in versements) ligne(v),
      ],
    );
  }

  List<Widget> _infosPaiement(BuildContext context) => [
    const SectionTitle('Paiement'),
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
    if (_mode == 'autre') ...[
      const SizedBox(height: 8),
      TextField(
        key: const Key('mode-libre'),
        controller: _modeLibre,
        decoration: const InputDecoration(
          labelText: 'Préciser le mode (ex. Wave, Coris Money)',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      if (_modesConnus.isNotEmpty)
        Wrap(
          spacing: 6,
          children: [
            for (final m in _modesConnus)
              ActionChip(
                label: Text(m),
                onPressed: () => setState(() => _modeLibre.text = m),
              ),
          ],
        ),
    ],
    const SizedBox(height: 10),
    TextField(
      key: const Key('payeur'),
      controller: _payeur,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Nom et prénom du payeur',
        border: OutlineInputBorder(),
      ),
    ),
    const SizedBox(height: 8),
    Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('telephone-payeur'),
            controller: _telephone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Téléphone (facultatif)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            key: const Key('reference'),
            controller: _reference,
            decoration: const InputDecoration(
              labelText: 'Référence (facultatif)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    ),
  ];

  List<Widget> _sansEleveVue(SchoolRow ecole, SchoolYearRow annee) => [
    Card(
      child: ListTile(
        leading: const Icon(Icons.savings_outlined),
        title: const Text('Recette sans élève'),
        subtitle: const Text('Fonds de caisse, don, location…'),
        trailing: TextButton(
          onPressed: () => _choisirEleve(null),
          child: const Text('Changer'),
        ),
      ),
    ),
    const SizedBox(height: 8),
    TextField(
      key: const Key('montant'),
      controller: _montantLibre,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Montant reçu (FCFA)',
        border: OutlineInputBorder(),
      ),
    ),
    ..._infosPaiement(context),
    const SizedBox(height: 12),
    BigButton(
      icon: Icons.check,
      label: 'Encaisser et faire le reçu',
      onPressed: _occupe ? null : () => _encaisserSansEleve(ecole, annee),
    ),
  ];
}

// ----------------------------------------------------------------------
// Reçu
// ----------------------------------------------------------------------

/// Données du reçu à imprimer (école, élève, reste à payer…).
Future<DonneesRecu> donneesRecu(WidgetRef ref, PaymentRow x) async {
  final (ecole, annee) = contexteFinances(ref)!;
  final lignes = ref.read(situationsProvider((ecole.id, annee.id))) ?? const [];
  final eleve = lignes
      .where((l) => l.eleve.eleve.id == x.studentId)
      .firstOrNull;
  final grille = ref.read(grilleProvider(annee.id)).value ?? const [];
  final ligne = grille.where((g) => g.id == x.feeItemId).firstOrNull;
  final membres = ref.read(membersProvider(ecole.id)).value ?? const [];
  final par = membres.where((m) => m.userId == x.receivedBy).firstOrNull;
  final paiements = ref.read(paiementsProvider(annee.id)).value ?? const [];
  final annule = paiements
      .where((o) => o.id == x.reversesPaymentId)
      .firstOrNull;
  final detail = [
    for (final a
        in ref.read(detailsProvider(annee.id)).value ??
            const <PaymentAllocationRow>[])
      if (a.paymentId == x.id)
        (a.label ?? libelleRubrique(a.rubric ?? ''), a.amount),
  ];
  final cantine = ref.read(situationsAbonnementProvider((ecole.id, annee.id)));
  final media = ref.read(mediaDirProvider);
  final logo = ecole.logoPath == null || media == null
      ? null
      : File(p.join(media.path, ecole.logoPath));
  return DonneesRecu(
    detail: detail,
    telephonePayeur: x.payerPhone,
    ecole: ecole.name,
    commune: ecole.commune,
    telephone: ecole.phone,
    logo: logo != null && logo.existsSync() ? await logo.readAsBytes() : null,
    numero: x.receiptNumber,
    date: dateHeure(x.paidAt),
    montant: x.amount,
    mode: libelleMode(x.method, x.methodLabel),
    reference: x.reference,
    rubrique:
        ligne?.label ??
        libelleRubrique(x.rubric, ref.read(nomsRubriquesProvider)),
    eleve: eleve?.nom,
    classe: eleve?.classe,
    payeur: x.payerName,
    recuPar: par?.displayName,
    // Reçu de cantine : reste des mois de cantine engagés (A26).
    resteApres: x.rubric == rubriqueCantine
        ? (cantine == null ? null : cantine[x.studentId]?.reste)
        : eleve?.situation.reste,
    annule: annule?.receiptNumber,
    motif: x.reversalReason,
    anneeScolaire: annee.label,
  );
}

/// Sortie d'un reçu : imprimer, télécharger (enregistrer le PDF) ou
/// partager (WhatsApp…).
enum SortieRecu { imprimer, telecharger, partager }

Future<void> sortirRecu(
  BuildContext context,
  WidgetRef ref,
  PaymentRow x, {
  SortieRecu comment = SortieRecu.imprimer,
  bool partager = false,
}) => avecMessage(context, () async {
  final pdf = await pdfRecu(
    await ref.read(policesPdfProvider.future),
    await donneesRecu(ref, x),
  );
  final nom = 'Recu_${x.receiptNumber}.pdf';
  final mode = partager ? SortieRecu.partager : comment;
  final sortie = ref.read(sortiePdfProvider);
  switch (mode) {
    case SortieRecu.imprimer:
      await sortie.imprimer(pdf, nom);
    case SortieRecu.partager:
      await sortie.partager(pdf, nom);
    case SortieRecu.telecharger:
      await ref.read(sortieFichierProvider)(pdf, nom, 'application/pdf');
  }
});

class RecuPage extends ConsumerWidget {
  const new(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contexteFinances(ref);
    final x = ref.watch(paiementProvider(id)).value;
    if (c == null || x == null) return _chargement('Reçu');
    final (_, annee) = c;
    final detail = [
      for (final a
          in ref.watch(detailsProvider(annee.id)).value ??
              const <PaymentAllocationRow>[])
        if (a.paymentId == x.id) a,
    ];
    final paiements = ref.watch(paiementsProvider(annee.id)).value ?? const [];
    final annulation = paiements
        .where((o) => o.reversesPaymentId == x.id)
        .firstOrNull;
    final origine = paiements
        .where((o) => o.id == x.reversesPaymentId)
        .firstOrNull;
    final (ecole, _) = c;
    final eleve =
        (ref.watch(situationsProvider((ecole.id, annee.id))) ??
                const <LigneEleve>[])
            .where((l) => l.eleve.eleve.id == x.studentId)
            .firstOrNull;
    final envoye = x.syncedAt != null;
    return EcoleScaffold(
      title: x.amount < 0
          ? 'Annulation ${x.receiptNumber}'
          : 'Reçu ${x.receiptNumber}',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    x.receiptNumber,
                    key: const Key('numero-recu'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(dateHeure(x.paidAt)),
                  const SizedBox(height: 8),
                  Text(
                    fcfa(x.amount),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(enLettres(x.amount)),
                  const SizedBox(height: 8),
                  if (eleve != null) Text('${eleve.nom} — ${eleve.classe}'),
                  Text(
                    '${libelleMode(x.method, x.methodLabel)}'
                    '${x.reference == null ? '' : ' — réf. ${x.reference}'}',
                  ),
                  for (final a in detail)
                    Text('${a.label ?? ''} : ${fcfa(a.amount)}'),
                  if (x.payerName != null)
                    Text(
                      'Versé par ${x.payerName}'
                      '${x.payerPhone == null ? '' : ' (${x.payerPhone})'}',
                    ),
                  if (origine != null)
                    Text('Annule le reçu ${origine.receiptNumber}'),
                  if (x.reversalReason != null)
                    Text('Motif : ${x.reversalReason}'),
                  const SizedBox(height: 6),
                  Text(
                    envoye
                        ? 'Enregistré sur le serveur.'
                        : 'Pas encore envoyé : il le sera dès que le réseau '
                              'revient (numéro déjà définitif).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          if (annulation != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                key: const Key('recu-annule'),
                leading: const Icon(Icons.block),
                title: Text('Annulé par ${annulation.receiptNumber}'),
                subtitle: Text(annulation.reversalReason ?? ''),
                onTap: () => context.push('/finances/recu/${annulation.id}'),
              ),
            ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.share,
            label: 'Partager par WhatsApp',
            onPressed: () => sortirRecu(context, ref, x, partager: true),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Imprimer'),
                  onPressed: () => sortirRecu(context, ref, x),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('telecharger-recu'),
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger en PDF'),
                  onPressed: () => sortirRecu(
                    context,
                    ref,
                    x,
                    comment: SortieRecu.telecharger,
                  ),
                ),
              ),
            ],
          ),
          if (annulation == null && x.reversesPaymentId == null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              key: const Key('annuler-recu'),
              style: StylesBoutons.danger,
              icon: const Icon(Icons.undo),
              label: const Text('Annuler ce reçu (erreur)'),
              onPressed: () => _annuler(context, ref, x),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _annuler(
    BuildContext context,
    WidgetRef ref,
    PaymentRow x,
  ) async {
    final motif = await demanderMotif(
      context,
      titre: 'Annuler le reçu ${x.receiptNumber} ?',
      explication:
          'Le reçu reste enregistré ; une annulation de ${fcfa(-x.amount)} '
          'est créée avec son propre numéro. Indiquez pourquoi.',
    );
    if (motif == null || !context.mounted) return;
    final a = await avecMessage(
      context,
      () => ref.read(financesRepositoryProvider).annuler(x, motif),
    );
    if (a != null && context.mounted) {
      unawaited(ref.read(syncEngineProvider).syncNow());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Annulation ${a.receiptNumber} enregistrée.')),
      );
    }
  }
}

/// Demande un motif obligatoire (annulation).
Future<String?> demanderMotif(
  BuildContext context, {
  required String titre,
  required String explication,
}) {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(titre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(explication),
            const SizedBox(height: 12),
            TextField(
              key: const Key('motif'),
              controller: c,
              autofocus: true,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Motif (obligatoire)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Retour'),
          ),
          FilledButton(
            onPressed: c.text.trim().isEmpty
                ? null
                : () => Navigator.pop(ctx, c.text.trim()),
            child: const Text('Annuler l’écriture'),
          ),
        ],
      ),
    ),
  );
}

/// Liste des reçus de l'année (les plus récents d'abord).
class RecusPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RecusPage> createState() => _RecusState();
}

class _RecusState extends ConsumerState<RecusPage> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Reçus');
    final (ecole, annee) = c;
    final paiements = ref.watch(paiementsProvider(annee.id)).value ?? const [];
    final rubriques = ref.watch(nomsRubriquesProvider);
    final noms = {
      for (final l
          in ref.watch(situationsProvider((ecole.id, annee.id))) ??
              const <LigneEleve>[])
        l.eleve.eleve.id: l.nom,
    };
    final q = _q.trim().toLowerCase();
    final visibles = [
      for (final x in paiements)
        if (q.isEmpty ||
            x.receiptNumber.toLowerCase().contains(q) ||
            (noms[x.studentId] ?? '').toLowerCase().contains(q))
          x,
    ];
    return EcoleScaffold(
      title: 'Reçus',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MentionFcfa(),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'N° de reçu ou nom de l’élève',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 8),
          TableauDonnees(
            vide: 'Aucun reçu.',
            colonnes: const [
              ColonneTableau('N° de reçu', flex: 3, largeurMin: 130),
              ColonneTableau('Date', flex: 3, largeurMin: 130),
              ColonneTableau('Élève / objet', flex: 4, largeurMin: 150),
              ColonneTableau('Montant', montant: true, largeurMin: 104),
            ],
            lignes: [
              for (final x in visibles)
                LigneTableau([
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          x.receiptNumber,
                          key: Key('recu-${x.receiptNumber}'),
                        ),
                      ),
                      if (x.syncedAt == null)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Tooltip(
                            message: 'À envoyer',
                            child: Icon(Icons.cloud_upload_outlined, size: 16),
                          ),
                        ),
                    ],
                  ),
                  Text(dateHeure(x.paidAt)),
                  Text(
                    noms[x.studentId] ?? libelleRubrique(x.rubric, rubriques),
                  ),
                  Text(
                    fcfa(x.amount),
                    style: x.amount < 0
                        ? TextStyle(color: CouleursFinances.de(context).rouge)
                        : null,
                  ),
                ], onTap: () => context.push('/finances/recu/${x.id}')),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Situation des élèves, impayés, relances
// ----------------------------------------------------------------------

/// Situation des élèves (A24) : synthèse de l'école ou d'une classe, puis
/// la situation de chaque élève, regroupée par classe ; recherche par nom.
class ElevesFinancesPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ElevesFinancesPage> createState() => _ElevesFinancesState();
}

class _ElevesFinancesState extends ConsumerState<ElevesFinancesPage> {
  String? _classe;
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Situation des élèves');
    final (ecole, annee) = c;
    final lignes = ref.watch(situationsProvider((ecole.id, annee.id)));
    if (lignes == null) return _chargement('Situation des élèves');
    final classes =
        ref.watch(classesProvider(annee.id)).value ?? const <ClassRow>[];
    final perimetre = [
      for (final l in lignes)
        if (_classe == null || l.eleve.classe?.id == _classe) l,
    ];
    final q = _q.trim().toLowerCase();
    final visibles = [
      for (final l in perimetre)
        if (q.isEmpty || l.nom.toLowerCase().contains(q)) l,
    ];
    final nomClasse = classes.where((k) => k.id == _classe).firstOrNull?.name;
    return EcoleScaffold(
      title: 'Situation des élèves',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MentionFcfa(),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ChoiceChip(
                key: const Key('situation-ecole'),
                label: const Text('Toute l’école'),
                selected: _classe == null,
                onSelected: (_) => setState(() => _classe = null),
              ),
              for (final k in classes)
                ChoiceChip(
                  key: Key('situation-classe-${k.id}'),
                  label: Text(k.name),
                  selected: _classe == k.id,
                  onSelected: (_) => setState(() => _classe = k.id),
                ),
            ],
          ),
          const SizedBox(height: 4),
          TableauSynthese(
            Synthese.depuis([for (final l in perimetre) l.situation]),
            titre: nomClasse == null
                ? 'Situation financière de l’école'
                : 'Situation financière — $nomClasse',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('recherche-situation'),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Rechercher un élève (nom ou prénom)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
          for (final (classe, groupe) in parClasse(visibles, classes))
            TableauDonnees(
              titre: classe,
              colonnes: const [
                ColonneTableau('Nom et prénom', flex: 5, largeurMin: 170),
                ColonneTableau('Montant total', flex: 3, montant: true),
                ColonneTableau('Montant payé', flex: 3, montant: true),
                ColonneTableau(
                  'Montant restant',
                  flex: 3,
                  montant: true,
                  largeurMin: 110,
                ),
              ],
              lignes: [
                for (final l in groupe)
                  LigneTableau(
                    [
                      Text(
                        l.nom,
                        key: Key('situation-${l.eleve.eleve.id}'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(fcfa(l.situation.du)),
                      Text(fcfa(l.situation.encaisse)),
                      restantOuSolde(
                        context,
                        l.situation.reste,
                        l.situation.du,
                      ),
                    ],
                    onTap: () =>
                        context.push('/finances/eleve/${l.eleve.eleve.id}'),
                  ),
              ],
              total: groupe.length < 2
                  ? null
                  : LigneTableau([
                      Text('${groupe.length} élèves'),
                      Text(fcfa(_somme(groupe, (l) => l.situation.du))),
                      Text(fcfa(_somme(groupe, (l) => l.situation.encaisse))),
                      montantRestant(
                        context,
                        _somme(groupe, (l) => l.situation.reste),
                      ),
                    ]),
            ),
          if (visibles.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Aucun élève.'),
            ),
        ],
      ),
    );
  }
}

/// Libellé d'un versement dans les tableaux : « Scolarité – 1er
/// versement », « Assurance ».
String libelleVersement(VersementSituation v) =>
    v.tranche == null || v.libelle == v.ligne.label
    ? v.ligne.label
    : '${v.ligne.label} – ${v.libelle}';

/// Situation financière détaillée d'un élève (A24) : synthèse, puis
/// « FRAIS DE L'ANNÉE » rubrique par rubrique avec un total.
class SituationElevePage extends ConsumerWidget {
  const new(this.eleveId, {super.key});
  final String eleveId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Situation');
    final (ecole, annee) = c;
    final l =
        (ref.watch(situationsProvider((ecole.id, annee.id))) ??
                const <LigneEleve>[])
            .where((x) => x.eleve.eleve.id == eleveId)
            .firstOrNull;
    if (l == null) return _chargement('Situation');
    final paiements = [
      for (final x
          in ref.watch(paiementsProvider(annee.id)).value ??
              const <PaymentRow>[])
        if (x.studentId == eleveId) x,
    ];
    final attributions = [
      for (final a
          in ref.watch(attributionsProvider(annee.id)).value ??
              const <(DiscountRow, StudentDiscountRow)>[])
        if (a.$2.studentId == eleveId) a,
    ];
    final remises = ref.watch(remisesProvider).value ?? const [];
    final repo = ref.read(financesRepositoryProvider);
    final s = l.situation;
    final t = Theme.of(context).textTheme;
    final couleurs = CouleursFinances.de(context);
    final versements = [
      for (final v in s.versements)
        if (v.du > 0 || v.paye > 0) v,
    ];
    Widget statut(VersementSituation v) => v.reste == 0
        ? const MentionSolde()
        : Text(
            v.encaisse > 0
                ? 'Partiel'
                : v.echu
                ? 'En retard'
                : 'Impayé',
            style: TextStyle(
              color: v.encaisse > 0 ? couleurs.orange : couleurs.rouge,
              fontWeight: FontWeight.w600,
            ),
          );
    return EcoleScaffold(
      title: l.nom,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MentionFcfa(),
          TableauDonnees(
            titre: 'Situation financière',
            colonnes: const [
              ColonneTableau('Montant dû', montant: true, largeurMin: 110),
              ColonneTableau(
                'Montant encaissé',
                montant: true,
                largeurMin: 120,
              ),
              ColonneTableau('Montant restant', montant: true, largeurMin: 116),
              ColonneTableau(
                'Montant en retard',
                montant: true,
                largeurMin: 120,
              ),
              ColonneTableau(
                'Autres versements',
                montant: true,
                largeurMin: 124,
              ),
            ],
            lignes: [
              LigneTableau([
                Text(fcfa(s.du), key: const Key('eleve-du')),
                Text(fcfa(s.encaisse), key: const Key('eleve-encaisse')),
                restantOuSolde(
                  context,
                  s.reste,
                  s.du,
                  key: const Key('reste-eleve'),
                ),
                montantRestant(
                  context,
                  s.enRetard,
                  key: const Key('retard-eleve'),
                ),
                Text(fcfa(s.aVenir), key: const Key('a-venir-eleve')),
              ]),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Montant en retard : échéances dépassées non réglées. '
              'Autres versements : reste à payer dont l’échéance n’est pas '
              'encore arrivée.',
              style: t.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'FRAIS DE L’ANNÉE',
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text('${l.nom} • ${l.classe} • année scolaire ${annee.label}'),
          const SizedBox(height: 4),
          if (versements.isEmpty)
            const InfoMessage(
              'Aucun frais pour sa classe : complétez la grille des frais.',
            )
          else
            TableauDonnees(
              colonnes: const [
                ColonneTableau('Rubriques', flex: 5, largeurMin: 180),
                ColonneTableau('Montant total', flex: 3, montant: true),
                ColonneTableau('Montant payé', flex: 3, montant: true),
                ColonneTableau(
                  'Montant restant',
                  flex: 3,
                  montant: true,
                  largeurMin: 110,
                ),
                ColonneTableau('Statut', flex: 3, centre: true),
              ],
              lignes: [
                for (final v in versements)
                  LigneTableau([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(libelleVersement(v)),
                        if (v.echeance != null && v.reste > 0)
                          Text(
                            'avant le ${dateCourte(v.echeance!)}',
                            style: t.bodySmall,
                          ),
                      ],
                    ),
                    Text(fcfa(v.du)),
                    Text(fcfa(v.encaisse)),
                    montantRestant(context, v.reste),
                    statut(v),
                  ]),
              ],
              total: LigneTableau([
                const Text('TOTAL'),
                Text(fcfa(s.du)),
                Text(fcfa(s.encaisse)),
                restantOuSolde(context, s.reste, s.du),
                const SizedBox(),
              ]),
            ),
          if (s.lignes.any((x) => x.reduction > 0))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Montants après remise : '
                '${_remisesTexte(s)}.',
                style: t.bodySmall,
              ),
            ),
          if (s.autresRecettes != 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Recettes hors frais pour cet élève : '
                '${fcfa(s.autresRecettes)}.',
                style: t.bodySmall,
              ),
            ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.point_of_sale,
            label: 'Encaisser',
            onPressed: () => context.push('/finances/encaisser?eleve=$eleveId'),
          ),
          if (s.impaye > 0) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.sms_outlined),
              label: const Text('Préparer une relance'),
              onPressed: () => preparerRelance(context, ref, l),
            ),
          ],
          TableauDonnees(
            titre: 'Reçus',
            vide: 'Aucun versement.',
            colonnes: const [
              ColonneTableau('N° de reçu', flex: 3, largeurMin: 130),
              ColonneTableau('Date', flex: 3, largeurMin: 130),
              ColonneTableau('Montant', montant: true),
            ],
            lignes: [
              for (final x in paiements)
                LigneTableau([
                  Text(x.receiptNumber),
                  Text(dateHeure(x.paidAt)),
                  Text(
                    fcfa(x.amount),
                    style: x.amount < 0
                        ? TextStyle(color: couleurs.rouge)
                        : null,
                  ),
                ], onTap: () => context.push('/finances/recu/${x.id}')),
            ],
          ),
          const SectionTitle('Remises'),
          for (final (r, a) in attributions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.label),
              subtitle: Text(texteRemise(r, ref.watch(nomsRubriquesProvider))),
              trailing: IconButton(
                tooltip: 'Retirer la remise',
                icon: const Icon(Icons.close),
                onPressed: () => repo.retirerAttribution(a.id),
              ),
            ),
          if (remises.isNotEmpty)
            Wrap(
              spacing: 6,
              children: [
                for (final r in remises)
                  if (!attributions.any((a) => a.$1.id == r.id))
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(r.label),
                      onPressed: () => repo.attribuerRemise(
                        schoolId: ecole.id,
                        yearId: annee.id,
                        studentId: eleveId,
                        discountId: r.id,
                      ),
                    ),
              ],
            )
          else
            const Text('Aucune remise définie (Finances → Remises).'),
        ],
      ),
    );
  }
}

String _remisesTexte(SituationEleve s) => [
  for (final x in s.lignes)
    if (x.reduction > 0) '${x.ligne.label} −${fcfa(x.reduction)}',
].join(', ');

int _somme(List<LigneEleve> l, int Function(LigneEleve) f) =>
    l.fold(0, (s, x) => s + f(x));

/// « 10 % sur Scolarité », « 5 000 FCFA sur tous les frais ».
String texteRemise(DiscountRow r, [Map<String, String>? rubriques]) {
  final v = r.kind == 'pourcentage'
      ? '${r.value.toStringAsFixed(r.value % 1 == 0 ? 0 : 1)} %'
      : fcfa(r.value.round());
  return r.rubric == null
      ? '$v sur tous les frais'
      : '$v sur ${libelleRubrique(r.rubric!, rubriques)}';
}

/// Texte de relance : modifiable, puis partagé (WhatsApp, SMS…) par la
/// personne elle-même ; jamais envoyé automatiquement.
Future<void> preparerRelance(
  BuildContext context,
  WidgetRef ref,
  LigneEleve l, {
  String objet = 'la scolarité',
}) async {
  final (ecole, _) = contexteFinances(ref)!;
  final parents = await ref
      .read(studentsRepositoryProvider)
      .watchParents(l.eleve.eleve.id)
      .first;
  final telephones = [
    for (final g in parents)
      if ((g.phone ?? '').isNotEmpty) '${g.fullName} : ${g.phone}',
  ];
  final c = TextEditingController(
    text: messageRelance(
      ecole: ecole.name,
      eleve: l.nom,
      classe: l.classe,
      impaye: l.situation.impaye,
      telephoneEcole: ecole.phone,
      objet: objet,
    ),
  );
  if (!context.mounted) return;
  final texte = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Relance préparée'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (telephones.isEmpty)
              const Text('Aucun numéro de parent sur la fiche de l’élève.')
            else
              for (final t in telephones) Text(t),
            const SizedBox(height: 8),
            TextField(
              key: const Key('texte-relance'),
              controller: c,
              maxLines: 7,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 6),
            const Text(
              'Rien n’est envoyé automatiquement : vous choisissez à qui et '
              'comment (WhatsApp, SMS…).',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Fermer'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, c.text),
          child: const Text('Partager'),
        ),
      ],
    ),
  );
  if (texte != null) await ref.read(partagerTexteProvider)(texte);
}

class ImpayesPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Impayés');
    final (ecole, annee) = c;
    // Scolarité et autres frais ; la cantine a ses propres impayés.
    final lignes = ref.watch(
      situationsHorsCantineProvider((ecole.id, annee.id)),
    );
    if (lignes == null) return _chargement('Impayés');
    final retards = [
      for (final l in lignes)
        if (l.situation.impaye > 0) l,
    ]..sort((a, b) => b.situation.impaye.compareTo(a.situation.impaye));
    return EcoleScaffold(
      title: 'Impayés et relances',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MentionFcfa(),
          Text(
            retards.isEmpty
                ? 'Aucun impayé : toutes les échéances passées sont réglées.'
                : '${retards.length} élève(s) en retard • '
                      '${fcfa(_somme(retards, (l) => l.situation.impaye))}',
            key: const Key('resume-impayes'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Seules les échéances passées comptent. Les bulletins et les '
            'cartes ne dépendent jamais des paiements.',
          ),
          const SizedBox(height: 8),
          for (final (classe, groupe) in parClasse(
            retards,
            ref.watch(classesProvider(annee.id)).value ?? const <ClassRow>[],
          ))
            TableauDonnees(
              titre: classe,
              colonnes: const [
                ColonneTableau('Nom et prénom', flex: 5, largeurMin: 170),
                ColonneTableau('En retard', flex: 3, montant: true),
                ColonneTableau('Reste total', flex: 3, montant: true),
                ColonneTableau('Relance', centre: true, largeurMin: 80),
              ],
              lignes: [
                for (final l in groupe)
                  LigneTableau(
                    [
                      Text(l.nom, key: Key('impaye-${l.eleve.eleve.id}')),
                      montantRestant(context, l.situation.enRetard),
                      Text(fcfa(l.situation.reste)),
                      IconButton(
                        tooltip: 'Préparer une relance',
                        icon: const Icon(Icons.sms_outlined),
                        onPressed: () => preparerRelance(context, ref, l),
                      ),
                    ],
                    onTap: () =>
                        context.push('/finances/eleve/${l.eleve.eleve.id}'),
                  ),
              ],
              total: LigneTableau([
                Text('${groupe.length} élève(s)'),
                montantRestant(
                  context,
                  _somme(groupe, (l) => l.situation.enRetard),
                ),
                Text(fcfa(_somme(groupe, (l) => l.situation.reste))),
                const SizedBox(),
              ]),
            ),
        ],
      ),
    );
  }
}

/// Bouton « Finances » visible ? (directeur, délégué « finances »).
bool voitFinances(WidgetRef ref) =>
    ref.watch(mesDroitsProvider).contains('finances');

/// Message d'erreur lisible pour une valeur absente.
UserMessage manque(String quoi) => UserMessage('Indiquez $quoi.');
