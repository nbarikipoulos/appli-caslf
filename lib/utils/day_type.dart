import 'package:caslf/extensions/date_time_ext.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

enum DayType {
  before,
  today,
  tomorrow,
  later;

  static DayType getType(DateTime date) {
    DateTime toDayDateUTC(DateTime d) => DateTime.utc(d.year, d.month,d.day);

    int delta = toDayDateUTC(date)
      .difference(toDayDateUTC(DateTime.now()))
      .inDays
    ;

    return switch (delta) {
      < 0 => DayType.before,
      0 => DayType.today,
      1 => DayType.tomorrow,
      _ => DayType.later
    };
  }

}

String dayDateLabel(
  BuildContext context,
  DateTime date
) => switch(DayType.getType(date)) {
  DayType.today => context.localization.today,
  DayType.tomorrow => context.localization.tomorrow,
  _ => date.getDayAsString(),
};
