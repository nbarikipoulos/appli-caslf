import 'package:caslf/models/location/location_action.dart';
import 'package:caslf/models/message/channel.dart';
import 'package:caslf/models/message/channel_type.dart';
import 'package:caslf/models/message/message.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/utils/date_utils.dart';
import 'package:caslf/utils/day.dart';
import 'package:caslf/utils/string_utils.dart';
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
    var loc = context.localization;

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

    String locationLabel = loc.location(location.name);
    
    final [timeStart, timeEnd] = [date, this.end].map((date) => TimeOfDay
      .fromDateTime(date)
      .toHHMM()
    ).toList();
    
    if (recurrent) {
      // title
      title = loc.message_new_timeslots_title(locationLabel);

      // body

      String daysLabel = days!
        .map((day) => loc.day_long(day.name).append('s')) // FIXME
        .toList()
        .join(', ')
      ;

      final [dayStart, dayEnd] = [start!, end!].map(
        (date) => date.getDayMonthAsString()
      ).toList();
      
      body = loc.message_new_timeslots_body(
        dayStart,
        dayEnd, daysLabel,
        timeStart,
        timeEnd
      );
    } else {
      // title

      var f = shouldBeConfirmed
        ? loc.message_ask_new_timeslot_title
        : loc.message_new_timeslot_title
      ;

      title = f.call(locationLabel);

      // body

      var dateLabel = switch(DayType.getType(date)) {
        DayType.today => loc.today,
        DayType.tomorrow => loc.tomorrow,
        _ => date.getDayAsString(),
      }.toCapitalized;

      var bf = shouldBeConfirmed
        ? loc.message_ask_new_timeslot_body
        : loc.message_new_timeslot_body
      ;

      body= bf.call(
        dateLabel,
        timeStart,
        timeEnd
      );
    }

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
    var loc = context.localization;

    final channelId = Channel.computeId(
      type: ChannelType.openClose,
      location: location
    );

    final locationLabel = loc.location(location.name);
    final locationStatusLabel = loc.location_status(action.name);

    final title = loc.message_open_close_title(
      locationLabel.toCapitalized,
      locationStatusLabel
    );

    final body = switch(action) {
      LocationAction.open => loc.message_open_body(
        TimeOfDay.fromDateTime(end).toHHMM()
      ),
      LocationAction.close => loc.message_close_body
    };

    return Message.create(
      channelId: channelId,
      title: title,
      body: body
    );
  }

}

