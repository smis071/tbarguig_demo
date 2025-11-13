import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  Locale _locale = const Locale('fr');
  bool _isDark = false;

  Locale get locale => _locale;
  bool get isDark => _isDark;

  AppProvider() {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final lang = sp.getString('lang') ?? 'fr';
    _locale = Locale(lang);
    _isDark = sp.getBool('isDark') ?? false;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString('lang', locale.languageCode);
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('isDark', _isDark);
  }

  Future<void> setTheme(bool dark) async {
    _isDark = dark;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('isDark', _isDark);
  }
}
