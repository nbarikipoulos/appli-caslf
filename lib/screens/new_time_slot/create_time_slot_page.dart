import 'package:caslf/extensions/date_time_ext.dart';
import 'package:caslf/extensions/string_ext.dart';
import 'package:caslf/extensions/time_slot/time_slot_ext.dart';
import 'package:caslf/messages/time_slot_message.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/message/message.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_extra.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/preferences_service.dart';
import 'package:caslf/services/rules_service.dart';
import 'package:caslf/services/time_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/theme/theme_utils.dart'
  show primary;
import 'package:caslf/utils/day.dart';
import 'package:caslf/validator/rule_engine.dart';
import 'package:caslf/widgets/heading_item.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/misc.dart';
import 'package:caslf/widgets/my_title.dart';
import 'package:caslf/widgets/switch_list_tile_form.dart';
import 'package:caslf/widgets/time_slot/create/type_form.dart';
import 'package:caslf/widgets/time_slot/create/when_form.dart';
import 'package:caslf/widgets/time_slot/create/whens_form.dart';
import 'package:caslf/widgets/time_slot/create/where_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum CreatedBy { user, club }

enum Functionality {
  location(editable: false),
  type(mode: CreatedBy.club, editable: false),
  changeDay(editable: false),
  recurrent(editable: false),
  canNotNotify(mode: CreatedBy.club, editable: true),
  autoOpen(mode: CreatedBy.club, editable: true);

  bool show({CreatedBy? mode, bool value = true}) =>
    (this.mode == null || this.mode == mode)
    && value
  ;

  bool isEditable(bool isEditing, [value = true]) =>
    !isEditing
    || (editable && value)
  ;

  final CreatedBy? mode;
  final bool editable;

  const Functionality({
    this.mode,
    required this.editable
  });
}

class CreateTimeSlotPage extends StatefulWidget {
  final TimeSlot? timeSlot;

  const CreateTimeSlotPage({
    super.key,
    this.timeSlot
  });

  @override
  State<CreateTimeSlotPage> createState() => CreateTimeSlotPageState();
}

class CreateTimeSlotPageState extends State<CreateTimeSlotPage> {
  final user = UserService().current;

  bool get isEditing => widget.timeSlot != null;

  //FIXME Use only in Form; something is wrong at init time, to understand...
  final autovalidateMode = AutovalidateMode.always;

  late TimeSlot current;
  late CreatedBy mode;

  bool _durationHasBeenChanged = false;

  bool recurrent = false;
  late WhensFormData recurrentData;
  bool doNotNotify = false;

  late bool isValid;

  final _formKey = GlobalKey<FormState>();

  final _locationT0 = Location.ground;

  TimeSlot get defaultTimeSlot => TimeSlot(
    ownerId: user.uid,
    location: _locationT0,
    type: TimeSlotType.common,
    extra: {},
    date: TimeService().next,
    duration: PreferencesService().getDefaultDurationFor(
      _locationT0
    ),
    isAllDay: false,
    status: user.hasAccessTo(_locationT0)
      ? TimeSlotStatus.ok
      : TimeSlotStatus.awaiting
  );

