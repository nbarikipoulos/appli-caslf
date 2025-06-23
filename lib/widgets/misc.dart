import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const iconOk = Icon(Icons.done, color: Colors.green);
const iconNotOk = Icon(Icons.close, color: Colors.redAccent);

Future showSimpleAlertDialog(
    BuildContext context,
    String message
    ) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
            child: Text(context.localization.ok),
            onPressed: () { context.pop(); }
        )
      ],
    )
);
