# Préparer Atelier + pour Android et iOS

Ce document liste les réglages natifs connus comme nécessaires, compte tenu
des packages déjà choisis dans `pubspec.yaml`, à appliquer **après** que
`flutter create .` ait généré `android/` et `ios/` en local (ces dossiers
n'existent pas encore dans ce dépôt — voir `README.md`).

## Android (`android/app/`)

### Permissions (`AndroidManifest.xml`)

À ajouter dans `<manifest>` (hors `<application>`), requises par
`image_picker` et `flutter_local_notifications` :

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

`POST_NOTIFICATIONS` est une permission d'exécution (Android 13+) : elle doit
en plus être demandée à l'utilisateur au runtime (fait par le code Dart en
Phase 3, pas par le seul manifest).

### `build.gradle` (module `app`)

- `minSdkVersion` : au moins **21** (`flutter_local_notifications` et
  `sqlite3_flutter_libs` l'exigent). Flutter utilise déjà 21 par défaut la
  plupart du temps — à vérifier après génération, pas à augmenter sans
  raison.
- **Core library desugaring** requis par `flutter_local_notifications`
  (API `java.time.*`) :

```gradle
android {
  compileOptions {
    isCoreLibraryDesugaringEnabled = true
  }
}

dependencies {
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

## iOS (`ios/Runner/`)

### `Info.plist`

Chaînes de description obligatoires (Apple rejette toute app sans elles),
requises par `image_picker` (caméra ET galerie) :

```xml
<key>NSCameraUsageDescription</key>
<string>Atelier + a besoin de l'appareil photo pour prendre des photos de tissus et de modèles.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Atelier + a besoin d'accéder à vos photos pour choisir des images de tissus et de modèles.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Atelier + a besoin d'enregistrer des photos dans votre galerie.</string>
```

### Version minimale iOS

`supabase_flutter` et `flutter_local_notifications` récents exigent
généralement **iOS 13.0** minimum. Après génération, vérifier/ajuster dans
`ios/Podfile` (`platform :ios, '13.0'`) et dans les réglages de build Xcode
(`IPHONEOS_DEPLOYMENT_TARGET`).

### Outillage requis

La génération du dossier `ios/` fonctionne sur n'importe quel système
d'exploitation, mais **compiler/exécuter réellement l'app iOS nécessite un
Mac avec Xcode installé** (et CocoaPods, `sudo gem install cocoapods` ou via
Homebrew). Sur Windows/Linux, seul le développement Android est possible en
local.

## Après `flutter create .` : étapes à ne pas oublier

1. Corriger `.gitignore` — voir la remarque dans le message de vérification
   du projet (les dossiers `android/`/`ios/` y sont actuellement exclus,
   ce qui les empêcherait d'être commités une fois générés).
2. Remplacer ou supprimer `test/widget_test.dart` généré par défaut par
   Flutter (modèle "compteur" incompatible avec `AtelierPlusApp`).
3. Appliquer les réglages ci-dessus, puis `flutter pub get`.
4. `flutter run` (Android) ou `flutter run -d <simulateur iOS>` (macOS
   uniquement).
