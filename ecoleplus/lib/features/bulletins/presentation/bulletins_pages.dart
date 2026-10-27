import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/bulletins/data/bulletins_repository.dart';
import 'package:ecoleplus/features/bulletins/domain/bulletin.dart';
import 'package:ecoleplus/features/bulletins/pdf/pdf_bulletin.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/data/grades_repository.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:ecoleplus/features/grades/presentation/grades_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

final bulletinsRepositoryProvider = Provider<BulletinsRepository>(
  (ref) => BulletinsRepository(
    ref.watch(localStoreProvider),
    ref.watch(gradesRepositoryProvider),
  ),
);
final StreamProviderFamily<List<ReportCardRow>, String> cartesProvider =
    StreamProvider.family(
      (ref, classId) =>
          ref.watch(bulletinsRepositoryProvider).watchCartes(classId),
    );
final StreamProviderFamily<ModeleBulletin, String> modeleBulletinProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(bulletinsRepositoryProvider).watchModele(schoolId),
    );

/// Bulletins d'une classe : par trimestre ou pour l'année ; appréciations
/// (enseignant), observations et décision (directeur) ; PDF d'un élève ou
/// de toute la classe.
class BulletinsPage extends ConsumerStatefulWidget {
  const new(this.classId, {super.key});
  final String classId;

  @override
  ConsumerState<BulletinsPage> createState() => _BulletinsState();
}

class _BulletinsState extends ConsumerState<BulletinsPage> {
  int? _periode;
  bool _occupe = false;

  Future<void> _pdf(DonneesClasse d, int p, {String? eleve}) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final repo = ref.read(bulletinsRepositoryProvider);
      final liste = await repo.bulletins(d, p, eleve: eleve);
      final modele = await repo.watchModele(d.classe.schoolId).first;
      final pdf = await pdfBulletins(
        await ref.read(policesPdfProvider.future),
        modele,
        liste,
      );
      final qui = eleve == null ? d.classe.name : liste.single.eleve;
      final nom = 'Bulletin_${qui}_${periodeTexte(p)}'.replaceAll(
        RegExp(r'[^\p{L}\p{N}\-]+', unicode: true),
        '_',
      );
      await ref.read(sortiePdfProvider).imprimer(pdf, '$nom.pdf');
      return true;
    });
    if (mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(donneesClasseProvider(widget.classId)).value;
    final cartes = ref.watch(cartesProvider(widget.classId)).value ?? const [];
    final session = ref.watch(sessionProvider).value;
    if (d == null || session == null) {
      return const EcoleScaffold(
        title: 'Bulletins',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final p = _periode ??= d.dernierTrimestreNote;
    final annuel = p == anneeEntiere;
    final directeur = session.role == 'directeur';
    final enseignant = directeur || session.role == 'enseignant';
    final c = annuel ? d.annee() : d.trimestre(p);
    final resultats = {for (final r in c.resultats) r.eleve.id: r};
    final repo = ref.read(bulletinsRepositoryProvider);
    Future<void> save(String eleve, String col, String? v) =>
        repo.enregistrerCarte(d, eleve, p, {col: v});
    return EcoleScaffold(
      title: 'Bulletins — ${d.classe.name}',
      body: ListView(
        key: const Key('bulletins'),
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in const [1, 2, 3, anneeEntiere])
                ChoiceChip(
                  key: Key('bulletin-periode-$t'),
                  label: Text(periodeTexte(t)),
                  selected: p == t,
                  onSelected: (_) => setState(() => _periode = t),
                ),
            ],
          ),
          const SizedBox(height: 12),
          BigButton(
            key: const Key('bulletins-classe'),
            icon: Icons.picture_as_pdf,
            label: 'Bulletins de toute la classe (PDF)',
            onPressed: _occupe || d.eleves.isEmpty ? null : () => _pdf(d, p),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les notes, moyennes et rangs sont recalculés à chaque fois : '
            'une note corrigée change aussitôt le bulletin.',
          ),
          const SizedBox(height: 8),
          for (final s in d.eleves)
            Card(
              key: Key('eleve-bulletin-${s.id}'),
              child: ExpansionTile(
                title: Text('${s.lastName} ${s.firstNames}'),
                subtitle: Text(_resume(resultats[s.id]!, c, annuel)),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: () {
                  final carte = BulletinsRepository.carteDe(cartes, d, s.id, p);
                  return [
                    AutoSaveField(
                      key: ValueKey('appreciation-${s.id}-$p'),
                      label: 'Appréciation de l’enseignant(e)',
                      initial: carte?.teacherAppreciation,
                      maxLines: 3,
                      enabled: enseignant,
                      onSave: (v) => save(s.id, 'teacher_appreciation', v),
                    ),
                    AutoSaveField(
                      key: ValueKey('observation-${s.id}-$p'),
                      label: 'Observations du directeur',
                      initial: carte?.directorObservation,
                      maxLines: 3,
                      enabled: directeur,
                      onSave: (v) => save(s.id, 'director_observation', v),
                    ),
                    if (annuel || carte?.decision != null) ...[
                      AutoSaveField(
                        key: ValueKey('decision-${s.id}-$p-${carte?.decision}'),
                        label: 'Décision',
                        initial: carte?.decision,
                        enabled: directeur,
                        onSave: (v) => save(s.id, 'decision', v),
                      ),
                      if (directeur)
                        Wrap(
                          spacing: 6,
                          children: [
                            for (final dec in decisionsProposees)
                              ActionChip(
                                label: Text(dec),
                                onPressed: () => save(s.id, 'decision', dec),
                              ),
                          ],
                        ),
                    ],
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: Key('bulletin-${s.id}'),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Bulletin de l’élève (PDF)'),
                      onPressed: _occupe ? null : () => _pdf(d, p, eleve: s.id),
                    ),
                  ];
                }(),
              ),
            ),
        ],
      ),
    );
  }

  static String _resume(Resultat r, Classement c, bool annuel) {
    if (r.moyenne == null) {
      return annuel
          ? 'Il manque la moyenne d’un trimestre'
          : 'Aucune note comptée';
    }
    final rang = r.rang == null
        ? r.rangTexte
        : '${r.rangTexte}/${c.statistiques.effectif}';
    return 'Moyenne ${centiemesTexte(r.moyenne)} · $rang';
  }
}

