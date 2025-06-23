import 'package:caslf/constants.dart';
import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/time_slot/time_slot_extra.dart';
import 'package:caslf/models/time_slot/time_slot_status.dart';
import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/utils/other.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlot implements Comparable<TimeSlot> {
  final String id;
  String ownerId;
  Location location;
  TimeSlotType type;
  Set<TimeSlotExtra>? extra;
  DateTime date;
  Duration duration;
  String? message;
  String? where; // For external location
  bool autoOpen;
  bool isAllDay;
  TimeSlotStatus status;
  String? confirmedBy;
  Set<String>? attendees;

  static const String dummyId = '---';

  TimeSlot({
    this.id = dummyId,
    required this.ownerId,
    required this.location,
    required this.type,
    this.extra,
    required this.date,
    required this.duration,
    this.message,
    this.where,
    this.autoOpen = false,
    this.isAllDay = false,
    required this.status,
    this.confirmedBy,
    this.attendees
  });

  DateTime get end => date.add(duration);

  // aka in addition to owner and "acceptor"
  bool get hasAttendees => attendees != null && attendees!.isNotEmpty;

  int get numberOfUsers =>
    (ownerId != clubId ? 1 : 0)
    + (confirmedBy != null ? 1 : 0)
    + (attendees != null ? attendees!.length : 0)
  ;

  bool isUserExpected(String uid) => ownerId == uid
    || confirmedBy == uid
    || (attendees != null && attendees!.contains(uid))
  ;

  bool hasExtra(TimeSlotExtra value) => extra != null
    && extra!.contains(value)
  ;

  @override
  int compareTo(TimeSlot other) {
    var result = 0;
    result += 100 * date.compareTo(other.date);
    result += 10 * location.compareTo(other.location);
    result += id.compareTo(other.id);

    return result;
  }

  // Note if no id is provided,
  // a timeSlot with id set to 'dummyId' will be created
  TimeSlot copyWith({
    String? id,
    String? ownerId,
    Location? location,
    TimeSlotType? type,
    Set<TimeSlotExtra>? extra,
    DateTime? date,
    Duration? duration,
    String? message,
    String? where,
    bool? autoOpen,
    bool? isAllDay,
    TimeSlotStatus? status,
    String? confirmedBy,
    Set<String>? attendees
  }) => TimeSlot(
    id: id ?? dummyId,
    ownerId: ownerId ?? this.ownerId,
    location: location ?? this.location,
    type: type ?? this.type,
    extra: listMapper<TimeSlotExtra>(
      extra ?? this.extra,
      (v) => v
    )?.toSet(),
    date: date ?? this.date,
    duration: duration ?? this.duration,
    message: message ?? this.message,
    where: where ?? this.where,
    autoOpen: autoOpen ?? this.autoOpen,
    isAllDay: isAllDay ?? this.isAllDay,
    status: status ?? this.status,
    confirmedBy: confirmedBy ?? this.confirmedBy,
    attendees: attendees ?? this.attendees
  );

  factory TimeSlot.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options
  ) {
    // TimeSlot are stored by their uids
    final String id = snapshot.reference.id;
    final data = snapshot.data();

    return TimeSlot(
      id: id,
      ownerId: data?['owner_id'],
      location: Location.helper.byName(data?['location']),
      type: TimeSlotType.helper.byName(data?['type']),
      extra: listMapper<TimeSlotExtra>(
        data?['extra'],
        (v) => TimeSlotExtra.helper.byName(v)
      )?.toSet(),
      date: data?['date'].toDate(),
      duration: Duration(minutes: data?['duration']),
      message: data?['message'],
      where: data?['where'],
      autoOpen: data?['auto_open'] ?? false,
      isAllDay: data?['is_all_day'] ?? false,
      status: TimeSlotStatus.values.byName(data?['status']),
      confirmedBy: data?['confirmed_by'], // aka null if not set
      attendees: listMapper<String>(
        data?['attendees'],
        (v) => v
      )?.toSet()
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'owner_id': ownerId,
      'location': location.name,
      'type': type.name,
      if (extra != null && extra!.isNotEmpty) 'extra': extra!.map(
        (v) => v.name).toList(),
      'date': date,
      'duration': duration.inMinutes,
      if (
        message != null
        && message!.trim().isNotEmpty
      ) 'message': message!.trim(),
      if (
        where != null
        && where!.trim().isNotEmpty
      ) 'where': where!.trim(),
      'status': status.name,
      if (autoOpen) 'auto_open' : autoOpen,
      if (isAllDay) 'is_all_day': isAllDay,
      if (confirmedBy != null) 'confirmed_by' : confirmedBy,
      if (attendees != null && attendees!.isNotEmpty) 'attendees' : attendees
    };
  }
}