  WhensFormData get defaultRecurrentData => (
    start: TimeService().today,
    end: TimeService().today
      .add(Duration(days: 14)),
    days: [Day.monday],
    timeOfDay: const TimeOfDay(hour: 18, minute: 30),
    duration: PreferencesService().getDefaultDurationFor(_locationT0)
  );

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      TimeSlot edited = widget.timeSlot!;
      current = edited.copyWith(id: edited.id);
    } else {
      current = defaultTimeSlot;
      if (AdminService().actAsClub) {
        current.extra!.add(TimeSlotExtra.club);
      }
    }

    mode = current.isClub ? CreatedBy.club : CreatedBy.user;

    recurrent = false;
    recurrentData = defaultRecurrentData;
    doNotNotify = false;
  }

  @override
  Widget build(BuildContext context) {
    final [
      isRecurrentAllowed,
      canNotNotify,
      canChangeType,
      canActivateAutoOpen,
      actAsClub
    ] = [
      (GrantService service) => service.allowRecurrentTimeSlot,
      (GrantService service) => service.canNotNotify,
      (GrantService service) => service.canChangeTimeSlotType,
      (GrantService service) => service.canActivateAutoOpen,
      (GrantService service) => service.actAsClub
    ].map(context.select<GrantService, bool>)
    .toList();

    //
    // Init values next to grant change(s)
    //

    if (!canNotNotify) { doNotNotify = false; }

    if (!isRecurrentAllowed) { recurrent = false; }

    if (!canActivateAutoOpen) { current.autoOpen = false; }

    if (!isEditing) {
      if (actAsClub) {
        mode = CreatedBy.club;
        current.extra!.remove(TimeSlotExtra.casual);
        current.extra!.add(TimeSlotExtra.club);
      } else {
        mode = CreatedBy.user;
        current.ownerId = user.uid;
        current.type = TimeSlotType.common;
        current.extra!.add(TimeSlotExtra.casual);
        current.extra!.remove(TimeSlotExtra.club);
      }
    }

    List<Location> locations = GrantService.get().availableLocations;
    if (!locations.contains(current.location)) {
      current.location = locations.first;
    }

    RulesEngine ruleEngine = RulesService().create(context);

    return Scaffold(
        appBar: AppBar(
        title: MyTitle(
          title: isEditing
            ? tr(context)!.screen_edit_title
            : tr(context)!.screen_create_title,
          icon: mode == CreatedBy.club ? Icons.pets : null,
          color: primary
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          // autovalidateMode: AutovalidateMode.always,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: HeadingItem(title: tr(context)!.where.toCapitalized)
                ),
                WhereForm(
                  locations: Functionality.location.isEditable(isEditing)
                    ? locations
                    : [current.location],
                  initialValue: current.location,
                  onChanged: (Location value) {
                    setState(() {
                      current.location = value;
                      // Check type
                      final types = _getAvailableTypesFor(current);
                      if (!types.contains(current.type)) {
                        current.type = types.first;
                      }
                      if (!_durationHasBeenChanged) {
                        final duration = _getDefaultDuration(value);
                        current.duration = duration;
                        recurrentData = ( // FIXME ugly...
                          start: recurrentData.start,
                          end: recurrentData.end,
                          days: recurrentData.days,
                          timeOfDay: recurrentData.timeOfDay,
                          duration: duration
                        );
                      }
                    });
                  }
                ),
                if(Functionality.type.show(
                  mode: mode,
                  value: canChangeType
                )) ...[
                  Center(
                    child: HeadingItem(title: tr(context)!.type.toCapitalized)
                  ),
                  TypeForm(
                    types: Functionality.type.isEditable(isEditing)
                      ? _getAvailableTypesFor(current)
                      : [current.type],
                    initialValue: current.type,
                    onChanged: (value) {
                      setState(() {
                        current.type = value;
                      });
                    }
                  )
                ],
                Center(
                  child: HeadingItem(title: tr(context)!.when.toCapitalized)
                ),
                if (
                  Functionality.recurrent.show(value: isRecurrentAllowed)
                  && Functionality.recurrent.isEditable(isEditing)
                ) SwitchListTile(
                  //controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    tr(context)!.screen_create_recurrent_switch
                  ),
                  value: recurrent,
                  onChanged: (value) {
                    setState(() {
                      recurrent = value;
                    });
                  }
                ),
                !recurrent
                  ? WhenForm(
                    autovalidateMode: autovalidateMode,
                    initialDate: current.date,
                    initialDuration: isEditing && current.isAllDay
                      ? _getDefaultDuration() // Avoid 24h displaying
                      : current.duration
                    ,
                    allowAllDay: mode == CreatedBy.club,
                    isAllDay: current.isAllDay,
                    canChangeDay: !isEditing,
                    onChanged: (WhenFormData value) {
                      setState(() {
                        current.date = value.date;
                        if (current.duration != value.duration) {
                          current.duration = value.duration;
                          _durationHasBeenChanged = true;
                        }
                        current.isAllDay = value.isAllDay;
                      });
                    },
                    validator: (WhenFormData value) {
                      TimeSlot ts = current.copyWith(
                        id: current.id,
                        date: value.isAllDay
                          ? value.date.toDayDate()
                          : value.date,
                        duration: value.isAllDay
                          ? const Duration(hours: 24)
                          : value.duration,
                        isAllDay: value.isAllDay
                      );

                      return ruleEngine.validate(
                        ts,
                        'timeSlot.is.conflicting'
                      );
                    }
                  )
                  : WhensForm(
                    startDate: recurrentData.start,
                    endDate: recurrentData.end,
                    initialDays: recurrentData.days,
                    timeOfDay: recurrentData.timeOfDay,
                    initialDuration: recurrentData.duration,
                    autovalidateMode: autovalidateMode,
                    onChanged: (WhensFormData value) {
                      setState(() {
                        recurrentData = value;
                        if (
                          !_durationHasBeenChanged &&
                          value.duration != _getDefaultDuration()
                        ) {
                          _durationHasBeenChanged = true;
                        }
                      });
                    }
                  ),
                Center(
                  child: HeadingItem(title: tr(context)!.misc.toCapitalized)
                ),
                TextFormField(
                  autovalidateMode: autovalidateMode,
                  decoration: InputDecoration(
                    labelText: _isDescriptionMandatory(current)
                      ? tr(context)!.screen_create_switch_comment_text
                      : tr(context)!.screen_create_switch_comment_text_opt,
                    prefixIcon: const Icon(Icons.message)
                  ),
                  initialValue: current.message,
                  onChanged: (message) {
                    setState(() {
                      current.message = message;
                    });
                  },
                  validator: (message) => ruleEngine.validate(
                    current.copyWith(message: message),
                    'timeSlot.must.have.comment'
                  )
                ),
                if (current.location == Location.external) TextFormField(
                  autovalidateMode: autovalidateMode,
                  decoration: InputDecoration(
                      labelText: tr(context)!.screen_create_switch_where_text,
                      prefixIcon: const Icon(Icons.language)
                  ),
                  initialValue: current.where,
                  onChanged: (where) {
                    setState(() {
                      current.where = where;
                    });
                  },
                  validator: (where) => ruleEngine.validate(
                      current.copyWith(where: where),
                      'timeSlot.external.must.have.location'
                  )
                ),
                if (Functionality.canNotNotify.show(
                  mode: mode,
                  value: canNotNotify
                )) SwitchListTileFormField(
                  initialValue: doNotNotify,
                  autovalidateMode: autovalidateMode,
                  enabled: Functionality.canNotNotify.isEditable(isEditing),
                  title: Text(
                    tr(context)!.screen_create_switch_do_not_notify
                  ),
                  onChanged: (value) {
                    setState(() {
                      doNotNotify = value;
                    });
                  },
                ),
                if (Functionality.autoOpen.show(
                  mode: mode,
                  value: canActivateAutoOpen
                    && current.location.isOpenable
                )) SwitchListTileFormField(
                  initialValue: current.autoOpen,
                  autovalidateMode: autovalidateMode,
                  enabled: Functionality.autoOpen.isEditable(isEditing),
                  title: Text(
                    tr(context)!.screen_create_switch_auto_open_close
                  ),
                  onChanged: (value) {
                    setState(() {
                      current.autoOpen = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  child: Text(
                    isEditing
                      ? tr(context)!.screen_edit_perform
                      : tr(context)!.screen_create_perform
                  ),
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();

                      // aka 'guest' case
                      bool shouldBeAdded = context
                        .read<GrantService>()
                        .canReallyAddTimeSlot
                      ;

                      if (shouldBeAdded) {
                        // Main job
                        await _doOnPressed(context);
                      } else {
                        await showSimpleAlertDialog(
                          context,
                          tr(context)!.guest_message_timeslot
                        );
                      }

                      // Back
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  }
                )
              ]
            )
          )
        )
      )
    );
  }

  Duration _getDefaultDuration([Location? location]) => PreferencesService()
    .getDefaultDurationFor(location ?? current.location)
  ;

  bool _isDescriptionMandatory(TimeSlot timeSlot) =>
    timeSlot.type == TimeSlotType.event ||
    timeSlot.type == TimeSlotType.competition ||
    timeSlot.location == Location.external
  ;

  List<TimeSlotType> _getAvailableTypesFor(TimeSlot timeSlot) =>
    timeSlot.location == Location.external
      ? [TimeSlotType.event, TimeSlotType.competition]
      : TimeSlotType.helper.values
    ;

  Future<void> _doOnPressed(BuildContext context) => isEditing
    ? _doUpdate(context)
    : _doAdd(context)
  ;

  Future<void> _doUpdate(BuildContext context) async {
    bool sendMessage;
    Message? message;

    TimeSlot t0 = widget.timeSlot!;

    //
    // Update date, if needed
    //

    if (current.isAllDay) {
      current.date = current.date.toDayDate(); // -> 0h
      current.duration = const Duration(hours: 24);
    }

    //
    // Check potential changes in date
    //

    final Map<String, Object?> values = {
      if (current.isAllDay != t0.isAllDay)
        'is_all_day': current.isAllDay,
      if (current.date.compareTo(t0.date) != 0)
        'date': current.date,
      if (current.duration.compareTo(t0.duration) != 0)
        'duration': current.duration.inMinutes
    };

    // If any change in date, let's ack users
    sendMessage = values.isNotEmpty;

    //
    // Other managed changes
    //

    String comment = current.message ?? '';
    if (comment != t0.message) {
      values['message'] = comment.isEmpty
        ? FieldValue.delete()
        : comment
      ;
    }

    if (
      current.where != null // aka is mandatory
      && current.where != t0.where // != ...
    ) {
      values['where'] = current.where;
    }

    //
    // Message to send
    //

    if (sendMessage) {
      message = TimeSlotMessageBuilder(
        context: context,
        timeSlot: t0
      ).timeUpdate(current);
    }

    //
    // main job
    //

    if (values.isNotEmpty) {
      await TimeSlotService()
        .update(t0.id, values)
        .then((_) {
          if (message != null) {
            _doSendMessage(message);
          }
        })
      ;
    }

  }

  Future<void> _doAdd(BuildContext context) async {
    //Last update: Update the time slot to create
    // (admin, act as club, creator)
    TimeSlot timeSlotSeed = _prepareSeed();

    // Time slot(s) to create

    List<TimeSlot> timeSlots = recurrent
      ? timeSlotSeed.createRecurrent(
        start: recurrentData.start,
        end: recurrentData.end,
        days: recurrentData.days
      )
      : [timeSlotSeed]
    ;

    TimeSlotMessageBuilder builder = TimeSlotMessageBuilder(
      context: context,
      timeSlot: timeSlotSeed
    );

    // Message to send
    Message message = recurrent
      ? builder.createRecurrent(
          start: recurrentData.start,
          end: recurrentData.end,
          days: recurrentData.days
        )
      : builder.createNew()
    ;


    await TimeSlotService()
      .setAll(timeSlots)
      .then((_) => _doSendMessage(message))
    ;
  }

  Future<void> _doSendMessage(Message message) async {
    if (!doNotNotify) {
      MessagesService().send(message);
    }
  }

  TimeSlot _prepareSeed() {
    // Status: admin/club does not need acknowledge!
    TimeSlotStatus status = user.hasAccessTo(current.location)
      || AdminService().isAdminMode
      || AdminService().actAsClub
      ? TimeSlotStatus.ok
      : TimeSlotStatus.awaiting
    ;

    DateTime? date;
    Duration? duration;
    String? where;
    bool? autoOpen;

    // Specific updates for recurrent time slots
    if (recurrent) {
      date = DateTime.now()
        .copyWithTimeOfDay(recurrentData.timeOfDay)
      ;
      duration = recurrentData.duration;
    }

    // All day time slot case
    if (current.isAllDay) {
      date = current.date.toDayDate(); // -> 0h
      duration = const Duration(hours: 24);
    }

    // Ensure empty location settings aka 'where' field
    if(current.location != Location.external) {
      where = ''; // null will not unset field, see the copy method
    }

    if (!current.location.isOpenable) {
      autoOpen = false;
    }

    return current.copyWith(
      status: status,
      date: date,
      duration: duration,
      autoOpen: autoOpen,
      where: where
    );
  }
}
