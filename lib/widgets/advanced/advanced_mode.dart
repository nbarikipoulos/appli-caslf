import 'package:caslf/services/application_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdvancedMode extends StatefulWidget {
  const AdvancedMode({super.key});

  @override
  State<AdvancedMode> createState() => _AdvancedModeState();
}

class _AdvancedModeState extends State<AdvancedMode> {

  @override
  Widget build(BuildContext context) {
    bool isAdvancedMode = context.select<ApplicationService, bool>(
      (service) => service.isAdvancedMode
    );

    bool useAlternativeChannels = context.select<MessagesService, bool>(
        (service) => service.useAlternativeChannels
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SwitchListTile(
          value: isAdvancedMode,
          title: Text(
            tr(context)!.advanced_mode_activate
          ),
          onChanged: (bool value) async {
            ApplicationService().isAdvancedMode = value;
            if (!value && MessagesService().useAlternativeChannels) {
              await MessagesService().toggleChannels();
            }
          },
        ),
        SwitchListTile(
          value: useAlternativeChannels,
          title: Text(
            tr(context)!.use_alternative_channels
          ),
          onChanged: isAdvancedMode
              ? (bool value) async {
                await MessagesService().toggleChannels();
              } : null,
        )
      ],
    );
  }
}