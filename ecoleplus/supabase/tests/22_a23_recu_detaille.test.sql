-- A23 : un reçu peut régler plusieurs rubriques (détail inaltérable).
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set sec1 '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
begin;
select plan(12);
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);

insert into public.fee_items (id, school_id, school_year_id, rubric, label, class_id, amount, payment_terms) values
  ('f2000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'scolarite', 'Scolarité',
   'c0000000-0000-4000-8000-000000000002', 30000, 'partiel'),
  ('f2000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'assurance', 'Assurance',
   'c0000000-0000-4000-8000-000000000002', 1000, 'integral');
insert into public.fee_installments (id, school_id, fee_item_id, label, starts_on, due_on, amount) values
  ('f3000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'f2000000-0000-4000-8000-000000000001', '1er versement', null, null, 10000);

select lives_ok($$insert into public.payments (id, school_id, school_year_id, student_id, rubric, amount,
  method, method_label, payer_name, payer_phone, paid_at, device_id, device_seq, receipt_number) values
  ('e3000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000001', 'plusieurs', 11000,
   'autre', 'Wave', 'M. TEST', '70000000', now(),
   '90000000-0000-4000-8000-000000000001', 2, 'R2526-A-00002')$$,
  'reçu de plusieurs rubriques, mode « Autre » précisé (Wave)');
select lives_ok($$insert into public.payment_allocations (school_id, payment_id, fee_item_id, installment_id, rubric, label, amount) values
  ('10000000-0000-4000-8000-000000000001', 'e3000000-0000-4000-8000-000000000001',
   'f2000000-0000-4000-8000-000000000001', 'f3000000-0000-4000-8000-000000000001', 'scolarite', '1er versement', 10000),
  ('10000000-0000-4000-8000-000000000001', 'e3000000-0000-4000-8000-000000000001',
   'f2000000-0000-4000-8000-000000000002', null, 'assurance', 'Assurance', 1000)$$,
  'détail : 1er versement + assurance');
select throws_ok($$insert into public.payment_allocations (school_id, payment_id, rubric, label, amount) values
  ('10000000-0000-4000-8000-000000000001', 'e3000000-0000-4000-8000-000000000001', 'autre', 'x', 1)$$,
  'P0001', null, 'détail au-delà du montant du reçu : refusé');
select throws_ok($$insert into public.payment_allocations (school_id, payment_id, rubric, label, amount) values
  ('10000000-0000-4000-8000-000000000001', 'e3000000-0000-4000-8000-000000000001', 'autre', 'x', -1)$$,
  'P0001', null, 'détail de signe opposé : refusé');
update public.payment_allocations set amount = 1 where payment_id = 'e3000000-0000-4000-8000-000000000001';
select is((select sum(amount)::int from public.payment_allocations where payment_id = 'e3000000-0000-4000-8000-000000000001'),
  11000, 'détail non modifiable par l''application');
reset role;
select throws_ok($$delete from public.payment_allocations where payment_id = 'e3000000-0000-4000-8000-000000000001'$$,
  null, null, 'détail jamais supprimé, même par l''administrateur');
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);

-- Annulation : reprend le mode libre et le payeur ; détail opposé.
select lives_ok($$insert into public.payments (id, school_id, school_year_id, rubric, amount, method, paid_at,
  device_id, device_seq, receipt_number, reverses_payment_id, reversal_reason) values
  ('e3000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'plusieurs', -11000, 'autre', now(),
   '90000000-0000-4000-8000-000000000001', 3, 'R2526-A-00003',
   'e3000000-0000-4000-8000-000000000001', 'Mauvais élève')$$, 'annulation du reçu détaillé');
select is((select (method_label, payer_name, payer_phone)::text from public.payments
            where id = 'e3000000-0000-4000-8000-000000000002'),
  '(Wave,"M. TEST",70000000)', 'annulation : mode et payeur repris');
select lives_ok($$insert into public.payment_allocations (school_id, payment_id, fee_item_id, installment_id, rubric, label, amount) values
  ('10000000-0000-4000-8000-000000000001', 'e3000000-0000-4000-8000-000000000002',
   'f2000000-0000-4000-8000-000000000001', 'f3000000-0000-4000-8000-000000000001', 'scolarite', '1er versement', -10000),
  ('10000000-0000-4000-8000-000000000001', 'e3000000-0000-4000-8000-000000000002',
   'f2000000-0000-4000-8000-000000000002', null, 'assurance', 'Assurance', -1000)$$,
  'détail de l''annulation');

-- Observations du récapitulatif.
select lives_ok($$insert into public.fee_notes (school_id, school_year_id, class_id, notes) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025',
   'c0000000-0000-4000-8000-000000000002', 'Tenue obligatoire')$$, 'observations');

select set_config('request.jwt.claims', :'sec1', true);
select is((select count(*)::int from public.payment_allocations), 4, 'économe : voit le détail');
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.payment_allocations) + (select count(*)::int from public.fee_notes), 0,
  'enseignant : rien');

select * from finish();
rollback;
