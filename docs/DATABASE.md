# ForeverCare AI
# Base de données SQLite

Version : 1.0

---

# Objectif

ForeverCare AI utilise une base SQLite unique.

Toute la persistance de l'application repose sur cette base.

Le fichier est entièrement géré par AppDatabase.

---

# Architecture

Flutter UI

↓

Riverpod

↓

UseCases

↓

Repositories

↓

DataSources

↓

AppDatabase

↓

SQLite

---

# Fichier principal

lib/core/database/app_database.dart

Ce fichier est l'unique point d'entrée vers SQLite.

Aucun autre fichier ne doit ouvrir une connexion SQLite.

---

# Organisation

AppDatabase

↓

Tables

↓

DataSources

↓

Repositories

↓

UseCases

↓

Providers

---

# Convention de nommage

## Tables

Toujours au pluriel.

Exemples

clients

products

orders

appointments

suppliers

payments

protocols

---

## Colonnes

Toujours en snake_case.

Exemples

id

first_name

last_name

created_at

updated_at

purchase_price

sale_price

alert_stock

birth_date

---

# Clés primaires

Toutes les tables possèdent :

id TEXT PRIMARY KEY

Les identifiants sont générés par l'application.

---

# Dates

Toutes les dates sont enregistrées au format :

ISO 8601

Exemple

2026-07-12T08:35:00.000

---

# Valeurs booléennes

SQLite ne possède pas de type booléen.

Convention utilisée :

0 = false

1 = true

---

# Migrations

Chaque modification de structure implique :

augmentation de DATABASE_VERSION

création d'une migration

tests

validation

Aucune modification directe en production.

---

# DataSources

Chaque module possède son DataSource.

Exemples

ClientLocalDataSource

ProductLocalDataSource

OrderLocalDataSource

Ils sont les seuls autorisés à exécuter des requêtes SQL.

---

# Repositories

Les Repositories ne connaissent jamais SQLite.

Ils dialoguent uniquement avec les DataSources.

---

# Providers

Les Providers ne connaissent jamais SQLite.

Ils utilisent exclusivement les UseCases.

---

# Widgets

Les Widgets ne connaissent jamais SQLite.

Ils utilisent exclusivement Riverpod.

---

# Diagramme

Flutter UI

↓

Riverpod

↓

UseCases

↓

Repositories

↓

DataSources

↓

SQLite

---

# Sauvegarde

Le fichier SQLite doit être sauvegardé régulièrement.

Les futures versions intégreront :

Export

Import

Sauvegarde Cloud

---

# Evolution prévue

Version 1.1

Historique des migrations

Version 1.2

Synchronisation Cloud

Version 2.0

Mode multi-utilisateurs

---

Fin du document.