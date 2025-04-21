import 'package:caslf/models/location/location.dart';
import 'package:caslf/services/preferences_service.dart';
import 'package:caslf/utils/string_utils.dart';
import 'package:caslf/widgets/heading_item.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/time/duration_form_field.dart';
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
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: HeadingItem(
                  title: tr(context)!.screen_default_time_slot_subtitle
                ),
              ),
              Text(
                tr(context)!.screen_default_duration_subtitle
              ),
              ...Location.helper.values.map(
                (location) => _duration(context, location)
              ),
              Text(
                tr(context)!.misc.toCapitalized
              ),
              _confirmDeletion(context, shouldConfirmDeletion)
            ],
          )
        ),
      ),
    );
  }

  Widget _confirmDeletion(
    BuildContext context,
    bool value,
  ) => SwitchListTile(
    value: value,
    title: Text(
      tr(context)!.screen_default_confirm_deletion_title
    ),
    subtitle: Text(
      tr(context)!.screen_default_confirm_deletion_subtitle
    ),
    onChanged: (bool value) async {
      PreferencesService().confirmTimeSlotDeletion = value;
    },
  );

  Widget _duration(
    BuildContext context,
    Location location
  ) => Padding(
    padding: const EdgeInsets.only(left: 16.0),
    child: DurationFormField(
      initialDuration: PreferencesService().getDefaultDurationFor(location),
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        labelText: tr(context)!.location(location.name),
        prefixIcon: Icon(
          location.icon,
          color: location.color,
          size: 36
        )
      ),
      onChanged: (Duration value) {
        PreferencesService().setDefaultDurationFor(location, value);
      },
      validator: (value) {
        if (value!.inMinutes == 0) {
          return tr(context)!.duration_is_zero;
        }
        return null;
      }
    ),
  );

}