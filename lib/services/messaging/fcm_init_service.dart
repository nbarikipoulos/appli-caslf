import 'package:caslf/services/messaging/messaging_utils.dart';
import 'package:caslf/services/application_service.dart';
import 'package:caslf/services/service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmInitService extends ChangeNotifier implements Service {
  FcmInitService._();

  static FcmInitService? _instance;

  factory FcmInitService() => _instance ??= FcmInitService._();

  bool get initializationDone => _initialized;
  bool get isNotificationGranted =>
    _authForMessaging == AuthorizationStatus.authorized
  ;

  AuthorizationStatus get getAuthorizationStatus => _authForMessaging;

  bool get hasBeenSetByUser =>
    _authForMessaging == AuthorizationStatus.authorized
    || _authForMessaging == AuthorizationStatus.denied
  ;

  String? get fcmToken => _fcmToken;

  final _messaging = FirebaseMessaging.instance;
  AuthorizationStatus _authForMessaging = AuthorizationStatus.notDetermined;

  // For web case
  String? _fcmToken;

  bool _initialized = false;

  final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();
  final String _authAlreadyDoneAndOkId = 'auth_notif_granted';

  Future<AuthorizationStatus> getPermission() => _messaging
    .getNotificationSettings()
    .then((permission) => permission.authorizationStatus)
  ;

  Future<AuthorizationStatus> requestPermission() => _messaging
    .requestPermission(provisional: false)
    .then((permission) => permission.authorizationStatus)
  ;

  Future initNotification() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    return setupFlutterNotifications();
  }

  Future setFcmToken() async {
    if (kIsWeb) {
      _fcmToken = await _messaging.getToken();
    }
  }

  Future perform() async {
    bool alreadyDone =
      await _asyncPrefs.getBool(_authAlreadyDoneAndOkId) ?? false
    ;

    if (
      ApplicationService().isWepAppOnIOS
      && alreadyDone
    ) {
      _authForMessaging = await getPermission();
    } else {
      _authForMessaging = await requestPermission();
    }

    if (_authForMessaging == AuthorizationStatus.authorized) {
      await initNotification();
      await setFcmToken();
      await _asyncPrefs.setBool(_authAlreadyDoneAndOkId, true);
      _initialized = true;
      notifyListeners();
    } else {
      await _asyncPrefs.setBool(_authAlreadyDoneAndOkId, false);
    }
  }

  @override
  Future init() async {
    // _authForMessaging = await getPermission();

    //
    // Early exits
    //

    // auth has been already set by user
    if (hasBeenSetByUser) {
      return;
    }

    bool authOK = await _asyncPrefs.getBool(_authAlreadyDoneAndOkId) ?? false;

    // iOS need action from users => initialization delayed
    if (!authOK && ApplicationService().isWepAppOnIOS) {
      return;
    }

    //
    // Main job
    //

    await perform();

  }

  @override
  Future<void> clear() async {
    // Do nothing
  }

}