import 'package:ecoleplus/features/assistant/data/assistant_api.dart';

/// Assistant simulé pour les tests d'écrans : enregistre les demandes ;
/// peut simuler l'absence d'Internet ou une limite atteinte.
class FakeAssistantApi implements AssistantApi {
  final demandes = <Map<String, Object?>>[];
  bool horsLigne = false;
  bool limite = false;
  int restantEnseignant = 30;
  final limites = <String, int>{};

  @override
  Future<ReponseIa> demander(Map<String, Object?> demande) async {
    if (horsLigne) throw const HorsLigneIa();
    if (limite) {
      throw const LimiteIa(
        'Vous avez utilisé vos 30 demandes de ce mois. Elles reviennent le '
        '1er du mois prochain ; vos fiches enregistrées restent disponibles.',
      );
    }
    demandes.add(demande);
    restantEnseignant--;
    final action = demande['action'];
    return ReponseIa(
      fiche: FicheIa(
        'Préparation : ${demande['theme'] ?? demande['difficultes']}'
        '${action == null ? '' : ' ($action)'}',
        const [
          SectionIa('Objectif général', '- Comprendre les fractions'),
          SectionIa('Déroulement', '- Partager une galette en parts égales'),
        ],
      ),
      sources: demande['sans_bibliotheque'] == true
          ? const []
          : const [
              SourceIa(
                documentId: 'doc-1',
                titre: 'Guide des fractions',
                page: 2,
              ),
            ],
      restant: Restant(enseignant: restantEnseignant, ecole: 280),
      modele: 'simulé',
    );
  }

  @override
  Future<Restant> restant(String schoolId) async {
    if (horsLigne) throw const HorsLigneIa();
    return Restant(enseignant: restantEnseignant, ecole: 280);
  }

  @override
  Future<List<DocumentIa>> documents(String schoolId) async => const [
    DocumentIa('doc-1', 'Guide des fractions'),
    DocumentIa('doc-2', 'Lectures CM1'),
  ];

  @override
  Future<UsageEcole> usageEcole(String schoolId) async => UsageEcole(
    [
      UsageIa(
        membershipId: 'm-ens',
        nom: 'Enseignant Un',
        demandes: 30 - restantEnseignant,
        limite: limites['m-ens'] ?? 30,
        coutMicroUsd: 0,
      ),
    ],
    demandes: 30 - restantEnseignant,
    limite: 300,
    coutMicroUsd: 0,
    budgetMicroUsd: 5000000,
  );
}
