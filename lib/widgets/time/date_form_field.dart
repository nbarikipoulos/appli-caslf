import 'package:caslf/extensions/date_time_ext.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/time/extended_text_controller.dart';
import 'package:flutter/material.dart';

class DateFormField extends StatefulWidget {
  final bool enabled;
  final DateTimeEditingController? controller;
  final DateTime? initialDate;
  final DateTime? lastDate;
  final InputDecoration? decoration;
  final AutovalidateMode? autovalidateMode;
  final void Function (DateTime dateTime) onChanged;
  final FormFieldValidator<DateTime>? validator;

  const DateFormField({
    this.enabled = true,
    this.controller,
    this.initialDate,
    this.lastDate,
    this.decoration,
    this.autovalidateMode,
    required this.onChanged,
    this.validator,
    super.key,
  }) : assert(initialDate == null || controller == null);

  @override
  State<StatefulWidget> createState() => DateFormFieldState();
}

class DateFormFieldState extends State<DateFormField> {

  late DateTimeEditingController controller;
  late DateTime lastDate;

  @override
  void initState() {
    super.initState();

    var t0 =  widget.initialDate ?? DateTime.now();

    controller =
      widget.controller
      ?? DateTimeEditingController(
        initialValue: t0
      )
    ;

    // Number of months
    // FIXME
    const n = 1;

    lastDate = t0.copyWith(
      month: t0.month + n + 1,
      day: 0
    );

  }

  @override
  Widget build(BuildContext context) => TextFormField(
    enabled: widget.enabled,
    controller: controller,
    autovalidateMode: widget.autovalidateMode,
    readOnly: true,
    enableInteractiveSelection: false,
    decoration: widget.decoration ?? InputDecoration(
      labelText: tr(context)!.day,
      prefixIcon: const Icon(Icons.calendar_month)
    ),
    validator: (_) => widget.validator?.call(controller.data),
    onTap: () async => {
      showDatePicker(
        context: context,
        initialDate: controller.data,
        firstDate: DateTime.now(),
        lastDate: widget.lastDate ?? DateTime(2100),
      ).then( (date) {
        if (date != null) {
          controller.data = date;
          widget.onChanged.call(date);
        }
      })
    },
  );
}

class DateTimeEditingController extends ExtendedEditingController<DateTime> {
  DateTimeEditingController({ super.initialValue });

  @override
  void updateText() {
    text = data?.getDayAsString() ?? '';
  }
}