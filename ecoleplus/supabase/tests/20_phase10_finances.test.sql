-- Phase 10 : finances — droits (directeur, délégué « finances »), reçus
-- inaltérables, numéros contrôlés, annulations motivées, enseignant bloqué.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set sec1 '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
begin;
select plan(29);

-- Téléphone de la secrétaire (série C).
insert into public.devices (id, school_id, user_id, label, series_code) values
  ('90000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001',
   'a0000000-0000-4000-8000-000000000004', 'Téléphone de la secrétaire', 'C');

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);

-- Grille : scolarité du CM1.
select lives_ok($$insert into public.fee_items (id, school_id, school_year_id, rubric, label, level_code, amount) values
  ('f1000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'scolarite', 'Scolarité', 'CM1', 25000)$$,
  'directeur : grille de frais');

-- Encaissement correct (série A du directeur).
select lives_ok($$insert into public.payments (id, school_id, school_year_id, student_id, rubric, fee_item_id, amount,
  method, paid_at, device_id, device_seq, receipt_number, payer_name) values
  ('e1000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000001', 'scolarite',
   'f1000000-0000-4000-8000-000000000001', 10000, 'especes', now(),
   '90000000-0000-4000-8000-000000000001', 2, 'R2526-A-00002', 'M. TEST')$$,
  'directeur : encaissement, reçu R2526-A-00002');
select is((select received_by::text from public.payments where id = 'e1000000-0000-4000-8000-000000000001'),
  'a0000000-0000-4000-8000-000000000001', 'auteur imposé par le serveur');

select throws_ok($$insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at,
  device_id, device_seq, receipt_number) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'autre', 500, 'especes', now(),
   '90000000-0000-4000-8000-000000000001', 3, 'R2526-A-00099')$$,
  'P0001', null, 'numéro de reçu incohérent : refusé');
select throws_ok($$insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at,
  device_id, device_seq, receipt_number) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'autre', 500, 'especes', now(),
   '90000000-0000-4000-8000-000000000003', 1, 'R2526-C-00001')$$,
  '42501', null, 'série du téléphone d''une autre personne : refusée');
select throws_ok($$insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at,
  device_id, device_seq, receipt_number) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'autre', 500, 'especes', now(),
   '90000000-0000-4000-8000-000000000001', 2, 'R2526-A-00002')$$,
  '23505', null, 'même numéro deux fois : refusé (aucun doublon)');

-- Inaltérable : ni modification ni suppression, même par le directeur.
update public.payments set amount = 1 where id = 'e1000000-0000-4000-8000-000000000001';
select is((select amount from public.payments where id = 'e1000000-0000-4000-8000-000000000001'), 10000::bigint,
  'modification d''un reçu par l''application : sans effet');
delete from public.payments where id = 'e1000000-0000-4000-8000-000000000001';
select is((select count(*)::int from public.payments where id = 'e1000000-0000-4000-8000-000000000001'), 1,
  'suppression d''un reçu par l''application : sans effet');
reset role;
select throws_ok($$delete from public.payments where id = 'e1000000-0000-4000-8000-000000000001'$$,
  null, null, 'suppression refusée même pour l''administrateur de la base');
select throws_ok($$update public.payments set amount = 1 where id = 'e1000000-0000-4000-8000-000000000001'$$,
  null, null, 'modification refusée même pour l''administrateur de la base');
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);

-- Annulation (contre-passation) motivée.
select throws_ok($$insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at,
  device_id, device_seq, receipt_number, reverses_payment_id, reversal_reason) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'scolarite', -5000, 'especes', now(),
   '90000000-0000-4000-8000-000000000001', 3, 'R2526-A-00003', 'e1000000-0000-4000-8000-000000000001', 'Erreur')$$,
  'P0001', null, 'annulation d''un autre montant : refusée');
select throws_ok($$insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at,
  device_id, device_seq, receipt_number, reverses_payment_id) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'scolarite', -10000, 'especes', now(),
   '90000000-0000-4000-8000-000000000001', 3, 'R2526-A-00003', 'e1000000-0000-4000-8000-000000000001')$$,
  '23514', null, 'annulation sans motif : refusée');
select lives_ok($$insert into public.payments (id, school_id, school_year_id, rubric, amount, method, paid_at,
  device_id, device_seq, receipt_number, reverses_payment_id, reversal_reason) values
  ('e1000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'autre', -10000, 'especes', now(),
   '90000000-0000-4000-8000-000000000001', 3, 'R2526-A-00003', 'e1000000-0000-4000-8000-000000000001',
   'Montant saisi sur le mauvais élève')$$,
  'annulation motivée du montant exact : acceptée');
