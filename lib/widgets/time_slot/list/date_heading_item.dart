import 'package:caslf/utils/date_utils.dart';
import 'package:caslf/utils/string_utils.dart';
import 'package:caslf/widgets/heading_item.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

class DateHeadingItem extends StatelessWidget {
  const DateHeadingItem({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    var label = switch(DayType.getType(date)) {
      DayType.today => tr(context)!.today,
      DayType.tomorrow => tr(context)!.tomorrow,
      _ => date.getDayAsString(),
    };

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: HeadingItem(title: label.toCapitalized),
    );
  }
}