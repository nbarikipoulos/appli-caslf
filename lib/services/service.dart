import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/application_service.dart';
import 'package:caslf/services/location_status_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/messaging/fcm_init_service.dart';
import 'package:caslf/services/preferences_service.dart';
import 'package:caslf/services/time_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';

abstract class Service {
  Future<void> init();

  Future<void> clear();
}

class ServicesHandler implements Service {
  ServicesHandler._();

  static ServicesHandler? _instance;

  factory ServicesHandler() => _instance ??= ServicesHandler._();

  bool _initialized = false;

  bool get hasBeenInitialised => _initialized;

  @override
  Future<void> init() async {
    if (_initialized) { // Early exit
      return;
    }

    await ApplicationService().init();
    await TimeService().init();
    await PreferencesService().init();
    await LocationStatusService().init();
    await UserService().init();
    await AdminService().init();
    await FcmInitService().init();
    await MessagesService().init();
    await TimeSlotService().init();

    _initialized = true;
  }

  @override
  Future<void> clear() async {
    await FcmInitService().clear();
    await MessagesService().clear();
    await TimeSlotService().clear();
    await AdminService().clear();
    await LocationStatusService().clear();
    await PreferencesService().clear();
    await UserService().clear();
    await TimeService().clear();
    await ApplicationService().clear();

    _initialized = false;
  }
}