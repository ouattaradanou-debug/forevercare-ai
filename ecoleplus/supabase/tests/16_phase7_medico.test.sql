-- Phase 7 : dossier médico-scolaire — refus au niveau des données, journal
-- complet, module désactivé = rien, aptitude seule exposable.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set ens2 '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
\set aicha '\'d0000000-0000-4000-8000-000000000001\''
begin;
select plan(22);

select ok(not exists (select 1 from app.sync_tables where table_name in ('records', 'yearly_exams', 'fitness', 'access_log')),
  'aucune table médicale n''est synchronisée vers les téléphones');

set local role authenticated;

-- Enseignant : aucun accès direct, aucune lecture par les fonctions.
select set_config('request.jwt.claims', :'ens1', true);
select throws_ok('select * from medical.records', '42501', null, 'enseignant : schéma médical inaccessible');
select throws_ok('select * from medical.access_log', '42501', null, 'enseignant : journal médical inaccessible');
select is(public.medical_get(:aicha) ->> 'refuse', 'true', 'enseignant : lecture refusée');
select is(public.medical_save(:aicha, '{"asthme": "oui"}', null, null) ->> 'refuse', 'true',
  'enseignant : écriture refusée');

-- Directeur, module désactivé (par défaut) : rien.
select set_config('request.jwt.claims', :'dir1', true);
select is(public.medical_get(:aicha) ->> 'refuse', 'true', 'module désactivé : lecture refusée au directeur');
select is(public.medical_save(:aicha, '{"asthme": "oui"}', null, null) ->> 'refuse', 'true',
  'module désactivé : écriture refusée');

update public.school_modules set enabled = true
 where module_key = 'medico_scolaire' and school_id = '10000000-0000-4000-8000-000000000001';

select is(public.medical_save(:aicha,
  '{"groupe_sanguin_rhesus": "O+", "asthme": "Non", "vacc_bcg": "2017"}',
  '[{"year_label": "2025-2026", "poids": "24 kg", "taille": "1,22 m", "examen_physique": "RAS"}]',
  '{"school_year_id": "20000000-0000-4000-8000-000000002025", "aptitude": "a_surveiller", "expose_to_teacher": false}')
  ->> 'ok', 'true', 'directeur : fiche enregistrée (champs facultatifs)');
select is(public.medical_get(:aicha) -> 'record' ->> 'groupe_sanguin_rhesus', 'O+', 'directeur : fiche relue');
select is(public.medical_get(:aicha) -> 'examens' -> 0 ->> 'poids', '24 kg', 'directeur : examen de l''année relu');
select is(public.medical_get(:aicha) -> 'aptitudes' -> 0 ->> 'aptitude', 'a_surveiller', 'directeur : aptitude relue');
select is(public.medical_save(:aicha, '{"groupe_sanguin_rhesus": "O+", "asthme": "Oui"}', null, null) ->> 'ok', 'true',
  'directeur : fiche modifiée');
select is((public.medical_get(:aicha) -> 'record' ->> 'asthme'), 'Oui', 'modification relue');

-- Aptitude non exposée : l'enseignante de la classe ne voit rien.
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.medical_aptitudes('c0000000-0000-4000-8000-000000000002')), 0,
  'aptitude non exposée : invisible pour l''enseignante');
select set_config('request.jwt.claims', :'dir1', true);
select is(public.medical_save(:aicha, null, null,
  '{"school_year_id": "20000000-0000-4000-8000-000000002025", "aptitude": "a_surveiller", "expose_to_teacher": true}')
  ->> 'ok', 'true', 'directeur : aptitude exposée à l''enseignante');
select set_config('request.jwt.claims', :'ens1', true);
select is((select array_agg(aptitude)::text from public.medical_aptitudes('c0000000-0000-4000-8000-000000000002')),
  '{a_surveiller}', 'enseignante de la classe : la seule mention d''aptitude');
select is(public.medical_get(:aicha) ->> 'refuse', 'true', 'enseignante : toujours aucun détail médical');
select set_config('request.jwt.claims', :'ens2', true);
select is((select count(*)::int from public.medical_aptitudes('c0000000-0000-4000-8000-000000000002')), 0,
  'autre enseignant : rien');

-- Autre école : rien.
select set_config('request.jwt.claims', :'dir2', true);
select is(public.medical_get(:aicha) ->> 'refuse', 'true', 'directeur d''une autre école : refusé');

-- Journal complet, lisible par le directeur seul.
select set_config('request.jwt.claims', :'dir1', true);
select is((select count(*)::int from public.medical_log('10000000-0000-4000-8000-000000000001')
            where not allowed and student is not null), 6,
  'tentatives refusées journalisées (enseignante, module désactivé, autre école)');
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.medical_log('10000000-0000-4000-8000-000000000001')), 0,
  'enseignante : ne lit pas le journal médical');
reset role;
select is((select count(*)::int from public.audit_log where table_name in ('records', 'yearly_exams', 'fitness')), 0,
  'aucune donnée médicale dans le journal d''activité général');

select * from finish();
rollback;
