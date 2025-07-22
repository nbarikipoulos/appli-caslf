import 'package:caslf/extensions/date_time_ext.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/time_service.dart';
import 'package:caslf/services/time_slot_service.dart';
import 'package:caslf/utils/day_type.dart';
import 'package:caslf/widgets/time_slot/card/time_slot_card.dart';
import 'package:caslf/widgets/time_slot/list/date_heading_item.dart';
import 'package:caslf/widgets/time_slot/list/dismissible_time_slot.dart';
import 'package:caslf/widgets/time_slot/list/empty_card.dart';
import 'package:caslf/widgets/time_slot/time_slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeSlotListView extends StatefulWidget {
  const TimeSlotListView({super.key});

  @override
  State<TimeSlotListView> createState() => _TimeSlotListViewState();
}

class _TimeSlotListViewState extends State<TimeSlotListView> {
  Future<void>? _future;
  int _month = TimeService().currentMonth;

  final grantService = GrantService(adminService: AdminService());

  @override
  void initState() {
    super.initState();
    // T0, do nothing
    _future = Future.value();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TimeSlotService>();
    context.watch<GrantService>();

    // Ensure build at day change...
    context.select<TimeService, int>((service) => service.currentDay);

    // ... and monthly change.
    final month = context.select<TimeService, int>(
      (service) => service.currentMonth
    );

    if (month != _month) {
      setState(() {
        _month = month;
        _future = TimeSlotService().init();
      });
    }

    var items = _items();

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return snapshot.connectionState != ConnectionState.done
        ? const Center(
          child: CircularProgressIndicator()
        )
        : Container(
            margin: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: ListView.builder(
              addAutomaticKeepAlives: true,
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];

                return _isDismissible(item)
                  ? DismissibleTimeSlot(child: item as TimeSlotWidget)
                  : item
                ;
              }
            ),
        );
      }
    );
  }

  bool _isDismissible(Widget item) =>
    item is TimeSlotWidget
    && item.timeSlot.location.isOpenable
    && DayType.getType(item.timeSlot.date) == DayType.today
    && grantService.hasAccessTo(item.timeSlot.location)
    && !(
      item.timeSlot.type == TimeSlotType.closed
      || item.timeSlot.type == TimeSlotType.maintenance
    )
  ;

  List<Widget> _items() {
    var result = <Widget>[];

    final timeSlots = TimeSlotService().timeSlots;

    DateTime today = DateTime
      .now()
      .toDayDate()
    ;

    DateTime tomorrow = today.copyWith(day: today.day + 1);

    f(DateTime day) {
      var tss = timeSlots[day];
      return [
        DateHeadingItem(date: day),
        ...tss == null || tss.isEmpty
          ? [const EmptyCard()]
          : tss.map((timeSlot) => TimeSlotCard(timeSlot: timeSlot))
            .toList()
      ];
    }

    // Move to today, or first available day...
    var iterable = timeSlots.keys.skipWhile(
      (day) => day.isBefore(today)
    );

    if (iterable.isEmpty) { // ...if any
      result.addAll([...f(today), ...f(tomorrow)]);
    } else { // Then check for today and tomorrow (always displayed)
      for (var day in [today, tomorrow]) {
        result.addAll(f(day));
        if (iterable.isNotEmpty && iterable.first == day) { // Move to next
          iterable = iterable.skip(1); // then it could be empty once again
        }
      }
    }

    var iterator = iterable.iterator;

    while (iterator.moveNext()) { // Main add
      result.addAll(f(iterator.current));
    }

    return result;
  }
}
