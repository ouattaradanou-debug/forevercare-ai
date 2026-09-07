# Règles de développement

## Architecture

- `lib/core` : configuration, thème, routeur, utilitaires
- `lib/data` : modèles, repositories, sources locale (Drift) et distante (Supabase)
- `lib/features/<fonctionnalite>` : un dossier par fonctionnalité (auth, clients, mesures, rendezvous, finances, permissions, abonnement, branding, home)
- `lib/shared` : widgets réutilisables

## Validation

Avant chaque commit :

```
flutter analyze
flutter test
flutter run
```

## Git

Un commit par fonctionnalité. Ne jamais mélanger plusieurs modules dans un même commit.
