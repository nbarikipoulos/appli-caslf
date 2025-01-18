import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/user/user_grant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  String displayName;
  final UserGrant? grant;

  bool hasAccessTo(Location location) =>
    grant != null &&
    grant!.accesses.contains(location)
  ;

  UserData._({
    required this.uid,
    required this.displayName,
    required this.grant
  });

  factory UserData({
    required String uid,
    String? displayName,
    UserGrant? grant
  }) => UserData._(
    uid: uid,
    displayName: displayName ?? '---',
    grant: grant
  );

  factory UserData.from(UserData user, {
    UserGrant? grant
  }) => UserData(
    uid: user.uid,
    displayName: user.displayName,
    grant: grant
  );

  factory UserData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options
  ) {
    // Users are stored by their uid
    final String uid = snapshot.reference.id;
    final data = snapshot.data();

    return UserData(
      uid: uid,
      displayName: data?['display_name'],
    );
  }

  // Not intended to be used
  Map<String, dynamic> toFirestore() {
    throw UnimplementedError();
  }

}