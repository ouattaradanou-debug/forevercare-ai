# Règles de développement

## Architecture

Toujours respecter la Clean Architecture.

## Organisation

Chaque module doit posséder :

- domain
- data
- presentation

## Validation

Avant chaque commit :

flutter analyze

flutter test

flutter run

## Git

Un commit par fonctionnalité.

Ne jamais mélanger plusieurs modules dans un même commit.