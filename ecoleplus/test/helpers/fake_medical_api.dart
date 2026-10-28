import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/medical/data/medical_api.dart';
import 'package:ecoleplus/features/medical/domain/fiche_medicale.dart';

/// Serveur médical simulé : mêmes règles que les fonctions du serveur
/// (refus si non autorisé, chaque tentative journalisée).
class FakeMedicalApi implements MedicalApi {
  /// Directeur et module actif (sinon : refus).
  bool autorise = true;
  bool enLigne = true;

  final Map<String, DossierMedical> dossiers = {};
  final Map<String, Map<String, Object?>> aptitudes = {};
  final List<LigneJournalMedical> journalEcrit = [];
  final List<Map<String, Object?>> enregistrements = [];

  void _controle(String? eleve, String action) {
    if (!enLigne) throw const UserMessage(messageHorsLigneMedical);
    journalEcrit.add(
      LigneJournalMedical(
        quand: DateTime.now(),
        qui: 'Directeur Test',
        eleve: eleve,
        action: action,
        autorise: autorise,
      ),
    );
    if (!autorise) {
      throw const UserMessage(
        'Accès refusé : le dossier médico-scolaire est réservé au directeur, '
        'module activé.',
      );
    }
  }

  @override
  Future<DossierMedical> lire(String studentId) async {
    _controle(studentId, 'consultation');
    final d = dossiers[studentId] ?? DossierMedical();
    final a = aptitudes[studentId];
    return DossierMedical(
      fiche: {...d.fiche},
      examens: [
        for (final e in d.examens) ExamenAnnuel(e.annee, {...e.valeurs}),
      ],
      aptitudesParAnnee: [
        if (a != null && a['aptitude'] != null)
          AptitudeAnnee(
            anneeId: a['school_year_id']! as String,
            aptitude: a['aptitude']! as String,
            exposee: a['expose_to_teacher'] as bool? ?? false,
          ),
      ],
    );
  }

  @override
  Future<void> enregistrer(
    String studentId, {
    Map<String, Object?>? fiche,
    List<ExamenAnnuel> examens = const [],
    Map<String, Object?>? aptitude,
  }) async {
    _controle(studentId, 'modification');
    enregistrements.add({'fiche': fiche, 'aptitude': aptitude});
    dossiers[studentId] = DossierMedical(
      fiche: {
        for (final MapEntry(:key, :value) in (fiche ?? const {}).entries)
          key: value as String?,
      },
      examens: examens,
    );
    if (aptitude != null) aptitudes[studentId] = aptitude;
  }

  @override
  Future<void> noterImpression(String studentId) async =>
      _controle(studentId, 'impression');

  @override
  Future<List<LigneJournalMedical>> journal(String schoolId) async =>
      journalEcrit.reversed.toList();

  @override
  Future<Map<String, String>> aptitudesDeLaClasse(String classId) async => {
    for (final MapEntry(:key, :value) in aptitudes.entries)
      if (value['expose_to_teacher'] == true && value['aptitude'] != null)
        key: value['aptitude']! as String,
  };
}
