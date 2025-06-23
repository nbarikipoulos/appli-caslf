import 'package:caslf/extensions/time_slot/time_slot_ext.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

@Deprecated('Replaced by Attendance')
class ConfirmTimeSlot extends StatelessWidget {
  final TimeSlot timeSlot;

  const ConfirmTimeSlot({
    super.key,
    required this.timeSlot
  });

  @override
  Widget build(BuildContext context) {
    final String uid = UserService().current.uid;

    return Container(
      padding: const EdgeInsets.only(right: 0.0),
      child: IconButton(
        icon: const Icon(Icons.key),
        tooltip: tr(context)!.confirm,
        onPressed: () => TimeSlotService().accept(
          timeSlot.id,
          uid
        ).then(
          (_) => MessagesService().send(
            timeSlot // Enforce status...
              .copyWith(status: TimeSlotStatus.accepted)
              .createMessage(context)
          )
        ),
      ),
    );
  }

}
