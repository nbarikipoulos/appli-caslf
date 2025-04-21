import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/user/user_data.dart';
import 'package:caslf/models/user/user_type.dart';
import 'package:caslf/services/service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/utils/string_utils.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserData user = UserService().current;
  late final UserType type = user.grant!.type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            tr(context)!.screen_user_title
          ),
        ),
        body: SafeArea(
          child: Align(
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.start,
            child:
              ProfileScreen(
                showDeleteConfirmationDialog: true,
                providers: const [],
                actions: [
                  DisplayNameChangedAction( (_, __, newName) async {
                    await UserService().updateDisplayName(newName.trim());
                  }),
                  SignedOutAction((context) async {
                    await ServicesHandler().clear();
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      context.goNamed('login');
                    }
                  }),
                ],
                children: [
                  Text(
                      tr(context)!.screen_user_type_label,
                  ),
                  ListTile(
                    leading: Icon(
                      type.icon,
                      color: type.color
                    ),
                    title: Text(
                      tr(context)!.user_type(type.name),
                    ),
                  ),
                  Text(
                    tr(context)!.screen_user_canOpen_label,
                  ),
                  access(context)
                ]
              ),
          ),
        )
    );
  }

  Widget access(BuildContext context) {
    // prefix with 'le' in french... arf..., to fix.
    String f(Location location) => tr(context)!.screen_user_type_dummy_the
      .append(
        tr(context)!.location(location.name),
        separator: ' '
      )
    ;

    return Column(
        children: Location.helper.values.map((location) {
          return ListTile(
            leading: Icon(
              location.icon,
              color: location.color,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  f(location)
                ),
                user.hasAccessTo(location) ? iconOk : iconNotOk
              ],
            )
          );
        }).toList()
    );
  }

}