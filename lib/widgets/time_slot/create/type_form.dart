import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/toggle_buttons_form.dart';
import 'package:flutter/material.dart';

class TypeForm extends StatefulWidget {
  final List<TimeSlotType> types;
  final TimeSlotType initialValue;
  final void Function (TimeSlotType type) onChanged;

  const TypeForm({
    super.key,
    required this.types,
    required  this.initialValue,
    required this.onChanged
  });

  @override
  State<StatefulWidget> createState() => _TypeFormState();
}

class _TypeFormState extends State<TypeForm>{
  late TimeSlotType selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ToggleButtonsFormField<TimeSlotType>(
            values: widget.types,
            initialValues: [widget.initialValue],
            itemBuilder: (type) => Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Icon(type.icon, color: type.color),
                  const SizedBox(width: 4),
                  Text(tr(context)!.time_slot_type(type.name))
                ],
              )
            ),
            onPressed: (values) {
              setState(() {
                selected = values.first;
              });
              widget.onChanged.call(values.first);
            }
        ),
        // const SizedBox(height: 16),
        // const SizedBox(width: 32),
      ] ,
    );
  }

}