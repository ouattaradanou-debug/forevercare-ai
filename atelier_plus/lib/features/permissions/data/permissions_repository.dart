import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/local/database.dart';
import '../../../data/models/permissions_apprenti.dart';

/// Lecture/écriture des permissions d'un apprenti.
///
/// L'écriture n'est significative que pour le propriétaire : la RLS
/// (`permissions_update`) refuse déjà toute tentative d'un apprenti de
/// modifier ses propres droits, cette classe ne fait qu'exposer l'appel —
/// elle ne doit jamais être le seul rempart (défense en profondeur).
class PermissionsRepository {
  PermissionsRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;

  Future<PermissionsApprenti> lire(String utilisateurId) async {
    final ligne = await _client
        .from('permissions_apprenti')
        .select()
        .eq('utilisateur_id', utilisateurId)
        .maybeSingle();

    final permissions = ligne != null
        ? PermissionsApprenti.depuisJson(ligne)
        : PermissionsApprenti.aucunePermission(utilisateurId);

    await _mettreEnCache(permissions);
    return permissions;
  }

  /// Lecture prioritairement locale (fonctionnement hors-ligne au
  /// quotidien) : utilisée par le reste de l'application pour savoir si
  /// l'utilisateur courant peut afficher une action donnée.
  Future<PermissionsApprenti> lireDepuisCache(String utilisateurId) async {
    final ligne = await _baseLocale.permissionsDe(utilisateurId);
    if (ligne == null) {
      return PermissionsApprenti.aucunePermission(utilisateurId);
    }
    return PermissionsApprenti(
      utilisateurId: ligne.utilisateurId,
      creerClient: ligne.creerClient,
      modifierClient: ligne.modifierClient,
      prendreMesures: ligne.prendreMesures,
      ajouterPhotos: ligne.ajouterPhotos,
      modifierGabarits: ligne.modifierGabarits,
      ventes: ligne.ventes,
      stock: ligne.stock,
      enregistrerDepenses: ligne.enregistrerDepenses,
    );
  }

  Future<void> mettreAJour(PermissionsApprenti permissions) async {
    await _client
        .from('permissions_apprenti')
        .update(permissions.versJson())
        .eq('utilisateur_id', permissions.utilisateurId);
    await _mettreEnCache(permissions);
  }

  Future<void> _mettreEnCache(PermissionsApprenti permissions) {
    return _baseLocale.enregistrerPermissions(
      utilisateurId: permissions.utilisateurId,
      creerClient: permissions.creerClient,
      modifierClient: permissions.modifierClient,
      prendreMesures: permissions.prendreMesures,
      ajouterPhotos: permissions.ajouterPhotos,
      modifierGabarits: permissions.modifierGabarits,
      ventes: permissions.ventes,
      stock: permissions.stock,
      enregistrerDepenses: permissions.enregistrerDepenses,
    );
  }
}
