-- Phase 14 : audit de sécurité automatique (rejoué à chaque modification).
begin;
select plan(12);

select is((select count(*)::int from information_schema.role_table_grants
            where grantee in ('anon', 'PUBLIC') and table_schema in ('public', 'medical')),
  0, 'personne non connectée : aucun droit sur les tables');

select is((select string_agg(p.proname, ', ') from pg_proc p join pg_namespace n on n.oid = p.pronamespace
            where n.nspname in ('public', 'medical', 'app') and has_function_privilege('anon', p.oid, 'execute')),
  null, 'personne non connectée : aucune fonction exécutable');

select is((select string_agg(n.nspname || '.' || p.proname, ', ') from pg_proc p
             join pg_namespace n on n.oid = p.pronamespace
            where p.prosecdef and n.nspname in ('public', 'app', 'medical')
              and not exists (select 1 from unnest(coalesce(p.proconfig, '{}')) c where c like 'search_path=%')),
  null, 'toute fonction « security definer » fixe son search_path');

select is((select count(*)::int from pg_class c join pg_namespace n on n.oid = c.relnamespace
            where c.relkind = 'r' and n.nspname in ('public', 'medical') and not c.relrowsecurity),
  0, 'RLS activée sur toutes les tables');

select is((select count(*)::int from pg_policies
            where schemaname in ('public', 'medical', 'storage') and roles && array['public', 'anon']::name[]),
  0, 'aucune règle d''accès ouverte à tous ou aux personnes non connectées');

select is((select count(*)::int from storage.buckets where public), 0,
  'stockage : aucun compartiment public (photos, documents, justificatifs)');

select is((select count(*)::int from information_schema.role_table_grants
            where grantee = 'authenticated' and table_schema = 'medical'),
  0, 'dossier médico-scolaire : aucune table lisible directement (fonctions journalisées seulement)');

select is((select count(*)::int from pg_policies
            where (schemaname, tablename) in (('public', 'audit_log'), ('public', 'sync_conflicts'))
              and cmd <> 'SELECT'),
  0, 'journaux d''activité et de conflits : jamais modifiables par l''application');

select is((select count(*)::int from pg_policies
            where schemaname = 'medical' and tablename = 'access_log' and permissive = 'PERMISSIVE'
              and cmd in ('UPDATE', 'DELETE')),
  0, 'journal d''accès médical : ni modifié ni effacé');

select is((select prosecdef from pg_proc where oid = 'public.ia_passages(uuid, text, uuid[], integer)'::regprocedure),
  false, 'IA : passages cherchés avec les droits de la personne (security invoker)');

select ok((select bool_and(exists (select 1 from pg_trigger t where t.tgrelid = c.oid and not t.tgisinternal
                                     and t.tgname in (c.relname || '_no_delete', 'append_only')))
             from pg_class c join pg_namespace n on n.oid = c.relnamespace
            where n.nspname = 'public' and c.relname in ('students', 'payments', 'grades', 'expenses', 'attendance')),
  'élèves, notes, présences : suppression interdite ; paiements, dépenses : ajout seul');

-- Personne non connectée : rien ne sort, même par l'API.
set local role anon;
select throws_ok($$select count(*) from public.students$$, '42501', null,
  'non connecté : lecture des élèves refusée');

select * from finish();
rollback;
