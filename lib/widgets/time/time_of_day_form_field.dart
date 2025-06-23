import 'package:caslf/extensions/time_of_day_ext.dart';
import 'package:caslf/utils/time_adjust.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

import 'extended_text_controller.dart';

class TimeOfDayFormField extends StatefulWidget {
  final TimeEditingControllerOfDay? controller;
  final TimeOfDay? initialTime;
  final InputDecoration? decoration;
  final void Function (TimeOfDay timeOfDay) onChanged;
  final AutovalidateMode? autovalidateMode;
  final FormFieldValidator<TimeOfDay>? validator;

  const TimeOfDayFormField({
    this.controller,
    this.initialTime,
    this.decoration,
    required this.onChanged,
    this.autovalidateMode,
    this.validator,
    super.key
  }) : assert(initialTime == null || controller == null);

  @override
  State<StatefulWidget> createState() => TimeOfDayFormFieldState();
}

class TimeOfDayFormFieldState extends State<TimeOfDayFormField> {

  late TimeEditingControllerOfDay controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller
      ?? TimeEditingControllerOfDay(
        initialValue: widget.initialTime ?? TimeOfDay.now()
      )
    ;
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    autovalidateMode: widget.autovalidateMode,
    readOnly: true,
    enableInteractiveSelection: false,
    decoration: widget.decoration ?? InputDecoration(
      labelText: tr(context)!.time,
      prefixIcon: const Icon(Icons.schedule)
    ),
    validator: (_) => widget.validator?.call(controller.data),
    onTap: () async => {
      showTimePicker(
        initialTime: controller.data!,
        context: context,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      ).then( (timeOfDay) {
        if (timeOfDay != null) {
          TimeOfDay adjusted = Precision.adjustTimeOfDay(timeOfDay);
          controller.data = adjusted;
          widget.onChanged.call(adjusted);
        }
      })
    },
  );

}

class TimeEditingControllerOfDay extends ExtendedEditingController<TimeOfDay> {
  TimeEditingControllerOfDay({ super.initialValue });

  @override
  void updateText() {
    text = data?.toHHMM() ?? '';
  }
}