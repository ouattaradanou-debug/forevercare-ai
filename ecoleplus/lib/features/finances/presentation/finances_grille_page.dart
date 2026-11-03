import 'dart:async';
import 'dart:io';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/finances/data/finances_repository.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/finances/pdf/pdf_finances.dart';
import 'package:ecoleplus/features/finances/presentation/finances_pages.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// Modalités de paiement d'une rubrique (A23).
const modalites = {
  'integral': 'En une fois',
  'partiel': 'Paiement partiel autorisé',
};

/// Libellés des versements de la scolarité.
const libellesVersements = ['1er versement', '2e versement', '3e versement'];

/// « du 01/10/2026 au 31/10/2026 », « avant le 31/10/2026 »,
/// « à l'inscription ».
String textePeriode(String? debut, String? fin) {
  if (fin == null) return 'À l’inscription';
  if (debut == null) return 'Avant le ${dateCourte(fin)}';
  return 'Du ${dateCourte(debut)} au ${dateCourte(fin)}';
}

/// Lit « jj/mm/aaaa » (null si vide ou invalide).
DateTime? lireDateCourte(String t) {
  final m = RegExp(r'^\s*(\d{1,2})/(\d{1,2})/(\d{4})\s*$').firstMatch(t);
  if (m == null) return null;
  final j = int.parse(m.group(1)!);
  final d = DateTime(int.parse(m.group(3)!), int.parse(m.group(2)!), j);
  return d.day == j ? d : null;
}

/// Un versement en cours de saisie.
class _VersementSaisi {
  new(this.libelle);
  final String libelle;
  final montant = TextEditingController();
  final du = TextEditingController();
  final au = TextEditingController();

  /// À l'inscription (dû tout de suite, sans période).
  bool aLInscription = false;

  int get valeur => lireMontant(montant.text) ?? 0;

  void vider() {
    montant.clear();
    du.clear();
    au.clear();
    aLInscription = false;
  }

  void dispose() {
    montant.dispose();
    du.dispose();
    au.dispose();
  }
}

/// Une rubrique en cours de saisie (la scolarité a trois versements).
class _RubriqueSaisie {
  new(this.code, this.libelle)
    : versements = code == 'scolarite'
          ? [for (final l in libellesVersements) _VersementSaisi(l)]
          : [_VersementSaisi(libelle)];
  final String code;
  final String libelle;
  final List<_VersementSaisi> versements;
  String modalite = 'partiel';

  int get total => versements.fold(0, (s, v) => s + v.valeur);
  bool get scolarite => code == 'scolarite';

  void dispose() {
    for (final v in versements) {
      v.dispose();
    }
  }
}

/// Paramétrage des frais en une seule grille (A23) : classes cochées en
/// haut, une ligne par rubrique (la scolarité en trois versements),
/// totaux calculés, récapitulatif à imprimer ou partager.
class GrilleFraisPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<GrilleFraisPage> createState() => _GrilleFraisState();
}

