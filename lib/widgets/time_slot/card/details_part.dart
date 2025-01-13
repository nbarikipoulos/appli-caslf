import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/user/user_data.dart';
import 'package:caslf/services/messages_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/utils/time_slot_utils.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailsPart extends StatelessWidget {
  final TimeSlot timeSlot;

  const DetailsPart({
    super.key,
    required this.timeSlot
  });

  @override
  Widget build(BuildContext context) {
    UserData current = UserService().current;

    bool canAccept = current.hasAccessTo(timeSlot.location);
    bool isAwaiting = timeSlot.status == TimeSlotStatus.awaiting;
    bool hasBeenAccepted = timeSlot.status == TimeSlotStatus.accepted;

    selector(String id) => (BuildContext context, UserService service) => 
      service.userSync(id)?.displayName;

    return FutureBuilder(
      future: _init(),
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
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Selector<UserService, String?>(
                      selector: selector(timeSlot.ownerId),
                      builder: (context, name, __) => Text(
                        tr(context)!.created_by(name ?? '???')
                      )
                    ),
                    if(isAwaiting && canAccept) Container(
                      padding: const EdgeInsets.only(right: 0.0),
                      child: IconButton(
                        icon: const Icon(Icons.key),
                        tooltip: tr(context)!.confirm,
                        onPressed: () => TimeSlotService().accept(
                            timeSlot.id,
                            current.uid
                        ).then(
                          (_) => MessagesService().send(
                            timeSlot // Enforce status...
                              .copyWith(status: TimeSlotStatus.accepted)
                              .createMessage(context)
                          )
                        ),
                      ),
                  ),
                ],
               ),
               if (hasBeenAccepted) Selector<UserService, String?>(
                 selector: selector(timeSlot.confirmedBy!),
                 builder: (context, name, __) => Text(
                   tr(context)!.accepted_by(name ?? '???')
                 )
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

    UserData owner = (await f(timeSlot.ownerId))!;
    UserData? confirmedBy;
    if (timeSlot.confirmedBy != null) {
      confirmedBy = (await f(timeSlot.confirmedBy!));
    }

    return (owner, confirmedBy);
  }

}