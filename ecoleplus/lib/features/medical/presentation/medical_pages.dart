import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/documents/data/documents_repository.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/medical/data/medical_api.dart';
import 'package:ecoleplus/features/medical/domain/fiche_medicale.dart';
import 'package:ecoleplus/features/medical/pdf/pdf_b5.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final medicalApiProvider = Provider<MedicalApi>(
  (ref) => SupabaseMedicalApi(ref.watch(supabaseClientProvider)),
);

/// Le dossier médico-scolaire est-il actif pour l'école ?
final ProviderFamily<bool, String> medicalActifProvider = Provider.family(
  (ref, schoolId) =>
      ref
          .watch(modulesProvider(schoolId))
          .value
          ?.any((m) => m.$1.key == 'medico_scolaire' && m.$2) ??
      false,
);

const rappelMicro =
    'Pas de micro sur cette fiche : la dictée passerait par un service '
    'extérieur au téléphone.';

/// Fiche médico-scolaire d'un élève (B5) : directeur seulement, en ligne
/// seulement ; rien n'est gardé sur le téléphone.
class FicheMedicalePage extends ConsumerStatefulWidget {
  const new(this.studentId, {super.key});
  final String studentId;

  @override
  ConsumerState<FicheMedicalePage> createState() => _FicheState();
}

class _FicheState extends ConsumerState<FicheMedicalePage> {
  DossierMedical? _dossier;
  String? _erreur;
  bool _modifie = false;
  bool _occupe = false;
  final _champs = <String, TextEditingController>{};
  final _examens = <(String, Map<String, TextEditingController>)>[];
  String? _aptitude;
  bool _exposee = false;

  @override
  void initState() {
    super.initState();
    unawaited(_charger());
  }

