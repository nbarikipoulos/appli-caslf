import 'package:caslf/extensions/time_of_day_ext.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_extra.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/my_title.dart';
import 'package:caslf/widgets/time_slot/card/sub/attendance.dart';
import 'package:flutter/material.dart';

class HeaderPart extends StatelessWidget {
  final TimeSlot timeSlot;
  final Color? colorz;

  const HeaderPart({
    super.key,
    required this.timeSlot,
    this.colorz
  });

  @override
  Widget build(BuildContext context) {
    final isAwaiting = timeSlot.status == TimeSlotStatus.awaiting;

    final IconData? icon = isAwaiting
      ? Icons.question_mark
      : switch(timeSlot.type) {
        TimeSlotType.common => null,
        (_) => timeSlot.type.icon
      }
    ;

    final hasExtraInfo = icon != null;
    final String extraLabel = isAwaiting
      ? tr(context)!.time_slot_status(TimeSlotStatus.awaiting.name)
      : tr(context)!.time_slot_type(timeSlot.type.name)
    ;

    final user = UserService().current;

    final showAttendeeButton = timeSlot.ownerId != user.uid
      && GrantService(adminService: AdminService()).canJoinTimeSlot(timeSlot)
      && ( // First, only for maintenance and 'casual' timeslots
        timeSlot.type == TimeSlotType.maintenance
        || timeSlot.hasExtra(TimeSlotExtra.casual)
      )
    ;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTitle(
              title: _timeLabel(context),
              icon: Icons.schedule, //icon,
              color: colorz,
              position: Position.start,
            ),
            if (timeSlot.location == Location.external) MyTitle(
              title: timeSlot.where!,
              icon: Icons.language, //icon,
              color: colorz,
              position: Position.start,
            ),
            if (hasExtraInfo) MyTitle(
              title: extraLabel,
              icon: icon,
              color: colorz,
              position: Position.start,
            ),
          ]
        ),
        if (showAttendeeButton) Attendance(
          timeSlot: timeSlot,
          userId: UserService().current.uid
        )
      ],
    );
  }

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