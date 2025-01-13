import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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