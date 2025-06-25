import 'package:caslf/extensions/date_time_ext.dart';
import 'package:caslf/extensions/time_of_day_ext.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/utils/day.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

extension TimeSlotExtension on TimeSlot {

  List<TimeSlot> createRecurrent({
    required DateTime start,
    required DateTime end,
    required List<Day> days,
  }) {
    if (days.isEmpty) { // Early exit
      throw 'List of days must no be empty';
    }

    List<TimeSlot> result = [];

    // Monday
    var targetWeekday = days.map((d) => d.code).toList();
    int nb = targetWeekday.length;

    int i = targetWeekday.indexWhere((d) => d >=start.weekday);
    if (i <0) i =0;

    // Move to first targeted weekday
    DateTime current = start.copyWith(
        day: start.day + (targetWeekday[i] - start.weekday)%7
    );

    var delta = nb == 1
      ? [7]
      : List.generate(
        nb,
        (i) => (targetWeekday[(i+1)%nb] - targetWeekday[i]) % 7
      )
    ;

    DateTime endPlus1 = end.copyWith(day: end.day + 1);
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(date);

    while (current.isBefore(endPlus1)) {
      TimeSlot timeSlot = copyWith(
        date: current.copyWithTimeOfDay(timeOfDay)
      );

      result.add(timeSlot);

      current = current.copyWith(day: current.day + delta[i%nb]);
      i++;
    }

    return result;
  }
}

//FIXME to move
String timeRangeLabel(
  BuildContext context,
  TimeSlot timeSlot
) {
  String result;

  final localization = context.localization;

  if (timeSlot.isAllDay) {
    result = localization.all_day;
  } else {
    final [timeStart, timeEnd] = [
      timeSlot.date,
      timeSlot.end
    ].map((date) => TimeOfDay
      .fromDateTime(date)
      .toHHMM()
    ).toList();

    result = localization.time_slot_from_to(timeStart, timeEnd);
  }

 return result;
}
