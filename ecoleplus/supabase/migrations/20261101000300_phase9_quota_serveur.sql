-- Phase 9 (correctif) : le quota d'espace d'une école est réglé côté
-- serveur seulement (administrateur du serveur), jamais depuis
-- l'application : un directeur ne peut pas augmenter son propre quota.
create or replace function app.schools_quota_guard() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  if current_user in ('authenticated', 'anon') then
    new.storage_quota_bytes := old.storage_quota_bytes;
  end if;
  return new;
end $$;

create trigger schools_quota_guard before update of storage_quota_bytes on public.schools
  for each row execute function app.schools_quota_guard();
