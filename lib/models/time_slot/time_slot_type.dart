import 'package:caslf/theme/theme_utils.dart'
  show primary;
import 'package:caslf/utils/enum_helper.dart';
import 'package:flutter/material.dart';

enum TimeSlotType {
  unknown(icon: Icons.warning_amber, color: Colors.red),
  common(icon: Icons.schedule, color: primary),
  event(icon: Icons.celebration, color: Colors.pinkAccent),
  competition(icon: Icons.emoji_events, color: Colors.orangeAccent),
  maintenance(icon: Icons.construction, color: Colors.brown),
  closed(icon: Icons.block, color: Colors.red);

  final IconData icon;
  final Color color;

  const TimeSlotType({
    required this.icon,
    required this.color
  });

  static final EnumHelper<TimeSlotType> helper = EnumHelper(
    TimeSlotType.values,
    TimeSlotType.unknown
  );

}
