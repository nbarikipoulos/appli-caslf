import 'package:flutter/material.dart';

class TimeSlotMessage extends StatelessWidget {
  final String message;
  final TextStyle? style;

  const TimeSlotMessage({
    super.key,
    required this.message,
    this.style
  });

  @override
  Widget build(BuildContext context) => Text(
    message,
    style: style,
      overflow: TextOverflow.ellipsis,
  );
}