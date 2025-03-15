import 'package:caslf/constants.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/models/user/user_data.dart';
import 'package:caslf/models/user/user_grant.dart';
import 'package:caslf/models/user/user_type.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/service.dart';
import 'package:caslf/services/user_service.dart';

class GrantService implements Service {
  AdminService adminService;

  GrantService({required this.adminService});

  //FIXME, use singleton approach (check proxied behavior)
  factory GrantService.get() => GrantService(adminService: AdminService());

  //
  // All available grants below
  //

  // Aka can access to the create TS pages
  bool get canAddTimeSlot => switch(_userGrant.type) {
    UserType.confirmed || UserType.guest => true,
    _ => false
  } || actAsClub;

  // Aka can at last update the db! "Ceinture et Bretelles"
  bool get canReallyAddTimeSlot => _userGrant.type == UserType.confirmed;

  bool get allowRecurrentTimeSlot => adminService.allowRecurrentTimeSlot;

  bool canDeleteTimeSlot(TimeSlot timeSlot) =>
    _userGrant.type != UserType.guest
    && (
      (
        timeSlot.ownerId == _user.uid
        && timeSlot.confirmedBy == null // Do not delete confirmed TimeSlot
      ) || (
        timeSlot.ownerId == clubId &&
        actAsClub
      )
      || adminService.isAdminMode
    )
  ;

  bool canEditTimeSlot(TimeSlot timeSlot) =>
    canDeleteTimeSlot(timeSlot)
    || timeSlot.confirmedBy == _user.uid // Acceptor can edit a timeSlot
  ;

  bool get canNotNotify => adminService.isAdminMode || actAsClub;

  bool get canChangeTimeSlotType => actAsClub;

  bool get canActivateAutoOpen => actAsClub;

  bool get actAsClub => adminService.actAsClub;

  bool hasAccessTo(Location location) => _user.hasAccessTo(location)
    || actAsClub
    || adminService.isAdminMode
  ;

  bool canJoinTimeSlot(TimeSlot timeSlot) {
    bool result = false;
    final UserType userType = _user.grant!.type;

    switch(userType) {
      case UserType.confirmed:
      case UserType.guest: // blocked later
        result = true;
        break;
      case UserType.beginner:
        result =
          timeSlot.type == TimeSlotType.maintenance // They can come :D
          || timeSlot.type == TimeSlotType.event
          || timeSlot.location != Location.ground
        ;
        break;
      default: result = false; break;
    }

    return result;
  }

  //
  // Manage 'guest' user
  //

  bool get isAllowedToSendNotification => switch(_userGrant.type) {
    UserType.beginner || UserType.confirmed => true,
    _ => false
  };

  UserData get _user => UserService().current;
  UserGrant get _userGrant => _user.grant!;

  @override
  Future<void> clear() async {
    // Do nothing
  }

  @override
  Future<void> init() async {
    // Do nothing
  }

}