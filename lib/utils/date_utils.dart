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
    int delta = -1 * DateTime
      .now()
      .toDayDate()
      .difference(date)
      .inDays
    ;

    return switch (delta) {
      <0 => DayType.before,
      0 => DayType.today,
      1 => DayType.tomorrow,
      _ => DayType.later
    };
  }

}
