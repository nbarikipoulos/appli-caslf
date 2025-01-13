import 'package:caslf/firebase/firebase_options.dart';
import 'package:caslf/router/app_router.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/application_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/location_status_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/messaging/fcm_init_service.dart';
import 'package:caslf/services/preferences_service.dart';
import 'package:caslf/services/time_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/theme/theme_utils.dart';
import 'package:firebase_auth/firebase_auth.dart'
  hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting('fr_FR','en_EN').then((_) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );

    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    var logged = FirebaseAuth.instance.currentUser != null;
    var initialPath = logged
      ? '/timeSlots'
      : '/login'
    ;

    NavigationHelper.init(initialPath);
  }).then(
    (_) => runApp(const MyApp())
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApplicationService()),
        ChangeNotifierProvider(create: (_) => TimeService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => TimeSlotService()),
        ChangeNotifierProvider(create: (_) => LocationStatusService()),
        ChangeNotifierProvider(create: (_) => PreferencesService()),
        ChangeNotifierProvider(create: (_) => AdminService()),
        ChangeNotifierProvider(create: (_) => FcmInitService()),
        ChangeNotifierProvider(create: (_) => MessagesService()),
        ProxyProvider<AdminService, GrantService>(
          update: (_, adminService, grantService) => GrantService(
            adminService : adminService
          )
        )
      ],
      child: Builder(
        builder: (context) {
          return Selector<PreferencesService, ThemeMode>(
            selector: (_, preferences) => preferences.themeMode,
            builder: (_, themeMode, __) => MaterialApp.router(
              title: 'CASLF',
              theme: appTheme,
              darkTheme: appThemeDark,
              themeMode: themeMode, // system
              localizationsDelegates: [
                AppLocalizations.delegate,
                FirebaseUILocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates
              ],
              supportedLocales: const [
                Locale('fr')
              ],
              routerConfig: NavigationHelper().router
            )
          );
        }
      )
    );
  }

}
