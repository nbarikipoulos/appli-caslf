import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/location/location_action.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/services/location_status_service.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/utils/time_slot_utils.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/time_slot/time_slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DismissibleTimeSlot extends StatelessWidget {
  final TimeSlotWidget child;

  const DismissibleTimeSlot({
    super.key,
    required this.child
  });

  TimeSlot get _timeSlot => child.timeSlot;
  Location get _location => _timeSlot.location;

  @override
  Widget build(BuildContext context) {
    final isCurrentlyOpen = context.select<LocationStatusService, bool>(
      (service) => service.locationStatuses[_location]!.isOpen
    );

    final direction = switch(isCurrentlyOpen) {
      true => DismissDirection.endToStart,
      false => DismissDirection.startToEnd
    };

    return Dismissible(
      key: Key(child.timeSlot.id),
      direction: direction,
      confirmDismiss: (direction) async {
        await LocationStatusService().toggleState(_location);

        if (!_timeSlot.autoOpen) { // aka do not notify for auto opened
          final action = isCurrentlyOpen // revert op.
            ? LocationAction.close
            : LocationAction.open
          ;

          final message = _timeSlot.openCloseMessage(
            context,
            action: action
          );

          MessagesService().send(message);
        }

        return Future.value(false); // i.e. do not remove item at all
      }, // Do not remove item at all
      background: _bgOpen(context),
      secondaryBackground: _bgClose(context),
      child: child
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
    ),
  );

}