import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/cantine/presentation/cantine_providers.dart';
import 'package:ecoleplus/features/finances/data/finances_repository.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

final financesRepositoryProvider = Provider<FinancesRepository>(
  (ref) => FinancesRepository(
    ref.watch(localStoreProvider),
    remote: ref.watch(syncRemoteProvider),
    mediaDir: ref.watch(mediaDirProvider),
  ),
);

/// Date du jour (« 2026-10-12 ») ; remplaçable dans les tests.
final aujourdhuiProvider = Provider<String>(
  (ref) => ref.watch(clockProvider).nowIso().substring(0, 10),
);

final StreamProviderFamily<List<FeeItemRow>, String> grilleProvider =
    StreamProvider.family(
      (ref, yearId) =>
          ref.watch(financesRepositoryProvider).watchGrille(yearId),
    );

final StreamProviderFamily<List<FeeRubricRow>, String> rubriquesProvider =
    StreamProvider.family((ref, schoolId) {
      // La rubrique « Cantine » n'apparaît que si le module est actif.
      final cantine = ref.watch(cantineActiveProvider(schoolId));
      return ref
          .watch(financesRepositoryProvider)
          .watchRubriques(schoolId)
          .map(
            (l) => [
              for (final r in l)
                if (cantine || r.code != rubriqueCantine) r,
            ],
          );
    });

/// Libellés des rubriques de l'école connectée (code → libellé).
final Provider<Map<String, String>> nomsRubriquesProvider = Provider((ref) {
  final s = ref.watch(sessionProvider).value;
  if (s == null) return const {};
  return {
    for (final r
        in ref.watch(rubriquesProvider(s.schoolId)).value ??
            const <FeeRubricRow>[])
      r.code: r.label,
  };
});

final StreamProvider<List<FeeInstallmentRow>> tranchesProvider = StreamProvider(
  (ref) => ref.watch(financesRepositoryProvider).watchTranches(),
);

final StreamProvider<List<DiscountRow>> remisesProvider = StreamProvider(
  (ref) => ref.watch(financesRepositoryProvider).watchRemises(),
);

final StreamProviderFamily<List<(DiscountRow, StudentDiscountRow)>, String>
attributionsProvider = StreamProvider.family(
  (ref, yearId) =>
      ref.watch(financesRepositoryProvider).watchAttributions(yearId),
);

final StreamProviderFamily<List<PaymentRow>, String> paiementsProvider =
    StreamProvider.family(
      (ref, yearId) =>
          ref.watch(financesRepositoryProvider).watchPaiements(yearId),
    );

final StreamProviderFamily<List<FeeNoteRow>, String> notesFraisProvider =
    StreamProvider.family(
      (ref, yearId) => ref.watch(financesRepositoryProvider).watchNotes(yearId),
    );

/// Détail des reçus de l'année (A23).
final StreamProviderFamily<List<PaymentAllocationRow>, String> detailsProvider =
    StreamProvider.family(
      (ref, yearId) =>
          ref.watch(financesRepositoryProvider).watchDetails(yearId),
    );

final StreamProviderFamily<PaymentRow?, String> paiementProvider =
    StreamProvider.family(
      (ref, id) => ref.watch(financesRepositoryProvider).watchPaiement(id),
    );

final StreamProviderFamily<List<ExpenseRow>, String> depensesProvider =
    StreamProvider.family(
      (ref, yearId) =>
          ref.watch(financesRepositoryProvider).watchDepenses(yearId),
    );

final StreamProviderFamily<List<CashClosingRow>, String> cloturesProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(financesRepositoryProvider).watchClotures(schoolId),
    );

/// Élève, sa classe et sa situation financière de l'année.
class LigneEleve {
  const new(this.eleve, this.situation);
  final EleveDansAnnee eleve;
  final SituationEleve situation;
  String get nom => '${eleve.eleve.lastName} ${eleve.eleve.firstNames}';
  String get classe => eleve.classe?.name ?? 'Sans classe';
}

/// Situation de tous les élèves présents (calculée sur le téléphone, sans
/// Internet). Clé : (école, année).
final ProviderFamily<List<LigneEleve>?, (String, String)> situationsProvider =
    Provider.family((ref, k) {
      final (schoolId, yearId) = k;
      final eleves = ref.watch(elevesProvider((schoolId, yearId, false))).value;
      final grille = ref.watch(grilleProvider(yearId)).value;
      final tranches = ref.watch(tranchesProvider).value;
      final remises = ref.watch(attributionsProvider(yearId)).value;
      final paiements = ref.watch(paiementsProvider(yearId)).value;
      final details = ref.watch(detailsProvider(yearId)).value;
      if (details == null ||
          eleves == null ||
          grille == null ||
          tranches == null ||
          remises == null ||
          paiements == null) {
        return null;
      }
      // Cantine (phase 11) : la cotisation ne s'applique qu'aux
      // bénéficiaires dont la famille participe, module actif.
      final cantine = ref.watch(cantineActiveProvider(schoolId));
      final mode = ref.watch(modeCantineProvider(schoolId));
      final beneficiaires = cantine
          ? ref.watch(beneficiairesProvider(yearId)).value
          : const <String, CanteenBeneficiaryRow>{};
      if (beneficiaires == null ||
          (cantine && !ref.watch(reglagesCantineProvider(schoolId)).hasValue)) {
        return null;
      }
      final jour = ref.watch(aujourdhuiProvider);
      // Ordre de la grille : scolarité d'abord, puis l'ordre des rubriques
      // de l'école (A23).
      final ordre = {
        for (final (i, r)
            in (ref.watch(rubriquesProvider(schoolId)).value ??
                    const <FeeRubricRow>[])
                .indexed)
          r.code: i,
      };
      int rang(FeeItemRow f) =>
          f.rubric == 'scolarite' ? -1 : ordre[f.rubric] ?? 999;
      List<FeeItemRow> trier(List<FeeItemRow> l) =>
          l..sort((a, b) => rang(a).compareTo(rang(b)));
      return [
        for (final e in eleves)
          LigneEleve(
            e,
            situation(
              studentId: e.eleve.id,
              lignes: trier(
                avecCantine(
                  fraisApplicables(
                    grille,
                    niveau: e.inscription?.levelCode ?? e.classe?.levelCode,
                    classe: e.classe?.id,
                  ),
                  actif: cantine,
                  participeAuxFrais: participe(mode, beneficiaires[e.eleve.id]),
                ),
              ),
              tranches: tranches,
              remises: remises,
              paiements: paiements,
              allocations: details,
              aujourdhui: jour,
            ),
          ),
      ];
    });

/// Situations sans la cantine : impayés de scolarité (distincts des
/// impayés de cantine, 10.9).
final ProviderFamily<List<LigneEleve>?, (String, String)>
situationsHorsCantineProvider = Provider.family((ref, k) {
  final toutes = ref.watch(situationsProvider(k));
  if (toutes == null) return null;
  return [
    for (final l in toutes)
      LigneEleve(
        l.eleve,
        filtrerRubrique(l.situation, rubriqueCantine, garder: false),
      ),
  ];
});

/// Cotisations de cantine : seulement les élèves qui ont la rubrique.
final ProviderFamily<List<LigneEleve>?, (String, String)>
situationsCantineProvider = Provider.family((ref, k) {
  final toutes = ref.watch(situationsProvider(k));
  if (toutes == null) return null;
  return [
    for (final l in toutes)
      if (l.situation.lignes.any((x) => x.ligne.rubric == rubriqueCantine))
        LigneEleve(
          l.eleve,
          filtrerRubrique(l.situation, rubriqueCantine, garder: true),
        ),
  ];
});
