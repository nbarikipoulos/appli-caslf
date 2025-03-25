import 'package:caslf/utils/date_utils.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/switch_list_tile_form.dart';
import 'package:caslf/widgets/time/date_form_field.dart';
import 'package:caslf/widgets/time/duration_form_field.dart';
import 'package:caslf/widgets/time/time_of_day_form_field.dart';
import 'package:flutter/material.dart';

typedef WhenFormData = ({
  DateTime date,
  Duration duration,
  bool isAllDay
});

class WhenForm extends StatefulWidget {
  final DateTime initialDate;
  final Duration initialDuration;
  final bool allowAllDay;
  final bool isAllDay;
  final bool canChangeDay;
  final void Function (WhenFormData data) onChanged;
  final AutovalidateMode? autovalidateMode;
  final String? Function(WhenFormData data)? validator;

  const WhenForm({
    super.key,
    required this.initialDate,
    required  this.initialDuration,
    this.allowAllDay = false,
    this.isAllDay = false,
    this.canChangeDay = true,
    required this.onChanged,
    this.autovalidateMode,
    this.validator
  });

  @override
  State<StatefulWidget> createState() => _WhenFormState();
}

class _WhenFormState extends State<WhenForm>{
  late DateTime selectedDate;
  late Duration selectedDuration;
  late bool isAllDay;

  late DurationEditingController _durationController;
  bool _hasDurationChanged = false;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.initialDate;
    selectedDuration = widget.initialDuration;
    isAllDay = widget.isAllDay;

    _durationController = DurationEditingController(
      initialValue: widget.initialDuration
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        DateFormField(
          enabled: widget.canChangeDay,
          initialDate: widget.initialDate,
          lastDate: null,
          autovalidateMode: widget.autovalidateMode,
          onChanged: (DateTime date) {
            TimeOfDay time = TimeOfDay.fromDateTime(selectedDate);
            setState(() {
              selectedDate = date.copyWithTimeOfDay(time);
            });
            widget.onChanged.call(_data());
          },
          validator: (value) {
            if (selectedDate.isBefore(DateTime.now())){
              return tr(context)!.start_time_expired;
            }

            return widget.validator?.call(_data());
          }
        ),
        if (!isAllDay) ...[
          TimeOfDayFormField(
            initialTime: TimeOfDay.fromDateTime(selectedDate),
            autovalidateMode: widget.autovalidateMode,
            onChanged: (TimeOfDay time) {
              setState(() {
                selectedDate = selectedDate.copyWithTimeOfDay(time);
              });
              widget.onChanged.call(_data());
            },
            validator: (value) {
              if (selectedDate.isBefore(DateTime.now())){
                return tr(context)!.start_time_expired;
              }

              return widget.validator?.call(_data());
            }
          )
          ,DurationFormField(
            controller: _durationController,
            // initialDuration: widget.initialDuration,
            autovalidateMode: widget.autovalidateMode,
            onChanged: (Duration duration) {
              setState(() {
                selectedDuration = duration;
                _hasDurationChanged = true;
              });
              widget.onChanged.call(_data());
            },
            validator: (value) {
              if (value!.inMinutes == 0) {
                return tr(context)!.duration_is_zero;
              }

              return widget.validator?.call(_data());
            }
        )],
        if (widget.allowAllDay) SwitchListTileFormField(
          initialValue: isAllDay,
          autovalidateMode: widget.autovalidateMode,
          title: Text(
            tr(context)!.screen_create_switch_all_day
          ),
          onChanged: (value) {
            setState(() { isAllDay = value; });
            widget.onChanged.call(_data());
          },
          validator: (value) => widget.validator?.call(_data())
        )
      ] ,
    );
  }

  WhenFormData _data() => (
    date: selectedDate,
    duration: selectedDuration,
    isAllDay: isAllDay
  );

  @override
  void didUpdateWidget(covariant WhenForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldInitialDuration = oldWidget.initialDuration;
    final newInitialDuration = widget.initialDuration;

    bool hasInitialDurationChanged = oldInitialDuration
      .compareTo(newInitialDuration) != 0
    ;



    if (hasInitialDurationChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _durationController.data = newInitialDuration;
          if (!_hasDurationChanged) {
            selectedDuration = newInitialDuration;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}