import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _cleThemePrefs = 'theme_mode';

/// Mode de thème choisi par l'utilisateur (clair, sombre ou système),
/// persisté localement — préférence d'affichage personnelle, indépendante
/// du compte et donc jamais synchronisée avec Supabase.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _charger();
    return ThemeMode.system;
  }

  Future<void> _charger() async {
    final prefs = await SharedPreferences.getInstance();
    final valeur = prefs.getString(_cleThemePrefs);
    state = _depuisTexte(valeur);
  }

  Future<void> definir(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleThemePrefs, mode.name);
  }

  ThemeMode _depuisTexte(String? valeur) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == valeur,
      orElse: () => ThemeMode.system,
    );
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
