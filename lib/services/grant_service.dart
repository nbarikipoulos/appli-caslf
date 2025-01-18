import 'package:caslf/constants.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/user/user_data.dart';
import 'package:caslf/models/user/user_type.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/service.dart';
import 'package:caslf/services/user_service.dart';

class GrantService implements Service {
  AdminService adminService;

  GrantService({required this.adminService});

  //
  // All available grants below
  //

  // Aka can access to the create TS pages
  bool get canAddTimeSlot => switch(_user.type) {
    UserType.confirmed || UserType.guest => true,
    _ => false
  } || actAsClub;

  // Aka can at last update the db! "Ceinture et Bretelles"
  bool get canReallyAddTimeSlot => _user.type == UserType.confirmed;

  bool get allowRecurrentTimeSlot => adminService.allowRecurrentTimeSlot;

  bool canDeleteTimeSlot(TimeSlot timeSlot) => 
    _user.type != UserType.guest 
    && (
      timeSlot.ownerId == _user.uid
      || (
        timeSlot.ownerId == clubId &&
        actAsClub
      )
      || adminService.isAdminMode
    )
  ;

  bool get canNotNotify => adminService.isAdminMode || actAsClub;

  bool get canChangeTimeSlotType => actAsClub;

  bool get canActivateAutoOpen => actAsClub;

  bool get actAsClub => adminService.actAsClub;

  bool hasAccessTo(Location location) => _user.hasAccessTo(location)
    || actAsClub
    || adminService.isAdminMode
  ;

  //
  // Manage 'guest' user
  //

  bool get isAllowedToSendNotification => switch(_user.type) {
    UserType.beginner || UserType.confirmed => true,
    _ => false
  };

  UserData get _user => UserService().current;

  @override
  Future<void> clear() async {
    // Do nothing
  }

  @override
  Future<void> init() async {
    // Do nothing
  }

}