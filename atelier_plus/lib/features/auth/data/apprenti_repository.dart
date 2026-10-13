import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/telephone.dart';
import '../../../data/local/database.dart';
import '../../../data/models/permissions_apprenti.dart';
import '../../../data/models/utilisateur.dart';
import 'exceptions_auth.dart';

/// Création de comptes apprentis par le propriétaire.
///
/// Ne peut PAS utiliser `client.auth.signUp` directement : le SDK Supabase
/// ne gère qu'une session à la fois, et créer un nouvel utilisateur ainsi
/// depuis un appareil déjà connecté remplacerait immédiatement la session
/// du propriétaire par celle du nouvel apprenti (déconnexion involontaire).
///
/// La création passe donc par la fonction Edge `creer-apprenti`
/// (`supabase/functions/creer-apprenti/`), qui utilise la clé
/// `service_role` côté serveur pour créer le compte Auth sans jamais
/// affecter la session de l'appelant, après avoir vérifié que l'appelant
/// est bien propriétaire de l'atelier.
class ApprentiRepository {
  ApprentiRepository(this._client, this._baseLocale);

  final SupabaseClient _client;
  final AppDatabase _baseLocale;

  /// Retourne l'utilisateur apprenti créé. Le PIN provisoire doit être
  /// communiqué à l'apprenti par le propriétaire (affiché une seule fois à
  /// l'écran, jamais stocké en clair côté application après cet appel).
  Future<Utilisateur> creerApprenti({
    required String nom,
    required String telephone,
    required String pinProvisoire,
  }) async {
    final FunctionResponse reponse;
    try {
      reponse = await _client.functions.invoke(
        'creer-apprenti',
        body: {
          'nom': nom,
          'telephone': Telephone.normaliser(telephone),
          'pin': pinProvisoire,
        },
      );
    } on FunctionException catch (e) {
      if (e.status == 409) {
        throw const TelephoneDejaUtiliseException();
      }
      rethrow;
    }

    final apprenti = Utilisateur.depuisJson(reponse.data as Map<String, dynamic>);

    // Mis en cache immédiatement : la couche de synchronisation complète
    // (Phase 3) n'existe pas encore, et le propriétaire doit voir le
    // nouvel apprenti sans attendre un futur cycle de synchronisation.
    await _baseLocale.enregistrerUtilisateur(
      id: apprenti.id,
      atelierId: apprenti.atelierId,
      nom: apprenti.nom,
      telephone: apprenti.telephone,
      role: apprenti.role.name,
      updatedAt: apprenti.updatedAt,
    );
    // `PermissionsApprenti.aucunePermission` met tout à `false`, mais le
    // serveur (déclencheur `creer_permissions_apprenti_par_defaut`) crée en
    // réalité la ligne avec ventes/stock/enregistrer_depenses à `true` par
    // défaut (voir supabase/schema.sql) — ce cache local, écrit
    // immédiatement après création pour un affichage sans attendre, doit
    // refléter ces mêmes valeurs par défaut pour ne pas diverger du serveur.
    final permissionsParDefaut = PermissionsApprenti.aucunePermission(apprenti.id).copierAvec(
      ventes: true,
      stock: true,
      enregistrerDepenses: true,
    );
    await _baseLocale.enregistrerPermissions(
      utilisateurId: permissionsParDefaut.utilisateurId,
      creerClient: permissionsParDefaut.creerClient,
      modifierClient: permissionsParDefaut.modifierClient,
      prendreMesures: permissionsParDefaut.prendreMesures,
      ajouterPhotos: permissionsParDefaut.ajouterPhotos,
      modifierGabarits: permissionsParDefaut.modifierGabarits,
      ventes: permissionsParDefaut.ventes,
      stock: permissionsParDefaut.stock,
      enregistrerDepenses: permissionsParDefaut.enregistrerDepenses,
    );

    return apprenti;
  }
}
