import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

final StreamProviderFamily<SchoolRow?, String> schoolProvider =
    StreamProvider.family<SchoolRow?, String>(
      (ref, id) => ref.watch(schoolRepositoryProvider).watchSchool(id),
    );
final StreamProviderFamily<List<SchoolYearRow>, String> yearsProvider =
    StreamProvider.family<List<SchoolYearRow>, String>(
      (ref, schoolId) =>
          ref.watch(schoolRepositoryProvider).watchYears(schoolId),
    );
final StreamProviderFamily<AdminHeaderRow?, String> headerProvider =
    StreamProvider.family<AdminHeaderRow?, String>(
      (ref, yearId) => ref.watch(schoolRepositoryProvider).watchHeader(yearId),
    );
final StreamProviderFamily<List<(ModuleCatalogRow, bool)>, String>
modulesProvider = StreamProvider.family<List<(ModuleCatalogRow, bool)>, String>(
  (ref, schoolId) => ref.watch(schoolRepositoryProvider).watchModules(schoolId),
);
final StreamProviderFamily<List<MembershipRow>, String> membersProvider =
    StreamProvider.family<List<MembershipRow>, String>(
      (ref, schoolId) =>
          ref.watch(schoolRepositoryProvider).watchMembers(schoolId),
    );
final StreamProviderFamily<Set<String>, String> permissionsProvider =
    StreamProvider.family<Set<String>, String>(
      (ref, membershipId) =>
          ref.watch(schoolRepositoryProvider).watchPermissions(membershipId),
    );
