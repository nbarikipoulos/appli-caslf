import 'dart:async';
import 'dart:collection';

import 'package:caslf/extensions/date_time_ext.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/services/service.dart';
import 'package:caslf/services/time_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeSlotService with ChangeNotifier implements Service {
  TimeSlotService._();

  static TimeSlotService? _instance;
  factory TimeSlotService() => _instance ??= TimeSlotService._();

  final timeSlots = SplayTreeMap<DateTime, Set<TimeSlot>>(
    (ts1, ts2) => ts1.compareTo(ts2)
  );
  
  final _db = FirebaseFirestore.instance;
  Query<TimeSlot>? _query;
  StreamSubscription<QuerySnapshot>? _timeSlotsSubscription;
  final String _collectionId = 'time_slots';

  // Time limitation mgt
  bool _timeLimit = true;

  Future toggleTimeLimitation() async {
    _timeLimit = !_timeLimit;
    return init();
  }

  ({
    bool canBeAdded,
    TimeSlot? conflicting
  }) canBeAdded(TimeSlot timeSlot) {
    // Early exit: Allow many external timeSlots
    if (timeSlot.location == Location.external) {
      return (
        canBeAdded: true,
        conflicting: null
      );
    }

    final day = timeSlot.date.toDayDate();

    // Get timeSlots of the days and filter with location
    final tss = timeSlots[day]
      ?.where((ts) => ts.location == timeSlot.location)
      ?? []
    ;

    if ( // Early exit
      tss.isEmpty
    ) {
      return (canBeAdded: true, conflicting: null);
    }

    final [start, end] = [
      timeSlot.date,
      timeSlot.end
    ];

    bool isOk = true;
    var it = tss.iterator;
    TimeSlot? current;
    while (isOk && it.moveNext()) {
      current = it.current;

      if (current.id != timeSlot.id) {
        final currentStart = current.date;
        final currentEnd = current.end;
        isOk = end.compareTo(currentStart) <= 0
          || start.compareTo(currentEnd) >= 0
          && !(
            start.compareTo(currentStart) <= 0
            && end.compareTo(currentEnd) >= 0
          )
        ;
      }
    }

    return (
      canBeAdded: isOk,
      conflicting: !isOk? current : null
    );
  }

  Future<void> accept(String timeSlotId, String uid) async => update(
    timeSlotId,
    {
      'confirmed_by' : uid,
      'status': TimeSlotStatus.accepted.name,
    }
  );

  Future<void> set(TimeSlot timeSlot) async => _db
    .collection(_collectionId)
    .doc()
    .set(timeSlot.toFirestore())
  ;

  Future<void> setAll(List<TimeSlot> timeslots) async {
    final batch = _db.batch();

    var ref = _db.collection(_collectionId);

    for (var timeSlot in timeslots) {
      ref.doc().set(timeSlot.toFirestore());
    }

    return batch.commit();
  }

  Future<void> update(
    String id,
    Map<String, Object?> values
  ) => _db.collection(_collectionId)
    .doc(id)
    .update(values)
  ;

  Future<void> delete(TimeSlot timeSlot) async => _db.collection(_collectionId)
    .doc(timeSlot.id)
    .delete()
  ;

  bool _add(TimeSlot timeSlot) {
    final day = timeSlot.date.toDayDate();
    
    if (!timeSlots.containsKey(day)) {
      timeSlots[day] = SplayTreeSet<TimeSlot>();
    }

    return timeSlots[day]!.add(timeSlot);
  }

  bool _modify(TimeSlot timeSlot) {
    _removeTimeSlot(timeSlot);

    final day = timeSlot.date.toDayDate();
    timeSlots[day]!.add(timeSlot);

    return true;
  }

  bool _remove(TimeSlot timeSlot) {
    final day = timeSlot.date.toDayDate();

    _removeTimeSlot(timeSlot);

    if (timeSlots[day]!.isEmpty) {
      timeSlots.remove(day);
    }

    return true;
  }

  bool _removeTimeSlot(TimeSlot timeSlot) {
    final day = timeSlot.date.toDayDate();
    var set = timeSlots[day]!; // could not be null
    final cached = set.firstWhere((ts) => ts.id == timeSlot.id);

    set.remove(cached);

    return true;
  }

  Query<TimeSlot> _queryBuilder({
    required DateTime startDate,
    DateTime? endDate
  }) {

    f(DateTime date) => Timestamp.fromDate(date);

    var result = _db
      .collection(_collectionId)
      .withConverter<TimeSlot>(
      fromFirestore: TimeSlot.fromFirestore,
      toFirestore: (TimeSlot timeSlot, _) => timeSlot.toFirestore()
    )
    .orderBy('date')
    .where('date', isGreaterThanOrEqualTo: f(startDate))
    ;

    if (endDate != null) {
      result = result.where('date', isLessThanOrEqualTo: f(endDate));
    }

    return result;
  }

  @override
  Future<void> init() async {
    await clear();

    final DateTime today = TimeService().today;

    _query = _queryBuilder(
      startDate: today,
      endDate: _timeLimit ? TimeService().timeLimit : null
    );

    _timeSlotsSubscription = _query
      !.snapshots()
      .listen((event) {
        bool shouldNotifyListener = false;

        for (var change in event.docChanges) {
          TimeSlot input = change.doc.data()!;

          shouldNotifyListener |= switch (change.type) {
            DocumentChangeType.added => _add(input),
            DocumentChangeType.modified => _modify(input),
            DocumentChangeType.removed => _remove(input),
          };
        }

        if (shouldNotifyListener) {
          notifyListeners();
        }
      })
    ;
  }

  @override
  Future<void> clear() async {
    await _timeSlotsSubscription?.cancel();
    timeSlots.clear();
  }

}