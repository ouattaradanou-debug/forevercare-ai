# Liste de contrôle avant publication (essai pilote puis Play Store)

Cochez chaque ligne. ⚠️ = action du porteur du projet (je ne peux pas la
faire à votre place).

## A. Serveur de production
- [ ] ⚠️ Projet Supabase **dédié à la production** (jamais celui de test ni
      celui d'Atelier Plus), région la plus proche (Europe de l'Ouest).
- [ ] Migrations appliquées (`supabase db push`) ; `supabase test db` vert
      sur une copie.
- [ ] Réglages d'authentification : mot de passe de 8 caractères au moins,
      modèle d'e-mail en français (le workflow « livraison » le fait).
- [ ] Fonctions serveur déployées : `connexion-telephone`, `gerer-membres`,
      `recuperer-mot-de-passe`, `assistant-ia`.
- [ ] ⚠️ Secrets des fonctions : `AI_API_KEY` (clé Claude avec plafond de
      dépense), `AI_PROVIDER=anthropic`, `AI_MODEL`.
- [ ] Sauvegarde nocturne active (GitHub « sauvegarde du serveur ») avec
      `BACKUP_PASSPHRASE` gardée hors ligne par deux personnes.
- [ ] Restauration essayée une fois sur un projet vide
      (`tools/test_restauration.sh` : déjà vert en intégration continue).
- [ ] Quotas : stockage par école, limites IA (`ai_quotas`).

## B. Application
- [ ] ⚠️ Créer la **clé de signature** une seule fois et la garder en deux
      endroits sûrs (sa perte empêche toute mise à jour) :
      `keytool -genkey -v -keystore ecoleplus.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ecoleplus`
- [ ] Fichier `android/key.properties` (jamais dans git) :
      `storeFile=…/ecoleplus.jks`, `storePassword=…`, `keyAlias=ecoleplus`,
      `keyPassword=…` ; la construction l'utilise automatiquement.
- [ ] Numéro de version (`pubspec.yaml`, `version: 1.0.0+1`) augmenté à
      chaque publication.
- [ ] Adresse du serveur de production dans les variables GitHub
      `SUPABASE_URL` / `SUPABASE_ANON_KEY`.
- [ ] Construction : `flutter build appbundle --release --obfuscate
      --split-debug-info=build/symboles` (Play Store) ou APK par type de
      téléphone (diffusion directe) ; garder le dossier `build/symboles`.
- [ ] `flutter analyze` sans remarque, tous les tests verts.
- [ ] Test sur un téléphone d'entrée de gamme (`PERFORMANCE.md`).

## C. Play Store (si diffusion par le Play Store)
- [ ] ⚠️ Compte développeur Google (25 $ une fois).
- [ ] Fiche : nom, description courte et longue en français, icône 512 px,
      captures d'écran (`docs/guide/`).
- [ ] **Politique de confidentialité** publiée sur une page web (données
      d'élèves mineurs, photos, santé, finances : voir
      `POINTS_JURIDIQUES.md`).
- [ ] Formulaire « Sécurité des données » : données collectées (noms,
      dates de naissance, photos, notes, paiements, santé si le module est
      activé), chiffrées en transit et sur le téléphone, non partagées avec
      des tiers, suppression sur demande du directeur.
- [ ] Public visé : **adultes** (directeurs, enseignants) — l'application
      n'est pas destinée aux enfants.
- [ ] Permission micro justifiée (dictée).

## D. Essai pilote
- [ ] ⚠️ Accord écrit de chaque école pilote (directeur), information des
      parents (texte du module médical, photos).
- [ ] Former le directeur avec `GUIDE_UTILISATION.md` (30 à 45 minutes).
- [ ] Un numéro d'assistance (WhatsApp) et une personne qui répond.
- [ ] Point hebdomadaire : problèmes, idées, synchronisations bloquées
      (écran « Synchronisation » du directeur).
