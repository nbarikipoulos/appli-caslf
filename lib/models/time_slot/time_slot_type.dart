import 'package:caslf/theme/theme_utils.dart'
  show primary;
import 'package:flutter/material.dart';

enum TimeSlotType {
  common(icon: Icons.done, color: primary),
  event(icon: Icons.celebration, color: Colors.pinkAccent),
  maintenance(icon: Icons.construction, color: Colors.brown),
  closed(icon: Icons.block, color: Colors.red);

  final IconData icon;
  final Color color;

  const TimeSlotType({
    required this.icon,
    required this.color
  });

}