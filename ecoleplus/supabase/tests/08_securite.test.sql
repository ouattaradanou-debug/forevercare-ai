-- Compléments de la phase 1 : journal d'activité, téléphones, question secrète.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
begin;
select plan(23);

-- ------------------------- Journal d'activité ------------------------
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
update public.schools set phone = '+226 22 22 22 22';
update public.school_modules set enabled = true where module_key = 'cantine';
select is((select details -> 'colonnes' from public.audit_log
            where table_name = 'schools' and action = 'modification' order by occurred_at desc limit 1),
  '["phone"]'::jsonb, 'journal : modification de l''école tracée avec la colonne changée');
select is((select actor_id::text from public.audit_log
            where table_name = 'schools' and action = 'modification' and actor_id is not null limit 1),
  'a0000000-0000-4000-8000-000000000001', 'journal : auteur enregistré');
select is((select details ->> 'module' from public.audit_log
            where table_name = 'school_modules' and action = 'modification' limit 1),
  'cantine', 'journal : activation d''un module tracée');
update public.schools set phone = '+226 22 22 22 22';
select is((select count(*)::int from public.audit_log where table_name = 'schools' and action = 'modification' and actor_id is not null), 1,
  'journal : un renvoi identique n''ajoute rien');
reset role;
select throws_ok($$update public.audit_log set action = 'falsifie'$$, 'P0001', null,
  'journal : impossible de le modifier, même pour l''administrateur de la base');
set local role authenticated;

select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.audit_log), 0, 'journal : invisible pour un enseignant');

-- ------------------------------ Téléphones ---------------------------
select is((public.register_device('9e000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001', 'Téléphone de l''enseignant')) ->> 'series_code', 'C',
  'connexion de l''enseignant : téléphone inscrit');
select is((public.device_heartbeat('9e000000-0000-4000-8000-000000000001', 7, '0.1.0')) ->> 'revoked',
  'false', 'signal de synchronisation accepté');
select throws_ok($$select public.revoke_device('90000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'un enseignant ne peut pas déconnecter le téléphone du directeur');

reset role;
insert into auth.sessions (id, user_id, created_at, updated_at)
values ('5e000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', now(), now());
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select is((select pending_count from public.devices where id = '9e000000-0000-4000-8000-000000000001'), 7,
  'le directeur voit les éléments non envoyés du téléphone de l''enseignant');
select is((select count(*)::int from public.audit_log where action = 'connexion'), 1,
  'la connexion de l''enseignant apparaît dans le journal');
select lives_ok($$select public.revoke_device('9e000000-0000-4000-8000-000000000001')$$,
  'le directeur déconnecte un téléphone perdu');
reset role;
select is((select count(*)::int from auth.sessions where user_id = 'a0000000-0000-4000-8000-000000000002'), 0,
  'les sessions de la personne sont fermées');
set local role authenticated;
select set_config('request.jwt.claims', :'ens1', true);
select is((public.device_heartbeat('9e000000-0000-4000-8000-000000000001', 0, '0.1.0')) ->> 'revoked',
  'true', 'le téléphone perdu apprend qu''il est déconnecté');
select throws_ok($$select public.register_device('9e000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001', 'x')$$, 'P0001', null,
  'un téléphone déconnecté ne peut pas se réinscrire sous la même identité');

-- ---------------------------- Question secrète -----------------------
select throws_ok($$select public.set_recovery_question('Ma question ?', 'ab')$$, 'P0001', null,
  'réponse trop courte refusée');
select lives_ok($$select public.set_recovery_question('Couleur de mon premier vélo ?', 'Bleu Ciel')$$,
  'question secrète enregistrée');
select throws_ok($$select public.recovery_verify('enseignant1@ecole-test.local', 'bleu ciel')$$,
  '42501', null, 'la vérification est réservée au serveur');
reset role;
select is((select position('bleu' in answer_hash) from app.recovery_secrets), 0,
  'la réponse n''est pas stockée en clair');
select is(public.recovery_lookup('enseignant1@ecole-test.local'), 'Couleur de mon premier vélo ?',
  'le serveur retrouve la question');
select is(public.recovery_verify('enseignant1@ecole-test.local', '  BLEU   cièl ') ->> 'statut', 'ok',
  'bonne réponse (majuscules, accents et espaces ignorés)');
select is((select count(*)::int from public.audit_log where action = 'recuperation_mot_de_passe'), 1,
  'la récupération est signalée dans le journal du directeur');
-- 5 erreurs : blocage, même avec la bonne réponse
select public.recovery_verify('enseignant1@ecole-test.local', 'rouge') from generate_series(1, 5);
select is(public.recovery_verify('enseignant1@ecole-test.local', 'bleu ciel') ->> 'statut', 'bloque',
  'après 5 erreurs en une heure : bloqué');

select * from finish();
rollback;
