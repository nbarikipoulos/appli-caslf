import 'package:caslf/models/location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationStatus {
  final Location location;
  bool isOpen;

  LocationStatus({
    required this.location,
    this.isOpen = false,
  });

  factory LocationStatus.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options
  ) {
    // Location are stored with .name attribute as document id
    final Location location = Location
      .values
      .byName(snapshot.reference.id)
    ;
    final data = snapshot.data();

    return LocationStatus(
      location : location,
      isOpen: data?['is_open']
    );
  }

  Map<String, dynamic> toFirestore() => {
    'is_open': isOpen,
  };

}
