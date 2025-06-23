import 'package:caslf/utils/time_adjust.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';

import 'extended_text_controller.dart';

class DurationFormField extends StatefulWidget {
  final DurationEditingController? controller;
  final Duration? initialDuration;
  final InputDecoration? decoration;
  final void Function (Duration duration) onChanged;
  final AutovalidateMode? autovalidateMode;
  final FormFieldValidator<Duration>? validator;

  const DurationFormField({
    this.controller,
    this.initialDuration,
    this.decoration,
    required this.onChanged,
    this.autovalidateMode,
    this.validator,
    super.key
  }) : assert(initialDuration == null || controller == null);

  @override
  State<StatefulWidget> createState() => DurationFormFieldState();
}

class DurationFormFieldState extends State<DurationFormField> {

  late DurationEditingController controller;

  @override
  void initState() {
    super.initState();

    controller =
      widget.controller
      ?? DurationEditingController(
        initialValue: widget.initialDuration ?? const Duration(hours: 1)
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
        labelText: tr(context)!.duration,
        prefixIcon: const Icon(Icons.hourglass_bottom)
    ),
    validator: (_) => widget.validator?.call(controller.data),
    onTap: () async => {
      showDurationPicker(
        context: context,
        baseUnit: BaseUnit.minute,
        lowerBound: const Duration(hours: 1),
        upperBound: const Duration(hours: 24),
        initialTime: controller.data!,
      ).then( (duration) {
        if (duration != null) {
          Duration adjusted = Precision.adjustDuration(duration);
          controller.data = adjusted;
          widget.onChanged.call(adjusted);
         }
      })
    },
  );

}

class DurationEditingController extends ExtendedEditingController<Duration> {
  DurationEditingController({ super.initialValue });

  @override
  void updateText() {
    if (data == null) { // Early exit
      text = '';
      return;
    }

    var f = data?.inMinutes;
    var hour = data?.inHours;
    var minute = f! % 60;

    var res = '${hour}h';
    if (minute != 0) {
      res += minute.toString();
    }

    text = res;
  }
}