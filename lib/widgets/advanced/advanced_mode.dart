import 'package:caslf/services/application_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/theme/theme_utils.dart'
  show primary;
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
    final isAdvancedMode = context.select<ApplicationService, bool>(
      (service) => service.isAdvancedMode
    );

    final [
      useAlternativeChannels,
      switchSendOfNotificationOff
    ] = [
      (MessagesService service) => service.useAlternativeChannels,
      (MessagesService service) => service.isSendOfNotificationSwitchedOff
    ].map(context.select<MessagesService, bool>)
      .toList()
    ;

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
            if (!value) {
              await _toggleOffAdvancedSettings();
            }
          },
        ),
        Divider(color: primary),
        SwitchListTile(
          value: useAlternativeChannels,
          title: Text(
            tr(context)!.use_alternative_channels
          ),
          onChanged: isAdvancedMode
            ? (bool value) async {
              await MessagesService().toggleChannels();
            } : null,
        ),
        SwitchListTile(
          value: switchSendOfNotificationOff,
          title: Text(
            tr(context)!.switch_notification_send_off
          ),
          onChanged: isAdvancedMode
            ? (bool value) async {
              await MessagesService().toggleSwitchSendOfNotificationOff();
            } : null,
        )
      ],
    );
  }

  Future<void> _toggleOffAdvancedSettings() async {
    final MessagesService service = MessagesService();

    if (service.useAlternativeChannels) {
      await service.toggleChannels();
    }

    if (service.isSendOfNotificationSwitchedOff) {
      await service.toggleSwitchSendOfNotificationOff();
    }
  }
}