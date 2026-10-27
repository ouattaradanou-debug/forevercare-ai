-- =====================================================================
-- A17 — Documents du directeur : attestation de prise de service,
-- certificat de scolarité, attestation de niveau, certificat de non
-- redevance. Champs manquants et journal des documents délivrés.
-- =====================================================================

-- Signataire : « Madame … Directrice … », « Professeur Certifié des Écoles ».
alter table public.schools
  add column director_civility text check (director_civility in ('madame', 'monsieur')),
  add column director_grade text;

-- Attestation de prise de service : décision d'affectation et date.
alter table public.teachers
  add column assignment_decision_number text,
  add column assignment_decision_date date,
  add column service_start_date date;

-- Journal des documents délivrés (ajout seul, sans numéro : décision du
-- 27/10/2026) : qui, quand, pour quel élève ou enseignant.
create table public.issued_documents (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid references public.school_years (id),
  doc_code text not null check (doc_code in (
    'prise_service', 'certificat_scolarite', 'attestation_niveau', 'non_redevance')),
  student_id uuid references public.students (id),
  teacher_id uuid references public.teachers (id),
  generated_by uuid,
  generated_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  synced_at timestamptz not null default now(),
  check ((student_id is null) <> (teacher_id is null))
);
alter table public.issued_documents enable row level security;
create trigger issued_documents_synced_at before insert on public.issued_documents
  for each row execute function app.touch_synced_at();
create trigger append_only before update or delete on public.issued_documents
  for each row execute function app.forbid_update();
create trigger issued_documents_generated_by before insert on public.issued_documents
  for each row execute function app.stamp_generated_by();

-- Directeur et délégué « registres » ; jamais l'enseignant.
create policy issued_documents_read on public.issued_documents for select to authenticated
  using (app.has_any_perm(school_id, array['registres']));
create policy issued_documents_insert on public.issued_documents for insert to authenticated
  with check (app.has_any_perm(school_id, array['registres']));

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('issued_documents', 'append', '{id}');
create trigger issued_documents_audit after insert on public.issued_documents
  for each row execute function app.audit_row();
