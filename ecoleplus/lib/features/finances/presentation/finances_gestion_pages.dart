import 'dart:async';
import 'dart:io';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/export/xlsx_ecriture.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/bibliotheque/presentation/bibliotheque_pages.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/finances/pdf/pdf_finances.dart';
import 'package:ecoleplus/features/finances/presentation/finances_pages.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/forms/presentation/apercu_pdf_page.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/presentation/classement_page.dart';
import 'package:ecoleplus/features/photos/presentation/photo_pages.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget _chargement(String titre) =>
    EcoleScaffold(title: titre, body: const LinearProgressIndicator());

/// Champ de montant en FCFA (chiffres seulement).
class ChampMontant extends StatelessWidget {
  const new({
    required this.controller,
    this.label = 'Montant (FCFA)',
    super.key,
  });
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

// ----------------------------------------------------------------------
// Grille des frais
// ----------------------------------------------------------------------

class GrillePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Grille des frais');
    final (_, annee) = c;
    final grille = ref.watch(grilleProvider(annee.id)).value ?? const [];
    final classes = {
      for (final k
          in ref.watch(classesProvider(annee.id)).value ?? const <ClassRow>[])
        k.id: k.name,
    };
    final tranches =
        ref.watch(tranchesProvider).value ?? const <FeeInstallmentRow>[];
    String pourQui(FeeItemRow f) => f.classId != null
        ? 'Classe ${classes[f.classId] ?? '?'}'
        : f.levelCode != null
        ? 'Niveau ${f.levelCode}'
        : 'Tous les niveaux';
    return EcoleScaffold(
      title: 'Grille des frais',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Année ${annee.label} • montants en FCFA'),
          const SizedBox(height: 4),
          const Text(
            'Un tarif par niveau s’applique à toutes ses classes ; un tarif '
            'de classe (même rubrique, même libellé) le remplace pour cette '
            'classe.',
          ),
          const SizedBox(height: 8),
          for (final f in grille)
            Card(
              child: ListTile(
                key: Key('frais-${f.id}'),
                title: Text('${f.label} • ${fcfa(f.amount)}'),
                subtitle: Text(
                  '${libelleRubrique(f.rubric)} • ${pourQui(f)} • '
                  '${tranches.where((t) => t.feeItemId == f.id).length} '
                  'tranche(s)',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/finances/grille/${f.id}'),
              ),
            ),
          if (grille.isEmpty) const Text('Aucun frais pour cette année.'),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.add,
            label: 'Ajouter un frais',
            onPressed: () => context.push('/finances/grille/nouveau'),
          ),
        ],
      ),
    );
  }
}

/// Création ou modification d'une ligne de la grille, avec son échéancier.
class LigneFraisPage extends ConsumerStatefulWidget {
  const new(this.id, {super.key});

  /// « nouveau » pour une nouvelle ligne.
  final String id;

  @override
  ConsumerState<LigneFraisPage> createState() => _LigneFraisState();
}

class _LigneFraisState extends ConsumerState<LigneFraisPage> {
  final _libelle = TextEditingController();
  final _montant = TextEditingController();
  String _rubrique = 'scolarite';
  String? _niveau;
  String? _classe;
  bool _charge = false;

  bool get _nouveau => widget.id == 'nouveau';

  @override
  void dispose() {
    _libelle.dispose();
    _montant.dispose();
    super.dispose();
  }

  void _charger(FeeItemRow? f) {
    if (_charge) return;
    _charge = true;
    if (f == null) {
      _libelle.text = rubriques[_rubrique]!;
      return;
    }
    _libelle.text = f.label;
    _montant.text = '${f.amount}';
    _rubrique = f.rubric;
    _niveau = f.levelCode;
    _classe = f.classId;
  }

