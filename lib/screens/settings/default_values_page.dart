import 'package:caslf/services/preferences_service.dart';
import 'package:caslf/widgets/heading_item.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DefaultValuesPage extends StatefulWidget {
  const DefaultValuesPage({super.key});

  @override
  State<DefaultValuesPage> createState() => _DefaultValuesPageState();
}

class _DefaultValuesPageState extends State<DefaultValuesPage> {

  @override
  Widget build(BuildContext context) {
    final shouldConfirmDeletion = context.select<PreferencesService, bool>(
      (service) => service.confirmTimeSlotDeletion
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(
            tr(context)!.screen_default_title
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: HeadingItem(
                    title: tr(context)!.screen_default_time_slot_subtitle
                  ),
                ),
                SwitchListTile(
                  value: shouldConfirmDeletion,
                  title: Text(
                    tr(context)!.screen_default_confirm_deletion_title
                  ),
                  subtitle: Text(
                    tr(context)!.screen_default_confirm_deletion_subtitle
                  ),
                  onChanged: (bool value) async {
                    PreferencesService().confirmTimeSlotDeletion = value;
                  },
                ),
              ],
            ),
          ),
        )
    );
  }
}