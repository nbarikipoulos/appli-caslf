import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/location/location_status.dart';
import 'package:caslf/router/app_router.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/location_status_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/widgets/location/location_status_card.dart';
import 'package:caslf/widgets/time_slot/list/time_slot_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeSlotsPage extends StatelessWidget {
  const TimeSlotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AdminService, bool>(
      (service) => AdminService().isAdminMode
    );

    final canOpenAnyAccesses = isAdmin
      || UserService().current.grant!.accesses.isNotEmpty
    ;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children:
                  Location.helper.values
                    .where((location) => location.isOpenable)
                    .map((location) => Expanded(
                      child: Selector<LocationStatusService, LocationStatus>(
                        selector: (_, service) => service
                          .locationStatuses[location]!,
                        builder: (_, status, __) => LocationCard(
                          location: location,
                          isOpen: status.isOpen
                        )
                      )
                    )).toList(),
              ),
              const SizedBox(height: 10),
              const Expanded(
                child: TimeSlotListView(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: context.read<GrantService>().canAddTimeSlot
        ? GestureDetector(
            onLongPressUp: () => canOpenAnyAccesses
              ? NavigationHelper().router.goNamed(
                NavigationHelper().addAndOpen.name
              ) : null,
            child: FloatingActionButton(
              onPressed: () {
                NavigationHelper().router.goNamed(
                  NavigationHelper().add.name
                );
              },
              child: const Icon(Icons.add),
            ),
        )
      : null,
    );
  }
}
