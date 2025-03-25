import 'package:caslf/services/service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService with ChangeNotifier implements Service {
  PreferencesService._();

  static PreferencesService? _instance;
  factory PreferencesService() => _instance ??= PreferencesService._();

  ThemeMode _mode = ThemeMode.system;
  bool _confirmTimeSlotDeletion = true;

  final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();
  final String _themePrefId = 'theme';
  final String _confirmTimeSlotDeletionId = 'confirm_time_slot_deletion';

  ThemeMode get themeMode => _mode;
  set themeMode (ThemeMode value) {
    if (_mode != value) {
      _mode = value;
      // Async call, but awaiting result does not matter...
      _asyncPrefs.setString(_themePrefId, value.name);
      notifyListeners();
    }
  }

  bool get confirmTimeSlotDeletion => _confirmTimeSlotDeletion;
  set confirmTimeSlotDeletion(bool value) {
    if (_confirmTimeSlotDeletion != value) {
      _confirmTimeSlotDeletion = value;
      // Async call, but awaiting result does not matter...
      _asyncPrefs.setBool(_confirmTimeSlotDeletionId, value);
      notifyListeners();
    }
  }

  @override
  Future<void> init() async {
    // Theme
    final String? theme = await _asyncPrefs.getString(_themePrefId);
    if (theme != null) {
      themeMode = ThemeMode.values.byName(theme);
    }

    // Should confirm the deletion of timeSlot
    final bool? shouldConfirmDeletion = await
      _asyncPrefs.getBool(_confirmTimeSlotDeletionId)
    ;
    if (shouldConfirmDeletion != null) {
      confirmTimeSlotDeletion = shouldConfirmDeletion;
    }

  }

  @override
  Future<void> clear() => Future.value();
}