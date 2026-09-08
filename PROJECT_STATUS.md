# Atelier+ — État du projet

## Phase 0 — Initialisation et identité visuelle

- [x] Rebrand du projet Flutter (nom de package, identifiants Android/iOS)
- [x] Dépendances configurées (Supabase, Drift, Riverpod, go_router, image_picker, connectivity_plus, flutter_local_notifications, intl)
- [x] Thème visuel centralisé (palette couture, typographie, boutons/cartes/champs)
- [x] Écran d'accueil statique (validation de la direction visuelle)
- [x] Schéma SQL Supabase complet + politiques RLS
- [ ] Validation utilisateur sur téléphone

## Phase 1 — Authentification et compte atelier

- [x] Connexion Supabase (config + initialisation)
- [x] Base locale Drift (ateliers, utilisateurs, permissions_apprenti)
- [x] Création de compte atelier (nom, logo, téléphone, PIN)
- [x] Connexion + récupération complète des données sur nouvel appareil
- [x] Gestion des apprentis (Edge Function service_role) + permissions
- [ ] Validation utilisateur sur téléphone

## Phase 2 — Clients et gabarits de mesures dynamiques

- [x] Gabarits par défaut Homme (5) / Femme (7) à partir de la bibliothèque de champs
- [x] Formulaire de création client continu et scrollable (aucun champ obligatoire)
- [x] Brouillon local auto-sauvegardé (debounce 1s), reprise après fermeture complète de l'app
- [x] Règle de finalisation assouplie (message doux si aucune mesure, jamais de blocage dur)
- [x] Liste des clients avec recherche instantanée (nom/téléphone)
- [ ] Écran "Gérer mes types de tenues" (ajout/masquage de champ, duplication de gabarit) — non commencé
- [ ] Validation utilisateur sur téléphone

## Phase 3 — Rendez-vous, finances et synchronisation offline

- [ ] Non commencé

## Phase 4 — Personnalisation de marque et abonnement

- [ ] Non commencé

## Phase 5 — Vérification finale

- [ ] Non commencé

---

Prochaine étape : validation de la Phase 0 sur téléphone, puis démarrage de la Phase 1.
