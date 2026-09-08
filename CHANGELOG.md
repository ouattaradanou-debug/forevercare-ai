# Changelog

Toutes les évolutions importantes du projet sont documentées ici.

---

## v0.1.0 — Phase 0 : Initialisation et identité visuelle

### Ajout

- Rebrand complet du projet Flutter en Atelier+ (package Dart, applicationId Android, bundle iOS)
- Architecture en couches : `core`, `data`, `features`, `shared`
- Thème visuel centralisé (palette indigo / terre cuite / or, typographie Fraunces + Inter)
- Écran d'accueil statique
- Schéma SQL Supabase complet (13 tables) avec Row Level Security

### Architecture

- Riverpod (gestion d'état)
- go_router (navigation)
- Drift + Supabase (offline-first)

---

## v0.2.0 — Phase 1 : Authentification et compte atelier

### Ajout

- Connexion téléphone + code PIN (email synthétique interne, sans SMS)
- Écrans de création de compte atelier (avec logo optionnel) et de connexion
- Base locale Drift : ateliers, utilisateurs, permissions_apprenti
- Récupération complète des données sur un nouvel appareil après connexion
  (scénario perte de téléphone)
- Gestion des apprentis : création via Edge Function `create-apprentice`
  (clé service_role, jamais côté client) + panneau de permissions
  (tout désactivé par défaut)
- Politiques Supabase Storage pour le bucket `logos`
- Écran d'accueil connecté aux vraies données atelier/utilisateur

### Architecture

- Riverpod pour l'état d'authentification et les données de compte
- go_router avec redirection automatique selon l'état de connexion

---

## v0.3.0 — Phase 2 : Clients et gabarits de mesures dynamiques

### Ajout

- Formulaire de création client **continu et scrollable** (Informations,
  Mesures, Photos du tissu, Photos des modèles, bouton Enregistrer fixe),
  sans stepper ni champ obligatoire — conçu pour des utilisateurs peu
  technophiles qui n'ont pas toujours toutes les informations en main
- Sauvegarde automatique en brouillon local (table Drift dédiée
  `brouillons_client`), debounce ~1s, un seul brouillon actif par
  utilisateur, survit à la fermeture complète de l'application et au
  redémarrage du téléphone (flush immédiat à la mise en arrière-plan)
- Reprise du brouillon proposée à la réouverture du formulaire
- Règle de finalisation assouplie : sans mesure, un message doux propose
  "Ajouter une mesure maintenant" ou "Enregistrer comme brouillon" plutôt
  qu'un blocage ; dès qu'une mesure existe, le client est créé et une
  synchronisation Supabase best-effort est tentée si une connexion est
  disponible
- Gabarits par défaut : 5 types de tenue Homme, 7 Femme, à partir de la
  bibliothèque de champs de mesure définie au départ du projet
- Écran liste des clients avec recherche instantanée (nom/téléphone)
- Section "Fiches à compléter" sur l'écran d'accueil (brouillon en attente)

### Architecture

- Un client (`clients`) n'est écrit — localement et sur Supabase — que par
  la finalisation, qui exige toujours une mesure : aucun chemin de code ne
  peut créer un client sans mesure, la règle est garantie par construction
- Champs d'identité client (nom, prénom, téléphone, sexe, date de prise
  des mesures) rendus optionnels côté Supabase (voir
  `supabase/migration_phase2_champs_optionnels.sql`)
- Photos de brouillon stockées en local uniquement ; l'envoi vers Supabase
  Storage sera ajouté avec le moteur de synchronisation de la Phase 3

---

## Prochaine version

v0.4.0 — Phase 3 : Rendez-vous, finances et synchronisation offline
