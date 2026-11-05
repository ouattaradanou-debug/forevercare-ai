import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/export/xlsx_ecriture.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/cantine/presentation/cantine_providers.dart';
import 'package:ecoleplus/features/classes/data/classes_repository.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:ecoleplus/features/grades/presentation/classement_page.dart';
import 'package:ecoleplus/features/pilotage/domain/absences.dart';
import 'package:ecoleplus/features/pilotage/domain/rapports.dart';
import 'package:ecoleplus/features/pilotage/pdf/pdf_pilotage.dart';
import 'package:ecoleplus/features/pilotage/presentation/edt_pages.dart';
import 'package:ecoleplus/features/pilotage/presentation/pilotage_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// PDF (aperçu et impression) ou Excel (partage) d'un rapport.
Future<void> exporterRapport(
  BuildContext context,
  WidgetRef ref,
  Rapport r, {
  required bool excel,
}) => avecMessage(context, () async {
  final nom = '${r.code}_${r.annee.replaceAll('/', '-')}';
  if (excel) {
    await ref.read(sortieFichierProvider)(
      ecrireXlsx(r.code, r.lignesExcel),
      '$nom.xlsx',
      typeXlsx,
    );
  } else {
    final pdf = await pdfRapport(
      await ref.read(policesPdfProvider.future),
      r,
      jourTexte(ref.read(aujourdhuiProvider)),
    );
    await ref.read(sortiePdfProvider).imprimer(pdf, '$nom.pdf');
  }
});

/// Absences de la période, par classe et par élève.
Rapport? rapportAbsences(WidgetRef ref, Periode periode) {
  final ctx = contexteEcole(ref);
  if (ctx == null) return null;
  final (ecole, annee) = ctx;
  final classes = ref.watch(classesProvider(annee.id)).value;
  final eff = ref.watch(effectifsProvider(annee.id)).value;
  final eleves = ref.watch(elevesProvider((ecole.id, annee.id, false))).value;
  final (du, au) = periode.bornes(
    ref.watch(aujourdhuiProvider),
    rentree: annee.startsOn,
  );
  final totaux = ref.watch(totauxPresencesProvider((ecole.id, du, au))).value;
  if (classes == null || eff == null || eleves == null || totaux == null) {
    return null;
  }
  return Rapport(
    code: 'Absences',
    titre: 'Absences et retards',
    ecole: ecole.name,
    annee: annee.label,
    periode: du == au
        ? jourTexte(du)
        : '${periode.libelle.toLowerCase()} (${_jj(du)} au ${_jj(au)})',
    tableaux: [
      tableauAbsencesClasses(
        totaux.parClasse([
          for (final c in classes) (c.id, c.name, eff[c.id]?.total ?? 0),
        ]),
      ),
      tableauAbsencesEleves(
        totaux.parEleve({
          for (final e in eleves)
            e.eleve.id: (
              '${e.eleve.lastName} ${e.eleve.firstNames}',
              e.classe?.name ?? '',
            ),
        }),
      ),
    ],
    notes: const [
      'Présence = élèves présents ou en retard ÷ élèves appelés.',
      'Les motifs d’absence ne figurent pas dans les rapports.',
    ],
  );
}

String _jj(String iso) => '${iso.substring(8, 10)}/${iso.substring(5, 7)}';

/// Statistiques d'absences (directeur : toute l'école ; enseignant : sa
/// classe, son téléphone ne recevant que ses élèves).
class AbsencesPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AbsencesPage> createState() => _AbsencesState();
}

class _AbsencesState extends ConsumerState<AbsencesPage> {
  Periode _periode = Periode.mois;

  @override
  Widget build(BuildContext context) {
    final r = rapportAbsences(ref, _periode);
    return EcoleScaffold(
      title: 'Absences',
      body: r == null
          ? const LinearProgressIndicator()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 6,
                  children: [
                    for (final p in Periode.values)
                      ChoiceChip(
                        label: Text(p.libelle),
                        selected: p == _periode,
                        onSelected: (_) => setState(() => _periode = p),
                      ),
                  ],
                ),
                Text(r.periode ?? '', key: const Key('absences-periode')),
                const SizedBox(height: 8),
                _BoutonsExport(r),
                for (final t in r.tableaux) ...[
                  SectionTitle(t.titre),
                  if (t.lignes.isEmpty)
                    const Text('Rien à signaler sur cette période.')
                  else
                    _TableauEcran(t),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.fact_check),
                  label: const Text('Faire ou corriger l’appel'),
                  onPressed: () => context.push('/appel'),
                ),
              ],
            ),
    );
  }
}

