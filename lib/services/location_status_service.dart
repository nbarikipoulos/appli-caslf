import 'dart:async';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/location/location_status.dart';
import 'package:caslf/services/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LocationStatusService with ChangeNotifier implements Service {
  LocationStatusService._();

  static LocationStatusService? _instance;
  factory LocationStatusService() => _instance ??= LocationStatusService._();

  final locationStatuses = <Location, LocationStatus>{};

  final _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _locationStatusSubscription;
  final String _collectionId = 'location_status';

  Future<void> toggleState(Location location) async {
    LocationStatus status = locationStatuses[location]!;
    bool newState = !status.isOpen;
    status.isOpen = newState;
    return _update(location, newState);
  }

  Future<void> open(Location location) => _update(location, true);

  Future<void> close(Location location) => _update(location, false);

  Future<void> _update(
    Location location,
    bool isOpen
  ) => _db.collection(_collectionId)
    .doc(location.name)
    .update({ 'is_open' : isOpen })
  ;

  @override
  Future init() async {
    // aka remove previous listener, if any
    await clear();

    _locationStatusSubscription = FirebaseFirestore.instance
      .collection(_collectionId)
      .withConverter<LocationStatus>(
        fromFirestore: LocationStatus.fromFirestore,
        toFirestore: (LocationStatus status, _) => status.toFirestore()
      )
      .snapshots()
      .listen((event) {
        bool shouldNotifyListener = false;

        for (var change in event.docChanges) {
          LocationStatus locationStatus = change.doc.data()!;
          switch (change.type) {
            case DocumentChangeType.added: // aka for t0 init
            case DocumentChangeType.modified:
              locationStatuses[locationStatus.location] = locationStatus;
              shouldNotifyListener = true;
              break;
            default:
              // do nothing
          }
        }

        if (shouldNotifyListener) {
          notifyListeners();
        }
      })
    ;
  }

  @override
  Future clear() async {
    await _locationStatusSubscription?.cancel();
  }

}