import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/telephone_utils.dart';

/// Authentification par numéro de téléphone + code PIN.
///
/// Voir `TelephoneUtils` pour l'explication du choix d'un email synthétique
/// en interne : l'utilisateur ne voit et ne saisit jamais d'adresse email.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> get changementsEtat => _client.auth.onAuthStateChange;

  User? get utilisateurCourant => _client.auth.currentUser;

  Future<AuthResponse> creerCompte({
    required String telephone,
    required String pin,
  }) {
    return _client.auth.signUp(
      email: TelephoneUtils.emailSynthetique(telephone),
      password: pin,
    );
  }

  Future<AuthResponse> seConnecter({
    required String telephone,
    required String pin,
  }) {
    return _client.auth.signInWithPassword(
      email: TelephoneUtils.emailSynthetique(telephone),
      password: pin,
    );
  }

  Future<void> seDeconnecter() => _client.auth.signOut();

  /// Enregistre (ou remplace) la question secrète de récupération du
  /// compte connecté — voir CodeOubliePage, seul moyen pour le
  /// propriétaire de réinitialiser son code PIN s'il l'oublie, faute de
  /// vrai email ou de fournisseur SMS (voir TelephoneUtils). Passe par une
  /// Edge Function : la table `recuperation_compte` n'accorde aucune
  /// policy RLS (voir supabase/migration_phase7_recuperation_compte.sql).
  Future<void> definirRecuperation({
    required String question,
    required String reponse,
  }) async {
    await _client.functions.invoke(
      'definir-recuperation',
      body: {'question': question, 'reponse': reponse},
    );
  }

  /// Première étape de "Code oublié ?" : renvoie la question secrète
  /// configurée pour ce numéro, sans nécessiter de session (l'utilisateur
  /// a justement perdu l'accès à son compte).
  Future<String> recupererQuestionRecuperation(String telephone) async {
    final response = await _client.functions.invoke(
      'recuperer-question',
      body: {'telephone': telephone},
    );
    return (response.data as Map)['question'] as String;
  }

  /// Seconde étape de "Code oublié ?" : vérifie la réponse et, si elle est
  /// correcte, remplace le code PIN par [nouveauPin].
  Future<void> reinitialiserCode({
    required String telephone,
    required String reponse,
    required String nouveauPin,
  }) async {
    await _client.functions.invoke(
      'reinitialiser-code',
      body: {
        'telephone': telephone,
        'reponse': reponse,
        'nouveauPin': nouveauPin,
      },
    );
  }
}