class _BoutonsExport extends ConsumerWidget {
  const new(this.r);
  final Rapport r;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Wrap(
    spacing: 8,
    children: [
      OutlinedButton.icon(
        key: Key('pdf-${r.code}'),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('PDF'),
        onPressed: () => exporterRapport(context, ref, r, excel: false),
      ),
      OutlinedButton.icon(
        key: Key('excel-${r.code}'),
        icon: const Icon(Icons.table_chart),
        label: const Text('Excel'),
        onPressed: () => exporterRapport(context, ref, r, excel: true),
      ),
    ],
  );
}

/// Un tableau de rapport à l'écran (défilement horizontal si besoin).
class _TableauEcran extends StatelessWidget {
  const new(this.t);
  final TableauRapport t;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      headingRowHeight: 40,
      dataRowMinHeight: 36,
      dataRowMaxHeight: 48,
      columnSpacing: 16,
      columns: [for (final e in t.entete) DataColumn(label: Text(e))],
      rows: [
        for (final l in [...t.lignes, ?t.total])
          DataRow(cells: [for (final v in l) DataCell(Text(texteCase(v)))]),
      ],
    ),
  );
}

// ------------------------------- Rapports -------------------------------

/// Les rapports automatiques (directeur). Les modules désactivés n'y
/// apparaissent pas.
class RapportsPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RapportsPage> createState() => _RapportsState();
}

class _RapportsState extends ConsumerState<RapportsPage> {
  /// 1, 2, 3 ; 0 = l'année.
  int _trimestre = 1;
  Periode _periode = Periode.mois;
  final _seuil = TextEditingController();

  @override
  void dispose() {
    _seuil.dispose();
    super.dispose();
  }

  /// Seuil saisi (centièmes) ; null : la moitié du barème.
  int? get _seuilCentiemes => centiemesDepuis(_seuil.text);

  String _seuilTexte(SchoolRow ecole) {
    final c = _seuilCentiemes ?? (ecole.gradingScale * 100).round() ~/ 2;
    return '${centiemesTexte(c)}/${centiemesTexte((ecole.gradingScale * 100).round())}';
  }

  String get _periodeNotes => _trimestre == 0
      ? 'Année entière'
      : _trimestre == 1
      ? '1er trimestre'
      : '${_trimestre}e trimestre';

