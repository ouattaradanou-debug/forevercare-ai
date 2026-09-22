import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

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
