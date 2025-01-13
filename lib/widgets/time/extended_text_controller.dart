import 'package:flutter/material.dart';

abstract class ExtendedEditingController<T> extends TextEditingController {
  T? _data;

  ExtendedEditingController({
    T? initialValue
  }) {
    _data = initialValue;
    updateText();
  }

  T? get data => _data;

  set data(T? v) {
    _data = v;
    updateText();
  }

  void updateText();
}
