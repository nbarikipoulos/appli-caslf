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

  bool get canAddTimeSlot => _user.type == UserType.confirmed;

  bool get allowRecurrentTimeSlot => adminService.allowRecurrentTimeSlot;

  bool canDeleteTimeSlot(TimeSlot timeSlot) => timeSlot.ownerId == _user.uid
    || adminService.isAdminMode
  ;

  bool get canNotNotify => adminService.isAdminMode || adminService.actAsClub;

  bool get canChangeTimeSlotType => adminService.actAsClub;

  bool get canActivateAutoOpen => adminService.actAsClub;

  bool get actAsClub => adminService.actAsClub;

  bool hasAccessTo(Location location) => _user.hasAccessTo(location)
    || adminService.actAsClub
    || adminService.isAdminMode
  ;

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