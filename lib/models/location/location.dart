import 'package:caslf/utils/enum_helper.dart';
import 'package:flutter/material.dart';

enum Location implements Comparable<Location> {
  unknown(icon: Icons.warning_amber, color: Colors.red, isOpenable: false),
  ground(icon: Icons.forest, color: Colors.green),
  gymnasium(icon: Icons.maps_home_work, color: Colors.blue),
  external(icon: Icons.directions, color: Colors.amberAccent, isOpenable: false);

  final IconData icon;
  final Color color;
  final bool isOpenable;

  const Location({
    required this.icon,
    required this.color,
    this.isOpenable = true
  });

  @override
  int compareTo(Location other) => other.name.compareTo(name);

  static final EnumHelper<Location> helper = EnumHelper(
    Location.values,
    Location.unknown
  );
}
