import 'package:caslf/extensions/time_of_day_ext.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_extra.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/my_title.dart';
import 'package:caslf/widgets/time_slot/card/sub/attendance.dart';
import 'package:flutter/material.dart';

class HeaderPart extends StatelessWidget {
  final TimeSlot timeSlot;

  const HeaderPart({
    super.key,
    required this.timeSlot,
  });

  @override
  Widget build(BuildContext context) {
    // Awaiting
    final isAwaiting = timeSlot.status == TimeSlotStatus.awaiting;

    // Type
    final type = timeSlot.type;

    // should content be highlighted ?
    final isHighlighted = switch(type) {
      TimeSlotType.event ||
      TimeSlotType.competition => true,
      (_) => false
    };

    final contentLabelStyle = isHighlighted
      ? TextStyle(
        color: type.color,
        fontWeight: FontWeight.bold
      ) : null
    ;

    // Color of icons
    final color = isAwaiting
      ? Colors.orange
      : switch(type) {
        TimeSlotType.common => timeSlot.location.color,
        (_) => type.color
      }
    ;

    // Type and comment, if any (excepted for common timeSlot)
    final displayType = type != TimeSlotType.common;

    final typeLabel = timeSlot.message
      ?? tr(context)!.time_slot_type(type.name)
    ;

    final user = UserService().current;

    final showAttendeeButton = timeSlot.ownerId != user.uid
      && GrantService.get().canJoinTimeSlot(timeSlot)
      && ( // First, only for maintenance and 'casual' timeslots
        type == TimeSlotType.maintenance
        || timeSlot.hasExtra(TimeSlotExtra.casual)
      )
    ;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTitle( // Schedule
              title: _timeLabel(context),
              style: contentLabelStyle,
              icon: scheduleIcon, //icon,
              color: color,
              position: Position.start,
            ),
            if (isAwaiting) MyTitle(
              title: tr(context)!.time_slot_status(TimeSlotStatus.awaiting.name),
              icon: Icons.question_mark, //icon,
              color: color,
              position: Position.start,
            ),
            if (displayType) MyTitle(
              title: typeLabel,
              style: contentLabelStyle,
              icon: type.icon,
              color: color,
              position: Position.start,
            ),
            if (timeSlot.location == Location.external) MyTitle(
              title: timeSlot.where!,
              style: contentLabelStyle,
              icon: Icons.gps_fixed, //icon,
              color: color,
              position: Position.start,
            )
          ]
        ),
        if (showAttendeeButton) Attendance(
          timeSlot: timeSlot,
          userId: UserService().current.uid
        )
      ],
    );
  }

  IconData get scheduleIcon => GrantService.get().canEditTimeSlot(timeSlot)
    ? Icons.access_time_filled
    : Icons.schedule
  ;

  String _timeLabel(BuildContext context) {
    String result;
    if (timeSlot.isAllDay) {
      result = tr(context)!.all_day;
    } else {
      final [start, end] = [
        timeSlot.date,
        timeSlot.end
      ].map((date) => TimeOfDay
        .fromDateTime(date)
        .toHHMM()
      ).toList();

      result = tr(context)!.time_slot_from_to(start, end);
    }

    return result;
  }
}