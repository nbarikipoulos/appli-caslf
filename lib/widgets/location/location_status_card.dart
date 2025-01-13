import 'package:caslf/models/location/location.dart';
import 'package:caslf/utils/string_utils.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';

const openClose = <bool, ({String key, Color bgColor})>{
  true: (key: 'open', bgColor: Colors.green),
  false: (key: 'close', bgColor: Colors.redAccent)
};

class LocationCard extends StatelessWidget {
  final Location location;
  final bool isOpen;

  const LocationCard({
    required this.location,
    required this.isOpen,
    super.key
  });

  @override
  Widget build(BuildContext context) => _getCard(context);

  Widget _getCard(BuildContext context) {
    var v = openClose[isOpen]!;

    var statusLabel = tr(context)!.location(location.name)
      .append(
        tr(context)!.location_status(v.key),
        separator: ' '
    );

    return Card(
      color: v.bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(// radius: 20,
                backgroundColor: Colors.white,
                child: Icon(location.icon, color: location.color),
              ),
          ),
          Expanded(
            child: Text(
              statusLabel.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )
          ),
        ]
      )
    );
  }

}
