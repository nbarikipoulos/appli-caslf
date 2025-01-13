
import 'package:flutter/material.dart';

class SwitchListTileFormField extends FormField<bool> {
  final Widget title;
  final Widget? subtitle;
  final Widget? secondary;
  final void Function (bool value) onChanged;

  SwitchListTileFormField({
    super.key,
    required this.title,
    this.subtitle,
    this.secondary,
    required this.onChanged,
    super.onSaved,
    super.initialValue,
    super.forceErrorText,
    super.validator,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
  }): super(
    builder: (FormFieldState field) => InputDecorator(
        decoration: InputDecoration(
          errorText: field.errorText,
        ),
        child:Center(
          child: SwitchListTile(
            value: field.value!,
            title: title,
            subtitle: subtitle,
            secondary: secondary,
            onChanged: (value) {
              field.didChange(value);
              onChanged.call(value);
            }
          ),
        )
      )
    )
  ;

}
