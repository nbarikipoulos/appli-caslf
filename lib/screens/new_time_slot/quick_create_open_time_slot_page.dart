import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/location/location_action.dart';
import 'package:caslf/models/message/message.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_extra.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/validator/rule_engine.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/location_status_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/preferences_service.dart';
import 'package:caslf/services/rules_service.dart';
import 'package:caslf/services/time_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/theme/theme_utils.dart'
  show primary;
import 'package:caslf/utils/misc_utils.dart';
import 'package:caslf/utils/string_utils.dart';
import 'package:caslf/utils/time_slot_utils.dart';
import 'package:caslf/utils/time_utils.dart';
import 'package:caslf/widgets/heading_item.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/my_title.dart';
import 'package:caslf/widgets/time/duration_form_field.dart';
import 'package:caslf/widgets/time_slot/create/where_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QuickCreateOpenTimeSlotPage extends StatefulWidget {
  const QuickCreateOpenTimeSlotPage({super.key});

  @override
  State<QuickCreateOpenTimeSlotPage> createState() => QuickCreateOpenTimeSlotPageState();
}

class QuickCreateOpenTimeSlotPageState extends State<QuickCreateOpenTimeSlotPage> {
  final user = UserService().current;

  //FIXME Use only in Form; something is wrong at init time, to understand...
  final autovalidateMode = AutovalidateMode.always;

  late TimeSlot current;

  final _formKey = GlobalKey<FormState>();

  final _locationT0 = Location.ground;

  late DurationEditingController _durationController;
  bool _durationHasBeenChanged = false;

  TimeSlot get defaultTimeSlot => TimeSlot(
    ownerId: user.uid,
    location: _locationT0,
    type: TimeSlotType.common,
    extra: { TimeSlotExtra.casual },
    date: Precision.adjustDate(TimeService().now),
    duration: PreferencesService().getDefaultDurationFor(
      _locationT0
    ),
    status: TimeSlotStatus.ok
  );

  @override
  void initState() {
    super.initState();

    current = defaultTimeSlot.copyWith(
      ownerId: user.uid
    );

    _durationController = DurationEditingController(
      initialValue: current.duration
    );
  }

  @override
  Widget build(BuildContext context) {
    RulesEngine ruleEngine = RulesService().create(context);

    return Scaffold(
        appBar: AppBar(
        title: MyTitle(
          title: tr(context)!.screen_quick_create_open_title,
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
                  child: HeadingItem(
                    title: tr(context)!.screen_quick_create_open_where
                      .toCapitalized
                    )
                ),
                WhereForm(
                  locations: _getLocations(),
                  initialValue: current.location,
                  onChanged: (Location value) {
                    setState(() {
                      current.location = value;
                      if (!_durationHasBeenChanged) {
                        final duration = PreferencesService()
                          .getDefaultDurationFor(value)
                        ;
                        current.duration = duration;
                        _durationController.data = duration;
                      }
                    });
                  }
                ),
                Center(
                  child: HeadingItem(
                    title: tr(context)!.screen_quick_create_open_how_long
                      .toCapitalized
                  )
                ),
                DurationFormField(
                  controller: _durationController,
                  // initialDuration: current.duration,
                  autovalidateMode: autovalidateMode,
                  onChanged: (Duration duration) {
                    setState(() {
                      current.duration = duration;
                      _durationHasBeenChanged = true;
                    });
                  },
                  validator: (duration) {
                    String? msg;
                    TimeSlot ts = current.copyWith(duration: duration);

                    msg = ruleEngine.validate(
                      duration,
                      'duration.zero'
                    );

                    msg ??= ruleEngine.validate(
                      ts,
                      'timeSlot.is.conflicting'
                    );

                    return msg;
                  }
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  child: Text(
                    tr(context)!.screen_quick_create_open_perform
                  ),
                  onPressed: () async {
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
    // Message to send
    Message message = current.openCloseMessage(
      context,
      action: LocationAction.open
    );

    await TimeSlotService()
      .set(current) // Create the timeSlot
      .then((_) => LocationStatusService().open(current.location)) // Open it
      .then((_) { // Notify
        MessagesService().send(message);
      })
    ;
  }

  List<Location> _getLocations() => AdminService().isAdminMode
    ? Location.helper.values
    : user.grant?.accesses ?? []
  ;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}
