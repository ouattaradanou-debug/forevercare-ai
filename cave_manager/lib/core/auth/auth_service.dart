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
  }) async {
    assert(
      role == RoleUtilisateur.proprietaire || role == RoleUtilisateur.proprietaireGerant,
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
    });
  }

  Future<void> seConnecter({required String telephone, required String pin}) async {
    await _client.auth.signInWithPassword(
      email: telephoneVersEmailTechnique(telephone),
      password: pin,
    );
  }

  Future<void> seDeconnecter() => _client.auth.signOut();

  /// Charge le profil de l'utilisateur actuellement authentifié.
  /// Retourne `null` si aucune session n'est active.
  Future<Profil?> profilActuel() async {
    final utilisateur = _client.auth.currentUser;
    if (utilisateur == null) return null;

    final ligne = await _client.from('profiles').select().eq('id', utilisateur.id).maybeSingle();
    if (ligne == null) return null;
    return Profil.depuisJson(ligne);
  }
}
