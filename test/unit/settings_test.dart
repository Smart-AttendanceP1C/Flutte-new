import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verishift_app/core/l10n/app_strings.dart';
import 'package:verishift_app/core/settings/settings_controller.dart';

void main() {
  test('theme choice persists and maps to ThemeMode', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final s = SettingsController(prefs);
    expect(s.themeMode, ThemeMode.system);
    await s.setTheme('dark');
    expect(s.themeMode, ThemeMode.dark);
    final s2 = SettingsController(prefs);
    expect(s2.themeMode, ThemeMode.dark);
    await s2.setTheme('light');
    expect(s2.themeMode, ThemeMode.light);
  });

  test('language persists and switches locale', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final s = SettingsController(prefs);
    expect(s.locale, const Locale('en'));
    await s.setLanguage('ar');
    expect(s.locale, const Locale('ar'));
    final s2 = SettingsController(prefs);
    expect(s2.languageCode, 'ar');
  });

  test('delegate supports en + ar only', () {
    const d = AppLocalizationsDelegate();
    expect(d.isSupported(const Locale('en')), isTrue);
    expect(d.isSupported(const Locale('ar')), isTrue);
    expect(d.isSupported(const Locale('fr')), isFalse);
  });
}
