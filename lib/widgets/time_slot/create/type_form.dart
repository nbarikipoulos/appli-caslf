import 'package:caslf/models/time_slot/time_slot_type.dart';
import 'package:caslf/widgets/drop_down_menu_form.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

class TypeForm extends StatefulWidget {
  final List<TimeSlotType> types;
  final TimeSlotType initialValue;
  final void Function (TimeSlotType type) onChanged;

  const TypeForm({
    super.key,
    required this.types,
    required this.initialValue,
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
    return Center(
      child: DropdownMenuFormField<TimeSlotType>(
        enabled: widget.types.length > 1,
        leadingIcon: Icon(selected.icon, color: selected.color),
        requestFocusOnTap: false,
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
        ),
        initialSelection: widget.initialValue,
        dropdownMenuEntries: widget.types.map<DropdownMenuEntry<TimeSlotType>>(
          (TimeSlotType type) => DropdownMenuEntry<TimeSlotType>(
            value: type,
            label: tr(context)!.time_slot_type(type.name),
            leadingIcon: Icon(
                type.icon,
                color: type.color
            ),
          )
        ).toList(),
        onSelected: (type) {
          setState(() {
            selected = type!;
          });
          widget.onChanged.call(selected);
        }
      ),
    );
  }
}