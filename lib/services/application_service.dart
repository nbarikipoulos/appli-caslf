import 'dart:async';
import 'package:caslf/services/service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart'
  hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationService extends ChangeNotifier implements Service {
  ApplicationService._();

  static ApplicationService? _instance;
  factory ApplicationService() => _instance ??= ApplicationService._();

  bool get loggedIn => _loggedIn;
  bool get isWeb => kIsWeb;
  bool get isWebOnIOS => _isWebOnIOS!;

  bool get isAdvancedMode => _isAdvancedMode!;

  set isAdvancedMode(bool value) {
    if (_isAdvancedMode != value) {
      _isAdvancedMode = value;
      // Async call, but awaiting result does not matter...
      _asyncPrefs.setBool(_advancedModePrefId, value);
      notifyListeners();
    }
  }

  bool _loggedIn = false;
  bool? _isWebOnIOS;
  bool? _isAdvancedMode;

  final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();
  final String _advancedModePrefId = 'advancedMode';

  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _userLoggedSubscription;

  @override
  Future init() async {
    if (kIsWeb) {
      // Web app on iOS app case...
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      final platform = deviceInfo.data['platform'].toLowerCase();

      _isWebOnIOS =
        platform == 'iphone' ||
        platform == 'ipad' ||
        platform == 'ios'
      ;
    } else {
      _isWebOnIOS = false;
    }

    _isAdvancedMode = await _asyncPrefs.getBool(_advancedModePrefId);
    _isAdvancedMode ??= false;

    _userLoggedSubscription = _auth.userChanges().listen((user) async {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }

  @override
  Future clear() => _userLoggedSubscription!.cancel();
}