  Future<Rapport?> _construire(String code) async {
    final ctx = contexteEcole(ref);
    if (ctx == null) return null;
    final (ecole, annee) = ctx;
    Rapport rapport(
      String titre,
      List<TableauRapport> t, {
      String? periode,
      List<String> notes = const [],
      bool paysage = false,
    }) => Rapport(
      code: code,
      titre: titre,
      ecole: ecole.name,
      annee: annee.label,
      periode: periode,
      tableaux: t,
      notes: notes,
      paysage: paysage,
    );
    final classes = ref.read(classesProvider(annee.id)).value ?? const [];
    final eff = ref.read(effectifsProvider(annee.id)).value ?? const {};
    Future<List<ResultatsClasse>> resultats() => ref.read(
      resultatsEcoleProvider((annee.id, _trimestre, _seuilCentiemes)).future,
    );
    switch (code) {
      case 'Effectifs':
        return rapport('Effectifs de l’école', [
          tableauEffectifs([
            for (final c in classes) (c.name, eff[c.id] ?? const Effectif()),
          ]),
        ]);
      case 'Listes':
        final eleves =
            ref.read(elevesProvider((ecole.id, annee.id, false))).value ??
            const [];
        return rapport('Listes des élèves par classe', [
          for (final c in classes)
            tableauListe(c.name, [
              for (final e in eleves)
                if (e.classe?.id == c.id)
                  (
                    '${e.eleve.lastName} ${e.eleve.firstNames}',
                    e.eleve.sex,
                    e.eleve.birthDate,
                    e.eleve.studentCode,
                  ),
            ]),
        ]);
      case 'Resultats':
        final r = await resultats();
        return rapport(
          'Résultats par classe et par matière',
          [tableauResultats(r, _seuilTexte(ecole)), tableauMatieres(r)],
          periode: _periodeNotes,
          paysage: true,
        );
      case 'Classements':
        final r = await resultats();
        return rapport('Classements', [
          for (final c in r) tableauClassementRapport(c),
        ], periode: _periodeNotes);
      case 'Difficulte':
        final r = await resultats();
        return rapport(
          'Élèves en difficulté',
          [tableauDifficulte(r, _seuilTexte(ecole))],
          periode: _periodeNotes,
          notes: [
            'Seuil : moyenne inférieure à ${_seuilTexte(ecole)}.',
            'Le seuil se change sur l’écran des rapports.',
          ],
        );
      case 'Absences':
        return rapportAbsences(ref, _periode);
      case 'Finances':
        return rapport(
          'Finances : recettes et impayés',
          [tableauFinances(_financesParClasse(ecole, annee, classes))],
          notes: ['Scolarité et frais de l’année, hors cantine.'],
        );
      case 'Synthese':
        return _synthese(ecole, annee, classes, eff, await resultats());
    }
    return null;
  }

  List<(String, Synthese)> _financesParClasse(
    SchoolRow ecole,
    SchoolYearRow annee,
    List<ClassRow> classes,
  ) {
    final l =
        ref.read(situationsHorsCantineProvider((ecole.id, annee.id))) ??
        const <LigneEleve>[];
    return [
      for (final c in classes)
        (
          c.name,
          Synthese.depuis([
            for (final x in l)
              if (x.eleve.classe?.id == c.id) x.situation,
          ]),
        ),
    ];
  }

