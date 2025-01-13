import 'package:flutter/material.dart';

enum Location implements Comparable<Location> {
  ground(icon: Icons.forest, color: Colors.green),
  gymnasium(icon: Icons.maps_home_work, color: Colors.blue);

  final IconData icon;
  final Color color;

  const Location({
    required this.icon,
    required this.color
  });

  @override
  int compareTo(Location other) => other.name.compareTo(name);
}