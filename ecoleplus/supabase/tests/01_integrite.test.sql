-- Intégrité garantie par la base (et non par l'interface).
begin;
select plan(20);

-- Reçus inaltérables
select throws_ok($$update public.payments set amount = 1 where receipt_number = 'R2526-A-00001'$$,
  'P0001', null, 'un reçu ne peut pas être modifié');
select throws_ok($$delete from public.payments where receipt_number = 'R2526-A-00001'$$,
  'P0001', null, 'un reçu ne peut pas être supprimé');
select throws_ok($$
  insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at, device_id, device_seq,
                               receipt_number, reverses_payment_id)
  values ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'cotisation', -2500,
          'especes', now(), '90000000-0000-4000-8000-000000000001', 2, 'R2526-A-00002',
          '70000000-0000-4000-8000-000000000001')$$,
  '23514', null, 'une contre-passation sans motif est refusée');
select throws_ok($$
  insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at, device_id, device_seq, receipt_number)
  values ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'cotisation', 1000,
          'especes', now(), '90000000-0000-4000-8000-000000000001', 2, 'R2526-B-00002')$$,
  'P0001', null, 'un numéro de reçu qui ne correspond pas à la série de l''appareil est refusé');
select throws_ok($$
  insert into public.payments (school_id, school_year_id, rubric, amount, method, paid_at, device_id, device_seq, receipt_number)
  values ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'cotisation', 1000,
          'especes', now(), '90000000-0000-4000-8000-000000000001', 1, 'R2526-A-00001')$$,
  '23505', null, 'un même numéro de reçu ne peut pas exister deux fois');
select is(
  (select sum(amount)::int from public.payments where student_id = 'd0000000-0000-4000-8000-000000000002'),
  0, 'solde après contre-passation = 0');

-- Aucune suppression physique de données scolaires
select throws_ok($$delete from public.students where first_names = 'Aïcha'$$,
  'P0001', null, 'un élève ne peut pas être supprimé physiquement');

-- Barème
select throws_ok($$
  update public.grades set score = 11
   where student_id = 'd0000000-0000-4000-8000-000000000001' and subject_id = 'e0000000-0000-4000-8000-000000000001'$$,
  'P0001', null, 'une note hors barème (11 sur 10) est refusée');
select throws_ok($$
  insert into public.grades (school_id, assessment_id, student_id, subject_id, status)
  values ('10000000-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000001',
          'd0000000-0000-4000-8000-000000000001', 'e0000000-0000-4000-8000-000000000005', 'note')$$,
  '23514', null, 'une note « saisie » sans valeur est refusée');

-- Registre matricule
select throws_ok($$update public.students set registry_number = 999 where first_names = 'Aïcha'$$,
  'P0001', null, 'le numéro d''ordre ne peut pas être modifié');
select lives_ok($$
  insert into public.students (school_id, last_name, first_names, registry_number)
  values ('10000000-0000-4000-8000-000000000001', 'TEST', 'Repris', 100)$$,
  'reprise d''un registre papier : numéro 100 accepté');
insert into public.students (school_id, last_name, first_names)
values ('10000000-0000-4000-8000-000000000001', 'TEST', 'Nouveau');
select is((select registry_number from public.students where first_names = 'Nouveau'), 101,
  'le numéro suivant continue après le plus grand numéro utilisé');

-- Archives et IA
select throws_ok($$
  insert into public.documents (school_id, space, title, ai_allowed)
  values ('10000000-0000-4000-8000-000000000001', 'archives', 'PV test', true)$$,
  '23514', null, 'un document d''archives ne peut pas être autorisé pour l''IA');
insert into public.documents (id, school_id, space, title, ai_allowed)
values ('50000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'archives', 'PV test', false),
       ('50000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'bibliotheque', 'Guide test', true);
select throws_ok($$
  insert into public.document_chunks (school_id, document_id, chunk_index, content, embedding)
  values ('10000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001', 0, 'texte',
          array_fill(0.1, array[1024])::extensions.vector)$$,
  'P0001', null, 'aucun vecteur IA pour un document d''archives');
select lives_ok($$
  insert into public.document_chunks (school_id, document_id, chunk_index, content, embedding)
  values ('10000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000002', 0,
          'La multiplication des nombres décimaux', array_fill(0.1, array[1024])::extensions.vector)$$,
  'vecteur accepté pour un document de bibliothèque autorisé');
select is(
  (select count(*)::int from public.document_chunks
    where tsv @@ websearch_to_tsquery('french', 'multiplications décimales')),
  1, 'recherche plein texte en français (racines) sur les passages');

-- Formulaires : version finale verrouillée
insert into public.official_forms (id, school_id, school_year_id, form_code)
values ('40000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
        '20000000-0000-4000-8000-000000002025', 'B6');
insert into public.form_versions (school_id, form_id, version_no, is_final, snapshot)
values ('10000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000001', 1, true, '{}');
select throws_ok($$update public.form_versions set snapshot = '{"x":1}' where version_no = 1$$,
  'P0001', null, 'une version finale ne peut pas être modifiée');

-- Stock : une sortie doit être négative et motivée
select throws_ok($$
  insert into public.stock_products (id, school_id, name, unit)
  values ('80000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Riz', 'kg');
  insert into public.stock_movements (school_id, product_id, kind, quantity_delta, occurred_on, device_id, device_seq)
  values ('10000000-0000-4000-8000-000000000001', '80000000-0000-4000-8000-000000000001', 'sortie', 5,
          current_date, '90000000-0000-4000-8000-000000000001', 1)$$,
  '23514', null, 'une sortie de stock positive ou sans motif est refusée');

select throws_ok($$
  insert into public.stock_products (id, school_id, name, unit)
  values ('80000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'Huile', 'litre');
  insert into public.stock_movements (school_id, product_id, kind, quantity_delta, occurred_on, device_id, device_seq)
  values ('10000000-0000-4000-8000-000000000001', '80000000-0000-4000-8000-000000000002', 'ajustement', -2,
          current_date, '90000000-0000-4000-8000-000000000001', 1)$$,
  '23514', null, 'un ajustement d''inventaire sans motif est refusé');

-- Maternelle : le schéma permet une évaluation qualitative sans note chiffrée
select lives_ok($$
  insert into public.classes (id, school_id, school_year_id, level_code, name)
  values ('c0000000-0000-4000-8000-000000000050', '10000000-0000-4000-8000-000000000001',
          '20000000-0000-4000-8000-000000002025', 'GS', 'GS A');
  insert into public.learning_domains (id, school_id, name)
  values ('c1000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Langage (exemple)');
  insert into public.qualitative_levels (id, school_id, code, label, color_hex, icon_key)
  values ('c2000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
          'acquis', 'Acquis', '#2E7D32', 'soleil');
  insert into public.preschool_periods (id, school_id, class_id, school_year_id, label)
  values ('c3000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
          'c0000000-0000-4000-8000-000000000050', '20000000-0000-4000-8000-000000002025', 'Période 1');
  insert into public.preschool_evaluations (school_id, period_id, student_id, domain_id, level_id)
  values ('10000000-0000-4000-8000-000000000001', 'c3000000-0000-4000-8000-000000000001',
          'd0000000-0000-4000-8000-000000000009', 'c1000000-0000-4000-8000-000000000001',
          'c2000000-0000-4000-8000-000000000001')$$,
  'évaluation de maternelle par niveau qualitatif enregistrable');

select * from finish();
rollback;
