import 'dart:async';
import 'dart:io';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/finances/pdf/pdf_finances.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
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

class EncaissementPage extends ConsumerStatefulWidget {
  const new({this.eleveId, super.key});
  final String? eleveId;

  @override
  ConsumerState<EncaissementPage> createState() => _EncaissementState();
}

class _EncaissementState extends ConsumerState<EncaissementPage> {
  String? _eleve;
  String? _ligne;
  String _rubrique = 'scolarite';
  String _mode = 'especes';
  final _montant = TextEditingController();
  final _reference = TextEditingController();
  final _payeur = TextEditingController();
  final _recherche = TextEditingController();
  bool _occupe = false;

  /// Recette sans élève (fonds de caisse, don, location…).
  bool get _sansEleve => _eleve == '';

  @override
  void initState() {
    super.initState();
    _eleve = widget.eleveId;
  }

  @override
  void dispose() {
    _montant.dispose();
    _reference.dispose();
    _payeur.dispose();
    _recherche.dispose();
    super.dispose();
  }

  Future<void> _encaisser(SchoolRow ecole, SchoolYearRow annee) async {
    final montant = lireMontant(_montant.text);
    if (montant == null) {
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
            studentId: _sansEleve ? null : _eleve,
            rubric: _rubrique,
            feeItemId: _ligne,
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

  @override
  Widget build(BuildContext context) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Encaisser');
    final (ecole, annee) = c;
    final lignes = ref.watch(situationsProvider((ecole.id, annee.id)));
    if (lignes == null) return _chargement('Encaisser');
    final eleve = lignes.where((l) => l.eleve.eleve.id == _eleve).firstOrNull;
    final q = _recherche.text.trim().toLowerCase();
    return EcoleScaffold(
      title: 'Encaisser',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_sansEleve)
            Card(
              child: ListTile(
                leading: const Icon(Icons.savings_outlined),
                title: const Text('Recette sans élève'),
                subtitle: const Text('Fonds de caisse, don, location…'),
                trailing: TextButton(
                  onPressed: () => setState(() => _eleve = null),
                  child: const Text('Changer'),
                ),
              ),
            )
          else if (eleve == null) ...[
            const Text('Pour quel élève ?'),
            const SizedBox(height: 6),
            TextField(
              key: const Key('recherche-eleve'),
              controller: _recherche,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Nom de l’élève',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            for (final l in lignes)
              if (q.isEmpty || l.nom.toLowerCase().contains(q))
                ListTile(
                  key: Key('choisir-${l.eleve.eleve.id}'),
                  title: Text(l.nom),
                  subtitle: Text(
                    '${l.classe} • reste ${fcfa(l.situation.reste)}',
                  ),
                  onTap: () => setState(() => _eleve = l.eleve.eleve.id),
                ),
            const Divider(),
            TextButton(
              onPressed: () => setState(() {
                _eleve = '';
                _rubrique = 'autre';
              }),
              child: const Text(
                'Recette sans élève (fonds de caisse, don, location…)',
              ),
            ),
          ] else ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(eleve.nom),
                subtitle: Text(
                  '${eleve.classe} • dû ${fcfa(eleve.situation.du)} • '
                  'reste ${fcfa(eleve.situation.reste)}',
                ),
                trailing: TextButton(
                  onPressed: () => setState(() {
                    _eleve = null;
                    _ligne = null;
                  }),
                  child: const Text('Changer'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Pour quoi ?'),
            Wrap(
              spacing: 6,
              children: [
                for (final s in eleve.situation.lignes)
                  ChoiceChip(
                    key: Key('ligne-${s.ligne.id}'),
                    label: Text('${s.ligne.label} (reste ${fcfa(s.reste)})'),
                    selected: _ligne == s.ligne.id,
                    onSelected: (v) => setState(() {
                      _ligne = v ? s.ligne.id : null;
                      _rubrique = s.ligne.rubric;
                      if (v && _montant.text.isEmpty && s.reste > 0) {
                        _montant.text = '${s.reste}';
                      }
                    }),
                  ),
                ChoiceChip(
                  label: const Text('Autre'),
                  selected: _ligne == null,
                  onSelected: (_) => setState(() {
                    _ligne = null;
                    _rubrique = 'autre';
                  }),
                ),
              ],
            ),
          ],
          if (_eleve != null) ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('montant'),
              controller: _montant,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Montant reçu (FCFA)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ChoiceField(
              label: 'Mode de paiement',
              value: _mode,
              options: modesPaiement,
              onChanged: (v) => setState(() => _mode = v ?? 'especes'),
            ),
            if (_mode != 'especes')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  key: const Key('reference'),
                  controller: _reference,
                  decoration: InputDecoration(
                    labelText: 'Référence (${libelleMode(_mode)})',
                    helperText: 'N° de transaction, de chèque ou de virement',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            TextField(
              controller: _payeur,
              decoration: const InputDecoration(
                labelText: 'Versé par (facultatif)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            BigButton(
              icon: Icons.check,
              label: 'Encaisser et faire le reçu',
              onPressed: _occupe ? null : () => _encaisser(ecole, annee),
            ),
            const SizedBox(height: 8),
            const Text(
              'Le numéro du reçu est définitif tout de suite, même sans '
              'Internet.',
            ),
          ],
        ],
      ),
    );
  }
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
  final media = ref.read(mediaDirProvider);
  final logo = ecole.logoPath == null || media == null
      ? null
      : File(p.join(media.path, ecole.logoPath));
  return DonneesRecu(
    ecole: ecole.name,
    commune: ecole.commune,
    telephone: ecole.phone,
    logo: logo != null && logo.existsSync() ? await logo.readAsBytes() : null,
    numero: x.receiptNumber,
    date: dateHeure(x.paidAt),
    montant: x.amount,
    mode: libelleMode(x.method),
    reference: x.reference,
    rubrique: ligne?.label ?? libelleRubrique(x.rubric),
    eleve: eleve?.nom,
    classe: eleve?.classe,
    payeur: x.payerName,
    recuPar: par?.displayName,
    resteApres: eleve?.situation.reste,
    annule: annule?.receiptNumber,
    motif: x.reversalReason,
    anneeScolaire: annee.label,
  );
}

Future<void> sortirRecu(
  BuildContext context,
  WidgetRef ref,
  PaymentRow x, {
  required bool partager,
}) => avecMessage(context, () async {
  final pdf = await pdfRecu(
    await ref.read(policesPdfProvider.future),
    await donneesRecu(ref, x),
  );
  final sortie = ref.read(sortiePdfProvider);
  await (partager ? sortie.partager : sortie.imprimer)(
    pdf,
    'Recu_${x.receiptNumber}.pdf',
  );
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
                    '${libelleMode(x.method)}'
                    '${x.reference == null ? '' : ' — réf. ${x.reference}'}',
                  ),
                  if (x.payerName != null) Text('Versé par ${x.payerName}'),
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
            label: 'Partager le reçu (WhatsApp…)',
            onPressed: () => sortirRecu(context, ref, x, partager: true),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Imprimer'),
            onPressed: () => sortirRecu(context, ref, x, partager: false),
          ),
          if (annulation == null && x.reversesPaymentId == null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              key: const Key('annuler-recu'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'N° de reçu ou nom de l’élève',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 8),
          for (final x in visibles)
            Card(
              child: ListTile(
                key: Key('recu-${x.receiptNumber}'),
                leading: Icon(
                  x.amount < 0 ? Icons.undo : Icons.receipt,
                  color: x.amount < 0 ? Colors.red : null,
                ),
                title: Text('${x.receiptNumber} • ${fcfa(x.amount)}'),
                subtitle: Text(
                  '${dateHeure(x.paidAt)} • '
                  '${noms[x.studentId] ?? libelleRubrique(x.rubric)}'
                  '${x.syncedAt == null ? ' • à envoyer' : ''}',
                ),
                onTap: () => context.push('/finances/recu/${x.id}'),
              ),
            ),
          if (visibles.isEmpty) const Text('Aucun reçu.'),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Situation des élèves, impayés, relances
// ----------------------------------------------------------------------

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
    final classes = ref.watch(classesProvider(annee.id)).value ?? const [];
    final q = _q.trim().toLowerCase();
    final visibles = [
      for (final l in lignes)
        if ((_classe == null || l.eleve.classe?.id == _classe) &&
            (q.isEmpty || l.nom.toLowerCase().contains(q)))
          l,
    ];
    final du = visibles.fold<int>(0, (s, l) => s + l.situation.du);
    final paye = visibles.fold<int>(0, (s, l) => s + l.situation.paye);
    return EcoleScaffold(
      title: 'Situation des élèves',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Toute l’école'),
                selected: _classe == null,
                onSelected: (_) => setState(() => _classe = null),
              ),
              for (final k in classes)
                ChoiceChip(
                  label: Text(k.name),
                  selected: _classe == k.id,
                  onSelected: (_) => setState(() => _classe = k.id),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Nom de l’élève',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              key: const Key('totaux-eleves'),
              title: Text(
                'Dû ${fcfa(du)} • payé ${fcfa(paye)} • reste '
                '${fcfa(_somme(visibles, (l) => l.situation.reste))}',
              ),
              subtitle: Text(
                du == 0
                    ? '${visibles.length} élève(s)'
                    : '${visibles.length} élève(s) • recouvrement '
                          '${(paye * 100 / du).round()} %',
              ),
            ),
          ),
          for (final l in visibles)
            ListTile(
              key: Key('situation-${l.eleve.eleve.id}'),
              title: Text(l.nom),
              subtitle: Text(
                '${l.classe} • payé ${fcfa(l.situation.paye)} sur '
                '${fcfa(l.situation.du)}',
              ),
              trailing: l.situation.impaye > 0
                  ? Text(
                      'Retard ${fcfa(l.situation.impaye)}',
                      style: const TextStyle(color: Colors.red),
                    )
                  : l.situation.reste == 0
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : Text('Reste ${fcfa(l.situation.reste)}'),
              onTap: () => context.push('/finances/eleve/${l.eleve.eleve.id}'),
            ),
        ],
      ),
    );
  }
}

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
    return EcoleScaffold(
      title: l.nom,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${l.classe} • année ${annee.label}'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reste à payer : ${fcfa(s.reste)}',
                    key: const Key('reste-eleve'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('Dû ${fcfa(s.du)} • payé ${fcfa(s.paye)}'),
                  if (s.impaye > 0)
                    Text(
                      'En retard (échéances passées) : ${fcfa(s.impaye)}',
                      key: const Key('retard-eleve'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (s.autresRecettes != 0)
                    Text('Autres versements : ${fcfa(s.autresRecettes)}'),
                ],
              ),
            ),
          ),
          const SectionTitle('Frais de l’année'),
          for (final x in s.lignes)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(x.ligne.label),
              subtitle: Text(
                'Dû ${fcfa(x.du)}'
                '${x.reduction > 0 ? ' (remise ${fcfa(x.reduction)})' : ''}'
                ' • payé ${fcfa(x.paye)}',
              ),
              trailing: Text(x.reste == 0 ? 'Soldé' : 'Reste ${fcfa(x.reste)}'),
            ),
          if (s.lignes.isEmpty)
            const Text(
              'Aucun frais pour sa classe : complétez la grille des frais.',
            ),
          const SizedBox(height: 8),
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
          const SectionTitle('Remises'),
          for (final (r, a) in attributions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.label),
              subtitle: Text(texteRemise(r)),
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
          const SectionTitle('Reçus'),
          for (final x in paiements)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(x.amount < 0 ? Icons.undo : Icons.receipt),
              title: Text('${x.receiptNumber} • ${fcfa(x.amount)}'),
              subtitle: Text(dateHeure(x.paidAt)),
              onTap: () => context.push('/finances/recu/${x.id}'),
            ),
          if (paiements.isEmpty) const Text('Aucun versement.'),
        ],
      ),
    );
  }
}

