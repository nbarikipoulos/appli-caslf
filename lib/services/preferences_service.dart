import 'package:caslf/services/service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService with ChangeNotifier implements Service {
  PreferencesService._();

  static PreferencesService? _instance;
  factory PreferencesService() => _instance ??= PreferencesService._();

  ThemeMode _mode = ThemeMode.system;

  final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();
  final String _themePrefId = 'theme';

  ThemeMode get themeMode => _mode;
  set themeMode (ThemeMode value) {
    if (_mode != value) {
      _mode = value;
      // Async call, but awaiting result does not matter...
      _asyncPrefs.setString(_themePrefId, value.name);
      notifyListeners();
    }
  }

  @override
  Future<void> init() async {
    final String? theme = await _asyncPrefs.getString(_themePrefId);

    if (theme != null) {
      themeMode = ThemeMode.values.byName(theme);
    }
  }

  @override
  Future<void> clear() => Future.value();
}