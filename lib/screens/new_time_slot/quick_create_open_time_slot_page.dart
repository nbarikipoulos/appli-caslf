import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/location/location_action.dart';
import 'package:caslf/models/message/message.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/location_status_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/time_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/theme/theme_utils.dart'
  show primary;
import 'package:caslf/utils/date_utils.dart';
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

  TimeSlot get defaultTimeSlot => TimeSlot(
    ownerId: user.uid,
    location: Location.ground,
    date: Precision.adjustDate(TimeService().now),
    duration: const Duration(hours: 2),
    status: TimeSlotStatus.ok
  );

  @override
  void initState() {
    super.initState();

    current = defaultTimeSlot.copyWith(
      ownerId: user.uid
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  initialDuration: current.duration,
                  autovalidateMode: autovalidateMode,
                  onChanged: (Duration duration) {
                    setState(() { current.duration = duration; });
                  },
                  validator: (value) {
                    if (value!.inMinutes == 0) {
                      return tr(context)!.duration_is_zero;
                    }

                    TimeSlot ts = current.copyWith(duration: value);
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
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  child: Text(
                    tr(context)!.screen_quick_create_open_perform
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();

                      // Main job
                      await _doOnPressed(context);

                      // Back
                      context.pop();
                    }
                  }
                ),
              ],
            ),
          )
        ),
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

  _getLocations() => AdminService().isAdminMode
    ? Location.values
    : user.grant?.accesses;

}

