-- Phase 11 : cantine — module OFF / ON / OFF → ON → OFF (R11), droits
-- (directeur, délégué « cantine », économe, enseignant), mouvements de
-- stock inaltérables et annulation miroir, pointage sans doublon,
-- cotisation de cantine par les reçus des Finances, dépenses de cantine.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set sec1 '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
\set can1 '{"sub":"a0000000-0000-4000-8000-0000000000c1","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
\set ecole '''10000000-0000-4000-8000-000000000001'''
begin;
select plan(39);

-- Responsable de cantine : délégué avec le seul droit « cantine », et son téléphone.
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
values ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-4000-8000-0000000000c1', 'authenticated',
        'authenticated', 'cantine@ecole-test.local', '', now(), now(), now());
insert into public.memberships (id, school_id, user_id, role, display_name) values
  ('a1000000-0000-4000-8000-0000000000c1', :ecole, 'a0000000-0000-4000-8000-0000000000c1', 'delegue', 'Cantine Test');
insert into public.delegate_permissions (school_id, membership_id, permission_key) values
  (:ecole, 'a1000000-0000-4000-8000-0000000000c1', 'cantine');
insert into public.devices (id, school_id, user_id, label, series_code) values
  ('90000000-0000-4000-8000-0000000000c1', :ecole, 'a0000000-0000-4000-8000-0000000000c1', 'Téléphone cantine', 'C');

set local role authenticated;

-- ------------------------------ OFF ------------------------------------
select set_config('request.jwt.claims', :'dir1', true);
select throws_ok($$insert into public.canteen_settings (school_id, mode) values
  ('10000000-0000-4000-8000-000000000001', 'mixte')$$, '42501', null, 'OFF : réglages refusés');
select throws_ok($$insert into public.stock_products (id, school_id, name, unit) values
  ('5a000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Riz', 'kg')$$,
  '42501', null, 'OFF : produit refusé');
select throws_ok($$insert into public.fee_items (school_id, school_year_id, rubric, label, amount) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'cantine', 'Cantine', 3000)$$,
  '42501', null, 'OFF : tarif de cantine refusé');
select throws_ok($$insert into public.expenses (school_id, school_year_id, category, label, amount, spent_on,
  device_id, device_seq) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'cantine', 'Bois', 1000,
   current_date, '90000000-0000-4000-8000-000000000001', 1)$$,
  '42501', null, 'OFF : dépense de cantine refusée');
select lives_ok($$insert into public.expenses (school_id, school_year_id, category, label, amount, spent_on,
  device_id, device_seq) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'fournitures', 'Craies', 1000,
   current_date, '90000000-0000-4000-8000-000000000001', 1)$$,
  'OFF : les autres dépenses restent possibles');

-- ------------------------------ ON -------------------------------------
reset role;
update public.school_modules set enabled = true where module_key = 'cantine' and school_id = :ecole;
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select lives_ok($$insert into public.canteen_settings (id, school_id, mode, local_definition) values
  ('5c000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'mixte',
   'Vivres apportés par la communauté')$$, 'ON : réglages (mode mixte)');
select lives_ok($$insert into public.canteen_beneficiaries (school_id, student_id, school_year_id, contributes) values
  ('10000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', false)$$, 'ON : bénéficiaire sans participation (mixte)');

-- Responsable de cantine.
select set_config('request.jwt.claims', :'can1', true);
select lives_ok($$insert into public.stock_products (id, school_id, name, unit, alert_threshold) values
  ('5a000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Riz', 'kg', 10)$$,
  'cantine : produit');
select lives_ok($$insert into public.stock_movements (id, school_id, product_id, kind, quantity_delta, provenance,
  occurred_on, device_id, device_seq) values
  ('5b000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '5a000000-0000-4000-8000-000000000001', 'entree', 50, 'parents', current_date,
   '90000000-0000-4000-8000-0000000000c1', 1)$$, 'cantine : entrée (contribution des parents)');
select is((select created_by::text from public.stock_movements where id = '5b000000-0000-4000-8000-000000000001'),
  'a0000000-0000-4000-8000-0000000000c1', 'auteur imposé par le serveur');
