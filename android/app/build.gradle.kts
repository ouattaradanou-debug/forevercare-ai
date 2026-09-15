plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.atelier_plus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.atelier_plus"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Remplace la clé de debug par défaut (régénérée aléatoirement à
        // chaque machine, donc différente à chaque construction sur
        // GitHub Actions — un nouvel APK ne pouvait alors jamais s'installer
        // "par-dessus" le précédent sur un téléphone : Android refuse toute
        // mise à jour signée par une clé différente, obligeant à
        // désinstaller l'ancienne version avant chaque test). Cette clé de
        // debug.keystore est volontairement suivie par git : une clé de
        // debug n'est pas un secret (c'est justement sa raison d'être), et
        // la garder identique sur toutes les machines (CI comme locale) est
        // ce qui permet des mises à jour normales, comme pour n'importe
        // quelle application.
        getByName("debug") {
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            // Signé avec la même clé de debug (voir signingConfigs
            // ci-dessus) : suffisant pour les APK de test envoyés aux
            // tailleurs, en attendant une vraie clé de publication le jour
            // d'une sortie sur le Play Store.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
