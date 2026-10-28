-- =====================================================================
-- Phase 7 — Dossier médico-scolaire (module 19, OPTIONNEL, SENSIBLE ; B5).
-- Le schéma « medical » reste fermé à l'API (aucun droit pour anon ni
-- authenticated) : tout passe par les fonctions ci-dessous, réservées au
-- directeur, module actif. Chaque tentative, autorisée ou refusée, est
-- inscrite au journal d'accès (qui, quand, quel élève, quoi). Les données
-- ne sont pas synchronisées vers les téléphones : rien n'est gardé en local.
-- =====================================================================

-- Journal d'accès : une ligne par tentative.
create or replace function app.medical_journal(
  p_school uuid, p_student uuid, p_action text, p_allowed boolean
) returns void
language sql security definer set search_path = '' as $$
  insert into medical.access_log (school_id, actor_id, student_id, action, allowed)
  values (p_school, auth.uid(), p_student, p_action, p_allowed);
$$;

-- Contrôle commun : directeur de l'école de l'élève et module actif.
-- Journalise toujours ; renvoie l'école si l'accès est permis, sinon null.
create or replace function app.medical_controle(p_student uuid, p_action text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_school uuid;
  v_ok boolean;
begin
  select s.school_id into v_school from public.students s where s.id = p_student;
  if v_school is null then
    return null;
  end if;
  v_ok := app.is_director(v_school) and app.module_enabled(v_school, 'medico_scolaire');
  perform app.medical_journal(v_school, p_student, p_action, v_ok);
  return case when v_ok then v_school end;
end $$;

create or replace function app.medical_refus() returns jsonb
language sql immutable as $$
  select jsonb_build_object('refuse', true,
    'message', 'Accès refusé : le dossier médico-scolaire est réservé au directeur, module activé.');
$$;

-- Lecture de la fiche d'un élève (antécédents, examens par année, aptitudes).
create or replace function public.medical_get(p_student uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_school uuid := app.medical_controle(p_student, 'consultation');
  v_record medical.records;
begin
  if v_school is null then
    return app.medical_refus();
  end if;
  select * into v_record from medical.records r where r.student_id = p_student and r.deleted_at is null;
  return jsonb_build_object(
    'record', case when v_record.id is null then null
                   else to_jsonb(v_record) - array['school_id', 'created_by', 'updated_by', 'synced_at',
                                                   'created_at', 'deleted_at'] end,
    'examens', coalesce((
      select jsonb_agg(to_jsonb(e) - array['school_id', 'record_id', 'created_by', 'updated_by', 'synced_at',
                                           'created_at', 'deleted_at', 'id'] order by e.year_label)
        from medical.yearly_exams e
       where e.record_id = v_record.id and e.deleted_at is null), '[]'::jsonb),
    'aptitudes', coalesce((
      select jsonb_agg(jsonb_build_object('school_year_id', f.school_year_id, 'aptitude', f.aptitude,
                                          'expose_to_teacher', f.expose_to_teacher))
        from medical.fitness f
       where f.student_id = p_student and f.deleted_at is null), '[]'::jsonb));
end $$;

-- Enregistrement (tous les champs facultatifs). p_record : champs de
-- medical.records ; p_examens : [{year_label, urines_alb, …}] ;
-- p_aptitude : {school_year_id, aptitude (null = retirer), expose_to_teacher}.
create or replace function public.medical_save(
  p_student uuid, p_record jsonb, p_examens jsonb, p_aptitude jsonb
) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_school uuid := app.medical_controle(p_student, 'modification');
  v_cols text;
  v_record uuid;
  e jsonb;
begin
  if v_school is null then
    return app.medical_refus();
  end if;

  select string_agg(quote_ident(column_name), ', ') into v_cols
    from information_schema.columns
   where table_schema = 'medical' and table_name = 'records'
     and column_name not in ('id', 'school_id', 'student_id', 'created_at', 'updated_at', 'deleted_at',
                             'created_by', 'updated_by', 'synced_at');
  insert into medical.records (school_id, student_id) values (v_school, p_student)
    on conflict (student_id) do nothing;
  select r.id into v_record from medical.records r where r.student_id = p_student;
  if p_record is not null then
    execute format('update medical.records t set (%1$s, updated_at, deleted_at) = '
                   '(select %1$s, now(), null::timestamptz from jsonb_populate_record(null::medical.records, $1)) '
                   'where t.id = $2', v_cols)
      using p_record, v_record;
  end if;

  select string_agg(quote_ident(column_name), ', ') into v_cols
    from information_schema.columns
   where table_schema = 'medical' and table_name = 'yearly_exams'
     and column_name not in ('id', 'school_id', 'record_id', 'year_label', 'created_at', 'updated_at',
                             'deleted_at', 'created_by', 'updated_by', 'synced_at');
  for e in select * from jsonb_array_elements(coalesce(p_examens, '[]'::jsonb)) loop
    insert into medical.yearly_exams (school_id, record_id, year_label)
      values (v_school, v_record, e ->> 'year_label')
      on conflict (record_id, year_label) do nothing;
    execute format('update medical.yearly_exams t set (%1$s, updated_at, deleted_at) = '
                   '(select %1$s, now(), null::timestamptz from jsonb_populate_record(null::medical.yearly_exams, $1)) '
                   'where t.record_id = $2 and t.year_label = $3', v_cols)
      using e, v_record, e ->> 'year_label';
  end loop;

  if p_aptitude is not null then
    if p_aptitude ->> 'aptitude' is null then
      update medical.fitness set deleted_at = now(), updated_at = now()
       where student_id = p_student and school_year_id = (p_aptitude ->> 'school_year_id')::uuid;
    else
      insert into medical.fitness (school_id, student_id, school_year_id, aptitude, expose_to_teacher)
      values (v_school, p_student, (p_aptitude ->> 'school_year_id')::uuid, p_aptitude ->> 'aptitude',
              coalesce((p_aptitude ->> 'expose_to_teacher')::boolean, false))
      on conflict (student_id, school_year_id) do update
        set aptitude = excluded.aptitude, expose_to_teacher = excluded.expose_to_teacher,
            deleted_at = null, updated_at = now();
    end if;
  end if;
  return jsonb_build_object('ok', true);
end $$;

-- Impression de la fiche (PDF) : seulement journalisée.
create or replace function public.medical_impression(p_student uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
begin
  if app.medical_controle(p_student, 'impression') is null then
    return app.medical_refus();
  end if;
  return jsonb_build_object('ok', true);
end $$;

-- Journal d'accès consultable par le directeur.
create or replace function public.medical_log(p_school uuid, p_limit integer default 200)
returns table (occurred_at timestamptz, actor text, student text, action text, allowed boolean)
language sql stable security definer set search_path = '' as $$
  select l.occurred_at,
         coalesce((select m.display_name from public.memberships m
                    where m.school_id = l.school_id and m.user_id = l.actor_id
                    order by m.created_at limit 1), 'Personne inconnue'),
         (select s.last_name || ' ' || s.first_names from public.students s where s.id = l.student_id),
         l.action, l.allowed
    from medical.access_log l
   where l.school_id = p_school and app.is_director(p_school)
   order by l.occurred_at desc
   limit least(greatest(p_limit, 1), 1000);
$$;

-- Seule information exposable à l'enseignant : la mention d'aptitude de
-- l'année en cours, si le directeur l'a choisi pour l'élève. Aucun détail
-- médical. Journalisé (élève non précisé : une ligne par consultation).
create or replace function public.medical_aptitudes(p_class uuid)
returns table (student_id uuid, aptitude text)
language plpgsql security definer set search_path = '' as $$
declare
  v_school uuid;
  v_year uuid;
  v_ok boolean;
begin
  select c.school_id, c.school_year_id into v_school, v_year from public.classes c where c.id = p_class;
  if v_school is null then
    return;
  end if;
  v_ok := app.module_enabled(v_school, 'medico_scolaire')
          and (app.is_director(v_school) or p_class in (select app.my_class_ids()));
  perform app.medical_journal(v_school, null, 'aptitudes de la classe', v_ok);
  if not v_ok then
    return;
  end if;
  return query
    select f.student_id, f.aptitude
      from medical.fitness f
      join public.enrollments en on en.student_id = f.student_id and en.class_id = p_class
                                and en.deleted_at is null
     where f.school_year_id = v_year and f.deleted_at is null and f.expose_to_teacher;
end $$;

revoke all on function public.medical_get(uuid), public.medical_save(uuid, jsonb, jsonb, jsonb),
  public.medical_impression(uuid), public.medical_log(uuid, integer), public.medical_aptitudes(uuid)
  from public, anon;
grant execute on function public.medical_get(uuid), public.medical_save(uuid, jsonb, jsonb, jsonb),
  public.medical_impression(uuid), public.medical_log(uuid, integer), public.medical_aptitudes(uuid)
  to authenticated;
revoke all on function app.medical_journal(uuid, uuid, text, boolean), app.medical_controle(uuid, text)
  from public, anon, authenticated;
