import 'package:flutter/material.dart';

class Rule<T> {
  final String id;
  final String? Function(
    BuildContext context,
    T input,
    [Map? parameters]
  ) validator;

  Rule({
    required this.id,
    required this.validator
  });

  String? validate(
    BuildContext context,
    T input,
    [Map? parameters]
  ) => Function.apply(validator, [context, input, parameters]);
}
