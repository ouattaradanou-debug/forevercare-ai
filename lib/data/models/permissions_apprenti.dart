import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart' as local;

/// Permissions accordées à un apprenti. Ne contient volontairement aucune
/// donnée ni aucun accès financier : ce modèle ne doit jamais évoluer pour
/// inclure une notion de commande ou de paiement.
class PermissionsApprenti {
  const PermissionsApprenti({
    required this.id,
    required this.utilisateurId,
    required this.creerClient,
    required this.modifierClient,
    required this.prendreMesures,
    required this.ajouterPhotos,
    required this.modifierGabarits,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String utilisateurId;
  final bool creerClient;
  final bool modifierClient;
  final bool prendreMesures;
  final bool ajouterPhotos;
  final bool modifierGabarits;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PermissionsApprenti.depuisSupabase(Map<String, dynamic> json) {
    return PermissionsApprenti(
      id: json['id'] as String,
      utilisateurId: json['utilisateur_id'] as String,
      creerClient: json['creer_client'] as bool,
      modifierClient: json['modifier_client'] as bool,
      prendreMesures: json['prendre_mesures'] as bool,
      ajouterPhotos: json['ajouter_photos'] as bool,
      modifierGabarits: json['modifier_gabarits'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory PermissionsApprenti.depuisLigneLocale(
    local.PermissionsApprentiLocal ligne,
  ) {
    return PermissionsApprenti(
      id: ligne.id,
      utilisateurId: ligne.utilisateurId,
      creerClient: ligne.creerClient,
      modifierClient: ligne.modifierClient,
      prendreMesures: ligne.prendreMesures,
      ajouterPhotos: ligne.ajouterPhotos,
      modifierGabarits: ligne.modifierGabarits,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
    );
  }

  local.PermissionsApprentiCompanion versCompagnonLocal() {
    return local.PermissionsApprentiCompanion(
      id: Value(id),
      utilisateurId: Value(utilisateurId),
      creerClient: Value(creerClient),
      modifierClient: Value(modifierClient),
      prendreMesures: Value(prendreMesures),
      ajouterPhotos: Value(ajouterPhotos),
      modifierGabarits: Value(modifierGabarits),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  PermissionsApprenti copierAvec({
    bool? creerClient,
    bool? modifierClient,
    bool? prendreMesures,
    bool? ajouterPhotos,
    bool? modifierGabarits,
  }) {
    return PermissionsApprenti(
      id: id,
      utilisateurId: utilisateurId,
      creerClient: creerClient ?? this.creerClient,
      modifierClient: modifierClient ?? this.modifierClient,
      prendreMesures: prendreMesures ?? this.prendreMesures,
      ajouterPhotos: ajouterPhotos ?? this.ajouterPhotos,
      modifierGabarits: modifierGabarits ?? this.modifierGabarits,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
