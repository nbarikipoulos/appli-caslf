import 'package:caslf/constants.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/user/user_data.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/time_slot/list/keep_alive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailsPart extends StatefulWidget {
  final TimeSlot timeSlot;

  const DetailsPart({
    super.key,
    required this.timeSlot
  });

  @override
  State<DetailsPart> createState() => _DetailsPartState();
}

class _DetailsPartState extends State<DetailsPart> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    bool showOwnerId = widget.timeSlot.ownerId != clubId
      && widget.timeSlot.ownerId != UserService().current.uid
    ;
    bool hasBeenAccepted = widget.timeSlot.status == TimeSlotStatus.accepted;
    bool hasAttendees = widget.timeSlot.hasAttendees;

    selector(String id) => (BuildContext context, UserService service) =>
      service.userSync(id)?.displayName;

    return KeepAliveFutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.connectionState != ConnectionState.done
          ? const Center(
            child: CircularProgressIndicator(),
          )
         : Padding(
           padding: const EdgeInsets.all(0.0),
           child: Column(
             spacing: 4.0,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (showOwnerId) Selector<UserService, String?>(
                 selector: selector(widget.timeSlot.ownerId),
                 builder: (context, name, __) => Text(
                   tr(context)!.created_by(name ?? '???')
                 )
               ),
               if (hasBeenAccepted) Selector<UserService, String?>(
                 selector: selector(widget.timeSlot.confirmedBy!),
                 builder: (context, name, __) => Text(
                   tr(context)!.accepted_by(name ?? '???')
                 )
               ),
               if (hasAttendees) Text(
                 tr(context)!.attendees(widget.timeSlot.numberOfUsers)
               )
             ],
           ),
         );
      }
    );
  }

  // aka owner, confirmedBy
  Future<(UserData, UserData?)> _init() async {
    Future<UserData?> f(String uid) => UserService().user(uid);

    UserData owner = (await f(widget.timeSlot.ownerId))!;
    UserData? confirmedBy;
    if (widget.timeSlot.confirmedBy != null) {
      confirmedBy = (await f(widget.timeSlot.confirmedBy!));
    }

    return (owner, confirmedBy);
  }
}