  Future<void> _enregistrer(SchoolRow ecole, SchoolYearRow annee) async {
    final montant = lireMontant(_montant.text);
    final ok = await avecMessage(context, () async {
      if (_libelle.text.trim().isEmpty) throw manque('le libellé');
      if (montant == null) throw manque('le montant');
      await ref.read(financesRepositoryProvider).enregistrerLigne({
        if (!_nouveau) 'id': widget.id,
        'school_id': ecole.id,
        'school_year_id': annee.id,
        'rubric': _rubrique,
        'label': _libelle.text.trim(),
        'level_code': _classe == null ? _niveau : null,
        'class_id': _classe,
        'billing_period': 'unique',
        'amount': montant,
      });
      return true;
    });
    if ((ok ?? false) && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Frais');
    final (ecole, annee) = c;
    final grille = ref.watch(grilleProvider(annee.id)).value;
    if (grille == null) return _chargement('Frais');
    final f = grille.where((x) => x.id == widget.id).firstOrNull;
    _charger(f);
    final niveaux = ref.watch(levelsProvider).value ?? const <LevelRow>[];
    final classes =
        ref.watch(classesProvider(annee.id)).value ?? const <ClassRow>[];
    final tranches = [
      for (final t
          in ref.watch(tranchesProvider).value ?? const <FeeInstallmentRow>[])
        if (t.feeItemId == widget.id) t,
    ];
    final totalTranches = tranches.fold<int>(0, (s, t) => s + t.amount);
    final repo = ref.read(financesRepositoryProvider);
    return EcoleScaffold(
      title: _nouveau ? 'Nouveau frais' : 'Frais : ${f?.label ?? ''}',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ChoiceField(
            label: 'Rubrique',
            value: _rubrique,
            options: rubriques,
            onChanged: (v) => setState(() {
              final ancien = rubriques[_rubrique];
              _rubrique = v ?? 'scolarite';
              if (_libelle.text == ancien) {
                _libelle.text = rubriques[_rubrique]!;
              }
            }),
          ),
          TextField(
            key: const Key('libelle-frais'),
            controller: _libelle,
            decoration: const InputDecoration(
              labelText: 'Libellé (imprimé sur le reçu)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ChampMontant(
            key: const Key('montant-frais'),
            controller: _montant,
            label: 'Montant pour l’année (FCFA)',
          ),
          const SizedBox(height: 12),
          const Text('Pour qui ?'),
          Wrap(
            spacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Tous les niveaux'),
                selected: _niveau == null && _classe == null,
                onSelected: (_) => setState(() {
                  _niveau = null;
                  _classe = null;
                }),
              ),
              for (final n in niveaux)
                ChoiceChip(
                  label: Text(n.label),
                  selected: _classe == null && _niveau == n.code,
                  onSelected: (_) => setState(() {
                    _niveau = n.code;
                    _classe = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('… ou une seule classe (tarif ajusté) :'),
          Wrap(
            spacing: 6,
            children: [
              for (final k in classes)
                ChoiceChip(
                  label: Text(k.name),
                  selected: _classe == k.id,
                  onSelected: (v) => setState(() {
                    _classe = v ? k.id : null;
                    _niveau = v ? k.levelCode : _niveau;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          BigButton(
            icon: Icons.check,
            label: 'Enregistrer',
            onPressed: () => _enregistrer(ecole, annee),
          ),
          if (!_nouveau && f != null) ...[
            const SectionTitle('Échéancier (tranches)'),
            Text(
              tranches.isEmpty
                  ? 'Sans tranche : tout est dû dès maintenant.'
                  : 'Total des tranches : ${fcfa(totalTranches)}'
                        '${totalTranches == f.amount ? '' : ' ⚠ différent du '
                                  'montant ${fcfa(f.amount)}'}',
            ),
            for (final t in tranches)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${t.label} • ${fcfa(t.amount)}'),
                subtitle: Text(
                  t.dueOn == null
                      ? 'Sans date'
                      : 'Avant le ${dateCourte(t.dueOn!)}',
                ),
                trailing: IconButton(
                  tooltip: 'Retirer la tranche',
                  icon: const Icon(Icons.close),
                  onPressed: () => repo.retirerTranche(t.id),
                ),
              ),
            OutlinedButton.icon(
              key: const Key('ajouter-tranche'),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une tranche'),
              onPressed: () => _ajouterTranche(context, f, tranches.length),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Retirer ce frais de la grille'),
              onPressed: () async {
                final ok = await confirmer(
                  context,
                  titre: 'Retirer « ${f.label} » ?',
                  message:
                      'Il ne sera plus dû. Les reçus déjà faits restent '
                      'enregistrés.',
                  bouton: 'Retirer',
                );
                if (ok) {
                  await repo.retirerLigne(f.id);
                  if (context.mounted) context.pop();
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _ajouterTranche(
    BuildContext context,
    FeeItemRow f,
    int deja,
  ) async {
    final libelle = TextEditingController(text: 'Tranche ${deja + 1}');
    final montant = TextEditingController();
    final date = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle tranche'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: libelle,
              decoration: const InputDecoration(labelText: 'Libellé'),
            ),
            ChampMontant(
              key: const Key('montant-tranche'),
              controller: montant,
            ),
            TextField(
              key: const Key('date-tranche'),
              controller: date,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'À payer avant le (jj/mm/aaaa)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (!(ok ?? false) || !context.mounted) return;
    await avecMessage(context, () async {
      final m = lireMontant(montant.text);
      if (m == null) throw manque('le montant de la tranche');
      final lue = _lireDate(date.text);
      if (date.text.trim().isNotEmpty && lue == null) {
        throw const UserMessage('Date à écrire jj/mm/aaaa.');
      }
      final d = lue == null ? null : AutoSaveDateField.iso(lue);
      await ref.read(financesRepositoryProvider).enregistrerTranche({
        'school_id': f.schoolId,
        'fee_item_id': f.id,
        'label': libelle.text.trim().isEmpty ? 'Tranche' : libelle.text.trim(),
        'amount': m,
        'due_on': d,
      });
    });
  }
}

DateTime? _lireDate(String t) {
  final m = RegExp(r'^\s*(\d{1,2})/(\d{1,2})/(\d{4})\s*$').firstMatch(t);
  if (m == null) return null;
  final d = DateTime(
    int.parse(m.group(3)!),
    int.parse(m.group(2)!),
    int.parse(m.group(1)!),
  );
  return d.day == int.parse(m.group(1)!) ? d : null;
}

// ----------------------------------------------------------------------
// Remises
// ----------------------------------------------------------------------

class RemisesPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Remises');
    final (ecole, _) = c;
    final remises = ref.watch(remisesProvider).value ?? const [];
    final repo = ref.read(financesRepositoryProvider);
    return EcoleScaffold(
      title: 'Remises',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Définissez les remises (fratrie, enfant du personnel…), puis '
            'attribuez-les dans la situation de chaque élève.',
          ),
          const SizedBox(height: 8),
          for (final r in remises)
            Card(
              child: ListTile(
                title: Text(r.label),
                subtitle: Text(texteRemise(r)),
                trailing: IconButton(
                  tooltip: 'Retirer',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => repo.retirerRemise(r.id),
                ),
              ),
            ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.add,
            label: 'Nouvelle remise',
            onPressed: () => _nouvelle(context, ref, ecole.id),
          ),
        ],
      ),
    );
  }

  Future<void> _nouvelle(
    BuildContext context,
    WidgetRef ref,
    String schoolId,
  ) async {
    final libelle = TextEditingController(text: 'Fratrie');
    final valeur = TextEditingController();
    var kind = 'pourcentage';
    String? rubrique = 'scolarite';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nouvelle remise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: libelle,
                  decoration: const InputDecoration(labelText: 'Libellé'),
                ),
                const SizedBox(height: 8),
                ChoiceField(
                  label: 'Type',
                  value: kind,
                  options: const {
                    'pourcentage': 'Pourcentage',
                    'montant': 'Montant fixe',
                  },
                  onChanged: (v) => setState(() => kind = v ?? kind),
                ),
                ChampMontant(
                  key: const Key('valeur-remise'),
                  controller: valeur,
                  label: kind == 'pourcentage'
                      ? 'Pourcentage (%)'
                      : 'Montant (FCFA)',
                ),
                const SizedBox(height: 8),
                ChoiceField(
                  label: 'Sur',
                  value: rubrique ?? 'tout',
                  options: const {'tout': 'Tous les frais', ...rubriques},
                  onChanged: (v) =>
                      setState(() => rubrique = v == 'tout' ? null : v),
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
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
    if (!(ok ?? false) || !context.mounted) return;
    await avecMessage(context, () async {
      final v = lireMontant(valeur.text);
      if (v == null) throw manque('la valeur de la remise');
      if (kind == 'pourcentage' && v > 100) {
        throw const UserMessage('Un pourcentage ne dépasse pas 100.');
      }
      await ref.read(financesRepositoryProvider).enregistrerRemise({
        'school_id': schoolId,
        'label': libelle.text.trim().isEmpty ? 'Remise' : libelle.text.trim(),
        'kind': kind,
        'value': v.toDouble(),
        'rubric': rubrique,
      });
    });
  }
}

// ----------------------------------------------------------------------
// Dépenses
// ----------------------------------------------------------------------

class DepensesPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Dépenses');
    final (_, annee) = c;
    final depenses = ref.watch(depensesProvider(annee.id)).value ?? const [];
    final annulees = {
      for (final d in depenses)
        if (d.reversesExpenseId != null) d.reversesExpenseId,
    };
    return EcoleScaffold(
      title: 'Dépenses',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BigButton(
            icon: Icons.add,
            label: 'Nouvelle dépense',
            onPressed: () => context.push('/finances/depense/nouvelle'),
          ),
          const SizedBox(height: 8),
          Text(
            'Total de l’année : '
            '${fcfa(depenses.fold<int>(0, (s, d) => s + d.amount))}',
          ),
          for (final d in depenses)
            Card(
              child: ListTile(
                key: Key('depense-${d.id}'),
                leading: Icon(
                  d.amount < 0
                      ? Icons.undo
                      : d.justificationPath == null
                      ? Icons.receipt_outlined
                      : Icons.photo_camera_outlined,
                ),
                title: Text('${d.label} • ${fcfa(d.amount)}'),
                subtitle: Text(
                  '${dateCourte(d.spentOn)} • ${libelleCategorie(d.category)}'
                  '${annulees.contains(d.id) ? ' • annulée' : ''}',
                ),
                onTap: () => context.push('/finances/depense/${d.id}'),
              ),
            ),
        ],
      ),
    );
  }
}

class NouvelleDepensePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<NouvelleDepensePage> createState() => _NouvelleDepenseState();
}

class _NouvelleDepenseState extends ConsumerState<NouvelleDepensePage> {
  final _libelle = TextEditingController();
  final _montant = TextEditingController();
  late final _date = TextEditingController(
    text: dateCourte(ref.read(aujourdhuiProvider)),
  );
  String _categorie = 'fournitures';
  String _mode = 'especes';
  (Uint8List, String)? _piece;
  bool _occupe = false;

  @override
  void dispose() {
    _libelle.dispose();
    _montant.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _photo({required bool camera}) async {
    final octets = await ref.read(choisirImageProvider)(camera: camera);
    if (octets != null && mounted) {
      setState(() => _piece = (octets, 'image/jpeg'));
    }
  }

  Future<void> _fichier() async {
    final f = await ref.read(choisirFichiersProvider)();
    if (f.isEmpty || !mounted) return;
    final octets = await File(f.first.chemin).readAsBytes();
    final pdf = f.first.nom.toLowerCase().endsWith('.pdf');
    setState(() => _piece = (octets, pdf ? 'application/pdf' : 'image/jpeg'));
  }

  Future<void> _enregistrer(SchoolRow ecole, SchoolYearRow annee) async {
    setState(() => _occupe = true);
    final d = await avecMessage(context, () {
      final montant = lireMontant(_montant.text);
      if (montant == null) throw manque('le montant');
      final lue = _lireDate(_date.text);
      if (lue == null) throw const UserMessage('Date à écrire jj/mm/aaaa.');
      final jour = AutoSaveDateField.iso(lue);
      return ref
          .read(financesRepositoryProvider)
          .depenser(
            schoolId: ecole.id,
            yearId: annee.id,
            categorie: _categorie,
            libelle: _libelle.text,
            montant: montant,
            date: jour,
            mode: _mode,
            justificatif: _piece,
          );
    });
    if (!mounted) return;
    setState(() => _occupe = false);
    if (d == null) return;
    unawaited(ref.read(syncEngineProvider).syncNow());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dépense ${d.voucherNumber} enregistrée.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Nouvelle dépense');
    final (ecole, annee) = c;
    final camera = ref.watch(cameraDisponibleProvider);
    return EcoleScaffold(
      title: 'Nouvelle dépense',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ChoiceField(
            label: 'Catégorie',
            value: _categorie,
            options: categoriesDepenses,
            onChanged: (v) => setState(() => _categorie = v ?? _categorie),
          ),
          TextField(
            key: const Key('objet-depense'),
            controller: _libelle,
            decoration: const InputDecoration(
              labelText: 'Objet (ex. achat de craies)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ChampMontant(key: const Key('montant-depense'), controller: _montant),
          const SizedBox(height: 12),
          TextField(
            controller: _date,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              labelText: 'Date (jj/mm/aaaa)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ChoiceField(
            label: 'Payé en',
            value: _mode,
            options: modesPaiement,
            onChanged: (v) => setState(() => _mode = v ?? _mode),
          ),
          const SectionTitle('Justificatif (facture, ticket)'),
          if (_piece != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file),
              title: Text(
                _piece!.$2 == 'application/pdf'
                    ? 'PDF joint (${(_piece!.$1.length / 1024).ceil()} Ko)'
                    : 'Photo jointe (${(_piece!.$1.length / 1024).ceil()} Ko)',
              ),
              trailing: IconButton(
                tooltip: 'Retirer',
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _piece = null),
              ),
            ),
          Wrap(
            spacing: 8,
            children: [
              if (camera)
                OutlinedButton.icon(
                  key: const Key('photo-justificatif'),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Photographier'),
                  onPressed: () => _photo(camera: true),
                ),
              OutlinedButton.icon(
                key: const Key('galerie-justificatif'),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(camera ? 'Galerie' : 'Choisir une image'),
                onPressed: () => _photo(camera: false),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Fichier PDF'),
                onPressed: _fichier,
              ),
            ],
          ),
          const SizedBox(height: 16),
          BigButton(
            icon: Icons.check,
            label: 'Enregistrer la dépense',
            onPressed: _occupe ? null : () => _enregistrer(ecole, annee),
          ),
        ],
      ),
    );
  }
}

class DepensePage extends ConsumerWidget {
  const new(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Dépense');
    final (_, annee) = c;
    final depenses = ref.watch(depensesProvider(annee.id)).value ?? const [];
    final d = depenses.where((x) => x.id == id).firstOrNull;
    if (d == null) return _chargement('Dépense');
    final annulation = depenses
        .where((x) => x.reversesExpenseId == d.id)
        .firstOrNull;
    final repo = ref.read(financesRepositoryProvider);
    return EcoleScaffold(
      title: 'Dépense ${d.voucherNumber ?? ''}',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(d.label, style: Theme.of(context).textTheme.titleLarge),
          Text(
            fcfa(d.amount),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            '${dateCourte(d.spentOn)} • ${libelleCategorie(d.category)} • '
            '${d.method == null ? '' : libelleMode(d.method!)}',
          ),
          if (d.reversalReason != null) Text('Motif : ${d.reversalReason}'),
          if (annulation != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.block),
                title: Text('Annulée (${annulation.voucherNumber ?? ''})'),
                subtitle: Text(annulation.reversalReason ?? ''),
              ),
            ),
          const SizedBox(height: 12),
          if (d.justificationPath != null)
            BigButton(
              icon: Icons.visibility,
              label: 'Voir le justificatif',
              onPressed: () => avecMessage(context, () async {
                final octets = await repo.justificatif(d);
                if (!context.mounted) return;
                if (d.justificationPath!.endsWith('.pdf')) {
                  await context.push(
                    '/apercu',
                    extra: ApercuPdf(octets, 'Justificatif.pdf'),
                  );
                } else {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EcoleScaffold(
                        title: 'Justificatif',
                        showSync: false,
                        body: InteractiveViewer(
                          maxScale: 6,
                          child: Center(child: Image.memory(octets)),
                        ),
                      ),
                    ),
                  );
                }
              }),
            )
          else if (d.amount > 0)
            const Text('Pas de justificatif.'),
          if (annulation == null && d.reversesExpenseId == null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              key: const Key('annuler-depense'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.undo),
              label: const Text('Annuler cette dépense (erreur)'),
              onPressed: () async {
                final motif = await demanderMotif(
                  context,
                  titre: 'Annuler la dépense ?',
                  explication:
                      'La dépense reste enregistrée ; une annulation de '
                      '${fcfa(-d.amount)} est créée. Indiquez pourquoi.',
                );
                if (motif == null || !context.mounted) return;
                await avecMessage(context, () => repo.annulerDepense(d, motif));
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Caisse et clôture
// ----------------------------------------------------------------------

const _mois = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', //
  'septembre', 'octobre', 'novembre', 'décembre',
];

String nomMois(String aaaamm) {
  final m = int.tryParse(aaaamm.substring(5, 7)) ?? 1;
  return '${_mois[m - 1]} ${aaaamm.substring(0, 4)}';
}

class CaissePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CaissePage> createState() => _CaisseState();
}

class _CaisseState extends ConsumerState<CaissePage> {
  late String _mois = ref.read(aujourdhuiProvider).substring(0, 7);

  @override
  Widget build(BuildContext context) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Caisse');
    final (ecole, annee) = c;
    final paiements = ref.watch(paiementsProvider(annee.id)).value ?? const [];
    final depenses = ref.watch(depensesProvider(annee.id)).value ?? const [];
    final clotures = ref.watch(cloturesProvider(ecole.id)).value ?? const [];
    final noms = {
      for (final l
          in ref.watch(situationsProvider((ecole.id, annee.id))) ??
              const <LigneEleve>[])
        l.eleve.eleve.id: l.nom,
    };
    final tout = journalCaisse(
      paiements: paiements,
      depenses: depenses,
      nomEleve: (id) => noms[id] ?? '',
    );
    final duMois = tout.where((m) => m.date.startsWith(_mois)).toList();
    final avant = tout.where((m) => m.date.compareTo(_mois) < 0).toList();
    final entrees = duMois
        .where((m) => m.montant > 0)
        .fold<int>(0, (s, m) => s + m.montant);
    final sorties = duMois
        .where((m) => m.montant < 0)
        .fold<int>(0, (s, m) => s + m.montant);
    final soldeEspeces = solde([...avant, ...duMois], mode: 'especes');
    final cloture = clotures
        .where((k) => k.periodMonth.startsWith(_mois))
        .firstOrNull;
    final mois = {
      for (final m in tout) m.date.substring(0, 7),
      ref.read(aujourdhuiProvider).substring(0, 7),
    }.toList()..sort((a, b) => b.compareTo(a));
    return EcoleScaffold(
      title: 'Caisse',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entrées : ${fcfa(entrees)}'),
                  Text('Sorties : ${fcfa(-sorties)}'),
                  Text(
                    'Solde du mois : ${fcfa(entrees + sorties)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Caisse (espèces) en fin de mois : ${fcfa(soldeEspeces)}',
                    key: const Key('caisse-fin-mois'),
                  ),
                ],
              ),
            ),
          ),
          if (cloture != null)
            Card(
              child: ListTile(
                key: const Key('mois-cloture'),
                leading: const Icon(Icons.lock),
                title: Text(
                  'Mois clôturé • solde ${fcfa(cloture.closingBalance)}',
                ),
                subtitle: Text(
                  cloture.closingBalance == soldeEspeces
                      ? 'Conforme aux écritures.'
                      : 'Écart avec les écritures actuelles : '
                            '${fcfa(soldeEspeces - cloture.closingBalance)} '
                            '(écriture ajoutée après la clôture).',
                ),
              ),
            )
          else
            OutlinedButton.icon(
              key: const Key('cloturer'),
              icon: const Icon(Icons.lock_outline),
              label: Text('Clôturer ${nomMois(_mois)}'),
              onPressed: () async {
                final ok = await confirmer(
                  context,
                  titre: 'Clôturer ${nomMois(_mois)} ?',
                  message:
                      'Comptez l’argent de la caisse : il doit y avoir '
                      '${fcfa(soldeEspeces)} en espèces. La clôture fige ce '
                      'solde (elle ne peut pas être refaite).',
                  bouton: 'Clôturer',
                );
                if (!ok || !context.mounted) return;
                await avecMessage(
                  context,
                  () => ref
                      .read(financesRepositoryProvider)
                      .cloturer(
                        schoolId: ecole.id,
                        mois: _mois,
                        solde: soldeEspeces,
                      ),
                );
              },
            ),
          const SectionTitle('Journal de caisse'),
          for (final m in duMois)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(m.libelle),
              subtitle: Text(
                '${dateCourte(m.date)} • ${m.numero} • '
                '${m.mode == null ? '' : libelleMode(m.mode!)}',
              ),
              trailing: Text(
                fcfa(m.montant),
                style: TextStyle(color: m.montant < 0 ? Colors.red : null),
              ),
            ),
          if (duMois.isEmpty) const Text('Aucun mouvement ce mois-ci.'),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Rapports
