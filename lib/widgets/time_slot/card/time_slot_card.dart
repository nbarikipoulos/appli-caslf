import 'package:caslf/extensions/string_ext.dart';
import 'package:caslf/extensions/time_slot/time_slot_ext.dart';
import 'package:caslf/messages/time_slot_message.dart';
import 'package:caslf/models/message/message.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/router/app_router.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/preferences_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/theme/theme_utils.dart'
  show primary;
import 'package:caslf/utils/day_type.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/my_title.dart';
import 'package:caslf/widgets/time_slot/card/extra_details_part.dart';
import 'package:caslf/widgets/time_slot/card/header_part.dart';
import 'package:caslf/widgets/time_slot/time_slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef DeletionAnswer = ({
  bool perform,
  bool sendMessage,
});

class TimeSlotCard extends StatelessWidget implements TimeSlotWidget {
  final TimeSlot _timeSlot;

  const TimeSlotCard({
    super.key,
    required TimeSlot timeSlot
  }): _timeSlot = timeSlot;

  @override
  TimeSlot get timeSlot => _timeSlot;

  @override
  Widget build(BuildContext context) {
    final isAwaiting = timeSlot.status == TimeSlotStatus.awaiting;

    final location = timeSlot.location;
    final type = timeSlot.type;

    // Arf.....
    final dividerColor = isAwaiting
      ? Colors.orange
      : switch(type) {
        TimeSlotType.common => location.color,
        (_) => type.color
      }
    ;

    final isAnonymized = context.select<AdminService, bool>(
      (service) => AdminService().isAnonymized
    );

    return GestureDetector(
      onLongPressStart: (value) {
        if (_canBeDeleted || _canBeEdited) {
          _showMenu(context, value.globalPosition);
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                location.icon,
                color: location.color,
                size: 48
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    HeaderPart(
                      timeSlot: timeSlot,
                    ),
                    if (_showDetails) ...[
                      Divider(
                        color: dividerColor,
                        thickness: 2
                      ),
                      if (_displayMessage) MyTitle(title: timeSlot.message!),
                      if (_hasAttendees) MyTitle(
                        title: tr(context)!.attendees(timeSlot.numberOfUsers)
                      ),
                      if (!isAnonymized) ExtraDetailsPart(timeSlot: timeSlot)
                    ]
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool get _canBeEdited => GrantService.get().canEditTimeSlot(timeSlot);
  bool get _canBeDeleted => GrantService.get().canDeleteTimeSlot(timeSlot);

  bool get _displayMessage => timeSlot.type == TimeSlotType.common
    && timeSlot.message != null
  ;
  bool get _hasAttendees => timeSlot.hasAttendees;
  bool get _showExtraDetails => !AdminService().isAnonymized
    && (
      _hasAttendees
      || (
        timeSlot.ownerId != UserService().current.uid &&
        !timeSlot.isClub
      )
    )
  ;

  bool get _showDetails => _displayMessage
    || _hasAttendees
    || _showExtraDetails
  ;

  void _showMenu(BuildContext context, Offset offset) {
    final RenderObject overlay = Overlay.of(context)
      .context
      .findRenderObject()!
    ;

    showMenu(
      context: context,
      items: [
        if (_canBeEdited) PopupMenuItem(
          child: Row(children: [
            const Icon(Icons.edit),
            const SizedBox(width: 8),
            Text(tr(context)!.edit)
          ]),
          onTap: () => NavigationHelper()
            .router
            .goNamed(
              NavigationHelper().edit.name,
              extra: timeSlot
            )
        ),
        if (_canBeDeleted) PopupMenuItem(
          child: Row(children: [
            const Icon(Icons.delete_outlined),
            const SizedBox(width: 8),
            Text(tr(context)!.delete)
          ]),
          onTap: () => (
            PreferencesService().confirmTimeSlotDeletion
              ? _dialogBuilder(context)
              : Future.value((perform: true, sendMessage: true))
            ).then( (DeletionAnswer? answer) {
              answer ??= (perform:false, sendMessage:false);
              if (answer.perform) {
                TimeSlotService().delete(timeSlot);
                if (answer.sendMessage) {
                  Message message = TimeSlotMessageBuilder(
                    context: context,
                    timeSlot: _timeSlot
                  ).deleted();
                  MessagesService().send(message);
                }
              }
            })
        )
      ],
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          offset.dx,
          offset.dy,
          30,
          30
        ),
        Rect.fromLTWH(
          0,
          0,
          overlay.paintBounds.size.width,
          overlay.paintBounds.size.height
        )
      )
    );
  }

  Future<DeletionAnswer?> _dialogBuilder(BuildContext context) {
    final title = tr(context)!.time_slot_delete_dialog_title;

    final dayLabel = dayDateLabel(context, timeSlot.date).toCapitalized;
    final locationLabel = tr(context)!.location(timeSlot.location.name);
    final timeRange = timeRangeLabel(context, timeSlot);
    final typeLabel = tr(context)!.time_slot_type(timeSlot.type.name);

    final content = switch(timeSlot.type) {
      TimeSlotType.common => tr(context)!.time_slot_delete_common_dialog_content(
        dayLabel,
        locationLabel,
        timeRange
      ),
      (_) => tr(context)!.time_slot_delete_typed_dialog_content(
        dayLabel,
        (timeSlot.message ?? locationLabel),
        timeRange,
        typeLabel.toCapitalized
      )
    };

    return showDialog<DeletionAnswer>(
      context: context,
      builder: (BuildContext context) {
        bool sendMessage = true;
        return AlertDialog(
          title: Text(title, style: TextStyle(color: primary)),
          content: StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setState
          ) => Wrap(
            children: [
              ListTile(
                title: Text(content),
              ),
              CheckboxListTile(
                title: Text(
                  tr(context)!.time_slot_delete_dialog_send_message
                ),
                value: sendMessage,
                onChanged: (value) {
                  setState(() {
                    sendMessage = value ?? false;
                  });
                })
              ]
            )
          ),
          // Text(content),
          actions: [
            TextButton(
              child: Text(tr(context)!.cancel),
              onPressed: () {
                Navigator.pop(
                  context,
                  (perform: false, sendMessage: false)
                );
              }
            ),
            TextButton(
              child: Text(tr(context)!.delete),
              onPressed: () {
                Navigator.pop(
                  context,
                  (perform: true, sendMessage: sendMessage)
                );
              }
            )
          ]
        );
      }
    );
  }
}
