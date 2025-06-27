import 'package:caslf/extensions/string_ext.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/user/user_data.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/my_title.dart';
import 'package:caslf/widgets/time_slot/list/keep_alive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExtraDetailsPart extends StatefulWidget {
  final TimeSlot timeSlot;

  const ExtraDetailsPart({
    super.key,
    required this.timeSlot
  });

  @override
  State<ExtraDetailsPart> createState() => _ExtraDetailsPartState();
}

class _ExtraDetailsPartState extends State<ExtraDetailsPart> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    bool showOwnerId = !widget.timeSlot.isClub
      && widget.timeSlot.ownerId != UserService().current.uid
    ;
    bool hasBeenAccepted = widget.timeSlot.status == TimeSlotStatus.accepted;

    selector(String uid) => (BuildContext context, UserService service) =>
      service.userSync(uid)?.displayName;

    return KeepAliveFutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.connectionState != ConnectionState.done
          ? const Center(
            child: CircularProgressIndicator(),
          )
          : Padding(
            padding: const EdgeInsets.fromLTRB(0,8,0,0),
            child: Column(
              spacing: 0.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showOwnerId) Selector<UserService, String?>(
                  selector: selector(widget.timeSlot.ownerId),
                  builder: (context, name, __) => MyTitle(
                    title: tr(context)!.created_by(
                      _toName(name, widget.timeSlot.ownerId)
                    )
                  )
                ),
                if (hasBeenAccepted) Selector<UserService, String?>(
                  selector: selector(widget.timeSlot.confirmedBy!),
                  builder: (context, name, __) => MyTitle(
                    title: tr(context)!.accepted_by(
                      _toName(name, widget.timeSlot.confirmedBy!)
                    )
                  )
                ),
                if (widget.timeSlot.hasAttendees) ExpansionTile(
                  dense: true,
                  minTileHeight: 0,
                  childrenPadding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  title: Text(tr(context)!.players),
                  children: _attendeeUids.map( (uid) =>
                    Selector<UserService, String?>(
                      selector: selector(uid),
                      builder: (context, name, __) => MyTitle(
                        title: _toName(name, uid)
                      )
                    )
                  ).toList()
               ),
             ],
           ),
         );
      }
    );
  }

  List<String> get _attendeeUids => [
    if (!widget.timeSlot.isClub) widget.timeSlot.ownerId,
    if (widget.timeSlot.confirmedBy != null) widget.timeSlot.confirmedBy!,
    ...widget.timeSlot.attendees!
  ];

  String _toName(String? name, String uid) {
    if (uid == UserService().current.uid) { //Early exit
      return tr(context)!.you.toCapitalized;
    }

    return name ?? uid;
  }


  Future<void> _init() async {
    final timeSlot = widget.timeSlot;

    Future<UserData?> f(String uid) => UserService().user(uid);

    List<String> uids = [
      timeSlot.ownerId,
      if (timeSlot.confirmedBy != null) timeSlot.confirmedBy!,
      if (timeSlot.hasAttendees) ...timeSlot.attendees!
    ];

    await Future.wait(uids.map(f));
  }
}
