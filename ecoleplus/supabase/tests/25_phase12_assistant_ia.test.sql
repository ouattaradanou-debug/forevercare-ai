-- Phase 12 : assistant IA — passages utilisables (jamais une autre classe,
-- les archives, un document exclu, sensible ou à la corbeille), fiches
-- propres à leur auteur, demandes écrites par le serveur seulement,
-- usage du mois et limites.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set ens2 '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
\set ecole '''10000000-0000-4000-8000-000000000001'''
begin;
select plan(17);

-- Bibliothèque de test (texte « fractions » partout).
insert into public.documents (id, school_id, space, title, is_common, class_ids, ai_allowed, is_sensitive,
                              index_status, trashed_at) values
  ('d1000000-0000-4000-8000-000000000001', :ecole, 'bibliotheque', 'Fractions CM1', false,
   '{c0000000-0000-4000-8000-000000000002}', true, false, 'indexe', null),
  ('d1000000-0000-4000-8000-000000000002', :ecole, 'bibliotheque', 'Fractions CM2', false,
   '{c0000000-0000-4000-8000-000000000003}', true, false, 'indexe', null),
  ('d1000000-0000-4000-8000-000000000003', :ecole, 'bibliotheque', 'Fractions exclu', true,
   '{}', false, false, 'indexe', null),
  ('d1000000-0000-4000-8000-000000000004', :ecole, 'archives', 'Fractions archives', false,
   '{}', false, false, 'exclu', null),
  ('d1000000-0000-4000-8000-000000000005', :ecole, 'bibliotheque', 'Fractions sensible', true,
   '{}', true, true, 'indexe', null),
  ('d1000000-0000-4000-8000-000000000006', :ecole, 'bibliotheque', 'Fractions corbeille', true,
   '{}', true, false, 'indexe', now()),
  ('d1000000-0000-4000-8000-000000000007', :ecole, 'bibliotheque', 'Guide commun', true,
   '{}', true, false, 'indexe', null);
insert into public.document_chunks (school_id, document_id, page, chunk_index, content)
select :ecole, d.id, 1, 0, 'Les fractions : ' || d.title || '. Une fraction partage l''unité en parts égales.'
  from public.documents d where d.id::text like 'd1000000-%';

set local role authenticated;

-- Enseignante du CM1 A.
select set_config('request.jwt.claims', :'ens1', true);
select is((select array_agg(titre order by titre) from public.ia_passages(:ecole, 'fractions', null, 20)),
  array['Fractions CM1', 'Guide commun'], 'CM1 : seulement sa classe et le commun autorisé');
select is((select count(*)::int from public.ia_passages(:ecole, 'fractions', '{d1000000-0000-4000-8000-000000000002}', 20)),
  0, 'CM1 : un document du CM2 coché de force ne sort pas');
select is((select count(*)::int from public.ia_passages(:ecole, 'fractions', '{d1000000-0000-4000-8000-000000000003,d1000000-0000-4000-8000-000000000004,d1000000-0000-4000-8000-000000000005,d1000000-0000-4000-8000-000000000006}', 20)),
  0, 'exclu, archives, sensible, corbeille : jamais');
select is((select count(*)::int from public.ia_passages(:ecole, 'partage unité', '{d1000000-0000-4000-8000-000000000001}', 20)),
  1, 'documents cochés : seulement ceux-là ; un seul mot suffit');
select is((select array_agg(titre order by titre) from public.ia_documents(:ecole)),
  array['Fractions CM1', 'Guide commun'], 'catalogue à cocher : mêmes règles');

-- Directeur : toute la bibliothèque autorisée, jamais archives / exclu / sensible / corbeille.
select set_config('request.jwt.claims', :'dir1', true);
select is((select array_agg(titre order by titre) from public.ia_passages(:ecole, 'fractions', null, 20)),
  array['Fractions CM1', 'Fractions CM2', 'Guide commun'], 'directeur : bibliothèque autorisée seulement');

-- Autre école : rien.
select set_config('request.jwt.claims', :'dir2', true);
select is((select count(*)::int from public.ia_passages(:ecole, 'fractions', null, 20)), 0, 'autre école : rien');

-- Demandes : écrites par le serveur seulement.
select set_config('request.jwt.claims', :'ens1', true);
select throws_ok($$insert into public.ai_requests (school_id, user_id, kind, request) values
  ('10000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'preparation', '{}')$$,
  '42501', null, 'une demande ne s''écrit pas depuis le téléphone (limites contournées)');
reset role;
insert into public.ai_requests (school_id, user_id, kind, status, request, cost_microusd) values
  (:ecole, 'a0000000-0000-4000-8000-000000000002', 'preparation', 'terminee', '{}', 3000),
  (:ecole, 'a0000000-0000-4000-8000-000000000002', 'exercices', 'terminee', '{}', 2000),
  (:ecole, 'a0000000-0000-4000-8000-000000000002', 'exercices', 'echec', '{}', 0),
  (:ecole, 'a0000000-0000-4000-8000-000000000003', 'remediation', 'terminee', '{}', 1000);
set local role authenticated;

-- Usage : l'enseignante voit sa ligne ; le directeur toute l'école.
select set_config('request.jwt.claims', :'ens1', true);
select is((select (demandes, limite, ecole_demandes, ecole_limite)::text from public.ia_usage(:ecole)),
  '(2,30,3,300)', 'enseignante : 2 demandes réussies sur 30 ; école 3 sur 300 (un échec ne compte pas)');
select is((select count(*)::int from public.ai_requests), 3, 'enseignante : lit ses seules demandes');
select set_config('request.jwt.claims', :'dir1', true);
select is((select count(*)::int from public.ia_usage(:ecole)), 3, 'directeur : une ligne par personne (directeur + 2 enseignants)');

-- Limite propre à un enseignant : le directeur seulement.
select lives_ok($$insert into public.ai_teacher_limits (school_id, membership_id, monthly_limit) values
  ('10000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000002', 40)$$,
  'directeur : 40 demandes pour l''enseignante');
select is((select limite from public.ia_usage(:ecole) where membership_id = 'a1000000-0000-4000-8000-000000000002'),
  40, 'limite ajustée appliquée');
select set_config('request.jwt.claims', :'ens1', true);
update public.ai_teacher_limits set monthly_limit = 999;
select is((select limite from public.ia_usage(:ecole)), 40, 'enseignante : ne change pas sa propre limite');

-- Fiches enregistrées : propres à leur auteur.
select lives_ok($$insert into public.lesson_preps (id, school_id, author_id, kind, theme, content) values
  ('1e000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'a0000000-0000-4000-8000-000000000002', 'preparation', 'Fractions', '{"titre":"Les fractions"}')$$,
  'enseignante : fiche enregistrée');
select set_config('request.jwt.claims', :'ens2', true);
select is((select count(*)::int from public.lesson_preps), 0, 'autre enseignant : ne voit pas la fiche');
select set_config('request.jwt.claims', :'dir1', true);
select is((select count(*)::int from public.lesson_preps), 1, 'directeur : lit la fiche');

select * from finish();
rollback;
