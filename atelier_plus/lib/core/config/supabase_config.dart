/// Configuration de connexion à Supabase.
///
/// Les valeurs sont injectées à la compilation via `--dart-define` afin de
/// ne jamais committer de secret dans le dépôt :
///
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=xxxx
/// ```
///
/// Ou avec un fichier `dart_define.json` (ignoré par git, voir .gitignore) :
///
/// ```
/// flutter run --dart-define-from-file=dart_define.json
/// ```
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Permet de détecter tôt (au démarrage) un oubli de configuration plutôt
  /// que de laisser Supabase échouer avec une erreur réseau peu claire.
  static bool get estConfigure => url.isNotEmpty && anonKey.isNotEmpty;
}
