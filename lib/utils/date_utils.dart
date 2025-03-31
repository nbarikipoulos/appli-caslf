import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {

  // remove HH, MM, etc.
  DateTime toDayDate() => DateTime(year, month, day);

  DateTime copyWithTimeOfDay(TimeOfDay time) => copyWith(
    hour: time.hour,
    minute: time.minute
  );

  String getDayMonthAsString({
    String languageCode = 'fr'
  }) => DateFormat
    .MMMd(languageCode)
    .format(this)
  ;

  String getDayAsString({
    String languageCode = 'fr'
  }) => DateFormat
    .MMMMEEEEd(languageCode)
    .format(this)
  ;

}

extension TimeOfDayExtension on TimeOfDay {

  String toHHMM({
    String separator = 'h'
  })  {
    final f = NumberFormat('00');

    return '${f.format(hour)}$separator${f.format(minute)}';
  }
}

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
