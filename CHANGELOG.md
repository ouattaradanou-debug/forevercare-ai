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

## Prochaine version

v0.3.0 — Phase 2 : Clients et gabarits de mesures dynamiques