// ----------------------------------------------------------------------

class RapportsFinancesPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RapportsFinancesPage> createState() => _RapportsState();
}

class _RapportsState extends ConsumerState<RapportsFinancesPage> {
  /// null : toute l'année ; sinon « 2026-10 ».
  String? _mois;

  RapportFinances? _donnees() {
    final c = contexteFinances(ref);
    if (c == null) return null;
    final (ecole, annee) = c;
    final paiements = ref.read(paiementsProvider(annee.id)).value ?? const [];
    final depenses = ref.read(depensesProvider(annee.id)).value ?? const [];
    final lignes = ref.read(situationsProvider((ecole.id, annee.id)));
    if (lignes == null) return null;
    bool dans(String d) => _mois == null || d.startsWith(_mois!);
    final recettes = <String, (int, int)>{};
    for (final x in paiements.where((x) => dans(x.paidAt))) {
      final k = libelleRubrique(x.rubric);
      final (e, a) = recettes[k] ?? (0, 0);
      recettes[k] = x.amount >= 0 ? (e + x.amount, a) : (e, a + x.amount);
    }
    final parCategorie = <String, int>{};
    for (final d in depenses.where((d) => dans(d.spentOn))) {
      final k = libelleCategorie(d.category);
      parCategorie[k] = (parCategorie[k] ?? 0) + d.amount;
    }
    final classes = <String, (int, int, int)>{};
    for (final l in lignes) {
      final (du, paye, reste) = classes[l.classe] ?? (0, 0, 0);
      classes[l.classe] = (
        du + l.situation.du,
        paye + l.situation.paye,
        reste + l.situation.reste,
      );
    }
    final journal = journalCaisse(
      paiements: paiements,
      depenses: depenses,
      nomEleve: (_) => '',
    );
    final jour = ref.read(aujourdhuiProvider);
    return RapportFinances(
      ecole: ecole.name,
      anneeScolaire: annee.label,
      periode: _mois == null ? 'année ${annee.label}' : nomMois(_mois!),
      recettes: [
        for (final MapEntry(key: k, value: (e, a)) in recettes.entries)
          (k, e, a),
      ],
      depenses: [
        for (final MapEntry(key: k, value: m) in parCategorie.entries) (k, m),
      ],
      classes: [
        for (final MapEntry(key: k, value: (du, p, r))
            in classes.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
          (k, du, p, r),
      ],
      impayes: [
        for (final l in lignes)
          if (l.situation.impaye > 0) (l.nom, l.classe, l.situation.impaye),
      ],
      soldeEspeces: solde(
        _mois == null
            ? journal
            : journal.where((m) => m.date.compareTo('$_mois-99') < 0).toList(),
        mode: 'especes',
      ),
      genereLe: dateCourte(jour),
    );
  }

  Future<void> _pdf({required bool partager}) async {
    final r = _donnees();
    if (r == null) return;
    await avecMessage(context, () async {
      final pdf = await pdfRapportFinances(
        await ref.read(policesPdfProvider.future),
        r,
      );
      final sortie = ref.read(sortiePdfProvider);
      final nom = 'Rapport_financier_${_mois ?? r.anneeScolaire}.pdf';
      await (partager ? sortie.partager : sortie.imprimer)(pdf, nom);
    });
  }

  Future<void> _excel() async {
    final c = contexteFinances(ref);
    if (c == null) return;
    final (ecole, annee) = c;
    final paiements = ref.read(paiementsProvider(annee.id)).value ?? const [];
    final depenses = ref.read(depensesProvider(annee.id)).value ?? const [];
    final noms = {
      for (final l
          in ref.read(situationsProvider((ecole.id, annee.id))) ??
              const <LigneEleve>[])
        l.eleve.eleve.id: l.nom,
    };
    final journal = journalCaisse(
      paiements: paiements,
      depenses: depenses,
      nomEleve: (id) => noms[id] ?? '',
      mois: _mois,
    );
    final octets = ecrireXlsx('Journal', [
      ['Date', 'N°', 'Libellé', 'Mode', 'Entrée (FCFA)', 'Sortie (FCFA)'],
      for (final m in journal)
        [
          dateCourte(m.date),
          m.numero,
          m.libelle,
          if (m.mode != null) libelleMode(m.mode!) else '',
          if (m.montant >= 0) ...[m.montant, ''] else ...['', -m.montant],
        ],
    ]);
    if (!mounted) return;
    await avecMessage(
      context,
      () => ref.read(sortieFichierProvider)(
        octets,
        'Journal_caisse_${_mois ?? annee.label}.xlsx',
        typeXlsx,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = contexteFinances(ref);
    if (c == null) return _chargement('Rapports');
    final (_, annee) = c;
    final paiements = ref.watch(paiementsProvider(annee.id)).value ?? const [];
    ref.watch(depensesProvider(annee.id));
    final mois = {
      for (final x in paiements) x.paidAt.substring(0, 7),
      ref.read(aujourdhuiProvider).substring(0, 7),
    }.toList()..sort((a, b) => b.compareTo(a));
    return EcoleScaffold(
      title: 'Rapports financiers',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Période'),
          Wrap(
            spacing: 6,
            children: [
              ChoiceChip(
                label: Text('Année ${annee.label}'),
                selected: _mois == null,
                onSelected: (_) => setState(() => _mois = null),
              ),
              for (final m in mois)
                ChoiceChip(
                  label: Text(nomMois(m)),
                  selected: _mois == m,
                  onSelected: (_) => setState(() => _mois = m),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Le rapport PDF contient : synthèse, recettes par rubrique, '
            'dépenses par catégorie, recouvrement par classe et impayés.',
          ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.picture_as_pdf,
            label: 'Rapport PDF',
            onPressed: () => _pdf(partager: false),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Partager le rapport PDF'),
            onPressed: () => _pdf(partager: true),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('export-excel'),
            icon: const Icon(Icons.table_chart),
            label: const Text('Journal de caisse (Excel)'),
            onPressed: _excel,
          ),
        ],
      ),
    );
  }
}