  @override
  void dispose() {
    for (final c in _champs.values) {
      c.dispose();
    }
    for (final (_, m) in _examens) {
      for (final c in m.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  TextEditingController _controleur(String? texte) =>
      TextEditingController(text: texte ?? '')..addListener(() {
        if (!_modifie && mounted) setState(() => _modifie = true);
      });

  String? get _anneeId {
    final session = ref.read(sessionProvider).value!;
    return ref
        .read(schoolProvider(session.schoolId))
        .value
        ?.currentSchoolYearId;
  }

  Future<void> _charger() async {
    try {
      final d = await ref.read(medicalApiProvider).lire(widget.studentId);
      if (!mounted) return;
      final annee = _anneeId;
      final apt = d.aptitudesParAnnee
          .where((a) => a.anneeId == annee)
          .firstOrNull;
      setState(() {
        _dossier = d;
        for (final (c, _) in champsFiche) {
          _champs[c] = _controleur(d.fiche[c]);
        }
        for (final e in d.examens) {
          _ajouterExamen(e.annee, e.valeurs);
        }
        _aptitude = apt?.aptitude;
        _exposee = apt?.exposee ?? false;
        _modifie = false;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _erreur = '$e');
    }
  }

  void _ajouterExamen(String annee, [Map<String, String?> valeurs = const {}]) {
    _examens.add((
      annee,
      {
        for (final (c, _) in constantes) c: _controleur(valeurs[c]),
        'examen_physique': _controleur(valeurs['examen_physique']),
      },
    ));
  }

  DossierMedical _saisi() => DossierMedical(
    fiche: {
      for (final MapEntry(:key, :value) in _champs.entries) key: value.text,
    },
    examens: [
      for (final (a, m) in _examens)
        ExamenAnnuel(a, {
          for (final MapEntry(:key, :value) in m.entries) key: value.text,
        }),
    ],
  );

  Future<bool> _enregistrer() async {
    setState(() => _occupe = true);
    final ok = await avecMessage(context, () async {
      final d = _saisi();
      await ref
          .read(medicalApiProvider)
          .enregistrer(
            widget.studentId,
            fiche: d.ficheJson(),
            examens: d.examens,
            aptitude: _anneeId == null
                ? null
                : {
                    'school_year_id': _anneeId,
                    'aptitude': _aptitude,
                    'expose_to_teacher': _aptitude != null && _exposee,
                  },
          );
      return true;
    });
    if (mounted) {
      setState(() {
        _occupe = false;
        if (ok ?? false) _modifie = false;
      });
      if (ok ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fiche médico-scolaire enregistrée.')),
        );
      }
    }
    return ok ?? false;
  }

  Future<void> _imprimer(StudentRow eleve, String? classe) async {
    if (_modifie && !await _enregistrer()) return;
    if (!mounted) return;
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      await ref.read(medicalApiProvider).noterImpression(widget.studentId);
      final store = ref.read(localStoreProvider);
      final ecole = await (store.db.select(
        store.db.schools,
      )..where((s) => s.id.equals(eleve.schoolId))).getSingle();
      final pdf = await pdfB5(
        await ref.read(policesPdfProvider.future),
        entete: await DocumentsRepository(store).entete(ecole),
        eleve: IdentiteB5(
          nom: '${eleve.lastName} ${eleve.firstNames}',
          sexe: eleve.sex,
          neLe: eleve.birthDate == null ? null : jjmmaaaa(eleve.birthDate),
          lieuNaissance: eleve.birthPlace,
          classe: classe,
        ),
        dossier: _saisi(),
        aptitudeDeLAnnee: _aptitude,
      );
      await ref
          .read(sortiePdfProvider)
          .imprimer(pdf, 'Fiche_medico-scolaire_${eleve.lastName}.pdf');
    });
    if (mounted) setState(() => _occupe = false);
  }

  Widget _champ(String cle, String libelle, {int lignes = 1}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: TextField(
      key: Key('medical-$cle'),
      controller: _champs[cle],
      maxLines: lignes,
      decoration: InputDecoration(
        labelText: libelle,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final eleve = ref.watch(eleveProvider(widget.studentId)).value;
    final parcours = ref.watch(parcoursProvider(widget.studentId)).value ?? [];
    final annee = _anneeId;
    final classe = [
      for (final (e, c) in parcours)
        if (e.schoolYearId == annee && e.endsOn == null) c?.name,
    ].firstOrNull;
    final titre = eleve == null
        ? 'Fiche médico-scolaire'
        : 'Fiche médico-scolaire — ${eleve.lastName} ${eleve.firstNames}';
    if (_erreur != null) {
      return EcoleScaffold(title: titre, body: InfoMessage(_erreur!));
    }
    if (_dossier == null || eleve == null) {
      return EcoleScaffold(
        title: titre,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final annees = ref.watch(yearsProvider(eleve.schoolId)).value ?? [];
    final libelleAnnee = annees.where((y) => y.id == annee).firstOrNull?.label;
    return PopScope(
      canPop: !_modifie,
      onPopInvokedWithResult: (sorti, _) async {
        if (sorti) return;
        final quitter = await confirmer(
          context,
          titre: 'Modifications non enregistrées',
          message:
              'Les changements de la fiche seront perdus. Touchez '
              '« Enregistrer » pour les garder.',
          bouton: 'Quitter sans enregistrer',
        );
        if (quitter && context.mounted) {
          setState(() => _modifie = false);
          Navigator.of(context).pop();
        }
      },
      child: EcoleScaffold(
        title: titre,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const InfoMessage(
              'Données de santé : réservées au directeur. Chaque ouverture '
              'est inscrite au journal. Rien n’est gardé sur le téléphone. '
              'Tous les champs sont facultatifs.',
              icon: Icons.lock_outline,
            ),
            const Text(rappelMicro),
            const SectionTitle('A) Antécédents familiaux'),
            for (final (c, l) in antecedentsFamiliaux) _champ(c, l),
            const SectionTitle('A) Antécédents personnels médicaux'),
            for (final (c, l) in antecedentsMedicaux) _champ(c, l),
            const SectionTitle('Vaccinations'),
            for (final (c, l) in vaccinations) _champ(c, l),
            const SectionTitle('Antécédents chirurgicaux'),
            for (final (c, l) in antecedentsChirurgicaux)
              _champ(c, l, lignes: 3),
            const SectionTitle('B) Examen clinique (par année)'),
            for (final (a, m) in _examens)
              Card(
                key: Key('examen-$a'),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a, style: Theme.of(context).textTheme.titleMedium),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final (c, l) in constantes)
                            SizedBox(
                              width: 140,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: TextField(
                                  key: Key('examen-$a-$c'),
                                  controller: m[c],
                                  decoration: InputDecoration(
                                    labelText: l,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      TextField(
                        key: Key('examen-$a-physique'),
                        controller: m['examen_physique'],
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Examen physique',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (libelleAnnee != null &&
                !_examens.any((e) => e.$1 == libelleAnnee) &&
                _examens.length < anneesSurLeModele)
              TextButton.icon(
                key: const Key('ajouter-examen'),
                icon: const Icon(Icons.add),
                label: Text('Ajouter l’examen de $libelleAnnee'),
                onPressed: () => setState(() {
                  _ajouterExamen(libelleAnnee);
                  _modifie = true;
                }),
              ),
            const SectionTitle('Observations (année en cours)'),
            Wrap(
              spacing: 8,
              children: [
                for (final MapEntry(key: code, value: libelle)
                    in aptitudes.entries)
                  ChoiceChip(
                    key: Key('aptitude-$code'),
                    label: Text(libelle),
                    selected: _aptitude == code,
                    onSelected: (choisi) => setState(() {
                      _aptitude = choisi ? code : null;
                      _modifie = true;
                    }),
                  ),
              ],
            ),
            SwitchListTile(
              key: const Key('exposer-aptitude'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Montrer cette mention à l’enseignant(e)'),
              subtitle: const Text(
                'Seulement « Apte », « À surveiller » ou « Inapte », sans '
                'aucun détail médical.',
              ),
              value: _exposee,
              onChanged: _aptitude == null
                  ? null
                  : (v) => setState(() {
                      _exposee = v;
                      _modifie = true;
                    }),
            ),
            const SizedBox(height: 8),
            BigButton(
              icon: Icons.save,
              label: 'Enregistrer',
              onPressed: _occupe || !_modifie ? null : _enregistrer,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Fiche médico-scolaire (PDF)'),
              onPressed: _occupe ? null : () => _imprimer(eleve, classe),
            ),
            if (_occupe) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}

/// Journal d'accès au dossier médico-scolaire (directeur).
class JournalMedicalPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    return EcoleScaffold(
      title: 'Journal du dossier médico-scolaire',
      body: FutureBuilder(
        future: ref.read(medicalApiProvider).journal(session.schoolId),
        builder: (context, snap) {
          if (snap.hasError) return InfoMessage('${snap.error}');
          final l = snap.data;
          if (l == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (l.isEmpty) {
            return const InfoMessage('Aucun accès pour l’instant.');
          }
          String deux(int n) => n.toString().padLeft(2, '0');
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Chaque ouverture, modification, impression ou tentative '
                'refusée est inscrite ici. Ce journal ne peut pas être '
                'modifié.',
              ),
              for (final e in l)
                ListTile(
                  leading: Icon(
                    e.autorise ? Icons.lock_open : Icons.block,
                    color: e.autorise ? null : Colors.red,
                  ),
                  title: Text(
                    '${e.qui} — ${e.action}'
                    '${e.autorise ? '' : ' (refusé)'}',
                  ),
                  subtitle: Text(
                    '${deux(e.quand.day)}/${deux(e.quand.month)}/'
                    '${e.quand.year} à ${deux(e.quand.hour)} h '
                    '${deux(e.quand.minute)}'
                    '${e.eleve == null ? '' : ' · ${e.eleve}'}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Texte d'information des parents (modèle proposé), imprimable.
class InformationParentsPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final ecole = ref.watch(schoolProvider(session.schoolId)).value;
    final texte = texteInformationParents(ecole?.name ?? 'de votre enfant');
    return EcoleScaffold(
      title: 'Information des parents',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoMessage(
            'Modèle proposé : faites-le vérifier localement avant usage '
            'réel. Remettez-le aux parents avant de remplir les fiches.',
          ),
          const SizedBox(height: 8),
          Text(texte),
          const SizedBox(height: 16),
          BigButton(
            icon: Icons.print,
            label: 'Imprimer (PDF)',
            onPressed: () async {
              final polices = await ref.read(policesPdfProvider.future);
              final doc =
                  pw.Document(
                    theme: polices.theme,
                    title: 'Information des parents',
                  )..addPage(
                    pw.Page(
                      pageFormat: PdfPageFormat.a4.copyWith(
                        marginLeft: 48,
                        marginRight: 48,
                        marginTop: 48,
                        marginBottom: 48,
                      ),
                      build: (_) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Center(
                            child: pw.Text(
                              'DOSSIER MÉDICO-SCOLAIRE — INFORMATION DES '
                              'PARENTS',
                              style: const pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            texte,
                            style: const pw.TextStyle(
                              fontSize: 11,
                              lineSpacing: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
              await ref
                  .read(sortiePdfProvider)
                  .imprimer(await doc.save(), 'Information_parents.pdf');
            },
          ),
        ],
      ),
    );
  }
}

/// Mention d'aptitude exposée à l'enseignant(e) (aucun détail médical).
class AptitudeExposee extends ConsumerWidget {
  const new({required this.classId, required this.studentId, super.key});
  final String classId;
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref.read(medicalApiProvider).aptitudesDeLaClasse(classId),
    builder: (context, snap) {
      final a = snap.data?[studentId];
      if (a == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Chip(
          key: const Key('aptitude-exposee'),
          avatar: const Icon(Icons.health_and_safety_outlined),
          label: Text('Aptitude : ${aptitudes[a] ?? a}'),
        ),
      );
    },
  );
}
