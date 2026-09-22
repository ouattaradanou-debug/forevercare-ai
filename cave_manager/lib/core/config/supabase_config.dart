/// Configuration Supabase injectée au build, jamais codée en dur.
///
/// Lancer l'app avec :
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=xxxx
/// ```
///
/// La clé "anon" est publique par conception (c'est la sécurité RLS côté
/// Postgres qui protège les données, pas le secret de cette clé) — voir
/// PHASE1.md, section sécurité. La clé "service role", elle, ne doit
/// jamais apparaître ici : elle vit uniquement dans l'Edge Function
/// `create-team-member`.
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get estConfigure => url.isNotEmpty && anonKey.isNotEmpty;
}
