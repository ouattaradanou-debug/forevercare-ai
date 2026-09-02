import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Client Supabase partagé. Suppose que `Supabase.initialize(...)` a déjà
/// été appelé dans `main.dart` (protégé par `SupabaseConfig.estConfigure`).
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Flux d'état d'authentification Supabase (connexion/déconnexion/refresh),
/// consommé par le router pour rediriger automatiquement vers l'écran de
/// connexion ou l'accueil.
final etatAuthProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});
