import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
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
      if (eleves == null ||
          grille == null ||
          tranches == null ||
          remises == null ||
          paiements == null) {
        return null;
      }
      final jour = ref.watch(aujourdhuiProvider);
      return [
        for (final e in eleves)
          LigneEleve(
            e,
            situation(
              studentId: e.eleve.id,
              lignes: fraisApplicables(
                grille,
                niveau: e.inscription?.levelCode ?? e.classe?.levelCode,
                classe: e.classe?.id,
              ),
              tranches: tranches,
              remises: remises,
              paiements: paiements,
              aujourdhui: jour,
            ),
          ),
      ];
    });
