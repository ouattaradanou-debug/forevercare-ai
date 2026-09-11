-- =============================================================================
-- Atelier+ — Politique Supabase Storage — Distribution de l'APK de test
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase.
--
-- Bucket "installations" : contient uniquement le fichier
-- "atelier-plus.apk", reconstruit et republié automatiquement à chaque
-- envoi de code sur GitHub (voir .github/workflows/build-apk.yml). Public
-- en lecture pour que le lien de téléchargement fonctionne directement
-- depuis WhatsApp, sans aucune connexion préalable — un tailleur n'a rien
-- d'autre à faire qu'ouvrir le lien.
--
-- Aucune policy d'écriture n'est accordée : seul le pipeline de build
-- (clé service_role, qui contourne RLS) peut déposer ou remplacer ce
-- fichier. Personne, pas même un propriétaire d'atelier connecté à
-- l'application, ne peut y écrire via un appel à l'API.
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('installations', 'installations', true)
on conflict (id) do nothing;

create policy "installations_lecture_publique"
  on storage.objects for select
  using (bucket_id = 'installations');
