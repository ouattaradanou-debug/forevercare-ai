# Phase 4 — Contrôle, validation & encaissement

Suite de [PHASE3.md](./PHASE3.md) (vente & commandes, validée). Cette
phase ajoute le contrôle/validation d'une commande et l'encaissement,
conformément au périmètre annoncé depuis la Phase 1 (PHASE1.md sections 1
et 9).

---

## 1. Périmètre fonctionnel exact de la phase

Inclus :
- **Contrôle** : relecture d'une commande encore en attente par un
  responsable, avant de la valider. N'ajoute aucune table ni écran dédié :
  c'est `CommandeDetailScreen`, déjà livré en Phase 3 (avec la correction
  d'une quantité / le retrait d'une ligne, migration 0013).
- **Validation** : transition `commandes.statut` `en_attente` ->
  `validee`, réservée aux responsables, qui décrémente automatiquement le
  stock des produits vendus.
- **Encaissement** : enregistrement d'un ou plusieurs paiements (espèces
  et/ou Mobile Money) pour une commande, avec calcul automatique du reste
  à payer en cas de paiement partiel (point 13 du cahier des charges,
  déjà modélisé et testé unitairement dès la Phase 1 via
  `calculerResteAPayer`).

Explicitement **hors périmètre** de cette phase (reporté à la Phase 5,
comme convenu) : facture, notification WhatsApp, clôture de caisse.

---

## 2. Hypothèses posées, signalées explicitement

1. **Validation et encaissement passent par la file de synchronisation
   locale (offline-first), pas par un appel réseau direct** — comme la
   prise de commande en Phase 3. Justifié par l'hypothèse déjà posée en
   Phase 1 (PHASE1.md section 10, point 4) : "toute prise de commande,
   tout encaissement, toute mise à jour de stock" doivent fonctionner
   hors ligne. La validation entraîne une mise à jour de stock, donc les
   deux passent par `VentesDao` (file de synchronisation), jamais par un
   appel Supabase direct — contrairement à l'annulation (Phase 3), qui
   reste un appel direct car elle ne touche pas le stock et était déjà
   actée ainsi avant cette phase.
