import 'dart:io';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/school/domain/school_year.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Lecture (flux réactifs) et écriture hors ligne des données de l'école.
class SchoolRepository {
  new(this.store, {this.mediaDir});

  final LocalStore store;

  /// Dossier local des images (image d'en-tête…).
  final Directory? mediaDir;
  static const _uuid = Uuid();
  static const mediaBucket = 'ecole-medias';

  AppDatabase get db => store.db;

  Stream<SchoolRow?> watchSchool(String id) => (db.select(
    db.schools,
  )..where((s) => s.id.equals(id))).watchSingleOrNull();

  Stream<List<SchoolYearRow>> watchYears(String schoolId) =>
      (db.select(db.schoolYears)
            ..where((y) => y.schoolId.equals(schoolId) & y.deletedAt.isNull())
            ..orderBy([(y) => OrderingTerm.desc(y.label)]))
          .watch();

  Stream<AdminHeaderRow?> watchHeader(String yearId) =>
      (db.select(
            db.adminHeaders,
          )..where((h) => h.schoolYearId.equals(yearId) & h.deletedAt.isNull()))
          .watchSingleOrNull();

  Stream<List<(ModuleCatalogRow, bool)>> watchModules(String schoolId) {
    final q = db.select(db.modulesCatalog).join([
      leftOuterJoin(
        db.schoolModules,
        db.schoolModules.moduleKey.equalsExp(db.modulesCatalog.key) &
            db.schoolModules.schoolId.equals(schoolId),
      ),
    ])..orderBy([OrderingTerm.asc(db.modulesCatalog.sortOrder)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (
            r.readTable(db.modulesCatalog),
            r.readTableOrNull(db.schoolModules)?.enabled ?? false,
          ),
      ],
    );
  }

  Stream<bool> watchModuleEnabled(String schoolId, String key) =>
      watchModules(schoolId)
          .map((list) => list.any((m) => m.$1.key == key && m.$2));

  Stream<List<MembershipRow>> watchMembers(String schoolId) =>
      (db.select(db.memberships)
            ..where((m) => m.schoolId.equals(schoolId) & m.deletedAt.isNull())
            ..orderBy([
              (m) => OrderingTerm.asc(m.role),
              (m) => OrderingTerm.asc(m.displayName),
            ]))
          .watch();

  Stream<Set<String>> watchPermissions(String membershipId) =>
      (db.select(db.delegatePermissions)..where(
            (d) => d.membershipId.equals(membershipId) & d.deletedAt.isNull(),
          ))
          .watch()
          .map((rows) => {for (final r in rows) r.permissionKey});

  // ------------------------------ Écritures ------------------------------

  Future<void> updateSchool(String id, Map<String, Object?> fields) =>
      store.save('schools', {'id': id, ...fields});

  Future<void> saveHeader(String id, Map<String, Object?> fields) =>
      store.save('admin_headers', {'id': id, ...fields});

  /// Prépare l'année suivante : la crée et recopie les en-têtes de l'année
  /// donnée (saisir une fois, réutiliser ; tout reste modifiable).
  Future<String> prepareNextYear(String schoolId, SchoolYearRow from) async {
    final label = anneeSuivante(from.label);
    final existing =
        await (db.select(db.schoolYears)..where(
              (y) => y.schoolId.equals(schoolId) & y.label.equals(label),
            ))
            .getSingleOrNull();
    if (existing != null) return existing.id;
    final yearId = _uuid.v4();
    await db.transaction(() async {
      await store.save('school_years', {
        'id': yearId,
        'school_id': schoolId,
        'label': label,
      });
      final h = await (db.select(
        db.adminHeaders,
      )..where((x) => x.schoolYearId.equals(from.id))).getSingleOrNull();
      final copy = (h?.toJson() ?? <String, dynamic>{})
        ..removeWhere(
          (k, _) => const {
            'created_at',
            'updated_at',
            'synced_at',
            'deleted_at',
          }.contains(k),
        );
      await store.save('admin_headers', {
        ...copy,
        'id': _uuid.v4(),
        'school_id': schoolId,
        'school_year_id': yearId,
      });
    });
    return yearId;
  }

  /// Bascule : l'année choisie devient l'année en cours, l'ancienne est
  /// archivée (toujours consultable, rien n'est supprimé).
  Future<void> switchToYear(String schoolId, String yearId) =>
      db.transaction(() async {
        final school = await (db.select(
          db.schools,
        )..where((s) => s.id.equals(schoolId))).getSingle();
        final previous = school.currentSchoolYearId;
        await store.save('school_years', {'id': yearId, 'archived_at': null});
        await store.save('schools', {
          'id': schoolId,
          'current_school_year_id': yearId,
        });
        if (previous != null && previous != yearId) {
          await store.save('school_years', {
            'id': previous,
            'archived_at': store.clock.nowIso(),
          });
        }
      });

  Future<void> setModule(String schoolId, String key, {required bool on}) =>
      store.save('school_modules', {
        'school_id': schoolId,
        'module_key': key,
        'enabled': on,
      });

  Future<void> setMemberActive(String membershipId, {required bool active}) =>
      store.save('memberships', {'id': membershipId, 'active': active});

  Future<void> setPermission(
    String schoolId,
    String membershipId,
    String key, {
    required bool granted,
  }) async {
    final row =
        await (db.select(db.delegatePermissions)..where(
              (d) =>
                  d.membershipId.equals(membershipId) &
                  d.permissionKey.equals(key),
            ))
            .getSingleOrNull();
    if (row == null && granted) {
      await store.save('delegate_permissions', {
        'id': _uuid.v4(),
        'school_id': schoolId,
        'membership_id': membershipId,
        'permission_key': key,
      });
    } else if (row != null) {
      await store.save('delegate_permissions', {
        'id': row.id,
        'deleted_at': granted ? null : store.clock.nowIso(),
      });
    }
  }

  /// Enregistre l'image d'en-tête d'une année : copie locale immédiate, envoi
  /// au serveur dès que le réseau le permet.
  Future<void> setEmblem(AdminHeaderRow header, File source) async {
    final ext = p.extension(source.path).toLowerCase();
    final objectPath = '${header.schoolId}/entetes/${header.id}$ext';
    final local = localMediaFile(objectPath);
    await local.parent.create(recursive: true);
    await source.copy(local.path);
    await db.transaction(() async {
      await saveHeader(header.id, {'emblem_path': objectPath});
      await db
          .into(db.fileUploads)
          .insert(
            FileUploadsCompanion.insert(
              localPath: local.path,
              bucket: mediaBucket,
              objectPath: objectPath,
              contentType: ext == '.png' ? 'image/png' : 'image/jpeg',
              createdAt: store.clock.nowIso(),
            ),
          );
    });
  }

  File localMediaFile(String objectPath) =>
      File(p.join(mediaDir!.path, objectPath));
}
