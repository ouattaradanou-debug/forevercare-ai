import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';

/// Description d'une table synchronisée : même nom en local et sur le serveur.
class SyncedTable<D extends DataClass> {
  const new({
    required this.name,
    required this.info,
    this.keyColumns = const ['id'],
    this.pushable = true,
    this.incremental = true,
  });

  final String name;
  final TableInfo<Table, D> info;

  /// Colonnes qui identifient une ligne (clé du serveur).
  final List<String> keyColumns;

  /// Faux pour les tables de référence en lecture seule.
  final bool pushable;

  /// Vrai si la table porte synced_at (téléchargement par curseur) ;
  /// sinon elle est rechargée entièrement (petites tables de référence).
  final bool incremental;

  String get tieColumn => keyColumns.last;

  Map<String, Object?> keyOf(Map<String, dynamic> row) => {
    for (final k in keyColumns) k: row[k],
  };

  String encodeKey(Map<String, dynamic> row) => jsonEncode(keyOf(row));
}

/// Tables synchronisées (phases 1 à 3), dans l'ordre des dépendances
/// (une école avant ses années, une année avant ses en-têtes…).
List<SyncedTable> syncedTables(AppDatabase db) => [
  SyncedTable<ModuleCatalogRow>(
    name: 'modules_catalog',
    info: db.modulesCatalog,
    keyColumns: const ['key'],
    pushable: false,
    incremental: false,
  ),
  SyncedTable<SchoolRow>(name: 'schools', info: db.schools),
  SyncedTable<SchoolYearRow>(name: 'school_years', info: db.schoolYears),
  SyncedTable<AdminHeaderRow>(name: 'admin_headers', info: db.adminHeaders),
  SyncedTable<SchoolModuleRow>(
    name: 'school_modules',
    info: db.schoolModules,
    keyColumns: const ['school_id', 'module_key'],
  ),
  SyncedTable<MembershipRow>(name: 'memberships', info: db.memberships),
  SyncedTable<DelegatePermissionRow>(
    name: 'delegate_permissions',
    info: db.delegatePermissions,
  ),
  SyncedTable<LevelRow>(
    name: 'levels',
    info: db.levels,
    keyColumns: const ['code'],
    pushable: false,
    incremental: false,
  ),
  SyncedTable<TeacherRow>(name: 'teachers', info: db.teachers),
  SyncedTable<TeacherPostingRow>(
    name: 'teacher_postings',
    info: db.teacherPostings,
  ),
  SyncedTable<TeacherInterruptionRow>(
    name: 'teacher_interruptions',
    info: db.teacherInterruptions,
  ),
  SyncedTable<TeacherAwardRow>(name: 'teacher_awards', info: db.teacherAwards),
  SyncedTable<TeacherDiplomaRow>(
    name: 'teacher_diplomas',
    info: db.teacherDiplomas,
  ),
  SyncedTable<ClassRow>(name: 'classes', info: db.classes),
  SyncedTable<TeacherAssignmentRow>(
    name: 'teacher_year_assignments',
    info: db.teacherYearAssignments,
  ),
  SyncedTable<StudentRow>(name: 'students', info: db.students),
  SyncedTable<StudentRegistryRow>(
    name: 'student_registry',
    info: db.studentRegistry,
  ),
  SyncedTable<GuardianRow>(name: 'guardians', info: db.guardians),
  SyncedTable<EnrollmentRow>(name: 'enrollments', info: db.enrollments),
  SyncedTable<SubjectRow>(name: 'subjects', info: db.subjects),
  SyncedTable<MentionScaleRow>(name: 'mention_scales', info: db.mentionScales),
  SyncedTable<ClassSubjectRow>(name: 'class_subjects', info: db.classSubjects),
  SyncedTable<AssessmentRow>(name: 'assessments', info: db.assessments),
  SyncedTable<GradeRow>(name: 'grades', info: db.grades),
  SyncedTable<AnnualResultRow>(name: 'annual_results', info: db.annualResults),
  SyncedTable<ReportTemplateRow>(
    name: 'report_templates',
    info: db.reportTemplates,
  ),
  SyncedTable<ReportCardRow>(name: 'report_cards', info: db.reportCards),
  SyncedTable<ScolarityCopyRow>(
    name: 'scolarity_copy_log',
    info: db.scolarityCopyLog,
  ),
  SyncedTable<IssuedDocumentRow>(
    name: 'issued_documents',
    info: db.issuedDocuments,
  ),
  SyncedTable<OfficialFormRow>(name: 'official_forms', info: db.officialForms),
  SyncedTable<DeviceRow>(name: 'devices', info: db.devices, pushable: false),
  SyncedTable<AuditRow>(name: 'audit_log', info: db.auditLog, pushable: false),
];
