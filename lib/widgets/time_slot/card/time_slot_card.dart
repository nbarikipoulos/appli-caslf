import 'package:caslf/constants.dart';
import 'package:caslf/extensions/string_ext.dart';
import 'package:caslf/extensions/time_slot/time_slot_ext.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/router/app_router.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/preferences_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/theme/theme_utils.dart'
  show primary;
import 'package:caslf/utils/day_type.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/time_slot/card/details_part.dart';
import 'package:caslf/widgets/time_slot/card/header_part.dart';
import 'package:caslf/widgets/time_slot/card/sub/message.dart';
import 'package:caslf/widgets/time_slot/time_slot_widget.dart';
import 'package:flutter/material.dart';

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
    bool isAwaiting = timeSlot.status == TimeSlotStatus.awaiting;

    const awaitingColor = Colors.orange;

    // Arf.....
    final dividerColor = isAwaiting
      ? awaitingColor
      : switch(timeSlot.type) {
        TimeSlotType.common => timeSlot.location.color,
        (_) => timeSlot.type.color
      }
    ;

    TextStyle? msgTextStyle =
      timeSlot.type == TimeSlotType.event ||
      timeSlot.type == TimeSlotType.competition
      ? TextStyle(
        color: timeSlot.type.color,
        fontWeight: FontWeight.bold
      ) : null
    ;

    final locationIconColor = switch(timeSlot.type) {
      // TimeSlotType.closed => timeSlot.type.color,
      (_) => timeSlot.location.color
    };

    final showMessage = timeSlot.message != null;
    final showDetails = (
      timeSlot.ownerId != clubId
      && timeSlot.ownerId != UserService().current.uid
    ) || timeSlot.hasAttendees
      || timeSlot.status == TimeSlotStatus.accepted
    ;

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
                timeSlot.location.icon,
                color: locationIconColor,
                size: 48
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    HeaderPart(
                      timeSlot: timeSlot,
                      colorz: dividerColor
                    ),
                    if (showMessage || showDetails) Divider(
                      color: dividerColor,
                      thickness: 2
                    ),
                    if (showMessage) TimeSlotMessage(
                      message: timeSlot.message!,
                      style : msgTextStyle
                    ),
                    if (showDetails) DetailsPart(timeSlot: timeSlot)
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
              : Future.value(true)
            ).then( (bool? perform) {
              if (perform ?? false) {
                TimeSlotService().delete(timeSlot);
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

  Future<bool?> _dialogBuilder(BuildContext context) {
    final title = tr(context)!.time_slot_delete_dialog_title;

    final content = tr(context)!.time_slot_delete_dialog_content(
      dayDateLabel(context, timeSlot.date).toCapitalized,
      tr(context)!.location(timeSlot.location.name),
      timeRangeLabel(context, timeSlot)
    );

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title, style: TextStyle(color: primary)),
        content: Text(content),
        actions: [
          TextButton(
            child: Text(tr(context)!.cancel),
            onPressed: () {
              Navigator.pop(context, false);
            }
          ),
          TextButton(
            child: Text(tr(context)!.delete),
            onPressed: () {
              Navigator.pop(context, true);
            }
          )
         ]
      )
    );
  }
}