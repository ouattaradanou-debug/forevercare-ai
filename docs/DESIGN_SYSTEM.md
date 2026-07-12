# ForeverCare AI
# ForeverCare Design Language (FDL)

Version : 1.0

---

# Objectif

Le ForeverCare Design Language (FDL) définit toutes les règles
graphiques de l'application.

Son objectif est de garantir :

- une interface homogène
- une expérience utilisateur cohérente
- une maintenance simplifiée
- des composants réutilisables

Aucun écran ne doit s'écarter de ces règles.

---

# Principes

Le Design System repose sur :

- Material Design 3
- Flutter
- Design Tokens
- Composants réutilisables

---

# Fondations

Les fondations sont situées dans :

lib/design_system/foundations/

Exemples :

app_colors.dart

app_spacing.dart

app_radius.dart

app_duration.dart

app_breakpoints.dart

app_icons.dart

---

# Espacements

Toutes les marges et tous les paddings utilisent AppSpacing.

Exemples :

AppSpacing.sm

AppSpacing.md

AppSpacing.lg

AppSpacing.xl

AppSpacing.xxl

Les valeurs numériques (8, 16, 24...) ne doivent pas être utilisées
directement dans les nouveaux développements.

---

# Rayons

Tous les arrondis utilisent AppRadius.

Exemples :

AppRadius.button

AppRadius.card

AppRadius.input

---

# Durées

Toutes les animations utilisent AppDuration.

Exemples :

AppDuration.fast

AppDuration.medium

AppDuration.slow

---

# Couleurs

Toutes les couleurs proviennent du thème.

Toujours utiliser :

Theme.of(context).colorScheme

Éviter les couleurs codées en dur.

---

# Typographie

La typographie est centralisée.

Toujours utiliser :

Theme.of(context).textTheme

Ne pas créer de styles directement dans les widgets
sauf exception justifiée.

---

# Composants officiels

Les composants suivants sont obligatoires.

Boutons

FCButton

Cartes

FCCard

Champs texte

FCTextField

Liste déroulante

FCDropdownField

Sélecteur de date

FCDateField

Tous les nouveaux écrans doivent utiliser ces composants.

---

# Icônes

Utiliser exclusivement les icônes Material.

Les icônes doivent rester cohérentes
dans toute l'application.

Exemples :

Dashboard

Icons.dashboard

Clients

Icons.people

Produits

Icons.inventory_2

Commandes

Icons.shopping_cart

Inventaire

Icons.warehouse

Protocoles

Icons.medication

Rendez-vous

Icons.calendar_month

Paiements

Icons.payments

---

# Responsive Design

Toutes les nouvelles interfaces doivent être compatibles :

Téléphone

Tablette

Desktop

Les dimensions doivent utiliser les breakpoints officiels.

---

# Accessibilité

Les textes doivent rester lisibles.

Les contrastes doivent respecter
les recommandations de Material Design.

Les boutons doivent conserver
une taille minimale confortable.

---

# Évolutions futures

Version 1.1

Mode sombre complet

Version 1.2

Thèmes personnalisables

Version 2.0

Personnalisation complète du Design System

---

# Validation

Avant validation :

flutter analyze

flutter test

flutter run

---

Fin du document.