/// Modèle de bulletin de l'école (directeur) : ce qui s'imprime.
class ModeleBulletinPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final m = ref.watch(modeleBulletinProvider(session.schoolId)).value;
    if (m == null) {
      return const EcoleScaffold(
        title: 'Modèle de bulletin',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final repo = ref.read(bulletinsRepositoryProvider);
    Future<void> changer(Map<String, Object> c) =>
        repo.enregistrerModele(session.schoolId, m.avec(c));
    Widget interrupteur(String cle, String titre, {required bool valeur}) =>
        SwitchListTile(
          key: Key('modele-$cle'),
          title: Text(titre),
          value: valeur,
          onChanged: (v) => changer({cle: v}),
        );
    return EcoleScaffold(
      title: 'Modèle de bulletin',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ces réglages valent pour tous les bulletins de l’école. Les '
            'notes, moyennes et rangs sont toujours calculés par '
            'l’application.',
          ),
          const SizedBox(height: 12),
          AutoSaveField(
            key: ValueKey('modele-titre-${m.titre}'),
            label: 'Titre du bulletin',
            initial: m.titre,
            onSave: (v) => changer({'titre': v ?? ''}),
          ),
          interrupteur(
            'coefficients',
            'Coefficients et points',
            valeur: m.afficherCoefficients,
          ),
          interrupteur('total', 'Total des points', valeur: m.afficherTotal),
          interrupteur('rang', 'Rang (« 7e/39 »)', valeur: m.afficherRang),
          interrupteur('mention', 'Mention', valeur: m.afficherMention),
          interrupteur(
            'statistiques',
            'Moyenne de la classe, meilleure et plus faible',
            valeur: m.afficherStatistiques,
          ),
          interrupteur(
            'parents',
            'Signature des parents',
            valeur: m.signatureParents,
          ),
          AutoSaveField(
            key: ValueKey('modele-enseignant-${m.libelleEnseignant}'),
            label: 'Signature de l’enseignant (libellé)',
            initial: m.libelleEnseignant,
            onSave: (v) => changer({'enseignant': v ?? ''}),
          ),
          AutoSaveField(
            key: ValueKey('modele-directeur-${m.libelleDirecteur}'),
            label: 'Signature du directeur (libellé)',
            initial: m.libelleDirecteur,
            onSave: (v) => changer({'directeur': v ?? ''}),
          ),
          AutoSaveField(
            key: ValueKey('modele-pied-${m.piedDePage}'),
            label: 'Texte en bas du bulletin (facultatif)',
            initial: m.piedDePage,
            maxLines: 2,
            onSave: (v) => changer({'pied': v ?? ''}),
          ),
        ],
      ),
    );
  }
}
