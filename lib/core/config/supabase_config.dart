/// Configuration de connexion au projet Supabase d'Atelier+.
///
/// Marche à suivre (à faire une seule fois, voir le résumé de la Phase 1) :
/// 1. Créer un projet sur https://supabase.com (gratuit).
/// 2. Exécuter `supabase/schema.sql` dans l'éditeur SQL du projet.
/// 3. Dans Project Settings > API, copier "Project URL" et "anon public key"
///    ci-dessous.
/// 4. Dans Authentication > Sign In / Providers > Email, désactiver
///    "Confirm email" (l'application n'utilise pas de vraies adresses email,
///    voir la note dans `TelephoneUtils`).
///
/// La clé "anon" n'est pas un secret : elle est conçue pour être embarquée
/// dans une application cliente, la sécurité réelle est assurée par les
/// politiques Row Level Security définies dans `supabase/schema.sql`.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jykjxstnctjkzjrtoyye.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5a2p4c3RuY3Rqa3pqcnRveXllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4MDE2MTMsImV4cCI6MjEwNDM3NzYxM30.eWqKpmYWUIUA2UPnC7UcD2wuMuQNQKZRiXXchMYptnw',
  );

  static bool get estConfigure =>
      !url.contains('VOTRE-PROJET') && !anonKey.contains('VOTRE_CLE');
}
