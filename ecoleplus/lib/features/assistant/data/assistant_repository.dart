import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/drafts/draft_store.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/assistant/data/assistant_api.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:uuid/uuid.dart';

/// Fiches enregistrées (synchronisées, propres à leur auteur), demandes en
/// attente d'Internet (sur le téléphone seulement) et limites par
/// enseignant (directeur).
class AssistantRepository {
  new(this.store);
  final LocalStore store;
  AppDatabase get db => store.db;
  DraftStore get _drafts => DraftStore(db);
  static const _uuid = Uuid();
  static const _cleAttente = 'assistant_ia_en_attente';

  Stream<List<LessonPrepRow>> watchFiches(String authorId) =>
      (db.select(db.lessonPreps)
            ..where((f) => f.authorId.equals(authorId) & f.deletedAt.isNull())
            ..orderBy([(f) => OrderingTerm.desc(f.updatedAt)]))
          .watch();

  Stream<LessonPrepRow?> watchFiche(String id) => (db.select(
    db.lessonPreps,
  )..where((f) => f.id.equals(id))).watchSingleOrNull();

  /// Enregistre (ou met à jour) une fiche relue par l'enseignant.
  Future<String> enregistrer({
    required String schoolId,
    required String authorId,
    required String kind,
    required Map<String, Object?> demande,
    required FicheIa fiche,
    required List<SourceIa> sources,
    String? id,
  }) async {
    if (fiche.titre.trim().isEmpty) {
      throw const UserMessage('La fiche n’a pas de titre.');
    }
    final i = id ?? _uuid.v4();
    await store.save('lesson_preps', {
      'id': i,
      'school_id': schoolId,
      'author_id': authorId,
      'kind': kind,
      'theme': demande['theme'] ?? demande['difficultes'],
      'request': demande,
      'content': fiche.toJson(),
      'sources': [for (final s in sources) s.toJson()],
      'deleted_at': null,
    });
    return i;
  }

  Future<void> retirer(String id) => store.save('lesson_preps', {
    'id': id,
    'deleted_at': store.clock.nowIso(),
  });

  static FicheIa ficheDe(LessonPrepRow r) =>
      FicheIa.fromJson(jsonDecode(r.content) as Map<String, dynamic>);
  static List<SourceIa> sourcesDe(LessonPrepRow r) => [
    for (final s in jsonDecode(r.sources) as List<dynamic>)
      SourceIa.fromJson(Map<String, dynamic>.from(s as Map)),
  ];
  static Map<String, dynamic> demandeDe(LessonPrepRow r) =>
      jsonDecode(r.request) as Map<String, dynamic>;

  // ---------------------- Demandes en attente ---------------------------

  /// Demandes faites sans Internet (gardées, envoyées plus tard).
  Future<List<Map<String, dynamic>>> enAttente() async {
    final d = await _drafts.load(_cleAttente);
    return [
      for (final x in (d['liste'] as List<dynamic>? ?? const []))
        Map<String, dynamic>.from(x as Map),
    ];
  }

  Future<void> garder(Map<String, Object?> demande) async {
    final l = await enAttente();
    await _drafts.save(_cleAttente, {
      'liste': [
        ...l,
        {...demande, '_garde_le': store.clock.nowIso()},
      ],
    });
  }

  Future<void> oublier(Map<String, dynamic> demande) async {
    final l = await enAttente();
    l.removeWhere((x) => x['_garde_le'] == demande['_garde_le']);
    await _drafts.save(_cleAttente, {'liste': l});
  }

  // ------------------------ Limites (directeur) --------------------------

  static String idLimite(String membershipId) =>
      _uuid.v5(Namespace.url.value, 'ecoleplus:limite-ia:$membershipId');

  Future<void> fixerLimite({
    required String schoolId,
    required String membershipId,
    required int limite,
  }) async {
    if (limite < 0 || limite > 1000) {
      throw const UserMessage('Limite : entre 0 et 1 000 demandes.');
    }
    await store.save('ai_teacher_limits', {
      'id': idLimite(membershipId),
      'school_id': schoolId,
      'membership_id': membershipId,
      'monthly_limit': limite,
      'deleted_at': null,
    });
  }
}