  Rapport _synthese(
    SchoolRow ecole,
    SchoolYearRow annee,
    List<ClassRow> classes,
    Map<String, Effectif> eff,
    List<ResultatsClasse> resultats,
  ) {
    final droits = ref.read(mesDroitsProvider);
    final absences = rapportAbsences(ref, Periode.mois);
    final total = classes.fold(
      const Effectif(),
      (s, c) => s + (eff[c.id] ?? const Effectif()),
    );
    final enseignants = ref.read(teachersProvider(ecole.id)).value?.length;
    final cles = <List<Object?>>[
      ['Élèves', total.total],
      ['Filles', total.filles],
      ['Garçons', total.garcons],
      ['Classes', classes.length],
      ['Enseignants', ?enseignants],
    ];
    if (droits.contains('finances')) {
      // Totaux : somme des classes (identique à la situation de l'école).
      final parClasse = _financesParClasse(ecole, annee, classes);
      final du = parClasse.fold(0, (s, c) => s + c.$2.du);
      final enc = parClasse.fold(0, (s, c) => s + c.$2.encaisse);
      final imp = parClasse.fold(0, (s, c) => s + c.$2.nbImpayes);
      cles.addAll([
        ['Recettes de l’année (FCFA)', enc],
        ['Reste à payer (FCFA)', du - enc],
        ['Élèves avec un impayé', imp],
        ['Recouvrement', texteTaux(du == 0 ? null : enc * 100 / du)],
      ]);
    }
    return Rapport(
      code: 'Synthese',
      titre: 'Synthèse de l’école',
      ecole: ecole.name,
      annee: annee.label,
      periode: _periodeNotes,
      tableaux: [
        TableauRapport('Chiffres clés', const ['', 'Valeur'], cles),
        tableauEffectifs([
          for (final c in classes) (c.name, eff[c.id] ?? const Effectif()),
        ]),
        if (resultats.isNotEmpty)
          tableauResultats(resultats, _seuilTexte(ecole)),
        if (absences != null) absences.tableaux.first,
        if (droits.contains('finances'))
          tableauFinances(_financesParClasse(ecole, annee, classes)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctx = contexteEcole(ref);
    if (ctx == null) {
      return const EcoleScaffold(
        title: 'Rapports',
        body: LinearProgressIndicator(),
      );
    }
    final (ecole, annee) = ctx;
    // Données lues au moment du rapport : on les garde chargées.
    ref
      ..watch(classesProvider(annee.id))
      ..watch(effectifsProvider(annee.id))
      ..watch(elevesProvider((ecole.id, annee.id, false)))
      ..watch(teachersProvider(ecole.id))
      // Gardé en mémoire tant que l'écran est ouvert (calcul des notes).
      ..watch(resultatsEcoleProvider((annee.id, _trimestre, _seuilCentiemes)));
    final droits = ref.watch(mesDroitsProvider);
    final finances = droits.contains('finances');
    if (finances) {
      ref.watch(situationsHorsCantineProvider((ecole.id, annee.id)));
    }
    final cantine = ref.watch(cantineActiveProvider(ecole.id));
    final notes = ecole.managesPrimary;
    final rapports = <(String, String, String, IconData)>[
      (
        'Effectifs',
        'Effectifs par classe et par sexe',
        'Filles, garçons, total',
        Icons.groups,
      ),
      ('Listes', 'Listes des élèves', 'Une liste par classe', Icons.list_alt),
      if (notes) ...[
        (
          'Resultats',
          'Résultats par classe et par matière',
          'Moyennes, taux de réussite',
          Icons.grading,
        ),
        (
          'Classements',
          'Classements',
          'Toutes les classes',
          Icons.format_list_numbered,
        ),
        (
          'Difficulte',
          'Élèves en difficulté',
          'Moyenne sous le seuil choisi',
          Icons.support,
        ),
      ],
      ('Absences', 'Absences', _periode.libelle, Icons.event_busy),
      if (finances)
        (
          'Finances',
          'Finances',
          'Recettes et impayés par classe',
          Icons.payments_outlined,
        ),
      (
        'Synthese',
        'Synthèse de l’école',
        'Les chiffres clés sur une page',
        Icons.summarize,
      ),
    ];
    return EcoleScaffold(
      title: 'Rapports',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Chaque rapport est calculé sur ce téléphone, même sans '
            'Internet, puis imprimé (PDF) ou partagé (Excel).',
          ),
          if (notes) ...[
            const SectionTitle('Notes : période'),
            Wrap(
              spacing: 6,
              children: [
                for (final t in const [1, 2, 3, 0])
                  ChoiceChip(
                    label: Text(t == 0 ? 'Année' : 'Trimestre $t'),
                    selected: _trimestre == t,
                    onSelected: (_) => setState(() => _trimestre = t),
                  ),
              ],
            ),
            TextField(
              key: const Key('seuil-difficulte'),
              controller: _seuil,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Seuil « élève en difficulté »',
                helperText:
                    'Moyenne en dessous de laquelle un élève est signalé '
                    '(vide : ${_seuilTexte(ecole)}).',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SectionTitle('Absences : période'),
          Wrap(
            spacing: 6,
            children: [
              for (final p in Periode.values)
                ChoiceChip(
                  label: Text(p.libelle),
                  selected: p == _periode,
                  onSelected: (_) => setState(() => _periode = p),
                ),
            ],
          ),
          const SectionTitle('Rapports'),
          for (final (code, titre, detail, icone) in rapports)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  key: Key('rapport-$code'),
                  leading: Icon(icone),
                  title: Text(titre),
                  subtitle: Text(detail),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        key: Key('pdf-$code'),
                        tooltip: 'PDF',
                        icon: const Icon(Icons.picture_as_pdf),
                        onPressed: () => _exporter(code, excel: false),
                      ),
                      IconButton(
                        key: Key('excel-$code'),
                        tooltip: 'Excel',
                        icon: const Icon(Icons.table_chart),
                        onPressed: () => _exporter(code, excel: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (cantine)
            Card(
              child: ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Rapports de la cantine'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/cantine/rapports'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _exporter(String code, {required bool excel}) async {
    final r = await avecMessage(context, () => _construire(code));
    if (r == null || !mounted) return;
    await exporterRapport(context, ref, r, excel: excel);
  }
}
