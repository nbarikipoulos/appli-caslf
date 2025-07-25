import 'package:caslf/messages/time_slot_message.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/location/location_action.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/services/location_status_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/time_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/time_slot/time_slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DismissibleTimeSlot extends StatefulWidget {
  final TimeSlotWidget child;

  const DismissibleTimeSlot({
    super.key,
    required this.child
  });

  @override
  State<DismissibleTimeSlot> createState() => _DismissibleTimeSlotState();
}

class _DismissibleTimeSlotState extends State<DismissibleTimeSlot>
  with WidgetsBindingObserver {
  late String _key;

  TimeSlot get _timeSlot => widget.child.timeSlot;
  Location get _location => _timeSlot.location;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _key = widget.child.timeSlot.id;
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() { // Enforce build
        _key = 'a$_key';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentlyOpen = context.select<LocationStatusService, bool>(
      (service) => service.locationStatuses[_location]!.isOpen
    );

    var direction = DismissDirection.none;
    if (isCurrentlyOpen) {
      direction = DismissDirection.endToStart;
    } else if (_timeSlot.end.isAfter(TimeService().now)) {
      direction = DismissDirection.startToEnd;
    }

    return Dismissible(
      key: Key(_key),
      direction: direction,
      confirmDismiss: (direction) async {
        await LocationStatusService().toggleState(_location);

        if (!_timeSlot.autoOpen) { // aka do not notify for auto opened
          final action = isCurrentlyOpen // revert op.
            ? LocationAction.close
            : LocationAction.open
          ;

          final message = TimeSlotMessageBuilder(
            context: context,
            timeSlot: _timeSlot
          ).openCloseMessage(action: action);

          MessagesService().send(message);
        }

        return Future.value(false); // i.e. do not remove item at all
      },
      background: _bgOpen(context),
      secondaryBackground: _bgClose(context),
      child: widget.child
    );
  }

  Widget _bgOpen(BuildContext context) => _background(
    direction: DismissDirection.startToEnd,
    bgColor: Colors.green,
    icon: Icons.login,
    label: tr(context)!.open
  );

  Widget _bgClose(BuildContext context) => _background(
    direction: DismissDirection.endToStart,
    bgColor: Colors.redAccent,
    icon: Icons.logout,
    label: tr(context)!.close
  );

  Widget _background({
    required DismissDirection direction,
    required Color bgColor,
    required IconData icon,
    required String label
  }) => Container(
    color: bgColor,
    margin: const EdgeInsets.symmetric(vertical: 4.0),
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      mainAxisAlignment: switch(direction) {
        DismissDirection.startToEnd => MainAxisAlignment.start,
        DismissDirection.endToStart => MainAxisAlignment.end,
        (_) => MainAxisAlignment.center // ...
      },
      children: <Widget>[
        Icon(
          icon,
          color: Colors.white,
        ),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: const TextStyle(color: Colors.white)
        )
      ]
    )
  );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
