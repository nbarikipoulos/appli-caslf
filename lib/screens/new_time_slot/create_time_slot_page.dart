import 'package:caslf/constants.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/message/message.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_extra.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/time_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/theme/theme_utils.dart'
  show primary;
import 'package:caslf/utils/date_utils.dart';
import 'package:caslf/utils/day.dart';
import 'package:caslf/utils/misc_utils.dart';
import 'package:caslf/utils/string_utils.dart';
import 'package:caslf/utils/time_slot_utils.dart';
import 'package:caslf/widgets/heading_item.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/my_title.dart';
import 'package:caslf/widgets/switch_list_tile_form.dart';
import 'package:caslf/widgets/time_slot/create/type_form.dart';
import 'package:caslf/widgets/time_slot/create/when_form.dart';
import 'package:caslf/widgets/time_slot/create/whens_form.dart';
import 'package:caslf/widgets/time_slot/create/where_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

  //FIXME Use only in Form; something is wrong at init time, to understand...
  final autovalidateMode = AutovalidateMode.always;

  late TimeSlot current;

  bool recurrent = false;
  late WhensFormData recurrentData;
  bool doNotNotify = false;

  late bool isValid;

  final _formKey = GlobalKey<FormState>();

  TimeSlot get defaultTimeSlot => TimeSlot(
    ownerId: user.uid,
    location: Location.ground,
    type: TimeSlotType.common,
    extra: {},
    date: TimeService().next,
    duration: const Duration(hours: 2),
    isAllDay: false,
    status: user.hasAccessTo(Location.ground)
      ? TimeSlotStatus.ok
      : TimeSlotStatus.awaiting
  );

  WhensFormData get defaultRecurrentData => (
    start: TimeService().today,
    end: TimeService().timeLimit,
    days: [Day.monday],
    timeOfDay: const TimeOfDay(hour: 18, minute: 30),
    duration: const Duration(hours: 4)
  );

  @override
  void initState() {
    super.initState();

    current = defaultTimeSlot.copyWith(
      ownerId: user.uid,
      location: widget.timeSlot?.location,
      date: widget.timeSlot?.date,
      duration: widget.timeSlot?.duration,
      status: widget.timeSlot?.status
    );

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

    // Init values next to change
    if (!canNotNotify) { doNotNotify = false; }
    if (!isRecurrentAllowed) { recurrent = false; }
    if (!actAsClub) {
      current.type = TimeSlotType.common;
      current.extra?.add(TimeSlotExtra.casual);
    } else {
      current.extra?.remove(TimeSlotExtra.casual);
    }
    if (!canActivateAutoOpen) { current.autoOpen = false; }

    return Scaffold(
        appBar: AppBar(
        title: MyTitle(
          title: tr(context)!.screen_create_title,
          icon: actAsClub ? Icons.pets : null,
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
                  locations: Location.values,
                  initialValue: current.location,
                  onChanged: (Location value) {
                    setState(() {
                      current.location = value;
                    });
                  }
                ),
                ...canChangeType ?
                  [
                    Center(
                      child: HeadingItem(title: tr(context)!.type.toCapitalized)
                    ),
                    TypeForm(
                      types: TimeSlotType.values,
                      initialValue: current.type,
                      onChanged: (value) {
                        setState(() {
                          current.type = value;
                        });
                      }
                    )
                  ]
                  : [Container()]
                ,
                Center(
                  child: HeadingItem(title: tr(context)!.when.toCapitalized)
                ),
                if (isRecurrentAllowed) SwitchListTile(
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
                    initialDuration: current.duration,
                    allowAllDay: actAsClub,
                    onChanged: (WhenFormData value) {
                      setState(() {
                        current.date = value.date;
                        current.duration = value.duration;
                        current.isAllDay = value.isAllDay;
                      });
                    },
                    validator: (WhenFormData value) {
                      TimeSlot ts = current.copyWith(
                        date: value.isAllDay
                          ? value.date.toDayDate()
                          : value.date,
                        duration: value.isAllDay
                          ? const Duration(hours: 24)
                          : value.duration,
                        isAllDay: value.isAllDay
                      );
                      final (:canBeAdded, :conflicting) = TimeSlotService()
                        .canBeAdded(ts)
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

                        msg = tr(context)!.conflict_in_timeSlot(start, end);
                      }

                      return msg;
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
                      });
                    }
                  ),
                Center(
                  child: HeadingItem(title: tr(context)!.misc.toCapitalized)
                ),
                TextFormField(
                  autovalidateMode: autovalidateMode,
                  decoration: InputDecoration(
                    labelText: current.type == TimeSlotType.event
                      ? tr(context)!.screen_create_switch_comment_text
                      : tr(context)!.screen_create_switch_comment_text_opt,
                    prefixIcon: const Icon(Icons.message)
                  ),
                  initialValue: current.message,
                  onChanged: (value) {
                    setState(() {
                      current.message = value;
                    });
                  },
                  validator: (value) {
                    if (
                      current.type == TimeSlotType.event
                      && (value == null || value.isEmpty)
                    ) {
                      return tr(context)!.add_comment_event;
                    }

                    return null;
                  },
                ),
                if (canNotNotify) SwitchListTileFormField(
                  initialValue: doNotNotify,
                  autovalidateMode: autovalidateMode,
                  title: Text(
                    tr(context)!.screen_create_switch_do_not_notify
                  ),
                  onChanged: (value) {
                    setState(() {
                      doNotNotify = value;
                    });
                  },
                ),
                if (canActivateAutoOpen) SwitchListTileFormField(
                  initialValue: current.autoOpen,
                  autovalidateMode: autovalidateMode,
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
                    tr(context)!.screen_create_switch_perform
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

  Future<void> _doOnPressed(BuildContext context) async {
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

    // Message to send
    Message message = recurrent
      ? timeSlotSeed.createMessage(
        context,
        recurrent: true,
        start: recurrentData.start,
        end: recurrentData.end,
        days: recurrentData.days
      )
      : timeSlotSeed.createMessage(context)
    ;

    await TimeSlotService()
      .setAll(timeSlots)
      .then((_) {
        if (!doNotNotify) {
          MessagesService().send(message);
        }
      })
    ;
  }

  TimeSlot _prepareSeed() {
    // Status: admin/club does not need acknowledge!
    TimeSlotStatus status = user.hasAccessTo(current.location)
        || AdminService().isAdminMode
        || AdminService().actAsClub
        ? TimeSlotStatus.ok
        : TimeSlotStatus.awaiting
    ;

    // Act as club ?
    String? ownerId = AdminService().actAsClub ? clubId : null;

    DateTime? date;
    Duration? duration;

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

    return current.copyWith(
      ownerId: ownerId,
      status: status,
      date: date,
      duration: duration
    );
  }

}

