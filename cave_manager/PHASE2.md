# Phase 2 — Produits & Stock

Suite de [PHASE1.md](./PHASE1.md) (fondations, validées). Cette phase ajoute le
CRUD produits et la gestion de stock, conformément au périmètre annoncé en
Phase 1 (section 1) et à la stratégie de conflit hors ligne validée avec vous
avant codage (PHASE1.md section 7).

---

## 1. Périmètre fonctionnel exact de la phase

Inclus :
- Catalogue produits : création/modification (Propriétaire et
  Propriétaire/Gérant uniquement), consultation (tous les rôles).
- Prix d'achat, séparé du reste du produit, visible et modifiable
  uniquement par Propriétaire/Propriétaire-Gérant (point 18 : jamais visible
  par le Gérant ni l'Agent de vente).
- Stock : consultation et ajustement (Propriétaire, Propriétaire/Gérant,
  Gérant) — l'Agent de vente n'y a **aucun** accès, ni en lecture ni en
  écriture (point 2.3).
- Mécanisme de synchronisation offline pour les ajustements de stock :
  chaque ajustement est un *delta*, jamais une valeur absolue ; deux
  appareils qui ajustent le même produit hors ligne voient leurs deltas
  s'additionner au retour de connexion (validé avec vous avant
  implémentation, voir décision ci-dessous).

Explicitement **hors périmètre** de cette phase (reportés comme convenu) :
vente/commandes (Phase 3), contrôle/validation/encaissement (Phase 4),
facture/WhatsApp/clôture (Phase 5).

**Non implémenté dans cette phase, signalé explicitement** : le mécanisme de
"réconciliation manuelle" au-delà d'un seuil d'écart significatif, évoqué en
Phase 1 comme piste possible. Le stock ne descend jamais sous zéro (filet de
sécurité côté trigger), mais aucun signalement automatique d'écart anormal
n'existe encore — l'historique complet des mouvements (`mouvements_stock`)
reste consultable pour une réconciliation manuelle si besoin. À ajouter si un
usage réel en montre la nécessité, plutôt que construit par anticipation.

---

## 2. Décision validée avec vous avant implémentation

**Question posée** : comment gérer un conflit quand deux appareils modifient
le même stock hors ligne puis se resynchronisent ?

**Réponse retenue : deltas additifs.** Chaque ajustement de stock est
enregistré comme une variation (`+3 cartons`, `-2 bouteilles`...), jamais
comme une quantité absolue. Au retour de connexion, tous les mouvements
en attente s'appliquent, et s'additionnent au total existant — aucun
écrasement possible, contrairement à un Last-Write-Wins qui ferait perdre
un des deux mouvements.

---

## 3. Modèle de données Supabase

Fichier : `supabase/migrations/0007_phase2_produits_stock.sql`.

| Table | Rôle | Colonnes clés |
|---|---|---|
| `produits` (enrichie) | Catalogue | + `bouteilles_par_carton` |
| `produits_couts` *(nouvelle)* | Prix d'achat, séparé | `produit_id`, `prix_achat` |
| `mouvements_stock` *(nouvelle)* | Journal append-only des deltas | `delta_cartons`, `delta_bouteilles`, `motif`, `created_by` |
| `stock` (déjà créée en Phase 1) | Total courant, recalculé par trigger | inchangée |

