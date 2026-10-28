import 'dart:io';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/cartes/domain/carte_scolaire.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Lot de cartes : une classe, un niveau ou toute l'école.
class Lot {
  const new classe(String this.classId) : levelCode = null;
  const new niveau(String this.levelCode) : classId = null;
  const new ecole() : classId = null, levelCode = null;

  final String? classId;
  final String? levelCode;
}

/// Cartes scolaires : élèves du lot, identifiant opaque du QR code (un par
/// élève et par année, gardé d'une impression à l'autre), photos locales.
class CartesRepository {
  new(this.store, {required this.mediaDir});

  final LocalStore store;
  final Directory? mediaDir;
  AppDatabase get db => store.db;

  static const _uuid = Uuid();
  static String idCarte(String studentId, String yearId) =>
      _uuid.v5(Namespace.url.value, 'ecoleplus:carte:$studentId:$yearId');
  static String idModele(String schoolId) =>
      _uuid.v5(Namespace.url.value, 'ecoleplus:modele-carte:$schoolId');

  // ------------------------------ Modèle ------------------------------

  Stream<CardTemplateRow?> watchModele(String schoolId) => (db.select(
    db.cardTemplates,
  )..where((t) => t.id.equals(idModele(schoolId)))).watchSingleOrNull();

  Future<void> choisirCouleur(String schoolId, String couleur) =>
      store.save('card_templates', {
        'id': idModele(schoolId),
        'school_id': schoolId,
        'name': 'Modèle de l’école',
        'primary_color': couleur,
        'is_default': true,
      });

  // ------------------------------ Élèves ------------------------------

  /// Élèves inscrits cette année (non sortis), avec leur classe, triés par
  /// classe puis par nom.
  Future<List<(StudentRow, ClassRow)>> eleves(String yearId, Lot lot) async {
    final classes =
        await (db.select(db.classes)..where(
              (c) => c.schoolYearId.equals(yearId) & c.deletedAt.isNull(),
            ))
            .get();
    final parId = {
      for (final c in classes)
        if ((lot.classId == null || c.id == lot.classId) &&
            (lot.levelCode == null || c.levelCode == lot.levelCode))
          c.id: c,
    };
    final inscrits =
        await (db.select(db.enrollments)..where(
              (e) =>
                  e.classId.isIn(parId.keys) &
                  e.deletedAt.isNull() &
                  e.endsOn.isNull(),
            ))
            .get();
    final eleves = {
      for (final s
          in await (db.select(db.students)..where(
                (s) =>
                    s.id.isIn({for (final e in inscrits) e.studentId}) &
                    s.deletedAt.isNull() &
                    s.exitDate.isNull(),
              ))
              .get())
        s.id: s,
    };
    return [
      for (final e in inscrits)
        if (eleves[e.studentId] case final s?) (s, parId[e.classId]!),
    ]..sort(
      (a, b) => '${a.$2.name} ${a.$1.lastName} ${a.$1.firstNames}'.compareTo(
        '${b.$2.name} ${b.$1.lastName} ${b.$1.firstNames}',
      ),
    );
  }

  File? photo(StudentRow s) {
    if (s.photoPath == null || mediaDir == null) return null;
    final f = File(p.join(mediaDir!.path, s.photoPath));
    return f.existsSync() ? f : null;
  }

  /// Élèves du lot dont la photo manque sur ce téléphone.
  Future<List<(StudentRow, ClassRow)>> sansPhoto(
    String yearId,
    Lot lot,
  ) async => [
    for (final e in await eleves(yearId, lot))
      if (photo(e.$1) == null) e,
  ];

  // ------------------------------ Cartes ------------------------------

  /// Identifiant opaque de la carte de l'année, créé à la première
  /// impression puis toujours le même.
  Future<String> jeton(StudentRow s, String yearId) async {
    final id = idCarte(s.id, yearId);
    final existe = await (db.select(
      db.studentCards,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (existe != null) {
      await store.save('student_cards', {
        'id': id,
        'generated_at': store.clock.nowIso(),
      });
      return existe.qrToken;
    }
    final jeton = nouveauJeton();
    await store.save('student_cards', {
      'id': id,
      'school_id': s.schoolId,
      'student_id': s.id,
      'school_year_id': yearId,
      'qr_token': jeton,
      'generated_at': store.clock.nowIso(),
    });
    return jeton;
  }

  /// Cartes du lot (ou d'un seul élève).
  Future<(EcoleCarte, List<CarteScolaire>)> cartes(
    SchoolRow ecole,
    SchoolYearRow annee,
    Lot lot, {
    String? studentId,
  }) async {
    final modele = await watchModele(ecole.id).first;
    final logo = ecole.logoPath == null || mediaDir == null
        ? null
        : File(p.join(mediaDir!.path, ecole.logoPath));
    final carte = EcoleCarte(
      nom: ecole.name,
      commune: ecole.commune,
      telephone: ecole.phone,
      adresse: ecole.address,
      email: ecole.email,
      logo: logo != null && logo.existsSync() ? logo.readAsBytesSync() : null,
      couleur: modele?.primaryColor ?? '#1B6E3C',
    );
    final liste = <CarteScolaire>[];
    for (final (s, c) in await eleves(annee.id, lot)) {
      if (studentId != null && s.id != studentId) continue;
      liste.add(
        CarteScolaire(
          nom: s.lastName,
          prenoms: s.firstNames,
          classe: c.name,
          annee: annee.label,
          identifiant:
              s.studentCode ??
              (s.registryNumber == null ? '—' : 'N° ${s.registryNumber}'),
          ecole: ecole.name,
          commune: ecole.commune,
          photo: photo(s)?.readAsBytesSync(),
          jeton: await jeton(s, annee.id),
        ),
      );
    }
    return (carte, liste);
  }
}
