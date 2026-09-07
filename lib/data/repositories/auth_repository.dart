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
}
