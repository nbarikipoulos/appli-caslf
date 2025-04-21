import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/user/user_type.dart';
import 'package:caslf/utils/other.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserGrant {
  final UserType type;
  final List<Location> accesses;
  final bool isAdmin;
  final bool canActAsClub;
  final bool isWriter;

  UserGrant._({
    required this.type,
    required this.accesses,
    required this.canActAsClub,
    required this.isAdmin,
    required this.isWriter,
  });

  factory UserGrant({
    UserType? type,
    List<Location>? accesses,
    bool? canActAsClub,
    bool? isAdmin,
    bool? isWriter
  }) => UserGrant._(
    type: type ?? UserType.confirmed, // Most frequent
    accesses: accesses ?? const[],
    canActAsClub: canActAsClub ?? false,
    isAdmin: isAdmin ?? false,
    isWriter: isWriter ?? false
  );

  factory UserGrant.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options
  ) {

    final data = snapshot.data();

    return UserGrant(
      type: mapper<UserType>(
        data?['user_type'],
        UserType.values.byName
      ),
      accesses: listMapper(
        data?['accesses'],
        (v) => Location.helper.byName(v)
      ),
      canActAsClub: data?['can_act_as_club'],
      isAdmin: data?['is_admin'],
      isWriter: data?['is_writer']
    );
  }

  // Not intended to be used
  Map<String, dynamic> toFirestore() {
    throw UnimplementedError();
  }

}