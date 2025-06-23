import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension TimeOfDayExtension on TimeOfDay {
  String toHHMM({
    String separator = 'h'
  }) {
    final f = NumberFormat('00');

    return '${f.format(hour)}$separator${f.format(minute)}';
  }
}