class _GrilleFraisState extends ConsumerState<GrilleFraisPage> {
  final _classes = <String>{};
  final _lignes = <String, _RubriqueSaisie>{};
  final _observations = TextEditingController();
  String? _chargePour;
  bool _modifie = false;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(sessionProvider).value;
    if (s != null) {
      unawaited(
        ref.read(financesRepositoryProvider).assurerRubriques(s.schoolId),
      );
    }
  }

  @override
  void dispose() {
    for (final l in _lignes.values) {
      l.dispose();
    }
    _observations.dispose();
    super.dispose();
  }

  void _marquer() {
    if (!_modifie) setState(() => _modifie = true);
  }

  _RubriqueSaisie _ligne(String code, String libelle) =>
      _lignes.putIfAbsent(code, () {
        final r = _RubriqueSaisie(code, libelle);
        for (final v in r.versements) {
          v.montant.addListener(() => setState(() {}));
        }
        return r;
      });

  /// Remplit la grille avec les frais de la première classe cochée.
  void _charger(
    ClassRow? reference,
    List<FeeItemRow> grille,
    List<FeeInstallmentRow> tranches,
    List<FeeNoteRow> notes,
    List<FeeRubricRow> rubriques,
  ) {
    final cle = reference?.id ?? '';
    if (_chargePour == cle) return;
    _chargePour = cle;
    _modifie = false;
    for (final r in rubriques) {
      _ligne(r.code, r.label);
    }
    for (final l in _lignes.values) {
      l.modalite = 'partiel';
      for (final v in l.versements) {
        v.vider();
      }
      if (l.scolarite) l.versements.first.aLInscription = true;
    }
    _observations.text = reference == null
        ? ''
        : notes.where((n) => n.classId == reference.id).firstOrNull?.notes ??
              '';
    if (reference == null) return;
    for (final f in fraisApplicables(
      grille,
      niveau: reference.levelCode,
      classe: reference.id,
    )) {
      final l = _lignes[f.rubric];
      if (l == null) continue;
      l.modalite = f.paymentTerms;
      final siens = [
        for (final t in tranches)
          if (t.feeItemId == f.id) t,
      ];
      if (siens.isEmpty) {
        l.versements.first
          ..montant.text = f.amount == 0 ? '' : '${f.amount}'
          ..aLInscription = true;
        continue;
      }
      for (final (i, t) in siens.take(l.versements.length).indexed) {
        final v = l.versements[i]
          ..montant.text = '${t.amount}'
          ..aLInscription = t.dueOn == null;
        v.du.text = t.startsOn == null ? '' : dateCourte(t.startsOn!);
        v.au.text = t.dueOn == null ? '' : dateCourte(t.dueOn!);
      }
    }
  }

  /// Ce qui est enregistré pour une classe (comparaison entre classes).
  static String _empreinte(
    ClassRow c,
    List<FeeItemRow> grille,
    List<FeeInstallmentRow> tranches,
  ) {
    final lignes = fraisApplicables(grille, niveau: c.levelCode, classe: c.id)
      ..sort((a, b) => a.rubric.compareTo(b.rubric));
    String versements(FeeItemRow f) => [
      for (final t in tranches)
        if (t.feeItemId == f.id) '${t.amount}/${t.startsOn}/${t.dueOn}',
    ].join(',');
    return [
      for (final f in lignes)
        '${f.rubric}:${f.amount}:${f.paymentTerms}:${versements(f)}',
    ].join(';');
  }

  /// Versements saisis, contrôlés (dates au bon format, période complète).
  List<Versement> _versements(_RubriqueSaisie l) {
    final out = <Versement>[];
    for (final (i, v) in l.versements.indexed) {
      final m = v.valeur;
      if (m == 0) continue;
      final nom = l.scolarite ? '${l.libelle} — ${v.libelle}' : l.libelle;
      if (v.aLInscription && (i == 0 || !l.scolarite)) {
        out.add(Versement(v.libelle, m));
        continue;
      }
      final au = lireDateCourte(v.au.text);
      final du = v.du.text.trim().isEmpty ? null : lireDateCourte(v.du.text);
      if (au == null) {
        throw UserMessage(
          '$nom : indiquez la date limite (jj/mm/aaaa) ou « à l’inscription ».',
        );
      }
      if (v.du.text.trim().isNotEmpty && du == null) {
        throw UserMessage('$nom : date de début à écrire jj/mm/aaaa.');
      }
      if (du != null && du.isAfter(au)) {
        throw UserMessage('$nom : la période commence après sa date limite.');
      }
      out.add(
        Versement(
          v.libelle,
          m,
          debut: du == null ? null : AutoSaveDateField.iso(du),
          fin: AutoSaveDateField.iso(au),
        ),
      );
    }
    return out;
  }

  Future<void> _enregistrer(
    SchoolRow ecole,
    SchoolYearRow annee,
    List<ClassRow> classes,
    List<FeeItemRow> grille,
  ) async {
    setState(() => _occupe = true);
    final ok = await avecMessage(context, () async {
      if (_classes.isEmpty) {
        throw const UserMessage('Cochez au moins une classe.');
      }
      final repo = ref.read(financesRepositoryProvider);
      final saisies = {
        for (final l in _lignes.values) l.code: (l, _versements(l)),
      };
      for (final c in classes.where((c) => _classes.contains(c.id))) {
        final applicables = fraisApplicables(
          grille,
          niveau: c.levelCode,
          classe: c.id,
        );
        for (final MapEntry(key: code, value: (l, versements))
            in saisies.entries) {
          final propre = grille
              .where(
                (f) =>
                    f.classId == c.id &&
                    f.rubric == code &&
                    f.deletedAt == null,
              )
              .firstOrNull;
          final herite = applicables
              .where((f) => f.rubric == code && f.classId == null)
              .firstOrNull;
          final champs = {
            'id':
                propre?.id ??
                FinancesRepository.idFraisClasse(annee.id, c.id, code),
            'school_id': ecole.id,
            'school_year_id': annee.id,
            'rubric': code,
            'label': l.libelle,
            'class_id': c.id,
            'level_code': null,
            'payment_terms': l.modalite,
          };
          if (versements.isNotEmpty) {
            await repo.enregistrerFrais(champs, versements);
          } else if (propre != null && herite == null) {
            await repo.retirerLigne(propre.id);
          } else if (herite != null) {
            // Rubrique du niveau non due pour cette classe : frais à 0.
            await repo.enregistrerFrais(champs, const [], autoriserZero: true);
          }
        }
        await repo.enregistrerNote(
          schoolId: ecole.id,
          yearId: annee.id,
          classId: c.id,
          texte: _observations.text,
        );
      }
      return true;
    });
    if (!mounted) return;
    setState(() {
      _occupe = false;
      if (ok ?? false) _modifie = false;
    });
    if (ok ?? false) {
      unawaited(ref.read(syncEngineProvider).syncNow());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Frais enregistrés pour ${_classes.length} classe'
            '${_classes.length > 1 ? 's' : ''}.',
          ),
        ),
      );
    }
  }

  Future<void> _ajouterRubrique(SchoolRow ecole) async {
    final nom = await demanderNom(context, titre: 'Nouvelle rubrique');
    if (nom == null || !mounted) return;
    await avecMessage(
      context,
      () => ref.read(financesRepositoryProvider).ajouterRubrique(ecole.id, nom),
    );
  }

  Future<void> _supprimerRubrique(
    SchoolRow ecole,
    SchoolYearRow annee,
    List<FeeRubricRow> rubriques,
    List<ClassRow> classes,
    List<FeeItemRow> grille,
  ) async {
    final choix = await showDialog<(FeeRubricRow, bool)>(
      context: context,
      builder: (ctx) => _DialogueSuppression(
        rubriques: rubriques,
        nbClasses: _classes.length,
      ),
    );
    if (choix == null || !mounted) return;
    final (r, toutEcole) = choix;
    final cibles = [
      for (final f in grille)
        if (f.rubric == r.code &&
            f.deletedAt == null &&
            (toutEcole || f.classId == null || _classes.contains(f.classId)))
          f,
    ];
    final repo = ref.read(financesRepositoryProvider);
    final recus = await repo.recusSurFrais(cibles.map((f) => f.id));
    if (!mounted) return;
    final ok = await confirmer(
      context,
      titre: 'Supprimer « ${r.label} » ?',
      message:
          '${toutEcole ? 'La rubrique sera retirée de toute l’école.' : 'La '
                    'rubrique sera retirée de la grille des '
                    '${_classes.length} classe(s) cochée(s).'}'
          '${recus == 0 ? '' : '\n\n$recus reçu(s) déjà fait(s) pour cette '
                    'rubrique restent valables et visibles dans '
                    'l’historique ; seul le montant dû disparaît.'}',
      bouton: 'Supprimer',
    );
    if (!ok || !mounted) return;
    await avecMessage(context, () async {
      for (final c in classes) {
        if (!toutEcole && !_classes.contains(c.id)) continue;
        final propre = grille
            .where(
              (f) =>
                  f.classId == c.id &&
                  f.rubric == r.code &&
                  f.deletedAt == null,
            )
            .firstOrNull;
        if (propre != null) await repo.retirerLigne(propre.id);
        final herite = fraisApplicables(
          grille,
          niveau: c.levelCode,
          classe: c.id,
        ).where((f) => f.rubric == r.code && f.classId == null).firstOrNull;
        if (herite != null && !toutEcole) {
          await repo.enregistrerFrais(
            {
              'id': FinancesRepository.idFraisClasse(annee.id, c.id, r.code),
              'school_id': ecole.id,
              'school_year_id': annee.id,
              'rubric': r.code,
              'label': r.label,
              'class_id': c.id,
            },
            const [],
            autoriserZero: true,
          );
        }
      }
      if (toutEcole) {
        for (final f in cibles) {
          await repo.retirerLigne(f.id);
        }
        await repo.retirerRubrique(r);
      }
    });
    _chargePour = null;
  }

  /// Récapitulatif d'une classe d'après ce qui est enregistré.
  RecapClasse _recap(
    ClassRow c,
    List<FeeItemRow> grille,
    List<FeeInstallmentRow> tranches,
    List<FeeNoteRow> notes,
    List<FeeRubricRow> rubriques,
  ) {
    final ordre = {for (final (i, r) in rubriques.indexed) r.code: i};
    final lignes =
        fraisApplicables(
          grille,
          niveau: c.levelCode,
          classe: c.id,
        ).where((f) => f.amount > 0).toList()..sort(
          (a, b) => (a.rubric == 'scolarite' ? -1 : ordre[a.rubric] ?? 99)
              .compareTo(b.rubric == 'scolarite' ? -1 : ordre[b.rubric] ?? 99),
        );
    final out = <LigneRecap>[];
    var scol = 0;
    var autres = 0;
    for (final f in lignes) {
      final siens = [
        for (final t in tranches)
          if (t.feeItemId == f.id) t,
      ];
      final mod = modalites[f.paymentTerms] ?? '';
      if (f.rubric == 'scolarite') {
        scol += f.amount;
      } else {
        autres += f.amount;
      }
      if (siens.length <= 1) {
        out.add(
          LigneRecap(
            f.label,
            f.amount,
            mod,
            siens.isEmpty
                ? 'À l’inscription'
                : textePeriode(siens.single.startsOn, siens.single.dueOn),
          ),
        );
        continue;
      }
      out.add(LigneRecap(f.label, f.amount, mod, '${siens.length} versements'));
      for (final t in siens) {
        out.add(
          LigneRecap(
            t.label,
            t.amount,
            '',
            textePeriode(t.startsOn, t.dueOn),
            versement: true,
          ),
        );
      }
    }
    return RecapClasse(
      classe: c.name,
      lignes: out,
      totalScolarite: scol,
      totalAutres: autres,
      observations: notes.where((n) => n.classId == c.id).firstOrNull?.notes,
    );
  }

  Future<void> _sortirRecap(
    SchoolRow ecole,
    SchoolYearRow annee,
    List<ClassRow> classes,
    List<FeeItemRow> grille,
    List<FeeInstallmentRow> tranches,
    List<FeeNoteRow> notes,
    List<FeeRubricRow> rubriques, {
    required bool partager,
  }) async {
    if (_classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cochez au moins une classe.')),
      );
      return;
    }
    if (_modifie) {
      final ok = await confirmer(
        context,
        titre: 'Enregistrer d’abord ?',
        message:
            'Le récapitulatif reprend les frais enregistrés : enregistrez '
            'vos modifications avant de l’imprimer.',
        bouton: 'Enregistrer',
      );
      if (!ok || !mounted) return;
      await _enregistrer(ecole, annee, classes, grille);
      return;
    }
    final cochees = classes.where((c) => _classes.contains(c.id)).toList();
    var parClasse = false;
    if (cochees.length > 1) {
      final r = await showDialog<bool>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Récapitulatif'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Un document regroupant les ${cochees.length} classes',
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Un document par classe'),
            ),
          ],
        ),
      );
      if (r == null) return;
      parClasse = r;
    }
    if (!mounted) return;
    await avecMessage(context, () async {
      final polices = await ref.read(policesPdfProvider.future);
      final media = ref.read(mediaDirProvider);
      final logo = ecole.logoPath == null || media == null
          ? null
          : File(p.join(media.path, ecole.logoPath));
      final octetsLogo = logo != null && logo.existsSync()
          ? await logo.readAsBytes()
          : null;
      final recaps = [
        for (final c in cochees) _recap(c, grille, tranches, notes, rubriques),
      ];
      final sortie = ref.read(sortiePdfProvider);
      final lots = parClasse
          ? [
              for (final r in recaps) [r],
            ]
          : [recaps];
      for (final lot in lots) {
        final pdf = await pdfRecapFrais(
          polices,
          ecole: ecole.name,
          anneeScolaire: annee.label,
          classes: lot,
          commune: ecole.commune,
          telephone: ecole.phone,
          logo: octetsLogo,
        );
        final nom = lot.length == 1
            ? 'Frais_${lot.single.classe.replaceAll(' ', '_')}_'
                  '${annee.label}.pdf'
            : 'Frais_scolaires_${annee.label}.pdf';
        await (partager ? sortie.partager : sortie.imprimer)(pdf, nom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = contexteFinances(ref);
    if (c == null) return _chargementPage();
    final (ecole, annee) = c;
    final classes = ref.watch(classesProvider(annee.id)).value;
    final grille = ref.watch(grilleProvider(annee.id)).value;
    final tranches = ref.watch(tranchesProvider).value;
    final notes = ref.watch(notesFraisProvider(annee.id)).value;
    final rubriques = ref.watch(rubriquesProvider(ecole.id)).value;
    if (classes == null ||
        grille == null ||
        tranches == null ||
        notes == null ||
        rubriques == null) {
      return _chargementPage();
    }
    // Scolarité d'abord, puis les rubriques dans l'ordre de l'école.
    final ordonnees = [
      ...rubriques.where((r) => r.code == 'scolarite'),
      ...rubriques.where((r) => r.code != 'scolarite'),
    ];
    final cochees = classes.where((k) => _classes.contains(k.id)).toList();
    _charger(cochees.firstOrNull, grille, tranches, notes, ordonnees);
    for (final r in ordonnees) {
      _ligne(r.code, r.label);
    }
    final differentes = cochees.length < 2
        ? const <ClassRow>[]
        : [
            for (final k in cochees.skip(1))
              if (_empreinte(k, grille, tranches) !=
                  _empreinte(cochees.first, grille, tranches))
                k,
          ];
    final lignes = [for (final r in ordonnees) ?_lignes[r.code]];
    final totalScol = lignes
        .where((l) => l.scolarite)
        .fold<int>(0, (s, l) => s + l.total);
    final totalAutres = lignes
        .where((l) => !l.scolarite)
        .fold<int>(0, (s, l) => s + l.total);
    final large = MediaQuery.sizeOf(context).width >= 720;
    return EcoleScaffold(
      title: 'Grille des frais',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Année ${annee.label} • montants en FCFA',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          // A. Classes concernées.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Classes concernées',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      TextButton.icon(
                        key: const Key('toutes-classes'),
                        icon: Icon(
                          _classes.length == classes.length
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        label: const Text('Toutes'),
                        onPressed: () => _changerClasses(
                          _classes.length == classes.length
                              ? <String>{}
                              : {for (final k in classes) k.id},
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final k in classes)
                        FilterChip(
                          key: Key('classe-${k.id}'),
                          label: Text(k.name),
                          selected: _classes.contains(k.id),
                          onSelected: (v) => _changerClasses({
                            ..._classes.where((x) => x != k.id),
                            if (v) k.id,
                          }),
                        ),
                    ],
                  ),
                  if (classes.isEmpty)
                    const Text('Créez d’abord les classes de l’année.'),
                ],
              ),
            ),
          ),
          if (_classes.isEmpty)
            const InfoMessage(
              'Cochez une ou plusieurs classes : la grille affiche leurs '
              'frais ; « Enregistrer » les applique à chaque classe cochée '
              '(chaque classe garde ensuite son propre paramétrage).',
            ),
          if (differentes.isNotEmpty)
            InfoMessage(
              'Ces classes ont des frais différents : la grille montre ceux '
              'de ${cochees.first.name}. « Enregistrer » appliquera la '
              'grille à ${differentes.map((k) => k.name).join(', ')} aussi.',
              icon: Icons.warning_amber,
            ),
          if (_classes.isNotEmpty) ...[
            const SizedBox(height: 8),
            // B. La grille.
            if (large) _enteteTableau(context),
            for (final l in lignes)
              _ligneGrille(
                context,
                l,
                large: large,
                onSupprimer: () {
                  for (final v in l.versements) {
                    v.vider();
                  }
                  _marquer();
                  setState(() {});
                },
              ),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('ajouter-rubrique'),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une rubrique'),
                  onPressed: () => _ajouterRubrique(ecole),
                ),
                OutlinedButton.icon(
                  key: const Key('supprimer-rubrique'),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Supprimer une rubrique'),
                  onPressed: () => _supprimerRubrique(
                    ecole,
                    annee,
                    ordonnees,
                    classes,
                    grille,
                  ),
                ),
              ],
            ),
            // D. Totaux.
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _total(
                      context,
                      'Total de la scolarité',
                      totalScol,
                      cle: 'total-scolarite',
                    ),
                    _total(
                      context,
                      'Total des autres rubriques',
                      totalAutres,
                      cle: 'total-autres',
                    ),
                    const Divider(),
                    _total(
                      context,
                      'Total à payer par élève',
                      totalScol + totalAutres,
                      fort: true,
                      cle: 'total-eleve',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('observations-frais'),
              controller: _observations,
              maxLines: 2,
              onChanged: (_) => _marquer(),
              decoration: const InputDecoration(
                labelText: 'Observations (imprimées sur le récapitulatif)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            BigButton(
              icon: Icons.check,
              label: _classes.length > 1
                  ? 'Enregistrer pour les ${_classes.length} classes'
                  : 'Enregistrer',
              onPressed: _occupe
                  ? null
                  : () => _enregistrer(ecole, annee, classes, grille),
            ),
            const SizedBox(height: 10),
            // E. Récapitulatif.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('imprimer-recap'),
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimer le récapitulatif'),
                    onPressed: () => _sortirRecap(
                      ecole,
                      annee,
                      classes,
                      grille,
                      tranches,
                      notes,
                      ordonnees,
                      partager: false,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('partager-recap'),
                    icon: const Icon(Icons.share),
                    label: const Text('Partager sur WhatsApp'),
                    onPressed: () => _sortirRecap(
                      ecole,
                      annee,
                      classes,
                      grille,
                      tranches,
                      notes,
                      ordonnees,
                      partager: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Change les classes cochées. La grille montre la première classe
  /// cochée ; une saisie en cours est gardée (elle s'appliquera aux classes
  /// cochées au moment d'enregistrer).
  void _changerClasses(Set<String> nouvelles) => setState(() {
    final avant = _classes.toList();
    _classes
      ..clear()
      ..addAll(nouvelles);
    if (nouvelles.isEmpty ||
        (!_modifie && (avant.isEmpty || !nouvelles.contains(avant.first)))) {
      _chargePour = null;
    }
  });

  static Widget _chargementPage() => const EcoleScaffold(
    title: 'Grille des frais',
    body: LinearProgressIndicator(),
  );

  Widget _total(
    BuildContext context,
    String libelle,
    int montant, {
    required String cle,
    bool fort = false,
  }) {
    final style = fort
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.titleSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(libelle, style: style)),
          Text(fcfa(montant), key: Key(cle), style: style),
        ],
      ),
    );
  }

  Widget _enteteTableau(BuildContext context) {
    final s = Theme.of(context).textTheme.labelLarge;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Rubrique', style: s)),
          Expanded(flex: 2, child: Text('Montant (FCFA)', style: s)),
          Expanded(flex: 3, child: Text('Modalités', style: s)),
          Expanded(flex: 5, child: Text('Période / date limite', style: s)),
          SizedBox(width: 48, child: Text('Actions', style: s)),
        ],
      ),
    );
  }

  Widget _champ(
    TextEditingController c,
    String label, {
    Key? key,
    bool date = false,
  }) => TextField(
    key: key,
    controller: c,
    onChanged: (_) => _marquer(),
    keyboardType: date ? TextInputType.datetime : TextInputType.number,
    inputFormatters: date ? null : [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(
      isDense: true,
      labelText: label,
      hintText: date ? 'jj/mm/aaaa' : null,
      border: const OutlineInputBorder(),
    ),
  );

  Widget _periode(_RubriqueSaisie l, int i, _VersementSaisi v) {
    final inscriptionPossible = !l.scolarite || i == 0;
    final cle = '${l.code}-${i + 1}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (inscriptionPossible)
          InkWell(
            key: Key('inscription-$cle'),
            onTap: () {
              setState(() => v.aLInscription = !v.aLInscription);
              _marquer();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  v.aLInscription
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 20,
                ),
                const SizedBox(width: 4),
                const Text('À l’inscription'),
              ],
            ),
          ),
        if (!v.aLInscription || !inscriptionPossible)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(
                  child: _champ(
                    v.du,
                    'Du (facultatif)',
                    key: Key('du-$cle'),
                    date: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _champ(
                    v.au,
                    'Au (date limite)',
                    key: Key('au-$cle'),
                    date: true,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _modalite(_RubriqueSaisie l) => DropdownButton<String>(
    key: Key('modalite-${l.code}'),
    isExpanded: true,
    value: l.modalite,
    items: [
      for (final MapEntry(key: k, value: v) in modalites.entries)
        DropdownMenuItem(value: k, child: Text(v)),
    ],
    onChanged: (v) {
      setState(() => l.modalite = v ?? l.modalite);
      _marquer();
    },
  );

  Widget _ligneGrille(
    BuildContext context,
    _RubriqueSaisie l, {
    required bool large,
    required VoidCallback onSupprimer,
  }) {
    final titre = Theme.of(context).textTheme.titleSmall;
    final effacer = IconButton(
      key: Key('vider-${l.code}'),
      tooltip: 'Effacer cette ligne',
      icon: const Icon(Icons.backspace_outlined),
      onPressed: onSupprimer,
    );
    Widget versement(int i, _VersementSaisi v) {
      final montant = _champ(
        v.montant,
        l.scolarite ? v.libelle : 'Montant',
        key: Key('montant-${l.code}-${i + 1}'),
      );
      if (large) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 12),
                  child: Text(
                    l.scolarite ? v.libelle : l.libelle,
                    style: l.scolarite ? null : titre,
                  ),
                ),
              ),
              Expanded(flex: 2, child: montant),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: i == 0 ? _modalite(l) : const SizedBox(),
              ),
              const SizedBox(width: 8),
              Expanded(flex: 5, child: _periode(l, i, v)),
              SizedBox(width: 48, child: i == 0 ? effacer : null),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [montant, const SizedBox(height: 4), _periode(l, i, v)],
        ),
      );
    }

    return Card(
      key: Key('ligne-grille-${l.code}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!large || l.scolarite)
              Row(
                children: [
                  Expanded(child: Text(l.libelle, style: titre)),
                  if (l.scolarite)
                    Text(
                      fcfa(l.total),
                      key: const Key('total-ligne-scolarite'),
                      style: titre,
                    ),
                  if (!large) effacer,
                ],
              ),
            if (!large) _modalite(l),
            for (final (i, v) in l.versements.indexed) versement(i, v),
            if (l.scolarite)
              Text(
                'Scolarité = 1er + 2e + 3e versement (calculé, non '
                'modifiable).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

/// Choix de la rubrique à supprimer : classes cochées ou toute l'école.
class _DialogueSuppression extends StatefulWidget {
  const new({required this.rubriques, required this.nbClasses});
  final List<FeeRubricRow> rubriques;
  final int nbClasses;

  @override
  State<_DialogueSuppression> createState() => _DialogueSuppressionState();
}

class _DialogueSuppressionState extends State<_DialogueSuppression> {
  FeeRubricRow? _r;
  bool _toutEcole = false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Supprimer une rubrique'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioGroup<String>(
            groupValue: _r?.code,
            onChanged: (c) => setState(
              () => _r = widget.rubriques.where((r) => r.code == c).firstOrNull,
            ),
            child: Column(
              children: [
                for (final r in widget.rubriques)
                  RadioListTile<String>(
                    key: Key('choix-supprimer-${r.code}'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(r.label),
                    value: r.code,
                  ),
              ],
            ),
          ),
          const Divider(),
          RadioGroup<bool>(
            groupValue: _toutEcole,
            onChanged: (v) => setState(() => _toutEcole = v ?? false),
            child: Column(
              children: [
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    'Pour les ${widget.nbClasses} classe(s) cochée(s) '
                    'seulement',
                  ),
                  value: false,
                ),
                const RadioListTile<bool>(
                  key: Key('supprimer-toute-ecole'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text('Pour toute l’école (retirer la rubrique)'),
                  value: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: _r == null
            ? null
            : () => Navigator.pop(context, (_r!, _toutEcole)),
        child: const Text('Continuer'),
      ),
    ],
  );
}

/// Demande un nom (nouvelle rubrique).
Future<String?> demanderNom(
  BuildContext context, {
  required String titre,
  String initial = '',
}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titre),
      content: TextField(
        key: const Key('nom-rubrique'),
        controller: c,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Nom (ex. Frais d’examen)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, c.text.trim()),
          child: const Text('Valider'),
        ),
      ],
    ),
  );
}
