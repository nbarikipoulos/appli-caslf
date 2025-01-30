import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    AdminService adminService = context.watch<AdminService>();

    return Scaffold(
        appBar: AppBar(
          title: Text(
            tr(context)!.screen_admin_title
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text(
                    tr(context)!.screen_admin_item_admin_title
                  ),
                  subtitle: Text(
                    tr(context)!.screen_admin_item_admin_subtitle
                  ),
                  value: adminService.isAdminMode,
                  onChanged: (bool value) {
                    adminService.isAdminMode = value;
                  },
                  secondary: const Icon(Icons.lock_open)
                ),
                SwitchListTile(
                    title: Text(
                      tr(context)!.screen_admin_item_recurrent_title
                    ),
                    subtitle: Text(
                      tr(context)!.screen_admin_item_recurrent_subtitle
                    ),
                    value: adminService.allowRecurrentTimeSlot,
                    onChanged: (bool value) {
                      adminService.allowRecurrentTimeSlot = value;
                    },
                    secondary: const Icon(Icons.repeat)
                ),
                SwitchListTile(
                  title: Text(
                    tr(context)!.screen_admin_item_time_limit_title
                  ),
                  subtitle: Text(
                    tr(context)!.screen_admin_item_time_limit_subtitle
                  ),
                  value: adminService.removeTimeLimit,
                  onChanged: (bool value) async {
                    adminService.removeTimeLimit = value;
                    await TimeSlotService().toggleTimeLimitation();
                  },
                  secondary: const Icon(Icons.all_inclusive)
                )
              ],
            ),
          ),
        )
    );
  }
}
