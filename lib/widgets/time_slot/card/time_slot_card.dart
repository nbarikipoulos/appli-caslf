import 'package:caslf/constants.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/time_slot/card/details_part.dart';
import 'package:caslf/widgets/time_slot/card/header_part.dart';
import 'package:caslf/widgets/time_slot/card/message.dart';
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

    TextStyle? msgTextStyle = timeSlot.type == TimeSlotType.event
      ? TextStyle(
        color: TimeSlotType.event.color,
        fontWeight: FontWeight.bold
      ) : null
    ;

    final locationIconColor = switch(timeSlot.type) {
      // TimeSlotType.closed => timeSlot.type.color,
      (_) => timeSlot.location.color
    };

    final showMessage = timeSlot.message != null;
    final showDetails = timeSlot.ownerId != clubId;

    return GestureDetector(
      onLongPressStart: (value) {
        if (_canBeDeleted()) {
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

  bool _canBeDeleted() => GrantService(
    adminService: AdminService()
  ).canDeleteTimeSlot(timeSlot);

  void _showMenu(BuildContext context, Offset offset) {
    final RenderObject overlay = Overlay.of(context)
      .context
      .findRenderObject()!
    ;

    showMenu(
      context: context,
      items: [
        PopupMenuItem(
          child: Row(children: [
            const Icon(Icons.delete_outlined),
            const SizedBox(width: 8),
            Text(tr(context)!.delete)
          ]),
          onTap: () => TimeSlotService().delete(timeSlot),
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

}