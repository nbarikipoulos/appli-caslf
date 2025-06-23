import 'package:caslf/extensions/date_time_ext.dart';
import 'package:caslf/extensions/string_ext.dart';
import 'package:caslf/extensions/time_of_day_ext.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/location/location_action.dart';
import 'package:caslf/models/message/channel.dart';
import 'package:caslf/models/message/channel_type.dart';
import 'package:caslf/models/message/message.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/utils/day_type.dart';
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

  Message createMessage(
    BuildContext context,
    { bool recurrent = false,
      DateTime? start, // mandatory if recurrent = true...
      DateTime? end, // idem
      List<Day>? days // re...
    }) {
    final localization = context.localization;

    bool shouldBeConfirmed = TimeSlotStatus.awaiting == status;

    ChannelType channelType = shouldBeConfirmed
      ? ChannelType.askFor
      : ChannelType.newSlot
    ;

    String channelId = Channel.computeId(
        type: channelType,
        location: location
    );

    String title;
    String body;

    String locationLabel = localization.location(location.name);

    final dateLabel = dayDateLabel(context, date); // day
    final scheduleLabel = timeRangeLabel(context, this); // time

    if (recurrent) {
      // title
      title = localization.message_new_timeslots_title(locationLabel);

      // body

      String daysLabel = days!
        .map((day) => localization.day_long(day.name).append('s')) // FIXME
        .toList()
        .join(', ')
      ;

      final [dayStart, dayEnd] = [start!, end!].map(
        (date) => date.getDayMonthAsString()
      ).toList();
      
      body = localization.message_new_timeslots_body(
        dayStart,
        dayEnd,
        daysLabel,
        scheduleLabel
      );
    } else if (location == Location.external) {
      // title
      final typeLbl =  localization.time_slot_type(type.name);
      title = localization.message_external_title(
        typeLbl,
        message!
      );

      // body

      body = localization.message_external_body(
        '${dateLabel.toCapitalized}, $scheduleLabel',
        where!
      );
    } else {
      // title

      final f = shouldBeConfirmed
        ? localization.message_ask_new_timeslot_title
        : switch(type) {
          TimeSlotType.common => localization.message_new_timeslot_title,
          TimeSlotType.event => localization.message_event_title,
          TimeSlotType.competition => localization.message_competition_title,
          TimeSlotType.maintenance => localization.message_maintenance_title,
          TimeSlotType.closed => localization.message_closed_title,
          TimeSlotType.unknown => throw UnimplementedError() // could not happen
        }
      ;

      final arg = type == TimeSlotType.event
        ? message!
        : locationLabel
      ;

      title = f.call(arg);

      // body

      body = switch(type) {
        TimeSlotType.common ||
        TimeSlotType.maintenance ||
        TimeSlotType.closed => localization.message_new_timeslot_body(
          dateLabel.toCapitalized,
          scheduleLabel
        ),
        TimeSlotType.event ||
        TimeSlotType.competition => localization.message_event_body(
          dateLabel.toCapitalized,
          locationLabel,
          scheduleLabel
        ),
        TimeSlotType.unknown => throw UnimplementedError() // could not happen
      };
    }

    return Message.create(
      channelId: channelId,
      title: title,
      body: body
    );
  }

  Message timeUpdateMessage(
    BuildContext context,
    TimeSlot newTimeSlot
  ) {
    final localization = context.localization;

    final channelType = newTimeSlot.status == TimeSlotStatus.awaiting
      ? ChannelType.askFor
      : ChannelType.newSlot
    ;

    final channelId = Channel.computeId(
      type: channelType,
      location: location
    );

    final locationLabel = localization.location(newTimeSlot.location.name);

    final dateLabel = dayDateLabel(context, date).toCapitalized;

    final scheduleLabelOld = timeRangeLabel(context, this);
    final scheduleLabelNew = timeRangeLabel(context, newTimeSlot);

    // title

    final f = switch(channelType) {
      ChannelType.askFor => localization.message_updated_ask_new_timeslot_title,
      (_) => localization.message_updated_timeslot_title
    };

    final title = Function.apply(
      f,
      [dateLabel, locationLabel]
    );

    // body

    final body = localization.message_updated_timeslot_body(
      scheduleLabelNew,
      scheduleLabelOld
    );

    return Message.create(
      channelId: channelId,
      title: title,
      body: body
    );
  }

  Message openCloseMessage(
    BuildContext context,
    { required LocationAction action }
  ) {
    final localization = context.localization;

    final channelId = Channel.computeId(
      type: ChannelType.openClose,
      location: location
    );

    final locationLabel = localization.location(location.name);
    final locationStatusLabel = localization.location_status(action.name);

    // title

    final title = localization.message_open_close_title(
      locationLabel.toCapitalized,
      locationStatusLabel
    );

    // body

    final body = switch(action) {
      LocationAction.open => localization.message_open_body(
        TimeOfDay.fromDateTime(end).toHHMM()
      ),
      LocationAction.close => localization.message_close_body
    };

    return Message.create(
      channelId: channelId,
      title: title,
      body: body
    );
  }

}

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
