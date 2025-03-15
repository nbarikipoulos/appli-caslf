import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/screens/auth/login_page.dart';
import 'package:caslf/screens/auth/reset_password_page.dart';
import 'package:caslf/screens/new_time_slot/create_time_slot_page.dart';
import 'package:caslf/screens/nav_bar_page.dart';
import 'package:caslf/screens/new_time_slot/quick_create_open_time_slot_page.dart';
import 'package:caslf/screens/news_page.dart';
import 'package:caslf/screens/settings/about_page.dart';
import 'package:caslf/screens/settings/admin_page.dart';
import 'package:caslf/screens/settings/appearance_page.dart';
import 'package:caslf/screens/settings/default_values_page.dart';
import 'package:caslf/screens/settings/notifications_page.dart';
import 'package:caslf/screens/settings/user_page.dart';
import 'package:caslf/screens/settings_page.dart';
import 'package:caslf/screens/time_slots_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {
  NavigationHelper._({required this.initialLocationPath});

  static NavigationHelper? _instance;

  factory NavigationHelper.init(String initialPath) =>
    _instance ??= NavigationHelper._(initialLocationPath: initialPath);

  factory NavigationHelper() => _instance!;

  GoRouter? _router;
  GoRouter get router => _router ??= _initRouter();

  final String initialLocationPath;

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _timeSlotsNavigatorKey = GlobalKey<NavigatorState>();
  final _infoNavigatorKey = GlobalKey<NavigatorState>();
  final _settingsNavigatorKey = GlobalKey<NavigatorState>();

  final login = (path: '/login', name: 'login');
  final resetPassword = (path: '/reset-password', name: 'reset-password');

  final timeSlots = (path: '/timeSlots', name: 'timeSlots');
  final add = (path: 'add', name: 'add');
  final edit = (path: 'edit', name: 'edit');
  final addAndOpen = (path: 'addAndOpen', name: 'addAndOpen');

  final news = (path: '/news', name: 'news');
  final settings = (path: '/settings', name: 'settings');

  final ui = (path: 'ui', name: 'ui');
  final user = (path: 'user', name: 'user');
  final notifications = (path: 'notifications', name: 'notifications');
  final defaults = (path: 'defaults', name: 'defaults');
  final admin = (path: 'admin', name: 'admin');
  final about = (path: 'about', name: 'about');

  _initRouter() => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocationPath,
    routes: [
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: login.path,
        name: login.name,
        pageBuilder: (context, state) => getPage(
          child: const LoginPage(),
          state: state
        )
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: resetPassword.path,
        name: resetPassword.name,
        pageBuilder: (context, state) => getPage(
          child: ResetPasswordPage(
            email: state.uri.queryParameters['email']
          ),
          state: state
        )
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => NavBarPage(
          navigationShell: navigationShell
        ),
        branches: [
          // The route branch for the TimeSlots page
          StatefulShellBranch(
            navigatorKey: _timeSlotsNavigatorKey,
            routes: [
              GoRoute(
                path: timeSlots.path,
                name: timeSlots.name,
                pageBuilder: (context, state) => getPage(
                  child: const TimeSlotsPage(),
                  state: state
                ),
                routes: [
                  GoRoute(
                    path: add.path,
                    name: add.name,
                      pageBuilder: (context, state) => getPage(
                      child: const CreateTimeSlotPage(),
                      state: state
                    )
                  ),
                  GoRoute(
                    path: edit.path,
                    name: edit.name,
                    pageBuilder: (context, state) {
                      TimeSlot timeSlot = state.extra as TimeSlot;
                      return getPage(
                        child: CreateTimeSlotPage(timeSlot: timeSlot),
                        state: state
                      );
                    }
                  ),
                  GoRoute(
                    path: addAndOpen.path,
                    name: addAndOpen.name,
                    pageBuilder: (context, state) => getPage(
                      child: const QuickCreateOpenTimeSlotPage(),
                      state: state
                    )
                  ),
                ]
              )
            ],
          ),
          // The route branch for the info page
          StatefulShellBranch(
            navigatorKey: _infoNavigatorKey,
            routes: [
              GoRoute(
                path: news.path,
                name: news.name,
                pageBuilder: (context, state) => getPage(
                  child: const NewsPage(),
                  state: state
                )
              )
            ],
          ),
          // The route branch for the settings page
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: settings.path,
                name: settings.name,
                pageBuilder: (context, state) => getPage(
                  child: SettingsPage(),
                  state: state
                ),
                routes: [
                  GoRoute(
                    path: ui.path,
                    name: ui.name,
                    pageBuilder: (context, state) => getPage(
                      child: const AppearancePage(),
                      state: state
                    )
                  ),
                  GoRoute(
                    path: user.path,
                    name: user.name,
                    pageBuilder: (context, state) => getPage(
                      child: const UserPage(),
                      state: state
                    )
                  ),
                  GoRoute(
                    path: notifications.path,
                    name: notifications.name,
                    pageBuilder: (context, state) => getPage(
                      child: const NotificationsPage(),
                      state: state
                    )
                  ),
                  GoRoute(
                    path: defaults.path,
                    name: defaults.name,
                    pageBuilder: (context, state) => getPage(
                      child: const DefaultValuesPage(),
                      state: state
                    )
                  ),
                  GoRoute(
                    path: admin.path,
                    name: admin.name,
                    pageBuilder: (context, state) => getPage(
                      child: const AdminPage(),
                      state: state
                    )
                  ),
                  GoRoute(
                      path: about.path,
                      name: about.name,
                      pageBuilder: (context, state) => getPage(
                          child: const AboutPage(),
                          state: state
                      )
                  )
                ]
              )
            ]
          )
        ],
      ),
    ],
  );

  Page getPage({
    required Widget child,
    required GoRouterState state
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child
    );
  }

}
