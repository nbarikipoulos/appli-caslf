import 'package:caslf/utils/date_utils.dart';
import 'package:caslf/utils/day.dart';
import 'package:caslf/utils/string_utils.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/time/date_form_field.dart';
import 'package:caslf/widgets/time/duration_form_field.dart';
import 'package:caslf/widgets/time/time_of_day_form_field.dart';
import 'package:caslf/widgets/toggle_buttons_form.dart';
import 'package:flutter/material.dart';

typedef WhensFormData = ({
  DateTime start,
  DateTime end,
  List<Day> days,
  TimeOfDay timeOfDay,
  Duration duration
});

class WhensForm extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<Day> initialDayOfWeeks;
  final TimeOfDay initialTimeOfDay;
  final Duration initialDuration;
  final void Function (WhensFormData data) onChanged;
  final AutovalidateMode? autovalidateMode;

  WhensForm({
    super.key,
    required this.startDate,
    required this.endDate,
    List<Day>? initialDays,
    TimeOfDay? timeOfDay,
    required this.initialDuration,
    required this.onChanged,
    this.autovalidateMode,
  }) : initialDayOfWeeks = initialDays??[Day.monday],
    initialTimeOfDay = timeOfDay??const TimeOfDay(hour: 18, minute: 30)
  ;

  @override
  State<StatefulWidget> createState() => _WhensFormState();
}

class _WhensFormState extends State<WhensForm>{
  late DateTime startDate;
  late DateTime endDate;
  late List<Day> selectedDays;
  late TimeOfDay selectedTimeOfDay;
  late Duration selectedDuration;

  late DurationEditingController _durationController;
  bool _hasInitialDurationChanged = false;

  @override
  void initState() {
    super.initState();
    startDate = widget.startDate;
    endDate = widget.endDate;
    selectedDays = widget.initialDayOfWeeks;
    selectedTimeOfDay = widget.initialTimeOfDay;
    selectedDuration = widget.initialDuration;

    _durationController = DurationEditingController(
      initialValue: widget.initialDuration
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        DateFormField(
          initialDate: startDate,
          autovalidateMode: widget.autovalidateMode,
          lastDate: null,
          onChanged: (DateTime date) {
            startDate = date.toDayDate();
            _onChanged();
          },
          decoration: InputDecoration(
            labelText: tr(context)!.start,
            prefixIcon: const Icon(Icons.first_page)
          ),
          validator: (value) {
            if (startDate.isAfter(endDate)){
              return tr(context)!.start_end_days_inverted;
            }
            return null;
          }
        ),
        DateFormField(
          initialDate: endDate,
          lastDate: null,
          autovalidateMode: widget.autovalidateMode,
          onChanged: (DateTime date) {
            endDate = date.toDayDate();
            _onChanged();
          },
          decoration: InputDecoration(
            labelText: tr(context)!.end,
            prefixIcon: const Icon(Icons.last_page)
          ),
          validator: (value) {
            if (startDate.isAfter(endDate)){
              return tr(context)!.start_end_days_inverted;
            }
            return null;
          }
        ),
        Center(
          child: Text(
            tr(context)!.days
          )
        ),
        ToggleButtonsFormField<Day>(
          values: Day.values,
          initialValues: selectedDays,
          singleSelection: false,
          autovalidateMode: widget.autovalidateMode,
          itemBuilder: (day) => Text(
            tr(context)!.day_short(day.name).toCapitalized
          ),
          onPressed: (values) {
            selectedDays = values;
            _onChanged();
          },
          validator: (values) {
            if (values is! Iterable || values!.isEmpty) {
              return tr(context)!.select_at_least_one_day;
            }
            return null;
          },
        ),
        TimeOfDayFormField(
          initialTime: selectedTimeOfDay,
          autovalidateMode: widget.autovalidateMode,
          onChanged: (TimeOfDay time) {
            selectedTimeOfDay= time;
            _onChanged();
          }
        ),
        const SizedBox(height: 8),
        DurationFormField(
          controller: _durationController,
          // initialDuration: selectedDuration,
          autovalidateMode: widget.autovalidateMode,
          onChanged: (Duration duration) {
            selectedDuration = duration;
            _onChanged();
          },
          validator: (value) {
            if (value!.inMinutes == 0) return tr(context)!.duration_is_zero;
            return null;
          }
        ),
      ] ,
    );
  }

  void _onChanged() => widget.onChanged.call((
    start: startDate,
    end: endDate,
    days: selectedDays,
    timeOfDay: selectedTimeOfDay,
    duration: selectedDuration
  ));

  @override
  void didUpdateWidget(covariant WhensForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldInitialDuration = oldWidget.initialDuration;
    final newInitialDuration = widget.initialDuration;

    _hasInitialDurationChanged = oldInitialDuration
      .compareTo(newInitialDuration) != 0
    ;

    if (_hasInitialDurationChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          selectedDuration = newInitialDuration;
          _durationController.data = newInitialDuration;
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