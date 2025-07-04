import 'package:caslf/utils/enum_helper.dart';

enum TimeSlotExtra {
  unknown,
  casual,
  club;

  static final EnumHelper<TimeSlotExtra> helper = EnumHelper(
    TimeSlotExtra.values,
    TimeSlotExtra.unknown
  );
}