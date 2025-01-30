import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/message/channel.dart';
import 'package:caslf/models/message/channel_type.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/messaging/fcm_init_service.dart';
import 'package:caslf/utils/string_utils.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    context.select<MessagesService, bool>(
      (service) => service.useAlternativeChannels
    );

    bool isNotificationGranted = context.select<FcmInitService, bool>(
      (service) => service.isNotificationGranted
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(
              tr(context)!.screen_notification_title
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: isNotificationGranted
                ? _channels(context)
                : _askForRight(context)
            ),
          ),
        )
    );
  }

  // Permissions must be ask next to a user's action on ios devices
  List<Widget> _askForRight(BuildContext context) {
    return [
      OutlinedButton(
        onPressed: () async {
          final service = FcmInitService();

          // Init fcm
          await service.perform();
          // Init channels
          if (service.isNotificationGranted) {
            await MessagesService().initSubscriptions(true);
          }
        },
        child: Text(
          tr(context)!.screen_notification_allow_notifications
        )
      )
    ];
  }

  List<Widget> _channels(BuildContext context) {
    final channels = MessagesService().getAllowedChannels();

    // FIXME To improve...

    final Map<Location, List<Channel>> locations = {
      for (var location in Location.values)
        location : channels.where((channel) => channel.location == location).toList()
    };

    // News
    final news = channels.firstWhere((channel) => channel.type == ChannelType.news);

    return [
     ...locations.entries
       .map((entry) => createGroup(
         context,
         entry.value,
         groupTitle(
           entry.key.icon,
           tr(context)!.location(entry.key.name),
           entry.key.color
         )
       )).toList(),
       createGroup(
         context,
         [news],
         groupTitle(
           Icons.message,
           tr(context)!.news,
           Colors.amber
         )
       )
     ];
  }

  Widget groupTitle(IconData icon, String title, Color color) => ListTile(
    titleTextStyle: Theme.of(context).textTheme.headlineSmall,
    leading: Icon(icon),
    iconColor: color,
    title: Text(
      title.toCapitalized,
      style: TextStyle(color: color),
    )
  );

  Widget createGroup(
    BuildContext context,
    List<Channel> channels,
    Widget title
  ) => Card(
    child: Column(
      children: [
        title,
        ...channels.map((channel) => Selector<MessagesService, bool?>(
          selector: (_, service) => service.getSubscribingFor(channel),
          builder: (context, value, __) => SwitchListTile(
            title: Text(
              getLabel(context, channel.type).toCapitalized
            ),
            // If value is null => grants have not been allowed.
            // Anyway, everything should be greyed...
            value: MessagesService().getSubscribingFor(channel) ?? false,
            onChanged: (bool value) {
              MessagesService().setSubscribingFor(channel, value);
            },
            secondary: Icon(
              channel.type.icon,
              color: Theme.of(context).textTheme.titleLarge?.color
            )
          )
        )
      ).toList()
    ]
  )
);

  // FIXME Arf.....
  String getLabel(BuildContext context, ChannelType type) {
    return switch(type) {
      ChannelType.newSlot => tr(context)!.screen_notification_new_slot,
      ChannelType.openClose => tr(context)!.screen_notification_open_close,
      ChannelType.askFor => tr(context)!.screen_notification_ask_for,
      ChannelType.news => tr(context)!.screen_notification_news,
    };
  }  
  
}
