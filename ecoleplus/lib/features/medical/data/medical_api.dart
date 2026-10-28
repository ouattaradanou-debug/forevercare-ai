import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/medical/domain/fiche_medicale.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Accès au dossier médico-scolaire : uniquement par les fonctions du
/// serveur (directeur, module actif, chaque tentative journalisée). Rien
/// n'est gardé sur le téléphone ; sans Internet, la fiche n'est pas
/// disponible.
abstract class MedicalApi {
  Future<DossierMedical> lire(String studentId);

  Future<void> enregistrer(
    String studentId, {
    Map<String, Object?>? fiche,
    List<ExamenAnnuel> examens = const [],
    Map<String, Object?>? aptitude,
  });

  Future<void> noterImpression(String studentId);

  Future<List<LigneJournalMedical>> journal(String schoolId);

  /// Mentions d'aptitude exposées pour une classe : {élève: aptitude}.
  Future<Map<String, String>> aptitudesDeLaClasse(String classId);
}

const messageHorsLigneMedical =
    'Connexion à Internet nécessaire : la fiche médico-scolaire n’est jamais '
    'gardée sur le téléphone.';

class SupabaseMedicalApi implements MedicalApi {
  new(this.client);
  final SupabaseClient client;

  Future<T> _appel<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on PostgrestException catch (e) {
      throw UserMessage(e.message);
    } on UserMessage {
      rethrow;
    } on Object {
      throw const UserMessage(messageHorsLigneMedical);
    }
  }

  static void _verifier(Object? r) {
    if (r case {'refuse': true, 'message': final String m}) {
      throw UserMessage(m);
    }
  }

  @override
  Future<DossierMedical> lire(String studentId) => _appel(() async {
    final r = await client.rpc<dynamic>(
      'medical_get',
      params: {'p_student': studentId},
    );
    _verifier(r);
    return DossierMedical.depuisJson(r as Map<String, dynamic>);
  });

  @override
  Future<void> enregistrer(
    String studentId, {
    Map<String, Object?>? fiche,
    List<ExamenAnnuel> examens = const [],
    Map<String, Object?>? aptitude,
  }) => _appel(() async {
    final r = await client.rpc<dynamic>(
      'medical_save',
      params: {
        'p_student': studentId,
        'p_record': fiche,
        'p_examens': [for (final e in examens) e.versJson()],
        'p_aptitude': aptitude,
      },
    );
    _verifier(r);
  });

  @override
  Future<void> noterImpression(String studentId) => _appel(() async {
    _verifier(
      await client.rpc<dynamic>(
        'medical_impression',
        params: {'p_student': studentId},
      ),
    );
  });

  @override
  Future<List<LigneJournalMedical>> journal(String schoolId) =>
      _appel(() async {
        final r = await client.rpc<dynamic>(
          'medical_log',
          params: {'p_school': schoolId},
        );
        return [
          for (final l in (r as List<dynamic>).cast<Map<String, dynamic>>())
            LigneJournalMedical(
              quand: DateTime.parse(l['occurred_at'] as String).toLocal(),
              qui: l['actor'] as String,
              eleve: l['student'] as String?,
              action: l['action'] as String,
              autorise: l['allowed'] as bool,
            ),
        ];
      });

  @override
  Future<Map<String, String>> aptitudesDeLaClasse(String classId) =>
      _appel(() async {
        final r = await client.rpc<dynamic>(
          'medical_aptitudes',
          params: {'p_class': classId},
        );
        return {
          for (final l in (r as List<dynamic>).cast<Map<String, dynamic>>())
            l['student_id'] as String: l['aptitude'] as String,
        };
      });
}
