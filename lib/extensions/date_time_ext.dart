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
