import 'dart:async';

import 'package:caslf/extensions/date_time_ext.dart';
import 'package:caslf/services/service.dart';
import 'package:caslf/utils/time_adjust.dart';
import 'package:flutter/material.dart';

class TimeService with ChangeNotifier implements Service {
  TimeService._();

  static TimeService? _instance;
  factory TimeService() => _instance ??= TimeService._();

  Timer? _timer;
  int? _currentDay;
  int? _currentMonth;

  DateTime get now => DateTime.now().copyWith(
    second: 0,
    millisecond: 0,
    microsecond: 0
  );

  DateTime get today => now.toDayDate();

  DateTime get next => [
    now,
    now.add(Duration(minutes: Precision.defaultPrecision.value))
  ].map(Precision.adjustDate)
    .firstWhere((date) => date.isAfter(now))
  ;

  int get currentDay => _currentDay!;
  int get currentMonth => _currentMonth!;

  // aka end of next month.
  DateTime get timeLimit => today
    .copyWith(
    month: today.month + 2, // +2 months
    day: 0, // aka minus 1 months
    hour: 23, // to end of the day...
    minute: 59
  );

  @override
  Future<void> init() async {
    final now = DateTime.now();
    final nextDay = now
      .toDayDate()
      .copyWith(day: now.day + 1)
    ;

    f() {
      final n = DateTime.now();
      _currentDay = n.day;
      _currentMonth = n.month;
    }

    f();

    _timer = Timer(nextDay.difference(now), () {
      _timer = Timer.periodic(
        const Duration(days: 1),
        (_) {
          f();
          notifyListeners();
        }
      );

      f();
      notifyListeners();
    });

  }

  @override
  Future<void> clear() {
    _timer?.cancel();

    return Future.value();
  }

}