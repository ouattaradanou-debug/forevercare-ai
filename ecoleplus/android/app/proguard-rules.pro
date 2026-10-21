# Certaines extensions (shared_preferences, path_provider...) sont appelées
# depuis Dart par JNI, c'est-à-dire par le NOM des classes Java/Kotlin. R8
# (optimisation de la version « release ») ne voit pas ces appels et
# supprimait ou renommait ces classes : plantage au démarrage
# (NoSuchMethodError getAll, puis ClassNotFoundException CoroutineSingletons).
# On conserve donc tout ce que JNI peut atteindre ; le reste reste optimisé.
-keep class io.flutter.plugins.** { *; }
-keep class com.github.dart_lang.** { *; }
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
-keep class androidx.datastore.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**