select throws_ok($$insert into public.stock_movements (school_id, product_id, kind, quantity_delta, occurred_on,
  device_id, device_seq) values
  ('10000000-0000-4000-8000-000000000001', '5a000000-0000-4000-8000-000000000001', 'entree', 5, current_date,
   '90000000-0000-4000-8000-0000000000c1', 2)$$, '23514', null, 'entrée sans provenance : refusée');
select throws_ok($$insert into public.stock_movements (school_id, product_id, kind, quantity_delta, out_reason,
  occurred_on, device_id, device_seq) values
  ('10000000-0000-4000-8000-000000000001', '5a000000-0000-4000-8000-000000000001', 'sortie', 5, 'repas',
   current_date, '90000000-0000-4000-8000-0000000000c1', 2)$$, '23514', null, 'sortie positive : refusée');
select lives_ok($$insert into public.stock_movements (id, school_id, product_id, kind, quantity_delta, out_reason,
  occurred_on, device_id, device_seq) values
  ('5b000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   '5a000000-0000-4000-8000-000000000001', 'sortie', -12.5, 'repas', current_date,
   '90000000-0000-4000-8000-0000000000c1', 2)$$, 'cantine : sortie pour les repas');
select throws_ok($$insert into public.stock_movements (school_id, product_id, kind, quantity_delta, occurred_on,
  device_id, device_seq) values
  ('10000000-0000-4000-8000-000000000001', '5a000000-0000-4000-8000-000000000001', 'ajustement', -1, current_date,
   '90000000-0000-4000-8000-0000000000c1', 3)$$, '23514', null, 'ajustement d''inventaire sans motif : refusé');
select throws_ok($$insert into public.stock_movements (school_id, product_id, kind, quantity_delta, occurred_on,
  device_id, device_seq) values
  ('10000000-0000-4000-8000-000000000001', '5a000000-0000-4000-8000-000000000001', 'entree', 5, current_date,
   '90000000-0000-4000-8000-000000000001', 3)$$, '42501', null, 'téléphone d''une autre personne : refusé');

-- Annulation miroir.
select throws_ok($$insert into public.stock_movements (school_id, product_id, kind, quantity_delta, occurred_on,
  device_id, device_seq, reverses_movement_id, reason) values
  ('10000000-0000-4000-8000-000000000001', '5a000000-0000-4000-8000-000000000001', 'annulation', 10, current_date,
   '90000000-0000-4000-8000-0000000000c1', 3, '5b000000-0000-4000-8000-000000000002', 'Erreur')$$,
  'P0001', null, 'annulation d''une autre quantité : refusée');
select lives_ok($$insert into public.stock_movements (id, school_id, product_id, kind, quantity_delta, occurred_on,
  device_id, device_seq, reverses_movement_id, reason) values
  ('5b000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001',
   '5a000000-0000-4000-8000-000000000001', 'annulation', 12.5, current_date,
   '90000000-0000-4000-8000-0000000000c1', 3, '5b000000-0000-4000-8000-000000000002', 'Saisie en double')$$,
  'annulation motivée de la quantité exacte : acceptée');
select throws_ok($$insert into public.stock_movements (school_id, product_id, kind, quantity_delta, occurred_on,
  device_id, device_seq, reverses_movement_id, reason) values
  ('10000000-0000-4000-8000-000000000001', '5a000000-0000-4000-8000-000000000001', 'annulation', -12.5, current_date,
   '90000000-0000-4000-8000-0000000000c1', 4, '5b000000-0000-4000-8000-000000000003', 'Encore')$$,
  'P0001', null, 'annulation d''une annulation : refusée');
update public.stock_movements set quantity_delta = 1 where id = '5b000000-0000-4000-8000-000000000001';
delete from public.stock_movements where id = '5b000000-0000-4000-8000-000000000001';
select is((select quantity_delta from public.stock_movements where id = '5b000000-0000-4000-8000-000000000001'),
  50::numeric, 'mouvement : ni modifié ni supprimé');
select is((select sum(quantity_delta) from public.stock_movements
            where product_id = '5a000000-0000-4000-8000-000000000001'), 50::numeric,
  'stock courant = somme des mouvements (sortie annulée)');

-- Pointage : un seul nombre par (jour, classe), même saisi deux fois.
select lives_ok($$insert into public.meal_services (id, school_id, day, class_id, meals_count) values
  ('5d000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', current_date,
   'c0000000-0000-4000-8000-000000000001', 32)$$, 'cantine : pointage du jour');
