# EcolePlus (nom provisoire)

Application mobile de gestion scolaire pour les écoles primaires du Burkina Faso (maternelle optionnelle), hors ligne d'abord. Porteur : SEDA Tech.

État : **phase 0** (socle technique). Voir `docs/`.

## Installation (poste de développement)

Prérequis : Flutter 3.47+, Android Studio (SDK + émulateur), Docker, Node.js 20+.

```bash
git clone https://github.com/ouattaradanou-debug/forevercare-ai.git
cd forevercare-ai/ecoleplus
cp .env.example .env
flutter pub get
npx supabase@2.121.0 start          # base locale (Docker)
npx supabase@2.121.0 db reset       # schéma + « École Test »
npx supabase@2.121.0 test db        # tests de sécurité et d'intégrité
flutter test                        # tests de l'application
flutter run                         # lance l'application sur l'émulateur
```

Tout vérifier d'un coup : `tools/check.sh`.

## Documentation
* `docs/ARCHITECTURE.md` — paquets, schéma, synchronisation, numérotation hors ligne, sécurité
* `docs/CORRESPONDANCE_FORMULAIRES.md` — chaque colonne des formulaires B1 à B7 → champ en base
* `docs/BIBLIOTHEQUE_ET_IA.md` — stockage, coûts, comparaison OCR et indexation
* `docs/HYPOTHESES_TERRAIN.md` — hypothèses à valider
* `docs/EVOLUTIONS.md` — décisions et ajouts proposés
* `docs/TESTS_PHASE_0.md` — procédure de test manuel
