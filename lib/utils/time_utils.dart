import 'package:flutter/material.dart';

enum Precision {
  full(value: 1),
  quarter(value: 15),
  half(value: 30),
  hour(value: 60);

  final int value;

  const Precision({required this.value});

  static const defaultPrecision = half;

  static TimeOfDay adjustTimeOfDay(TimeOfDay input, {
    Precision precision = defaultPrecision
  }) {
      int minutes = adjustMinute(
        input.minute,
        precision: precision
      );

      int hours = input.hour + minutes ~/ 60;
      int mins = minutes % 60;

      if (hours >= 24) {
        hours = 23;
        mins = 60 - precision.value;
      }

      return input.replacing(
        hour: hours,
        minute: mins
      );
  }

  static DateTime adjustDate(DateTime input, {
    Precision precision = defaultPrecision
  }) => input.copyWith(
      minute: adjustMinute(
          input.minute,
          precision: precision
      )
  );

  static Duration adjustDuration(Duration input, {
    Precision precision = defaultPrecision
  }) => Duration(
    minutes: adjustMinute(
      input.inMinutes,
      precision: precision
    )
  );

  static int adjustMinute(int minutes, {
    Precision precision = half
  }) => precision.value * (minutes / precision.value).round();

}