select is((select (student_id::text, rubric, fee_item_id::text)::text from public.payments
            where id = 'e1000000-0000-4000-8000-000000000002'),
  '(d0000000-0000-4000-8000-000000000001,scolarite,f1000000-0000-4000-8000-000000000001)',
  'annulation : élève et rubrique repris du reçu annulé');
select throws_ok($$insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at,
  device_id, device_seq, receipt_number, reverses_payment_id, reversal_reason) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'scolarite', -10000, 'especes', now(),
   '90000000-0000-4000-8000-000000000001', 4, 'R2526-A-00004', 'e1000000-0000-4000-8000-000000000001', 'Encore')$$,
  '23505', null, 'deuxième annulation du même reçu : refusée');
select throws_ok($$insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at,
  device_id, device_seq, receipt_number, reverses_payment_id, reversal_reason) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'scolarite', 10000, 'especes', now(),
   '90000000-0000-4000-8000-000000000001', 4, 'R2526-A-00004', 'e1000000-0000-4000-8000-000000000002', 'Annuler l''annulation')$$,
  null, null, 'annulation d''une annulation : refusée');

-- Dépense avec annulation.
select lives_ok($$insert into public.expenses (id, school_id, school_year_id, category, label, amount, spent_on,
  method, device_id, device_seq, voucher_number) values
  ('e2000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'fournitures', 'Craies', 3000, current_date, 'especes',
   '90000000-0000-4000-8000-000000000001', 1, 'D2526-A-00001')$$, 'directeur : dépense');
select lives_ok($$insert into public.expenses (school_id, school_year_id, category, label, amount, spent_on,
  device_id, device_seq, reverses_expense_id, reversal_reason) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'autre', 'x', -3000, current_date,
   '90000000-0000-4000-8000-000000000001', 2, 'e2000000-0000-4000-8000-000000000001', 'Doublon')$$,
  'dépense annulée par contre-passation');
select is((select category from public.expenses where reverses_expense_id = 'e2000000-0000-4000-8000-000000000001'),
  'fournitures', 'annulation : catégorie reprise');

-- Secrétaire (droit « finances » seulement).
select set_config('request.jwt.claims', :'sec1', true);
select lives_ok($$insert into public.payments (school_id, school_year_id, student_id, rubric, amount, method,
  reference, paid_at, device_id, device_seq, receipt_number) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025',
   'd0000000-0000-4000-8000-000000000002', 'inscription', 5000, 'orange_money', 'OM-123', now(),
   '90000000-0000-4000-8000-000000000003', 1, 'R2526-C-00001')$$,
  'économe : encaissement sur son téléphone');
select is((select count(*)::int from public.payments), 6, 'économe : voit tous les encaissements de l''école');
select lives_ok($$insert into storage.objects (bucket_id, name) values
  ('finances', '10000000-0000-4000-8000-000000000001/depenses/facture.jpg')$$, 'économe : justificatif déposé');

-- Enseignant : aucune donnée financière, rien en écriture.
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.payments) + (select count(*)::int from public.expenses)
        + (select count(*)::int from public.fee_items) + (select count(*)::int from public.cash_closings), 0,
  'enseignant : aucune donnée financière');
select throws_ok($$insert into public.fee_items (school_id, school_year_id, rubric, label, amount) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'autre', 'x', 1)$$,
  '42501', null, 'enseignant : grille refusée');
select is((select count(*)::int from storage.objects where bucket_id = 'finances'), 0,
  'enseignant : aucun justificatif');
select throws_ok($$insert into storage.objects (bucket_id, name) values
  ('finances', '10000000-0000-4000-8000-000000000001/depenses/x.jpg')$$, '42501', null,
  'enseignant : dépôt de justificatif refusé');

-- Directeur d'une autre école.
select set_config('request.jwt.claims', :'dir2', true);
select is((select count(*)::int from public.payments) + (select count(*)::int from public.expenses), 0,
  'autre école : rien');

-- Clôture mensuelle : auteur imposé.
select set_config('request.jwt.claims', :'dir1', true);
select lives_ok($$insert into public.cash_closings (school_id, period_month, closing_balance, closed_by) values
  ('10000000-0000-4000-8000-000000000001', date_trunc('month', current_date)::date, 12000,
   'a0000000-0000-4000-8000-000000000004')$$, 'clôture du mois');
select is((select closed_by::text from public.cash_closings), 'a0000000-0000-4000-8000-000000000001',
  'clôture : auteur imposé');

select * from finish();
rollback;
