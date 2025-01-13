import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

class DefaultValuesPage extends StatefulWidget {
  const DefaultValuesPage({super.key});

  @override
  State<DefaultValuesPage> createState() => _DefaultValuesPageState();
}

class _DefaultValuesPageState extends State<DefaultValuesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            tr(context)!.screen_default_title
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '\\(o_o)/',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(tr(context)!.nothing)
              ],
            ),
          ),
        )
    );
  }
}