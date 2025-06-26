import 'package:caslf/extensions/string_ext.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/message/channel.dart';
import 'package:caslf/models/message/channel_type.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/messaging/fcm_init_service.dart';
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

    final locations = Location.helper.values
      .where((location) => location != Location.external)
    ;

    final Map<Location, List<Channel>> channelForLocations = {
      for (var location in locations)
        location : channels.where(
          (channel) => channel.location == location
        ).toList()
    };

    // News
    f(ChannelType type) => channels
      .firstWhere((channel) => channel.type == type)
    ;

    //final news = channels.firstWhere((channel) => channel.type == ChannelType.news);

    return [
     ...channelForLocations.entries
       .map((entry) => createGroup(
         context,
         entry.value,
         groupTitle(
           entry.key.icon,
           tr(context)!.location(entry.key.name),
           entry.key.color
         )
       )),
       createGroup(
         context,
         [f(ChannelType.event)],
         groupTitle(
           TimeSlotType.event.icon,
           tr(context)!.time_slot_type(TimeSlotType.event.name),
           TimeSlotType.event.color
         )
       ),
       createGroup(
         context,
         [f(ChannelType.competition)],
         groupTitle(
           TimeSlotType.competition.icon,
           tr(context)!.time_slot_type(TimeSlotType.competition.name),
           TimeSlotType.competition.color
         )
       ),
       createGroup(
         context,
         [f(ChannelType.news)],
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
              getLabel(context, channel).toCapitalized
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
      )
    ]
  )
);

  // FIXME Arf.....
  String getLabel(
    BuildContext context,
    Channel channel
  ) => switch(channel.type) {
    ChannelType.newSlot => tr(context)!.screen_notification_new_slot,
    ChannelType.openClose => tr(context)!.screen_notification_open_close,
    ChannelType.askFor => tr(context)!.screen_notification_ask_for,
    ChannelType.news => tr(context)!.screen_notification_news,
    ChannelType.event => tr(context)!.screen_notification_event,
    ChannelType.competition => tr(context)!.screen_notification_competition,
  };
}