2. **La décrémentation du stock à la validation est appliquée par un
   trigger serveur, pas enfilée séparément côté client.** Le principe posé
   en Phase 1 ("validation et décrémentation du stock comme une seule
   unité atomique") envisageait un regroupement dans la file de
   synchronisation locale ; un trigger serveur est un mécanisme plus
   strict qui obtient la même garantie sans dépendre du client : un seul
   écrit (le changement de statut) déclenche les deux effets. Avantage
   supplémentaire non prévu à l'origine : même un appel API direct
   contournant l'app ne peut pas valider une commande sans décrémenter le
   stock, l'un ne pouvant pas exister sans l'autre — cohérent avec le
   principe déjà appliqué ailleurs (RLS/trigger comme frontière réelle,
   pas seulement un filtrage d'interface).
3. **Un encaissement reste possible tant que la commande n'est pas
   annulée**, y compris avant validation (dépôt/acompte). Le cahier des
   charges ne limite pas explicitement l'encaissement à l'après-validation
   ; interdire un acompte avant validation aurait été une contrainte
   ajoutée sans justification. À reconsidérer si un usage réel montre le
   contraire.
4. **Plusieurs encaissements par commande sont possibles** (paiement
   échelonné) : journal append-only (`encaissements`), même principe que
   `mouvements_stock`. Les cumuls (`commandes.montant_encaisse_especes`/
   `_mobile`) sont recalculés par trigger, jamais saisis côté client.
5. **Pas de transition automatique au solde complet** (ex. passer un
   statut "payée") : non demandé, ajouterait un état supplémentaire non
   spécifié. `resteAPayer == 0` suffit à afficher "Soldé" côté interface.
6. **Une fois validée, une commande ne peut plus revenir en arrière**
   (ni vers `en_attente`, ni annulée) : la policy RLS `commandes_update`
   n'autorise une transition qu'au départ de `en_attente`. Une commande
   validée par erreur nécessitera une correction manuelle hors de cette
   phase (même logique que les autres tables immuables du projet).

---

## 3. Modèle de données Supabase

Fichier : `supabase/migrations/0014_phase4_controle_validation_encaissement.sql`.

| Élément | Rôle |
|---|---|
| `commandes_update` (élargie) | Autorise désormais `en_attente` -> `validee` en plus de `en_attente` -> `annulee`, toujours réservé aux responsables |
| Trigger `appliquer_validation_commande` | À la transition vers `validee`, insère un `mouvements_stock` (delta négatif) par ligne de la commande — réutilise le mécanisme de Phase 2, jamais d'écriture directe sur `stock` |
| `encaissements` *(nouvelle)* | Paiement reçu (`montant_especes`, `montant_mobile_money`) ; append-only, lecture/écriture réservées aux responsables |
| `commandes.montant_encaisse_especes`/`_mobile` *(nouvelles colonnes)* | Cumuls recalculés par trigger `appliquer_encaissement` à chaque encaissement |

**Sûr en cas de retry réseau**, même raisonnement que les mécanismes déjà
en place (Phase 2/3) : le trigger de validation ne se déclenche que sur
`old.statut = 'en_attente' and new.statut = 'validee'` — un retry renvoie
un `UPDATE` sur une commande déjà `validee`, donc ni la condition du
trigger ni la `USING` clause de `commandes_update` ne s'appliquent une
seconde fois. Le trigger d'encaissement, `AFTER INSERT` uniquement, suit
le même principe que `appliquer_ligne_commande`.

---

## 4. Matrice de permissions (complète la matrice de PHASE1.md)

| Table | PROP | PG | GER | AGENT | Policy RLS |
|---|---|---|---|---|---|
| `commandes` (validation) | W (`en_attente`->`validee`) | idem | idem | **—** | `commandes_update` (élargie) |
| `encaissements` | R/W | R/W | R/W | **—** | `encaissements_select`/`_insert` (`is_responsable()`) |

---

## 5. Vérifications effectuées sur PostgreSQL 16 local (RLS réellement active)

Avant tout envoi vers la production, comme pour toutes les migrations
précédentes :

1. Un Agent tente de valider sa propre commande → refusé (`UPDATE 0`).
2. Un Agent tente d'enregistrer un encaissement → refusé (violation RLS).
3. Un Gérant valide la commande → réussit, statut `validee`.
4. Stock correctement décrémenté (20 → 15 cartons pour une ligne de 5
   cartons vendue).
5. Retry réseau (même `UPDATE` renvoyé deux fois) → le stock ne redescend
   pas une deuxième fois (reste à 15, pas 10).
6. Un Gérant tente de faire revenir une commande validée à `en_attente`
   → refusé (`UPDATE 0`).
7. Un Agent tente de lire les encaissements → 0 ligne renvoyée.
8. Un Gérant enregistre un encaissement partiel (10 000 espèces) → cumul
   correct, reste à payer calculé correctement (20 000 sur 30 000).
9. Un Gérant complète avec 20 000 en Mobile Money → soldé (0 restant).
10. Encaissement tenté sur une commande annulée → refusé.
11. Un Propriétaire/Gérant peut aussi valider une commande d'un Agent ;
    le plancher à 0 du stock (jamais négatif, mécanisme déjà en place
    depuis la Phase 2) continue de s'appliquer après une validation.

---

## 6. Écrans Flutter livrés

`CommandeDetailScreen` (Phase 3) étendu, pas de nouvel écran :
- Bouton **"Valider la commande"** (responsable, commande encore en
  attente) : confirmation, puis décrémentation automatique du stock côté
  serveur.
- Section **"Encaissement"** (responsable, commande non annulée) : total,
  montant déjà encaissé, reste à payer, bouton "Enregistrer un
  encaissement" ouvrant un formulaire (espèces/Mobile Money séparés) avec
  aperçu en direct du reste à payer après saisie — réutilise
  `calculerResteAPayer` (déjà écrite et testée unitairement en Phase 1).
  Un chip "Soldé" remplace le bouton une fois le reste à payer à 0.

**Validation et encaissement** : passent par `VentesDao`
(`validerCommande`/`enregistrerEncaissement`, file de synchronisation
locale Drift), pour fonctionner hors ligne — même mécanisme que la
création d'une commande en Phase 3. Aucune nouvelle table Drift locale
nécessaire (comme en Phase 3) : ces deux méthodes n'écrivent que dans la
file de synchronisation générique déjà existante.

---

## Non vérifié sur téléphone réel à la rédaction

Validation et encaissement n'ont pas encore été testés sur l'appareil
réel (seulement en local avec RLS). Aucun `build_runner` nécessaire :
`validerCommande`/`enregistrerEncaissement` sont des méthodes Dart
ordinaires sur `VentesDao` (déjà généré), sans nouvelle table ni colonne
Drift locale.

---

## En attente de votre validation avant la Phase 5 (Facture, WhatsApp & clôture).
