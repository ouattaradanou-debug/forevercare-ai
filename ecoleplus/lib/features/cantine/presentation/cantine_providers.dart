import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/cantine/data/cantine_repository.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

final cantineRepositoryProvider = Provider<CantineRepository>(
  (ref) => CantineRepository(ref.watch(localStoreProvider)),
);

/// Le module Cantine est-il actif pour l'école ? (Il nécessite les
/// Finances, toujours actives en version 1.)
final ProviderFamily<bool, String> cantineActiveProvider = Provider.family(
  (ref, schoolId) =>
      ref
          .watch(modulesProvider(schoolId))
          .value
          ?.any((m) => m.$1.key == 'cantine' && m.$2) ??
      false,
);

final StreamProviderFamily<CanteenSettingsRow?, String>
reglagesCantineProvider = StreamProvider.family(
  (ref, schoolId) =>
      ref.watch(cantineRepositoryProvider).watchReglages(schoolId),
);

/// Mode de fonctionnement (par défaut : sans participation des familles).
final ProviderFamily<String, String> modeCantineProvider = Provider.family(
  (ref, schoolId) =>
      ref.watch(reglagesCantineProvider(schoolId)).value?.mode ??
      'sans_participation',
);

/// Bénéficiaires de l'année, par élève.
final StreamProviderFamily<Map<String, CanteenBeneficiaryRow>, String>
beneficiairesProvider = StreamProvider.family(
  (ref, yearId) => ref
      .watch(cantineRepositoryProvider)
      .watchBeneficiaires(yearId)
      .map((l) => {for (final b in l) b.studentId: b}),
);

final StreamProviderFamily<List<MealServiceRow>, String> pointagesProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(cantineRepositoryProvider).watchPointages(schoolId),
    );

final StreamProviderFamily<List<StockProductRow>, String> produitsProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(cantineRepositoryProvider).watchProduits(schoolId),
    );

final StreamProviderFamily<List<StockMovementRow>, String> mouvementsProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(cantineRepositoryProvider).watchMouvements(schoolId),
    );

/// Stock courant de chaque produit.
final ProviderFamily<List<EtatProduit>?, String> stockProvider =
    Provider.family((ref, schoolId) {
      final p = ref.watch(produitsProvider(schoolId)).value;
      final m = ref.watch(mouvementsProvider(schoolId)).value;
      return p == null || m == null ? null : etatsStock(p, m);
    });

final StreamProviderFamily<List<CanteenMenuRow>, String> menusProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(cantineRepositoryProvider).watchMenus(schoolId),
    );