**Trigger `appliquer_mouvement_stock`** (`AFTER INSERT` sur
`mouvements_stock`, jamais `UPDATE`) : additionne chaque delta au total
existant dans `stock` (`upsert`), avec un plancher à zéro
(`greatest(..., 0)`). Le choix "`AFTER INSERT` seulement" est ce qui rend
un nouvel essai réseau (retry) sûr : le `RemoteWriter` générique déjà en
place (Phase 1) envoie chaque mouvement via `upsert` avec un id généré côté
client — si le même mouvement est renvoyé deux fois (accusé de réception
perdu, pas l'écriture elle-même), PostgreSQL traite la deuxième tentative
comme une mise à jour d'une ligne déjà existante (`ON CONFLICT DO UPDATE`),
pas comme une nouvelle insertion : le trigger ne se redéclenche donc pas, et
le delta n'est jamais appliqué deux fois. **Vérifié explicitement en local**
(voir section 5).

---

## 4. Matrice de permissions (complète la matrice de PHASE1.md)

| Table | PROP | PG | GER | AGENT | Policy RLS |
|---|---|---|---|---|---|
| `produits` | R/W/D | R/W/D | R | R | `produits_select` (toute la cave), `produits_write` (admin only) — inchangées depuis la Phase 1, déjà suffisantes |
| `produits_couts` | R/W | R/W | **—** | **—** | `produits_couts_select`, `produits_couts_write` (admin only) |
| `stock` | R/W | R/W | R/W | **—** | inchangées depuis la Phase 1 |
| `mouvements_stock` | R/W(insert) | R/W(insert) | R/W(insert) | **—** | `mouvements_stock_select`, `mouvements_stock_insert` — mêmes rôles que `stock`. Aucune policy `UPDATE`/`DELETE` : un mouvement, une fois créé, est immuable (corriger = ajouter un nouveau mouvement, jamais modifier l'historique) |

---

## 5. Vérifications effectuées sur PostgreSQL 16 local (RLS réellement active)

Avant tout envoi vers la production, comme pour toutes les migrations
précédentes :

1. **Fusion additive** : stock initial 10 cartons → deux mouvements de -2
   chacun (simulant deux appareils hors ligne) → stock final = 6 (pas -2
   écrasé par l'autre).
2. **Idempotence au retry** : un mouvement rejoué une deuxième fois avec le
   même id (simulation d'un accusé de réception réseau perdu) → stock
   passe de 6 à 5 (delta appliqué une seule fois), pas à 4.
3. **Agent de vente** : lit les prix de vente (`produits`), bloqué sur
   `produits_couts` (0 ligne, RLS silencieuse) et sur
   `mouvements_stock`/`produits` en écriture (erreur RLS explicite).
4. **Gérant** : peut créer un mouvement de stock, bloqué sur
   `produits_couts` et sur la création de produits.
5. **Propriétaire/Gérant** : accès complet, y compris prix d'achat.

---

## 6. Écrans Flutter livrés

- `ProduitsListScreen` : catalogue, bouton "+" (création) réservé à
  Propriétaire/Propriétaire-Gérant.
- `ProduitDetailScreen` : infos de vente pour tous ; stock (avec bouton
  "Ajuster le stock") pour Propriétaire/Propriétaire-Gérant/Gérant ; prix
  d'achat + bouton "Modifier le produit" pour Propriétaire/Propriétaire-
  Gérant uniquement.
- `ProduitFormScreen` : création/modification (nom, prix détail, prix gros,
  bouteilles/carton, prix d'achat, actif), un seul bouton "Enregistrer".
- Accessible depuis `HomeScreen` via un nouveau bouton "Produits" (visible
  pour les 4 rôles, chacun voyant un sous-ensemble différent une fois dans
  le détail d'un produit, selon la matrice ci-dessus).

**Catalogue produits (lecture/écriture)** : requêtes directes Supabase
(comme `ConfigurationCaveScreen` en Phase 1) — se configure typiquement
avec réseau, changements peu fréquents. **Ajustements de stock** : passent
par la file de synchronisation locale Drift (`StockDao`, nouvelle table
`LocalStock`) pour fonctionner réellement hors ligne — c'est la seule
partie de cette phase où l'offline-first était un besoin explicite du
cahier des charges (agent en tournée sans réseau).

---

## 7. Vérifié sur téléphone réel (Propriétaire)

Testé sur l'appareil réel (TECNO KI5k), contre le projet Supabase de
production :

1. **Création de produit** : "SOBEBRA" créé avec prix détail/gros,
   bouteilles/carton, et prix d'achat (table séparée `produits_couts`) —
   tous les champs s'affichent correctement sur `ProduitDetailScreen`.
2. **Ajustement de stock** : deux ajustements successifs déclenchés depuis
   l'écran ("Ajuster le stock"), cache local mis à jour immédiatement
   (0 → 12 cartons / 15 bouteilles).
3. **Synchronisation réelle** : les deux mouvements sont bien arrivés dans
   `mouvements_stock` côté serveur (12/13 puis 0/2), et le trigger
   `appliquer_mouvement_stock` a correctement additionné les deltas dans
   `stock` (12 cartons / 15 bouteilles) — confirmé par requête SQL directe
   dans le tableau de bord Supabase.

**Reste à vérifier** (non bloquant pour la validation du mécanisme
principal, mais pas encore testé sur l'appareil réel) : le comportement
des écrans Produits/Stock avec un compte Gérant ou Agent de vente (seule
la simulation RLS locale en Postgres l'a couvert jusqu'ici).

---

## En attente de votre validation avant la Phase 3 (Vente & Commandes).
