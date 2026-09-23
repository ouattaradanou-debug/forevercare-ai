import 'dart:async';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../cave/infos_cave.dart';
import '../constants/roles.dart';
import '../constants/type_cave.dart';
import 'profil.dart';
import 'telephone_identifiant.dart';

/// Service d'authentification et de configuration initiale de la cave.
///
/// Ces deux opérations (inscription, connexion) nécessitent une connexion
/// réseau active (vérification des identifiants par le serveur Supabase
/// Auth). Ce n'est pas une régression offline-first : une fois connecté,
/// `supabase_flutter` persiste la session localement et l'utilisateur
/// reste authentifié hors ligne pour toutes les opérations suivantes
/// (vente, encaissement, stock...). Seule la toute première connexion
/// requiert le réseau — comportement documenté dans PHASE1.md.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  Session? get sessionActuelle => _client.auth.currentSession;
  Stream<AuthState> get changementsAuth => _client.auth.onAuthStateChange;

  /// Crée le compte du premier utilisateur d'une cave (Propriétaire ou
  /// Propriétaire/Gérant) ainsi que la cave elle-même, de façon atomique
  /// côté serveur (RPC `creer_cave_et_proprietaire`).
  Future<void> creerCaveEtProprietaire({
    required String nomCave,
    required TypeCave typeCave,
    required String telephoneCave,
    required String localisation,
    required String nomUtilisateur,
    required String prenomUtilisateur,
    required String telephoneUtilisateur,
    required RoleUtilisateur role,
    required String pin,
    required String questionSecrete,
    required String reponseSecrete,
  }) async {
    assert(
      role == RoleUtilisateur.proprietaire ||
          role == RoleUtilisateur.proprietaireGerant,
      'Le premier compte doit être Propriétaire ou Propriétaire/Gérant.',
    );

    await _client.auth.signUp(
      email: telephoneVersEmailTechnique(telephoneUtilisateur),
      password: pin,
    );

    await _client.rpc('creer_cave_et_proprietaire', params: {
      'p_nom_cave': nomCave,
      'p_type_cave': typeCave.nomPostgres,
      'p_telephone_cave': telephoneCave,
      'p_localisation': localisation,
      'p_nom_utilisateur': nomUtilisateur,
      'p_prenom_utilisateur': prenomUtilisateur,
      'p_telephone_utilisateur': telephoneUtilisateur,
      'p_role': role.nomPostgres,
      'p_question_secrete': questionSecrete,
      'p_reponse_secrete': reponseSecrete,
    });
  }

  Future<void> seConnecter(
      {required String telephone, required String pin}) async {
    await _client.auth.signInWithPassword(
      email: telephoneVersEmailTechnique(telephone),
      password: pin,
    );
  }

  Future<void> seDeconnecter() => _client.auth.signOut();

  /// Récupère la question secrète associée à un numéro de téléphone.
  /// Renvoie `null` si aucun compte ne correspond à ce numéro.
  ///
  /// Appelable sans session active (RPC `obtenir_question_secrete`,
  /// ouverte au rôle `anon` côté base) : c'est justement le but, retrouver
  /// l'accès quand on est déconnecté.
  Future<String?> obtenirQuestionSecrete(String telephone) async {
    final resultat = await _client.rpc('obtenir_question_secrete', params: {
      'p_telephone': telephone,
    });
    return resultat as String?;
  }

  /// Vérifie seule la réponse à la question secrète (sans toucher au PIN),
  /// pour confirmer qu'elle est correcte avant même d'afficher les champs
  /// de saisie du nouveau code. Même statuts que [reinitialiserPin] :
  /// `'ok'`, `'reponse_incorrecte'`, `'bloque'`.
  Future<String> verifierReponseSecrete({
    required String telephone,
    required String reponse,
  }) async {
    final resultat = await _client.rpc('verifier_reponse_secrete', params: {
      'p_telephone': telephone,
      'p_reponse': reponse,
    });
    return resultat as String;
  }

  /// Réinitialise le code PIN si la réponse à la question secrète est
  /// correcte. Renvoie le statut renvoyé par la base : `'ok'`,
  /// `'reponse_incorrecte'` ou `'bloque'` (5 tentatives ratées, blocage
  /// temporaire — voir la migration SQL pour le détail).
  Future<String> reinitialiserPin({
    required String telephone,
    required String reponse,
    required String nouveauPin,
  }) async {
    final resultat = await _client.rpc('reinitialiser_pin', params: {
      'p_telephone': telephone,
      'p_reponse': reponse,
      'p_nouveau_pin': nouveauPin,
    });
    return resultat as String;
  }

  /// Informations actuelles de la cave (pour l'affichage/modification
  /// post-connexion, icône en haut à gauche de l'écran d'accueil).
  Future<InfosCave> informationsCaveActuelles(String caveId) async {
    final ligne = await _client
        .from('caves')
        .select('nom, telephone, localisation, type_cave, logo_url')
        .eq('id', caveId)
        .single();
    return InfosCave.depuisJson(ligne);
  }

  /// Modifie les informations de la cave après création. Protégé côté
  /// serveur par la policy RLS `caves_update` (réservée à
  /// `is_responsable()`, c'est-à-dire Propriétaire, Propriétaire/Gérant et
  /// Gérant — pas l'Agent de vente).
  ///
  /// Une mise à jour bloquée par RLS ne lève pas d'erreur PostgREST : elle
  /// affecte silencieusement 0 ligne (vérifié en local, contrairement à un
  /// `insert`/`rpc` qui, lui, renvoie bien `42501`). D'où le `.select()`
  /// et la vérification explicite ci-dessous : sans ça, un appel bloqué
  /// malgré le masquage côté UI semblerait avoir réussi.
  Future<void> modifierInformationsCave({
    required String caveId,
    required String nom,
    required String telephone,
    required String localisation,
    required TypeCave typeCave,
  }) async {
    final resultat = await _client
        .from('caves')
        .update({
          'nom': nom,
          'telephone': telephone,
          'localisation': localisation,
          'type_cave': typeCave.nomPostgres,
        })
        .eq('id', caveId)
        .select();
    if (resultat.isEmpty) {
      throw Exception('Modification refusée : rôle insuffisant.');
    }
  }

  /// Téléverse le logo de la cave (bucket `logos-cave`, chemin
  /// `<caveId>/logo_<horodatage>.<extension>` — le premier segment du
  /// chemin est ce que vérifient les policies de stockage pour s'assurer
  /// que chacun ne peut écrire que dans le dossier de sa propre cave) et
  /// enregistre son URL publique sur la cave. Renvoie cette URL.
  ///
  /// Nom de fichier horodaté (pas simplement `logo.<ext>`) : sinon,
  /// chaque nouveau logo aurait la même URL que le précédent, et
  /// `NetworkImage` (qui met en cache par URL côté Flutter) continuerait
  /// d'afficher l'ancienne image malgré le remplacement côté serveur —
  /// bug reproduit en changeant le logo deux fois de suite sur téléphone.
  Future<String> televerserLogoCave({
    required String caveId,
    required Uint8List octets,
    required String extension,
  }) async {
    final horodatage = DateTime.now().millisecondsSinceEpoch;
    final chemin = '$caveId/logo_$horodatage.$extension';
    await _client.storage.from('logos-cave').uploadBinary(
          chemin,
          octets,
          fileOptions: const FileOptions(upsert: true),
        );
    final url = _client.storage.from('logos-cave').getPublicUrl(chemin);

    final resultat = await _client
        .from('caves')
        .update({'logo_url': url}).eq('id', caveId).select();
    if (resultat.isEmpty) {
      throw Exception('Modification refusée : rôle insuffisant.');
    }
    return url;
  }

  /// Modifie le nom/prénom de l'utilisateur actuellement authentifié.
  /// Colonnes non sensibles : autorisées par `profiles_update_self` pour
  /// les 4 rôles (le masquage à Propriétaire/Propriétaire-Gérant/Gérant
  /// se fait côté UI uniquement, par choix délibéré — voir PHASE1.md).
  Future<void> modifierMonProfil(
      {required String nom, required String prenom}) async {
    final utilisateur = _client.auth.currentUser;
    if (utilisateur == null) {
      throw Exception('Aucune session active.');
    }
    await _client
        .from('profiles')
        .update({'nom': nom, 'prenom': prenom}).eq('id', utilisateur.id);
  }

  /// Charge le profil de l'utilisateur actuellement authentifié.
  /// Retourne `null` si aucune session n'est active.
  ///
  /// Délai maximum de 15s : sans ça, une requête réseau lente (signal
  /// faible) bloque l'app indéfiniment sur l'écran de démarrage, sans
  /// jamais afficher d'erreur ni rediriger vers la connexion.
  Future<Profil?> profilActuel() async {
    final utilisateur = _client.auth.currentUser;
    if (utilisateur == null) return null;

    try {
      final ligne = await _client
          .from('profiles')
          .select()
          .eq('id', utilisateur.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));
      if (ligne == null) return null;
      return Profil.depuisJson(ligne);
    } on TimeoutException {
      return null;
    }
  }
}
