import 'package:flutter/material.dart';

class ToggleButtonsFormField<T> extends FormField<List<T>> {
  final List<T> values;
  final List<T> initialValues;
  final Widget Function (T value) itemBuilder;
  final void Function (List<T> values) onPressed;

  ToggleButtonsFormField({
    super.key,
    required this.values,
    List<T>? initialValues,
    bool? singleSelection = true,
    required this.itemBuilder,
    required this.onPressed,
    super.onSaved,
    super.forceErrorText,
    super.validator,
    super.enabled = true,
    super.autovalidateMode,
    super.restorationId,
  }): initialValues = initialValues ?? [],
    super(
      initialValue: initialValues,
      builder: (FormFieldState<List<T>> field) {
        return InputDecorator(
          decoration: InputDecoration(
            errorText: field.errorText,
            border: InputBorder.none,
          ),
          child:Center(
            child: MyToggleButtons<T>(
              values: values,
              initialValues: initialValues,
              singleSelection: singleSelection,
              itemBuilder: itemBuilder,
              onPressed: (values) {
                field.didChange(values);
                onPressed.call(values);
              }
            ),
          )
        );
      },
    )
  ;
}

class MyToggleButtons<T> extends StatefulWidget {
  final List<T> values;
  final bool isSingleSelection;
  final List<T> initialValues;
  final Widget Function (T value) itemBuilder;
  final void Function (List<T> values) onPressed;

  const MyToggleButtons({
    super.key,
    bool? singleSelection,
    required this.values,
    List<T>? initialValues,
    required this.itemBuilder,
    required this.onPressed
  }) : isSingleSelection = singleSelection ?? true,
    initialValues = initialValues ?? const []
  ;

  @override
  State<StatefulWidget> createState() => _MyToggleButtonsState<T>();
}

class _MyToggleButtonsState<T> extends State<MyToggleButtons<T>>{
  late List<bool> _selected;

  @override
  void initState() {
    super.initState();

    _selected = List<bool>.generate(
      widget.values.length,
      (_) => false
    );

    for (T sel in widget.initialValues) {
      _selected[widget.values.indexOf(sel)] = true;
    }

  }

  @override
  Widget build(BuildContext context) => ToggleButtons(
    isSelected: _selected,
    onPressed: (int index) {
      setState(() {
        // The button that is tapped is set to true, and the others to false.
        if (widget.isSingleSelection) {
          for (int i = 0; i < _selected.length; i++) {
            _selected[i] = i == index;
          }
        } else {
          _selected[index] = !_selected[index];
        }
      });

      var values = <T>[];
      for (var i = 0; i < _selected.length; i++) {
        if (_selected[i]) {
          values.add(widget.values[i]);
        }
      }

      widget.onPressed.call(values);
    },
    children: widget.values
      .map(widget.itemBuilder.call)
      .toList(),
  );

}
