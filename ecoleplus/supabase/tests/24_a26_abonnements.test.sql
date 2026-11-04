-- A26 : cantine par abonnement mensuel — tarif et mois, abonnement d'un
-- mois au montant figé, reçu de plusieurs mois, responsable de cantine qui
-- encaisse la cantine seulement, module désactivé.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set can1 '{"sub":"a0000000-0000-4000-8000-0000000000c1","role":"authenticated"}'
\set ecole '''10000000-0000-4000-8000-000000000001'''
begin;
select plan(16);

insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
values ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-4000-8000-0000000000c1', 'authenticated',
        'authenticated', 'cantine@ecole-test.local', '', now(), now(), now());
insert into public.memberships (id, school_id, user_id, role, display_name) values
  ('a1000000-0000-4000-8000-0000000000c1', :ecole, 'a0000000-0000-4000-8000-0000000000c1', 'delegue', 'Cantine Test');
insert into public.delegate_permissions (school_id, membership_id, permission_key) values
  (:ecole, 'a1000000-0000-4000-8000-0000000000c1', 'cantine');
insert into public.devices (id, school_id, user_id, label, series_code) values
  ('90000000-0000-4000-8000-0000000000c1', :ecole, 'a0000000-0000-4000-8000-0000000000c1', 'Téléphone cantine', 'C');
update public.school_modules set enabled = true where module_key = 'cantine' and school_id = :ecole;

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select lives_ok($$insert into public.canteen_years (school_id, school_year_id, months, due_day) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025',
   '{2025-10-01,2025-11-01,2025-12-01}', 5)$$, 'directeur : mois de fonctionnement');
select lives_ok($$insert into public.canteen_rates (school_id, school_year_id, from_month, amount) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', '2025-10-01', 5000)$$,
  'directeur : tarif mensuel');

-- Responsable de cantine : abonnement d'octobre et de novembre, un reçu.
select set_config('request.jwt.claims', :'can1', true);
select lives_ok($$insert into public.canteen_subscriptions (id, school_id, school_year_id, student_id, month, amount_due) values
  ('5e000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000001', '2025-10-01', 5000),
  ('5e000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000001', '2025-11-01', 5000)$$,
  'cantine : deux mois abonnés');
select throws_ok($$insert into public.canteen_subscriptions (school_id, school_year_id, student_id, month, amount_due) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025',
   'd0000000-0000-4000-8000-000000000001', '2025-10-01', 5000)$$,
  '23505', null, 'même élève, même mois : un seul abonnement');
select lives_ok($$insert into public.payments (id, school_id, school_year_id, student_id, rubric, amount, method,
  paid_at, device_id, device_seq, receipt_number, payer_name) values
  ('e1000000-0000-4000-8000-0000000000a1', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000001', 'cantine', 10000,
   'especes', now(), '90000000-0000-4000-8000-0000000000c1', 1, 'R2526-C-00001', 'M. TEST')$$,
  'cantine : reçu de cantine');
select lives_ok($$insert into public.payment_allocations (school_id, payment_id, rubric, label, amount,
  canteen_subscription_id) values
  ('10000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-0000000000a1', 'cantine',
   'Cantine — octobre 2025', 5000, '5e000000-0000-4000-8000-000000000001'),
  ('10000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-0000000000a1', 'cantine',
   'Cantine — novembre 2025', 5000, '5e000000-0000-4000-8000-000000000002')$$,
  'un reçu, deux mois (détail)');
select throws_ok($$insert into public.payments (school_id, school_year_id, student_id, rubric, amount, method,
  paid_at, device_id, device_seq, receipt_number) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025',
   'd0000000-0000-4000-8000-000000000001', 'scolarite', 1000, 'especes', now(),
   '90000000-0000-4000-8000-0000000000c1', 2, 'R2526-C-00002')$$,
  '42501', null, 'cantine : encaisser la scolarité est refusé');
select is((select count(*)::int from public.payments), 1, 'cantine : ne voit que les reçus de cantine');

-- Montant figé : un nouveau tarif ne change pas un mois déjà abonné.
update public.canteen_subscriptions set amount_due = 1 where id = '5e000000-0000-4000-8000-000000000001';
select is((select amount_due from public.canteen_subscriptions where id = '5e000000-0000-4000-8000-000000000001'),
  5000, 'montant de l''abonnement figé');
select throws_ok($$update public.canteen_subscriptions set deleted_at = now()
  where id = '5e000000-0000-4000-8000-000000000001'$$, 'P0001', null,
  'mois payé : retrait refusé (annuler d''abord le reçu)');

-- Détail incohérent : abonnement d'un autre élève.
select lives_ok($$insert into public.canteen_subscriptions (id, school_id, school_year_id, student_id, month, amount_due) values
  ('5e000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000002', '2025-10-01', 5000)$$,
  'autre élève abonné');
select lives_ok($$insert into public.payments (id, school_id, school_year_id, student_id, rubric, amount, method,
  paid_at, device_id, device_seq, receipt_number) values
  ('e1000000-0000-4000-8000-0000000000a2', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000001', 'cantine', 5000,
   'especes', now(), '90000000-0000-4000-8000-0000000000c1', 3, 'R2526-C-00003')$$, 'reçu');
select throws_ok($$insert into public.payment_allocations (school_id, payment_id, rubric, label, amount,
  canteen_subscription_id) values
  ('10000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-0000000000a2', 'cantine',
   'Cantine', 5000, '5e000000-0000-4000-8000-000000000003')$$, 'P0001', null,
  'détail sur l''abonnement d''un autre élève : refusé');

-- Enseignant : rien.
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.canteen_subscriptions) + (select count(*)::int from public.canteen_rates),
  0, 'enseignant : aucun abonnement ni tarif');

-- Module désactivé : lectures vides, données conservées.
reset role;
update public.school_modules set enabled = false where module_key = 'cantine' and school_id = :ecole;
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select is((select count(*)::int from public.canteen_subscriptions), 0, 'OFF : abonnements invisibles');
reset role;
select is((select count(*)::int from public.canteen_subscriptions where school_id = :ecole), 3, 'OFF : conservés');

select * from finish();
rollback;
