import 'dart:convert';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/cantine/data/cantine_repository.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
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

// ----------------------- A26 : abonnements mensuels ----------------------

final StreamProviderFamily<CanteenYearRow?, String> anneeCantineProvider =
    StreamProvider.family(
      (ref, yearId) => ref.watch(cantineRepositoryProvider).watchAnnee(yearId),
    );

final StreamProviderFamily<List<CanteenRateRow>, String> tarifsProvider =
    StreamProvider.family(
      (ref, yearId) => ref.watch(cantineRepositoryProvider).watchTarifs(yearId),
    );

final StreamProviderFamily<List<CanteenSubscriptionRow>, String>
abonnementsProvider = StreamProvider.family(
  (ref, yearId) =>
      ref.watch(cantineRepositoryProvider).watchAbonnements(yearId),
);

/// Mois de fonctionnement de l'année (réglages, sinon octobre à juin).
/// Clé : (école, année).
final ProviderFamily<List<String>?, (String, String)> moisCantineProvider =
    Provider.family((ref, k) {
      final a = ref.watch(anneeCantineProvider(k.$2));
      if (!a.hasValue) return null;
      final regles = a.value == null
          ? const <String>[]
          : [
              for (final m in jsonDecode(a.value!.months) as List<dynamic>)
                debutMois('$m'),
            ];
      if (regles.isNotEmpty) return regles..sort();
      final annee = ref
          .watch(yearsProvider(k.$1))
          .value
          ?.where((y) => y.id == k.$2)
          .firstOrNull;
      return annee == null ? null : moisParDefaut(annee.label);
    });

/// Situation de cantine de chaque élève de l'année (élèves sortis
/// compris : leur historique est conservé). Clé : (école, année).
final ProviderFamily<Map<String, SituationCantine>?, (String, String)>
situationsAbonnementProvider = Provider.family((ref, k) {
  final (schoolId, yearId) = k;
  final mois = ref.watch(moisCantineProvider(k));
  final eleves = ref.watch(elevesProvider((schoolId, yearId, true))).value;
  final tarifs = ref.watch(tarifsProvider(yearId)).value;
  final abonnements = ref.watch(abonnementsProvider(yearId)).value;
  final fiches = ref.watch(beneficiairesProvider(yearId)).value;
  final details = ref.watch(detailsProvider(yearId)).value;
  if (mois == null ||
      eleves == null ||
      tarifs == null ||
      abonnements == null ||
      fiches == null ||
      details == null) {
    return null;
  }
  final payes = payeParAbonnement(details);
  return {
    for (final e in eleves)
      e.eleve.id: situationCantine(
        studentId: e.eleve.id,
        mois: mois,
        tarifs: tarifs,
        abonnements: abonnements,
        payes: payes,
        fiche: fiches[e.eleve.id],
      ),
  };
});
