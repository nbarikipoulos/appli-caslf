import 'package:caslf/router/app_router.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

final router = NavigationHelper().router;

typedef PrefEntry = ({
  String labelKey,
  IconData icon,
  Color? color,
  String route
});

final Map<String, PrefEntry> prefEntries = {
  'appearance': (
    labelKey: 'screen_settings_item_appearance',
    icon: Icons.crop_original,
    color: null,
    route: NavigationHelper().ui.name
   ),
   'user': (
     labelKey: 'screen_settings_item_user',
     icon: Icons.person,
     color: Colors.indigoAccent,
     route: NavigationHelper().user.name
  ),
  'notifications': (
    labelKey: 'screen_settings_item_notification',
    icon: Icons.notifications_active,
    color: Colors.amber,
    route: NavigationHelper().notifications.name
  ),
  'defaults': (
    labelKey: 'screen_settings_item_default',
    icon: Icons.numbers,
    color: null,
    route: NavigationHelper().defaults.name
  ),
  'admin': (
    labelKey: 'screen_settings_item_admin',
    icon: Icons.engineering,
    color: Colors.red,
    route: NavigationHelper().admin.name
  ),
  'about': (
    labelKey: 'screen_settings_item_about',
    icon: Icons.info,
    color: null,
    route: NavigationHelper().about.name
  )
};

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final user = UserService().current;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 8, top:8),
        child :Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getGroups().map(
            (group) => _createGroup(context, group)
          ).toList(),
        )
      )
    )
  )
;

  Iterable<List<String>> _getGroups() => [
    ['user'],
    ['appearance' /*, 'defaults' */],
    ['notifications'],
    user.grant!.isAdmin ? ['admin'] : null,
    ['about']
  ].nonNulls;

  Widget _createGroup(BuildContext context, List<String> entries) {
    var prefs = entries.map((entry) => prefEntries[entry]!);

    return Card(
        child: Column(
          children: prefs.map((elt) => InkWell(
            onTap: () { router.goNamed(elt.route); },
            child: ListTile(
              leading: Icon(elt.icon),
              iconColor: elt.color,
              title: Text(
                _getLabel(context, elt.labelKey)
              )
            ),
          )).toList()
        )
    );
  }

  // FIXME Arf.....
  String _getLabel(BuildContext context, String key) {
    return switch(key) {
      'screen_settings_item_user' => tr(context)!.screen_settings_item_user,
      'screen_settings_item_appearance' => tr(context)!.screen_settings_item_appearance,
      'screen_settings_item_notification' => tr(context)!.screen_settings_item_notification,
      'screen_settings_item_default' => tr(context)!.screen_settings_item_default,
      'screen_settings_item_admin' => tr(context)!.screen_settings_item_admin,
      'screen_settings_item_about' => tr(context)!.screen_settings_item_about,
      String() => '---',
    };
  }

}


