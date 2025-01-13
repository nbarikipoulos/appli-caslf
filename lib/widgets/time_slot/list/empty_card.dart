import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Text(
          '\\(o_o)/',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(tr(context)!.nothing)
      ],
    );
  }
}