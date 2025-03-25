import 'package:caslf/models/location/location.dart';
import 'package:caslf/services/service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService with ChangeNotifier implements Service {
  PreferencesService._();

  static PreferencesService? _instance;
  factory PreferencesService() => _instance ??= PreferencesService._();

  ThemeMode _mode = ThemeMode.system;
  bool _confirmTimeSlotDeletion = true;
  final _locationDurations = <Location, Duration>{};

  final _defaultDurationInMinutes = 120;

  final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();
  final String _themePrefId = 'theme';
  final String _confirmTimeSlotDeletionId = 'confirm_time_slot_deletion';
  String _getLocationDurationId(Location location) => [
    location.name,
    'duration'
  ].join('_');


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

  Duration getDefaultDurationFor(Location location) =>
    _locationDurations[location]!
  ;
  void setDefaultDurationFor(Location location, Duration value) {
    if ( // early exit
      value.compareTo(_locationDurations[location]!) == 0
    ) {
      return;
    }

    _locationDurations[location] = value;

    // No need to wait
    _asyncPrefs.setInt(
      _getLocationDurationId(location),
      value.inMinutes
    );

    notifyListeners();
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

    // Default duration for locations
    await Future.wait(
      Location.values.map((location) async {
        final id = _getLocationDurationId(location);
        int? value = await _asyncPrefs.getInt(id); // in minutes
        _locationDurations[location] = Duration(
          minutes: value ?? _defaultDurationInMinutes
        );
      }
    ));
  }

  @override
  Future<void> clear() {
    _locationDurations.clear();

    return Future.value();
  }
}