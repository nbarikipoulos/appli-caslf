import 'package:flutter/material.dart';

enum UserType {
  beginner(icon: Icons.star_half, color: Colors.amber),
  confirmed(icon: Icons.grade, color: Colors.amber),
  former(icon: Icons.ac_unit, color: Colors.amber),
  guest(icon: Icons.face, color: Colors.blueGrey);

  final IconData icon;
  final Color color;

  const UserType({
    required this.icon,
    required this.color
  });

}