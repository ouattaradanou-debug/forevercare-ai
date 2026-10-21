# Classes appelées depuis Dart par leur nom (JNI) : R8 ne doit ni les
# supprimer ni renommer leurs méthodes, sinon l'application plante au
# démarrage en version « release » (NoSuchMethodError sur getAll).
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.github.dart_lang.jni.** { *; }
-keep class kotlin.coroutines.Continuation { *; }
