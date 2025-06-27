import 'package:caslf/services/service.dart';
import 'package:flutter/material.dart';

class AdminService with ChangeNotifier implements Service {
  AdminService._();

  static AdminService? _instance;

  factory AdminService() => _instance ??= AdminService._();

  bool _isAdminMode = false;
  bool _actAsClub = false;
  bool _allowRecurrentTimeSlot = false;
  bool _removeTimeLimit = false;
  bool _isAnonymized = true;

  bool get isAdminMode => _isAdminMode;
  set isAdminMode (bool value) {
    if (_isAdminMode != value) {
      _isAdminMode = value;
      notifyListeners();
    }
  }

  bool get actAsClub => _actAsClub;
  set actAsClub (bool value) {
    if (_actAsClub != value) {
      _actAsClub = value;
      notifyListeners();
    }
  }

  bool get allowRecurrentTimeSlot => _allowRecurrentTimeSlot;
  set allowRecurrentTimeSlot (bool value) {
    if (_allowRecurrentTimeSlot != value) {
      _allowRecurrentTimeSlot = value;
      notifyListeners();
    }
  }

  bool get removeTimeLimit => _removeTimeLimit;
  set removeTimeLimit (bool value) {
    if (_removeTimeLimit != value) {
      _removeTimeLimit = value;
      notifyListeners();
    }
  }

  bool get isAnonymized => _isAnonymized;
  set isAnonymized (bool value) {
    if (_isAnonymized != value) {
      _isAnonymized = value;
      notifyListeners();
    }
  }

  @override
  Future init() async {
    _isAdminMode = false;
    _actAsClub = false;
    _allowRecurrentTimeSlot = false;
    _removeTimeLimit = false;
    _isAnonymized = true;
  }

  // Not persisted
  @override
  Future clear () => init();

}