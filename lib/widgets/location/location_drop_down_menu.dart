import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:caslf/models/location/location.dart';

class LocationDropDownMenu extends StatefulWidget {
  const LocationDropDownMenu({
    required this.locations,
    this.initialSelection,
    this.controller,
    InputDecorationTheme? decorationTheme,
    required this.onSelected,
    super.key
  }) : assert(initialSelection == null || controller == null),
    inputDecorationTheme = decorationTheme ?? const InputDecorationTheme(
      filled: false,
      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
    )
  ;

  final List<Location> locations;
  final Location? initialSelection;
  final LocationEditingController? controller;
  final InputDecorationTheme inputDecorationTheme;
  final Function (Location location) onSelected;

  @override
  State<StatefulWidget> createState() => LocationDropDownMenuState();
}

class LocationDropDownMenuState extends State<LocationDropDownMenu> {
  late LocationEditingController controller =
    widget.controller
    ?? LocationEditingController(
     location: widget.initialSelection!
    )
  ;

  late Location selectedLocation = controller.location;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<Location>(
      controller: controller,
      initialSelection: selectedLocation,
      leadingIcon: Icon(
        selectedLocation.icon,
        color: selectedLocation.color
      ),
      enableFilter: false,
      requestFocusOnTap: false,
      enabled: widget.locations.length != 1,
      inputDecorationTheme: widget.inputDecorationTheme,
      onSelected: (Location? location) {
        setState(() { selectedLocation = location!; });
        widget.onSelected.call(location!);
        controller.location = location;
      },
      dropdownMenuEntries: widget.locations.map<DropdownMenuEntry<Location>>(
        (Location item) => DropdownMenuEntry<Location>(
          value: item,
          label: tr(context)!.location(item.name),
          leadingIcon: Icon(
            item.icon,
            color: item.color
          ),
        )
      ).toList()
   );
  }

}

class LocationEditingController extends TextEditingController {
  LocationEditingController({
    required this.location
  });

  Location location;

}