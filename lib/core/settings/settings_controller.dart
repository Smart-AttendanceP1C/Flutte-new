import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local app preferences: theme mode + language. Persisted on device.
/// No backend dependency.
class SettingsController extends ChangeNotifier {
  static const _kTheme = 'sa.theme';
  static const _kLang = 'sa.lang';

  final SharedPreferences _prefs;
  SettingsController(this._prefs);

  ThemeMode get themeMode {
    switch (_prefs.getString(_kTheme)) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String get themeChoice => _prefs.getString(_kTheme) ?? 'system';

  Future<void> setTheme(String choice) async {
    await _prefs.setString(_kTheme, choice);
    notifyListeners();
  }

  Locale get locale {
    final code = _prefs.getString(_kLang) ?? 'en';
    return Locale(code);
  }

  String get languageCode => _prefs.getString(_kLang) ?? 'en';

  Future<void> setLanguage(String code) async {
    await _prefs.setString(_kLang, code);
    notifyListeners();
  }
}
