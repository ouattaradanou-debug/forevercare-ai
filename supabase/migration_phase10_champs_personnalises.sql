-- Phase 10 : distinguer les champs de mesure ajoutés par le tailleur
-- lui-même (bouton "Ajouter un champ") des champs par défaut (ou de leurs
-- copies dans le gabarit propre à l'atelier, voir
-- GabaritRepository.assurerGabaritPersonnalise) — seuls les premiers
-- doivent pouvoir être supprimés directement depuis le formulaire de
-- mesures (icône "×" dans SectionMesures) ; les champs par défaut restent
-- masquables uniquement depuis l'écran "Champs de mesure".

alter table public.champs_mesure
  add column if not exists est_personnalise boolean not null default false;

-- Rétro-marque comme "personnalisé" tout champ d'un gabarit propre à un
-- atelier dont le nom ne correspond à aucun champ du gabarit par défaut du
-- même sexe : un champ cloné depuis le défaut porte toujours exactement le
-- même nom, donc tout nom absent de cette liste a nécessairement été ajouté
-- manuellement par un tailleur avant cette migration.
update public.champs_mesure c
set est_personnalise = true
from public.types_tenue t
where c.type_tenue_id = t.id
  and t.atelier_id is not null
  and lower(trim(c.nom)) not in (
    select lower(trim(c2.nom))
    from public.champs_mesure c2
    join public.types_tenue t2 on t2.id = c2.type_tenue_id
    where t2.atelier_id is null and t2.sexe = t.sexe
  );
