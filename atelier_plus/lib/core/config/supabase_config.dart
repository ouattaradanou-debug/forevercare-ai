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

  /// URL/clé effectivement utilisées pour initialiser Supabase : les
  /// vraies valeurs si configurées, sinon des valeurs de substitution
  /// syntaxiquement valides. Indispensable de toujours appeler
  /// `Supabase.initialize` (voir main.dart) : `Supabase.instance.client`
  /// est utilisé partout dans l'application dès l'affichage du premier
  /// écran (redirection du router selon l'état de connexion), y compris
  /// hors-ligne — sans appel préalable à `initialize`, ne serait-ce que
  /// lire `Supabase.instance` lèverait une exception immédiatement, avant
  /// même la moindre tentative réseau (que le reste du code gère déjà
  /// normalement comme un cas hors-ligne).
  static String get urlEffective => estConfigure ? url : 'https://placeholder.invalid';
  static String get anonKeyEffective => estConfigure ? anonKey : 'placeholder-anon-key';
}
