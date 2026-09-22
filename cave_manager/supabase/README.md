# Supabase — Phase 1

## Mise en place

1. Créer un projet Supabase (ou en réutiliser un dédié à cette app — **ne
   pas** réutiliser le projet ForeverCare AI existant, domaines et schémas
   totalement différents).
2. Appliquer la migration :
   ```bash
   supabase link --project-ref <votre-projet>
   supabase db push
   ```
   ou coller le contenu de `migrations/0001_phase1_fondations.sql` dans le
   SQL Editor du dashboard Supabase.
3. Déployer la fonction de création de comptes :
   ```bash
   supabase functions deploy create-team-member
   ```
   Elle utilise automatiquement `SUPABASE_URL` et `SUPABASE_SERVICE_ROLE_KEY`
   (variables déjà injectées par Supabase pour toute Edge Function).
4. Renseigner côté Flutter (voir `lib/core/config/supabase_config.dart`) :
   `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

## Pourquoi certaines tables existent déjà (produits, stock, clotures)

Elles sont volontairement réduites à un squelette minimal en Phase 1. Elles
ne sont pas exposées dans l'app Flutter (aucun écran Phase 1 ne les touche).
Leur seul rôle ici est de porter des policies RLS réelles pour permettre le
test de sécurité obligatoire : un Agent de vente doit être bloqué au niveau
base de données, pas seulement à l'écran. Voir `PHASE1.md` à la racine du
module pour la justification complète et la matrice de permissions.

## Test manuel rapide des policies (au clavier, sans app)

Avec deux comptes de test (un Propriétaire/Gérant, un Agent de vente) créés
via `creer_cave_et_proprietaire` puis `create-team-member` :

```sql
-- Connecté en tant qu'Agent de vente (JWT agent dans le client Supabase) :
select * from stock;        -- doit renvoyer 0 ligne (pas d'erreur, RLS filtre)
insert into stock (cave_id, produit_id, quantite_cartons)
values ('<cave_id>', '<produit_id>', 5);  -- doit renvoyer une erreur 42501
```
