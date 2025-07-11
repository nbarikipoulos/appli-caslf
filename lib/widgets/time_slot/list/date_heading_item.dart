import 'package:caslf/extensions/string_ext.dart';
import 'package:caslf/utils/day_type.dart';
import 'package:caslf/widgets/heading_item.dart';
import 'package:flutter/material.dart';

class DateHeadingItem extends StatelessWidget {
  const DateHeadingItem({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: HeadingItem(
        title: dayDateLabel(context, date).toCapitalized
      ),
    );
}