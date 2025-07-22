import 'package:caslf/extensions/date_time_ext.dart';
import 'package:caslf/extensions/string_ext.dart';
import 'package:caslf/extensions/time_of_day_ext.dart';
import 'package:caslf/extensions/time_slot/time_slot_ext.dart';
import 'package:caslf/l10n/generated/app_localizations.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/location/location_action.dart';
import 'package:caslf/models/message/channel.dart';
import 'package:caslf/models/message/channel_type.dart';
import 'package:caslf/models/message/message.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/utils/day.dart';
import 'package:caslf/utils/day_type.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

class TimeSlotMessageBuilder {
  TimeSlotMessageBuilder({
    required BuildContext context,
    required TimeSlot timeSlot,
  }): _context = context, _timeSlot = timeSlot;

  final BuildContext _context;
  final TimeSlot _timeSlot;

  AppLocalizations get _localisation => _context.localization;

  String get _locationLabel => _localisation.location(_timeSlot.location.name);
  String get _dateLabel => dayDateLabel(_context, _timeSlot.date); // day
  String get _scheduleLabel => timeRangeLabel(_context, _timeSlot); // time

  String _channelId(ChannelType type) => switch(_timeSlot.type) {
    // Redirect event and competition to their dedicated channel
    TimeSlotType.event => Channel.computeId(
      type: ChannelType.event
    ),
    TimeSlotType.competition => Channel.computeId(
      type: ChannelType.competition
    ),
    (_) => Channel.computeId(
      type: type,
      location: _timeSlot.location
    )
  };

  Message createNew() {
    final bool shouldBeConfirmed = TimeSlotStatus.awaiting == _timeSlot.status;

    return shouldBeConfirmed
      ? _askFor()
      : _createNew()
    ;
  }

  Message createRecurrent({
    required DateTime start,
    required DateTime end,
    required List<Day> days
  }) {

    String title;
    String body;

    // title
    title = _localisation.message_new_timeslots_title(
      _locationLabel
    );

    // body

    String daysLabel = days
      .map((day) => _localisation.day_long(day.name).append('s')) // FIXME
      .toList()
      .join(', ')
    ;

    final [dayStart, dayEnd] = [start, end].map(
      (date) => date.getDayMonthAsString()
    ).toList();

    body = _localisation.message_new_timeslots_body(
      dayStart,
      dayEnd,
      daysLabel,
      _scheduleLabel
    );

    return _message(
      channelId: _channelId(ChannelType.newSlot),
      title: title,
      body: body
    );
  }

  Message deleted() {
    String title;
    String body;

    // title

    title = switch(_timeSlot.type) {
      TimeSlotType.common =>
        _localisation.message_deleted_common_timeslot_title(
          _dateLabel,
          _locationLabel
        ),
      TimeSlotType.event =>
        _localisation.message_deleted_event_timeslot_title(_dateLabel),
      TimeSlotType.competition =>
        _localisation.message_deleted_competition_timeslot_title(_dateLabel),
      TimeSlotType.maintenance =>
        _localisation.message_deleted_maintenance_timeslot_title(_dateLabel),
      TimeSlotType.closed =>
        _localisation.message_deleted_closed_timeslot_title(
          _dateLabel,
          _locationLabel
        ),
      (_) => throw UnimplementedError() // could not happen
    };

    // body

    body = switch(_timeSlot.type) {
      TimeSlotType.common =>
        _localisation.message_deleted_common_timeslot_body(
          _scheduleLabel
        ),
      TimeSlotType.competition ||
      TimeSlotType.event =>
        _localisation.message_deleted_with_desc_timeslot_body(
          _timeSlot.message!.toCapitalized
        ),
      TimeSlotType.maintenance =>
        _localisation.message_deleted_maintenance_timeslot_body(_locationLabel),
      TimeSlotType.closed =>
        _localisation.message_deleted_closed_timeslot_body,
      TimeSlotType.unknown => throw UnimplementedError() // could not happen
    };

    return _message(
      channelId: _channelId(ChannelType.newSlot),
      title: title,
      body: body
    );
  }

