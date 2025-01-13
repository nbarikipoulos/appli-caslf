
import 'package:flutter/material.dart';

enum Position {
  start,
  end
}

class MyTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;
  final Position position;

  const MyTitle({
    required this.title,
    this.icon,
    this.color,
    this.position = Position.end,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    final Widget label = Text(title);
    final Icon ico = Icon(icon, color: color);

    final widgets = [
      label,
      const SizedBox(width: 8),
      ico
    ];

    return icon == null
      ? label
      : Row(
        children: position == Position.end
          ? widgets
          : widgets.reversed.toList()
      )
    ;
  }

}