import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/utils/date_utils.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/my_title.dart';
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
      : tr(context)!.time_slot_type(timeSlot.type.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTitle(
          title: _timeLabel(context),
          icon: Icons.schedule, //icon,
          color: colorz,
          position: Position.start,
        ),
        if (hasExtraInfo) MyTitle(
          title: extraLabel,
          icon: icon,
          color: colorz,
          position: Position.start,
        )
      ]
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