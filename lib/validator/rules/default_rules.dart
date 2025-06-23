import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/utils/date_utils.dart';
import 'package:caslf/validator/rule.dart';
import 'package:caslf/validator/rule_engine.dart';
import 'package:caslf/validator/rule_factory.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

class DefaultRules implements RuleProvider {
  DefaultRules._() { _init(); }

  static DefaultRules? _instance;
  factory DefaultRules() => _instance ??= DefaultRules._();

  final Map<String, Rule> _rules = {};

  @override
  Rule? getRule(String id) => _rules[id];

  void _add(Rule rule) {
    _rules[rule.id] = rule;
  }

  void _init() {
    _add(_isConflicting);
    _add(_msgNotNullForEvent);
    _add(_locationFilled);
    _add(_duration0);
    _add(_isBefore);
    _add(_isDaysInverted);
  }
}

//////////////////////////////
// TimeSlot
//////////////////////////////

Rule<TimeSlot> _isConflicting = RuleFactory().create<TimeSlot>(
  'timeSlot.is.conflicting',
  (context, timeSlot, [parameters]) {
    final (:canBeAdded, :conflicting) = TimeSlotService()
      .canBeAdded(timeSlot)
    ;

    String? msg;

    if (!canBeAdded) {
      final [start, end] = [
        conflicting!.date,
        conflicting.end
      ].map((date) => TimeOfDay
        .fromDateTime(date)
        .toHHMM()
      ).toList();

      msg = localization(context).conflict_in_timeSlot(start, end);
    }

    return msg;
  }
);

Rule<TimeSlot> _msgNotNullForEvent = RuleFactory().create<TimeSlot>(
  'timeSlot.must.have.comment',
  (context, timeSlot, [parameters]) {
    String? message = timeSlot.message;
    bool commentRequired =
      timeSlot.type == TimeSlotType.event ||
      timeSlot.location == Location.external
    ;

    if (
      commentRequired &&
      (message == null || message.isEmpty)
    ) {
      return localization(context).add_comment_event;
    }

    return null;
  }
);

Rule<TimeSlot> _locationFilled = RuleFactory().create<TimeSlot>(
    'timeSlot.external.must.have.location',
    (context, timeSlot, [parameters]) {
      String? where = timeSlot.where;
      bool required = timeSlot.location == Location.external;

      if (
        required &&
        (where == null || where.isEmpty)
      ) {
        return localization(context).add_location_for_external;
      }

      return null;
    }
);

//////////////////////////////
// DateTime
//////////////////////////////

Rule<DateTime> _isBefore = RuleFactory().create<DateTime>(
  'date.time.is.before',
  (context, dateTime, [parameters]) {
    DateTime dateTime2 = parameters?['date']
      ?? DateTime.now()
    ;

    if (dateTime.isBefore(dateTime2)){
      return localization(context).start_time_expired;
    }
    return null;
  }
);

Rule<DateTime> _isDaysInverted = RuleFactory().create<DateTime>(
  'date.time.days.inverted',
  (context, dateTime, [parameters]) {
    DateTime end = parameters?['end_date']
      ?? DateTime.now()
    ;
    if (dateTime.isAfter(end)){
      return localization(context).start_end_days_inverted;
    }
    return null;
  }
);

//////////////////////////////
// Duration
//////////////////////////////

Rule<Duration> _duration0 = RuleFactory().create<Duration>(
  'duration.zero',
  (context, duration, [parameters]) {
    if (duration.inMinutes == 0) {
      return localization(context).duration_is_zero;
    }
    return null;
  }
);
