import 'package:caslf/models/time_slot/time_slot.dart';
import 'package:flutter/cupertino.dart';

abstract class TimeSlotWidget extends Widget {
  const TimeSlotWidget({super.key});

  TimeSlot get timeSlot;

}