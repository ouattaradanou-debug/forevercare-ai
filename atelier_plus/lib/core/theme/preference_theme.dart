import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _cleTheme = 'theme_mode';

/// Persiste le thème choisi (clair/sombre/système) — même mécanisme que
/// [PreferenceRappelNotifier] pour le délai de rappel.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _charger();
    return ThemeMode.system;
  }

  Future<void> _charger() async {
    final prefs = await SharedPreferences.getInstance();
    final valeur = prefs.getString(_cleTheme);
    state = ThemeMode.values.firstWhere(
      (m) => m.name == valeur,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> definir(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleTheme, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