int _somme(List<LigneEleve> l, int Function(LigneEleve) f) =>
    l.fold(0, (s, x) => s + f(x));

/// « 10 % sur Scolarité », « 5 000 FCFA sur tous les frais ».
String texteRemise(DiscountRow r) {
  final v = r.kind == 'pourcentage'
      ? '${r.value.toStringAsFixed(r.value % 1 == 0 ? 0 : 1)} %'
      : fcfa(r.value.round());
  return r.rubric == null
      ? '$v sur tous les frais'
      : '$v sur ${libelleRubrique(r.rubric!)}';
}

/// Texte de relance : modifiable, puis partagé (WhatsApp, SMS…) par la
/// personne elle-même ; jamais envoyé automatiquement.
Future<void> preparerRelance(
  BuildContext context,
  WidgetRef ref,
  LigneEleve l,
) async {
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
    final lignes = ref.watch(situationsProvider((ecole.id, annee.id)));
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
          for (final l in retards)
            Card(
              child: ListTile(
                key: Key('impaye-${l.eleve.eleve.id}'),
                title: Text(l.nom),
                subtitle: Text(
                  '${l.classe} • retard ${fcfa(l.situation.impaye)}',
                ),
                trailing: IconButton(
                  tooltip: 'Préparer une relance',
                  icon: const Icon(Icons.sms_outlined),
                  onPressed: () => preparerRelance(context, ref, l),
                ),
                onTap: () =>
                    context.push('/finances/eleve/${l.eleve.eleve.id}'),
              ),
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
