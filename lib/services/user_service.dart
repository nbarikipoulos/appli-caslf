import 'dart:async';

import 'package:caslf/constants.dart';
import 'package:caslf/models/user/user_data.dart';
import 'package:caslf/models/user/user_grant.dart';
import 'package:caslf/services/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
  hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';

class UserService with ChangeNotifier implements Service  {
  UserService._();

  static UserService? _instance;
  factory UserService() => _instance ??= UserService._();

  final _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _usersSubscription;
  final String _collectionId = 'users';

  final Map<String, UserData?> _users = {};
  UserData? _currentUser;

  UserData get current => _currentUser!;

  Future<UserData?> user(String uid, {bool full = false}) async {
    if (!_users.containsKey(uid)) {
      UserData? user = await _userFromDB(uid, full: full);
      _users[uid] = user;
  }
    return _users[uid];
  }

  UserData? userSync(String uid, {bool full = false}) => _users[uid];

  Future<void> updateDisplayName(
    String name
  ) async => _db
    .collection(_collectionId)
    .doc(current.uid)
    .update({'display_name' : name})
    .then((_) {
      // Arffff....
      _currentUser?.displayName = name;
      _users[_currentUser!.uid]!.displayName = name;
    })
  ;

  Future<UserData?> _userFromDB(
    String uid,
    {bool full = false}
  ) async {

    UserGrant? grant = full
      ? await _getUserGrant(uid)
      : null
    ;

    final snapshot = await _db
      .collection(_collectionId)
      .doc(uid)
      .withConverter(
        fromFirestore: UserData.fromFirestore,
        toFirestore: (userData, _) => userData.toFirestore()
      ).get()
    ;

    return snapshot.data() != null ?
      UserData.from(
        snapshot.data()!,
        grant: grant
      ) : null;
  }

  Future<UserGrant?> _getUserGrant(String uid) => _db.collection('private')
    .doc(uid)
    .withConverter(
      fromFirestore: UserGrant.fromFirestore,
      toFirestore: (grant, _) => grant.toFirestore()
    ).get()
    .then(
       (snapshot) => snapshot.data() ?? UserGrant()
    )
  ;

  @override
  Future<void> init() async {
    //
    // Add current user to cache
    //

    String uid = FirebaseAuth.instance.currentUser!.uid;

    var userData = await user(uid, full: true);

    // More or less the first connection for 'common' users
    // aka user which has not been added by hand in the
    // collection 'users' with specific grants.
    // then we need to add it now.
    userData ??= await _db.collection(_collectionId)
      .doc(uid)
      .set({})
      .then((_) {
        _users.remove(uid); // Clean-up the users store.
        // Query the db once again
        return user(uid, full: true);
      }
    );

    _currentUser = userData!;

    //
    // Add user representing the club by default
    //
    await user(clubId);

    // Add listener on CHANGE on (BASIC) user data
    _usersSubscription = _db
      .collection(_collectionId)
      .withConverter<UserData>(
        fromFirestore: UserData.fromFirestore,
        toFirestore: (userData, _) => userData.toFirestore()
      )
      .snapshots()
      .listen((event) {
        bool shouldNotifyListener = false;

        for (var change in event.docChanges) {
          UserData input = change.doc.data()!;

          if (change.type == DocumentChangeType.modified) {
            _users[input.uid] = input;
            shouldNotifyListener = true;
          }
        }

        if (shouldNotifyListener) {
          notifyListeners();
        }
      })
    ;
  }

  @override
  Future<void> clear() async {
    await _usersSubscription?.cancel();
    _currentUser = null;
    _users.clear();
  }

}