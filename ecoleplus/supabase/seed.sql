-- =====================================================================
-- Jeu de données FICTIF « École Test » (R7). Aucun nom réel.
-- 3 classes, 12 élèves, 2 enseignants, 1 directeur, notes piégeuses :
--   * CM1 / Composition 1 : deux élèves ex-aequo (2e ex-aequo, puis 4e),
--     une matière à coefficient nul (Dessin), une matière sans aucune note
--     (Histoire), un élève absent à une épreuve (Calcul) ;
--   * CM2 / Composition 1 : un élève absent à toute la composition ;
--   * CE1 : classe sans enseignant affecté et sans note (états vides).
-- Mots de passe de test : « motdepasse-test » (local uniquement).
-- =====================================================================

-- Comptes de test (Supabase Auth local)
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
                        created_at, updated_at, raw_app_meta_data, raw_user_meta_data,
                        confirmation_token, recovery_token, email_change_token_new, email_change,
                        email_change_token_current, phone_change, phone_change_token, reauthentication_token)
select '00000000-0000-0000-0000-000000000000', u.id::uuid, 'authenticated', 'authenticated', u.email,
       extensions.crypt('motdepasse-test', extensions.gen_salt('bf')), now(), now(), now(),
       '{"provider":"email","providers":["email"]}', '{}', '', '', '', '', '', '', '', ''
  from (values
  ('a0000000-0000-4000-8000-000000000001', 'directeur@ecole-test.local'),
  ('a0000000-0000-4000-8000-000000000002', 'enseignant1@ecole-test.local'),
  ('a0000000-0000-4000-8000-000000000003', 'enseignant2@ecole-test.local'),
  ('a0000000-0000-4000-8000-000000000004', 'secretaire@ecole-test.local'),
  ('a0000000-0000-4000-8000-000000000009', 'directeur@ecole-temoin.local')
  ) as u(id, email);

insert into auth.identities (id, user_id, provider_id, provider, identity_data, created_at, updated_at)
select gen_random_uuid(), u.id, u.id::text, 'email',
       jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true), now(), now()
  from auth.users u where u.email like '%@ecole-te%.local';

insert into public.schools (id, name, commune, departement, province, region, school_type, phone, director_name)
values ('10000000-0000-4000-8000-000000000001', 'École Test', 'Commune Test', 'Département Test',
        'Province Test', 'Région Test', 'publique', '+226 00 00 00 00', 'Directeur Test'),
       -- Seconde école : sert à prouver qu'une école ne voit jamais les données d'une autre.
       ('10000000-0000-4000-8000-000000000002', 'École Témoin', 'Commune Témoin', null,
        'Province Témoin', 'Région Témoin', 'privee', null, 'Directeur Témoin');

insert into public.school_years (id, school_id, label, starts_on, ends_on, archived_at) values
  ('20000000-0000-4000-8000-000000002024', '10000000-0000-4000-8000-000000000001', '2024-2025',
   '2024-10-01', '2025-07-31', '2025-08-31'),
  ('20000000-0000-4000-8000-000000002025', '10000000-0000-4000-8000-000000000001', '2025-2026',
   '2025-10-01', '2026-07-31', null),
  ('20000000-0000-4000-8000-000000009025', '10000000-0000-4000-8000-000000000002', '2025-2026',
   '2025-10-01', '2026-07-31', null);
update public.schools set current_school_year_id = '20000000-0000-4000-8000-000000002025'
 where id = '10000000-0000-4000-8000-000000000001';
update public.schools set current_school_year_id = '20000000-0000-4000-8000-000000009025'
 where id = '10000000-0000-4000-8000-000000000002';

-- Deux années, deux en-têtes différents (les en-têtes ne sont jamais codés en dur).
insert into public.admin_headers (school_id, school_year_id, ministry, region, regional_direction,
                                  provincial_direction, ceb, province, departement, commune, school_label)
values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002024', 'MINISTÈRE TEST',
   'Région Test A', 'Direction régionale Test A', 'Direction provinciale Test A', 'CEB Test 1',
   'Province Test A', 'Département Test', 'Commune Test', 'École Test'),
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'MINISTÈRE TEST',
   'Région Test B', 'Direction régionale Test B', 'Direction provinciale Test B', 'CEB Test 2',
   'Province Test B', 'Département Test', 'Commune Test', 'École Test');

insert into public.school_modules (school_id, module_key, enabled)
select s.id, mc.key, false from public.schools s cross join public.modules_catalog mc;

insert into public.teachers (id, school_id, last_name, first_names, sex, matricule, birth_date, birth_place,
                             emploi, categorie, echelon, tenure_status, commune_nomination_date,
                             first_teaching_nomination_date, seniority_general_from, seniority_emploi_from,
                             seniority_region_from, seniority_fonction_from)
