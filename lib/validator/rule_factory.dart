import 'package:caslf/validator/rule.dart';
import 'package:flutter/material.dart';

class RuleFactory {
  RuleFactory._();

  static RuleFactory? _instance;
  factory RuleFactory() => _instance ??= RuleFactory._();

  Rule<T> create<T>(
    String id,
    String? Function(
      BuildContext,
      T,
      [Map? parameters]
    ) validator
  ) => Rule<T>(
    id: id,
    validator: validator
  );
}