select throws_ok($$insert into public.meal_services (school_id, day, class_id, meals_count) values
  ('10000000-0000-4000-8000-000000000001', current_date, 'c0000000-0000-4000-8000-000000000001', 30)$$,
  '23505', null, 'deuxième pointage de la même classe le même jour : refusé (aucun doublon)');
select lives_ok($$insert into public.canteen_menus (school_id, week_start, content) values
  ('10000000-0000-4000-8000-000000000001', '2026-11-02', 'Lundi : riz sauce arachide')$$, 'cantine : menu');

-- Dépense de cantine (caisse commune) ; les autres dépenses restent invisibles.
select lives_ok($$insert into public.expenses (id, school_id, school_year_id, category, label, amount, spent_on,
  method, device_id, device_seq, voucher_number) values
  ('e2000000-0000-4000-8000-0000000000c1', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'cantine', 'Bois de chauffe', 2500, current_date, 'especes',
   '90000000-0000-4000-8000-0000000000c1', 1, 'D2526-C-00001')$$, 'cantine : dépense de cantine');
select throws_ok($$insert into public.expenses (school_id, school_year_id, category, label, amount, spent_on,
  device_id, device_seq) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'fournitures', 'Craies', 1000,
   current_date, '90000000-0000-4000-8000-0000000000c1', 2)$$, '42501', null,
  'cantine : autre dépense refusée');
select is((select count(*)::int from public.expenses), 1, 'cantine : ne voit que les dépenses de cantine');
select is((select count(*)::int from public.payments) + (select count(*)::int from public.fee_items), 0,
  'cantine : aucun reçu ni grille de scolarité');
select lives_ok($$insert into storage.objects (bucket_id, name) values
  ('finances', '10000000-0000-4000-8000-000000000001/cantine/bois.jpg')$$, 'cantine : justificatif déposé');
select throws_ok($$insert into storage.objects (bucket_id, name) values
  ('finances', '10000000-0000-4000-8000-000000000001/depenses/x.jpg')$$, '42501', null,
  'cantine : justificatif hors cantine refusé');

-- Économe (« finances ») : cotisation de cantine avec reçu ; voit la dépense de cantine.
select set_config('request.jwt.claims', :'sec1', true);
select is((select count(*)::int from public.canteen_beneficiaries), 1, 'économe : lit les bénéficiaires');
select is((select count(*)::int from public.stock_movements), 0, 'économe : pas le stock');
select is((select count(*)::int from public.expenses where category = 'cantine'), 1,
  'économe : dépense de cantine dans la caisse commune');
select set_config('request.jwt.claims', :'dir1', true);
select lives_ok($$insert into public.payments (id, school_id, school_year_id, student_id, rubric, amount, method,
  paid_at, device_id, device_seq, receipt_number) values
  ('e1000000-0000-4000-8000-0000000000c1', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000002', 'cantine', 1500, 'especes',
   now(), '90000000-0000-4000-8000-000000000001', 2, 'R2526-A-00002')$$,
  'cotisation de cantine partielle : reçu numéroté des Finances');

-- Enseignant : lit le menu, rien d'autre.
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.canteen_menus), 1, 'enseignant : menu affichable');
select is((select count(*)::int from public.stock_products) + (select count(*)::int from public.meal_services)
        + (select count(*)::int from public.canteen_beneficiaries), 0, 'enseignant : rien d''autre');

-- Autre école.
select set_config('request.jwt.claims', :'dir2', true);
select is((select count(*)::int from public.canteen_menus) + (select count(*)::int from public.stock_products), 0,
  'autre école : rien');

-- ------------------------- OFF → données intactes ----------------------
reset role;
update public.school_modules set enabled = false where module_key = 'cantine' and school_id = :ecole;
set local role authenticated;
select set_config('request.jwt.claims', :'can1', true);
select is((select count(*)::int from public.stock_movements) + (select count(*)::int from public.meal_services), 0,
  'OFF : lectures vides');
reset role;
select is((select count(*)::int from public.stock_movements where school_id = :ecole), 3,
  'OFF : données conservées');
update public.school_modules set enabled = true where module_key = 'cantine' and school_id = :ecole;
set local role authenticated;
select set_config('request.jwt.claims', :'can1', true);
select is((select count(*)::int from public.stock_movements), 3, 'OFF → ON : données revenues');

select * from finish();
rollback;
