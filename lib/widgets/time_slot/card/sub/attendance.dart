import 'package:caslf/models/message/message.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/user/user_data.dart';
import 'package:caslf/models/user/user_type.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/utils/time_slot_utils.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum _Action {join, leave}

class Attendance extends StatefulWidget {
  final TimeSlot timeSlot;
  final String userId;

  const Attendance({
    super.key,
    required this.timeSlot,
    required this.userId
  });

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late _Action _action;
  late UserData _user;

  @override
  void initState() {
    super.initState();
    _user = UserService().userSync(widget.userId)!;
    _action = widget.timeSlot.isUserExpected(_user.uid)
      ? _Action.leave
      : _Action.join
    ;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_getIcon()),
      tooltip: _tooltip(context),
      onPressed: !_isEnabled() ? null : () async => _onPressed(context)
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    var attendees = widget.timeSlot.attendees;
    Map<String, Object>? data;
    Message? message;

    if (_action == _Action.join) {
      if (_isConfirmation()) {
        TimeSlotStatus status = TimeSlotStatus.accepted;
        data = {
          'confirmed_by' : _user.uid,
          'status': status.name,
        };
        // Send message for new timeSlot as it is now confirmed
        message = widget.timeSlot // Enforce status..
          .copyWith(status: status)
          .createMessage(context)
        ;
      } else { // User is quite simply joining the timeSlot
        attendees ??= { };
        attendees.add(_user.uid);
        data = { 'attendees': attendees };
      }
    } else if (_action == _Action.leave){
      attendees!.remove(_user.uid);
      data = { 'attendees': attendees.isEmpty
        ? FieldValue.delete()
        : attendees
      };
    }

    await TimeSlotService().update(
      widget.timeSlot.id,
      data! // can not be null
    );

    if (message != null) {
      MessagesService().send(message);
    }

    setState(() {
      _action = _toggle();
    });
  }

  bool _isEnabled() => !_isOwner()
    // Acceptor of timeSlot are not allowed to leave !
    && !(_isAcceptor() && _action == _Action.leave)
    && _user.grant!.type != UserType.guest // done ahead for other users
  ;

  bool _isOwner() => widget.timeSlot.ownerId == _user.uid;

  bool _isAcceptor() => widget.timeSlot.confirmedBy != null
    && widget.timeSlot.confirmedBy == _user.uid
  ;

  bool _isConfirmation() => widget.timeSlot.status == TimeSlotStatus.awaiting
    && UserService()
      .userSync(_user.uid)
      !.hasAccessTo(widget.timeSlot.location)
  ;

  _Action _toggle() => switch(_action) {
    _Action.join => _Action.leave,
    _Action.leave => _Action.join
  };

  IconData _getIcon() => switch(_action) {
    _Action.join => Icons.person_add_alt_1,
    _Action.leave => Icons.person_remove
  };

  String _tooltip(BuildContext context) => switch(_action) {
    _Action.join => tr(context)!.tooltip_join_time_slot,
    _Action.leave => tr(context)!.tooltip_leave_time_slot,
  };

}