  Message _askFor() {
    String title;
    String body;

    title = _localisation.message_ask_common_timeslot_title(
      _locationLabel
    );

    body = _localisation.message_without_location_body(
      _dateLabel.toCapitalized,
      _scheduleLabel
    );

    return _message(
      channelId: _channelId(ChannelType.askFor),
      title: title,
      body: body
    );

  }

  Message _createNew() {
    String title;
    String body;

    // title
    title = switch(_timeSlot.type) {
      TimeSlotType.common => _localisation.message_common_timeslot_title(
        _locationLabel
      ),
      TimeSlotType.maintenance => _localisation.message_maintenance_title(
        _locationLabel
      ),
      TimeSlotType.closed => _localisation.message_closed_title(
        _locationLabel
      ),
      TimeSlotType.event => _localisation.message_event_title(
        _timeSlot.message!
      ),
      TimeSlotType.competition => _localisation.message_competition_title(
        _timeSlot.message!
      ),
      TimeSlotType.unknown => throw UnimplementedError() // could not happen
    };

    // body
    body = switch(_timeSlot.type) {
      TimeSlotType.common ||
      TimeSlotType.maintenance ||
      TimeSlotType.closed => _localisation.message_without_location_body(
        _dateLabel.toCapitalized,
        _scheduleLabel
      ),
      TimeSlotType.event ||
      TimeSlotType.competition => _localisation.message_with_location_body(
          _dateLabel,
          _scheduleLabel,
          _timeSlot.location == Location.external
            ? _timeSlot.where!
            : _locationLabel
      ),
      TimeSlotType.unknown => throw UnimplementedError() // could not happen
    };

    return _message(
      channelId: _channelId(ChannelType.newSlot),
      title: title,
      body: body
    );
  }

  Message timeUpdate(TimeSlot newTimeSlot) {
    final bool shouldBeConfirmed = TimeSlotStatus.awaiting == _timeSlot.status;

    return shouldBeConfirmed
      ? _updateTimeAskFor(newTimeSlot)
      : _timeUpdate(newTimeSlot)
    ;
  }

  Message _timeUpdate(TimeSlot newTimeSlot) {
    String title;
    String body;

    // title

    final typeLabel = _localisation.time_slot_type(_timeSlot.type.name);

    title = switch(_timeSlot.type) {
      TimeSlotType.common =>
        _localisation.message_updated_common_timeslot_title(
          _dateLabel,
          _locationLabel
        ),
      (_) =>
        _localisation.message_updated_typed_timeslot_title(
          _dateLabel,
          typeLabel
        )
    };

    // body

    final scheduleLabelOld = timeRangeLabel(_context, _timeSlot);
    final scheduleLabelNew = timeRangeLabel(_context, newTimeSlot);

    body = _localisation.message_updated_common_timeslot_body(
      scheduleLabelNew,
      scheduleLabelOld
    );

    return _message(
      channelId: _channelId(ChannelType.newSlot),
      title: title,
      body: body
    );
  }

  Message _updateTimeAskFor(TimeSlot newTimeSlot) {
    String title;
    String body;

    // title

    title = _localisation.message_updated_ask_common_timeslot_title(
      _dateLabel,
      _locationLabel
    );

    // body

    final scheduleLabelOld = timeRangeLabel(_context, _timeSlot);
    final scheduleLabelNew = timeRangeLabel(_context, newTimeSlot);

    body = _localisation.message_updated_common_timeslot_body(
      scheduleLabelNew,
      scheduleLabelOld
    );

    return _message(
      channelId: _channelId(ChannelType.askFor),
      title: title,
      body: body
    );
  }

  Message openCloseMessage({ required LocationAction action }) {
    final locationStatusLabel = _localisation.location_status(action.name);

    // title

    final title = _localisation.message_open_close_title(
        _locationLabel.toCapitalized,
        locationStatusLabel
    );

    // body

    final body = switch(action) {
      LocationAction.open => _localisation.message_open_body(
        TimeOfDay.fromDateTime(_timeSlot.end).toHHMM()
      ),
      LocationAction.close => _localisation.message_close_body
    };

    return _message(
      channelId: _channelId(ChannelType.openClose),
      title: title,
      body: body
    );
  }

  Message _message({
    required String channelId,
    required String title,
    required String body
  }) => Message.create(
    uid: UserService().current.uid,
    channelId: channelId,
    title: title,
    body: body
  );
}
