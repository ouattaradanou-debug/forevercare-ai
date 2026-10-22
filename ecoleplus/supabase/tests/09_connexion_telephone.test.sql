-- A11 : connexion du directeur avec son numéro de téléphone.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set dir9 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
begin;
select plan(17);

-- Un enseignant qui se connecte déjà avec un numéro (compte « numéro »).
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
                        created_at, updated_at)
values ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-4000-8000-0000000000e1',
        'authenticated', 'authenticated', '22670000001@tel.ecoleplus.invalid',
        extensions.crypt('motdepasse-test', extensions.gen_salt('bf')), now(), now(), now());

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select throws_ok($$select public.set_login_phone('70561740')$$, 'P0001', null,
  'numéro non normalisé refusé');
select throws_ok($$select public.set_login_phone('22670000001')$$, 'P0001',
  'Ce numéro est déjà utilisé pour se connecter à un autre compte.',
  'numéro déjà identifiant d''un enseignant : refusé');
select lives_ok($$select public.set_login_phone('22670561740')$$, 'le directeur choisit son numéro');
select is(public.get_login_phone(), '22670561740', 'il le retrouve dans « Mon compte »');
select lives_ok($$select public.set_login_phone('22670561741')$$, 'il peut en changer');
select is(public.get_login_phone(), '22670561741', 'un seul numéro par compte');

select set_config('request.jwt.claims', :'dir9', true);
select throws_ok($$select public.set_login_phone('22670561741')$$, 'P0001', null,
  'un autre directeur ne peut pas prendre le même numéro');
select is(public.get_login_phone(), null, 'il ne voit pas le numéro des autres');

select set_config('request.jwt.claims', :'dir1', true);
select throws_ok($$select public.login_lookup('22670561741', 'motdepasse-test')$$, '42501', null,
  'la vérification est réservée au serveur');
select throws_ok($$select count(*) from app.login_phones$$, '42501', null,
  'la table des numéros n''est pas lisible depuis l''application');

reset role;
select is(public.login_phone_taken('22670561741'), true, 'gerer-membres voit le numéro pris');
select is(public.login_lookup('22670561741', 'faux-mot-de-passe') ->> 'statut', 'faux',
  'mauvais mot de passe : refus sans e-mail');
select is(public.login_lookup('22679999999', 'motdepasse-test'), '{"statut": "faux"}'::jsonb,
  'numéro inconnu : même réponse qu''un mauvais mot de passe');
select is(public.login_lookup('22670561741', 'motdepasse-test'),
  '{"statut": "ok", "email": "directeur@ecole-test.local"}'::jsonb,
  'bon numéro et bon mot de passe : e-mail du compte');
select is((select count(*)::int from public.audit_log where action = 'connexion_par_numero'), 1,
  'la connexion par numéro est notée dans le journal');
select public.login_lookup('22670561741', 'faux') from generate_series(1, 5);
select is(public.login_lookup('22670561741', 'motdepasse-test') ->> 'statut', 'bloque',
  'après 5 erreurs en une heure : bloqué, même avec le bon mot de passe');

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select lives_ok($$select public.set_login_phone(null)$$, 'le directeur peut retirer son numéro');

select * from finish();
rollback;