values
  ('b0000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'ENSEIGNANT', 'Un', 'F',
   'MAT-TEST-001', '1985-03-14', 'Ville Test', 'Instituteur certifié (exemple)', 'B', '3', 'T',
   '2019-10-01', '2008-10-01', '2008-10-01', '2012-10-01', '2015-10-01', '2019-10-01'),
  ('b0000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'ENSEIGNANT', 'Deux', 'M',
   'MAT-TEST-002', '1992-11-02', 'Village Test', 'Instituteur adjoint (exemple)', 'C', '1', 'S',
   '2024-10-01', '2024-10-01', '2024-10-01', '2024-10-01', '2024-10-01', '2024-10-01');

insert into public.teacher_postings (school_id, teacher_id, commune, nominated_on, sort_order) values
  ('10000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Commune Ancienne Test', '2008-10-01', 1),
  ('10000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Commune Test', '2019-10-01', 2);
insert into public.teacher_diplomas (school_id, teacher_id, nature, delivered_on, is_academic) values
  ('10000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'BAC (exemple)', '2005-07-15', true),
  ('10000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'CAP (exemple)', '2010-06-30', false);

insert into public.memberships (id, school_id, user_id, role, teacher_id, display_name) values
  ('a1000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'a0000000-0000-4000-8000-000000000001', 'directeur', null, 'Directeur Test'),
  ('a1000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   'a0000000-0000-4000-8000-000000000002', 'enseignant', 'b0000000-0000-4000-8000-000000000001', 'Enseignant Un'),
  ('a1000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001',
   'a0000000-0000-4000-8000-000000000003', 'enseignant', 'b0000000-0000-4000-8000-000000000002', 'Enseignant Deux'),
  ('a1000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000001',
   'a0000000-0000-4000-8000-000000000004', 'delegue', null, 'Secrétaire Test'),
  ('a1000000-0000-4000-8000-000000000009', '10000000-0000-4000-8000-000000000002',
   'a0000000-0000-4000-8000-000000000009', 'directeur', null, 'Directeur Témoin');

-- La secrétaire a reçu uniquement le droit « finances ».
insert into public.delegate_permissions (school_id, membership_id, permission_key) values
  ('10000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000004', 'finances');

-- Un élève de l'École Témoin (ne doit jamais être visible depuis l'École Test).
insert into public.students (id, school_id, last_name, first_names, sex)
values ('d0000000-0000-4000-8000-000000000099', '10000000-0000-4000-8000-000000000002', 'TÉMOIN', 'Élève', 'F');

insert into public.devices (id, school_id, user_id, label, series_code) values
  ('90000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'a0000000-0000-4000-8000-000000000001', 'Téléphone du directeur', 'A'),
  ('90000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   'a0000000-0000-4000-8000-000000000001', 'Tablette du secrétariat', 'B');
select app.bump_counter('10000000-0000-4000-8000-000000000001', 'device_series', 2);

-- Classes de l'année en cours
insert into public.classes (id, school_id, school_year_id, level_code, name, main_teacher_id) values
  ('c0000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'CE1', 'CE1 A', null),
  ('c0000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'CM1', 'CM1 A', 'b0000000-0000-4000-8000-000000000001'),
  ('c0000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'CM2', 'CM2 A', 'b0000000-0000-4000-8000-000000000002'),
  -- Classe de l'année précédente (historique pour la fiche de scolarité)
  ('c0000000-0000-4000-8000-000000000099', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002024', 'CM1', 'CM1 A (2024-2025)', 'b0000000-0000-4000-8000-000000000001');

insert into public.teacher_year_assignments (school_id, school_year_id, teacher_id, class_id, fonction) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025',
   'b0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000002', 'Adjoint'),
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025',
   'b0000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000003', 'Adjoint');

-- 12 élèves (le numéro d'ordre du registre matricule est attribué par le serveur)
insert into public.students (id, school_id, last_name, first_names, sex, birth_date, birth_place, entry_date,
                             student_code, domicile) values
  ('d0000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'TEST', 'Aïcha',    'F', '2017-01-10', 'Ville Test', '2023-10-02', 'EL-0001', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'TEST', 'Boukary',  'M', '2017-05-22', 'Ville Test', '2023-10-02', 'EL-0002', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'TEST', 'Clarisse', 'F', '2016-09-03', 'Ville Test', '2023-10-02', 'EL-0003', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000001', 'TEST', 'Daouda',   'M', '2016-12-30', 'Village Test', '2023-10-02', 'EL-0004', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000001', 'TEST', 'Fatou',    'F', '2014-02-11', 'Ville Test', '2019-10-01', 'EL-0005', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000001', 'TEST', 'Gaston',   'M', '2014-07-19', 'Ville Test', '2019-10-01', 'EL-0006', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000007', '10000000-0000-4000-8000-000000000001', 'TEST', 'Hawa',     'F', '2014-04-08', 'Village Test', '2019-10-01', 'EL-0007', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000008', '10000000-0000-4000-8000-000000000001', 'TEST', 'Issa',     'M', '2013-10-25', 'Ville Test', '2024-01-15', 'EL-0008', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000009', '10000000-0000-4000-8000-000000000001', 'TEST', 'Jeanne',   'F', '2018-06-01', 'Ville Test', '2024-10-01', 'EL-0009', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000010', '10000000-0000-4000-8000-000000000001', 'TEST', 'Karim',    'M', '2018-08-14', 'Ville Test', '2024-10-01', 'EL-0010', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000011', '10000000-0000-4000-8000-000000000001', 'TEST', 'Léa',      'F', '2018-03-27', 'Village Test', '2024-10-01', 'EL-0011', 'Quartier Test'),
  ('d0000000-0000-4000-8000-000000000012', '10000000-0000-4000-8000-000000000001', 'TEST', 'Moussa',   'M', '2018-11-30', 'Ville Test', '2024-10-01', 'EL-0012', 'Quartier Test');

-- Issa vient d'une autre école (« venant de »)
insert into public.student_registry (id, school_id, origin_school)
values ('d0000000-0000-4000-8000-000000000008', '10000000-0000-4000-8000-000000000001', 'École Ancienne Test');

insert into public.guardians (school_id, student_id, relation, full_name, profession, domicile, phone, is_lodger)
select '10000000-0000-4000-8000-000000000001', s.id, 'pere', 'Parent Test de ' || s.first_names,
       'Cultivateur (exemple)', 'Quartier Test', null, true
  from public.students s where s.school_id = '10000000-0000-4000-8000-000000000001';

insert into public.enrollments (school_id, student_id, class_id, school_year_id, level_code, starts_on)
select '10000000-0000-4000-8000-000000000001', s.id,
       case when n <= 4 then 'c0000000-0000-4000-8000-000000000002'::uuid      -- CM1 : élèves 1-4
            when n <= 8 then 'c0000000-0000-4000-8000-000000000003'::uuid      -- CM2 : élèves 5-8
            else 'c0000000-0000-4000-8000-000000000001'::uuid end,             -- CE1 : élèves 9-12
       '20000000-0000-4000-8000-000000002025',
       case when n <= 4 then 'CM1' when n <= 8 then 'CM2' else 'CE1' end,
       '2025-10-01'
  from (select id, right(id::text, 2)::int as n from public.students
         where school_id = '10000000-0000-4000-8000-000000000001') s;

-- Historique 2024-2025 : Fatou était en CM1 (format « 7e/39 » pour la fiche de scolarité)
insert into public.enrollments (school_id, student_id, class_id, school_year_id, level_code, starts_on, ends_on)
values ('10000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000005',
        'c0000000-0000-4000-8000-000000000099', '20000000-0000-4000-8000-000000002024', 'CM1', '2024-10-01', '2025-07-31');
insert into public.annual_results (school_id, student_id, school_year_id, class_id, level_code, result_date,
                                   general_average, rank, rank_ex_aequo, class_size, decision)
values ('10000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000005',
        '20000000-0000-4000-8000-000000002024', 'c0000000-0000-4000-8000-000000000099', 'CM1', '2025-07-15',
        7.25, 7, false, 39, 'Admise en CM2');

-- Matières (primaire)
insert into public.subjects (id, school_id, name, sort_order) values
  ('e0000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Lecture', 1),
  ('e0000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'Calcul', 2),
  ('e0000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'Dictée', 3),
  ('e0000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000001', 'Dessin', 4),
  ('e0000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000001', 'Histoire', 5);

-- CM1 : Dessin à coefficient nul ; Histoire sans aucune note
insert into public.class_subjects (school_id, class_id, subject_id, coefficient)
select '10000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000002', id,
       case name when 'Dessin' then 0 else 1 end
  from public.subjects;
-- CM2 : Lecture et Calcul
insert into public.class_subjects (school_id, class_id, subject_id, coefficient)
select '10000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000003', id, 1
  from public.subjects where name in ('Lecture', 'Calcul');

insert into public.assessments (id, school_id, class_id, school_year_id, label, sequence, held_on, max_score) values
  ('f0000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'c0000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000002025', 'Composition 1', 1, '2025-12-10', 10),
  ('f0000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   'c0000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000002025', 'Composition 1', 1, '2025-12-10', 10);

-- Notes CM1 / Composition 1 (sur 10) :
--   Aïcha    : Lecture 8, Calcul 7, Dictée 6, Dessin 10 (coef 0) -> total 21, moyenne 7,00 -> 1er
--   Boukary  : 6, 6, 6, Dessin 2                                 -> total 18, moyenne 6,00 -> 2e ex-aequo
--   Clarisse : 7, 5, 6                                           -> total 18, moyenne 6,00 -> 2e ex-aequo
--   Daouda   : 5, Calcul ABSENT, 6                               -> 4e (hypothèse : l'absence exclut la matière
--              -> total 11 / coef 2 = 5,50 ; si l'absence vaut 0 -> 11 / 3 = 3,67 ; rang 4 dans les deux cas)
insert into public.grades (school_id, assessment_id, student_id, subject_id, score, status)
select '10000000-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000001',
       ('d0000000-0000-4000-8000-0000000000' || v.st)::uuid, ('e0000000-0000-4000-8000-0000000000' || v.su)::uuid,
       v.score, v.status
  from (values
    ('01', '01', 8.0, 'note'), ('01', '02', 7.0, 'note'), ('01', '03', 6.0, 'note'), ('01', '04', 10.0, 'note'),
    ('02', '01', 6.0, 'note'), ('02', '02', 6.0, 'note'), ('02', '03', 6.0, 'note'), ('02', '04', 2.0, 'note'),
    ('03', '01', 7.0, 'note'), ('03', '02', 5.0, 'note'), ('03', '03', 6.0, 'note'),
    ('04', '01', 5.0, 'note'), ('04', '02', null, 'absent'), ('04', '03', 6.0, 'note')
  ) as v(st, su, score, status);

-- Notes CM2 / Composition 1 : Hawa absente à toute la composition.
insert into public.grades (school_id, assessment_id, student_id, subject_id, score, status)
select '10000000-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000002',
       ('d0000000-0000-4000-8000-0000000000' || v.st)::uuid, ('e0000000-0000-4000-8000-0000000000' || v.su)::uuid,
       v.score, v.status
  from (values
    ('05', '01', 9.0, 'note'), ('05', '02', 8.5, 'note'),
    ('06', '01', 4.0, 'note'), ('06', '02', 5.0, 'note'),
    ('07', '01', null, 'absent'), ('07', '02', null, 'absent'),
    ('08', '01', 7.0, 'note'), ('08', '02', 7.0, 'note')
  ) as v(st, su, score, status);

-- Finances : deux reçus sur deux appareils (séries A et B), puis une contre-passation.
insert into public.payments (id, school_id, school_year_id, student_id, rubric, amount, method, reference,
                             paid_at, received_by, device_id, device_seq, receipt_number) values
  ('70000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000001', 'cotisation', 2500, 'especes', null,
   '2025-10-06 09:00+00', 'a0000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', 1, 'R2526-A-00001'),
  ('70000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 'd0000000-0000-4000-8000-000000000002', 'cotisation', 2500, 'orange_money', 'OM-TEST-123',
   '2025-10-06 09:05+00', 'a0000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000002', 1, 'R2526-B-00001');
insert into public.payments (school_id, school_year_id, student_id, rubric, amount, method, paid_at, received_by,
                             device_id, device_seq, receipt_number, reverses_payment_id, reversal_reason) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025',
   'd0000000-0000-4000-8000-000000000002', 'cotisation', -2500, 'orange_money', '2025-10-06 10:00+00',
   'a0000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000002', 2, 'R2526-B-00002',
   '70000000-0000-4000-8000-000000000002', 'Encaissement saisi deux fois (exemple)');

-- Programme d'activités : exemples de suggestions (modifiables, jamais imposées).
insert into public.activity_objectives (id, school_id, school_year_id, order_no, label) values
  ('60000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '20000000-0000-4000-8000-000000002025', 1, 'Gérer rationnellement les ressources');
insert into public.activity_lines (school_id, objective_id, sort_order, planned_activity, deadline_on, constraint_text,
                                   expected_result, achieved_result, success_rate) values
  ('10000000-0000-4000-8000-000000000001', '60000000-0000-4000-8000-000000000001', 1,
   'Répartir les enseignants dans les classes', '2025-09-30', '/', 'Chaque classe a un enseignant',
   'Deux classes sur trois pourvues', 66.67),
  ('10000000-0000-4000-8000-000000000001', '60000000-0000-4000-8000-000000000001', 2,
   'Distribuer les fournitures', '2025-10-15', null, 'Fournitures distribuées', null, null);
