import 'package:caslf/models/location/location.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/toggle_buttons_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WhereForm extends StatefulWidget {
  final List<Location> locations;
  final Location initialValue;
  final void Function (Location location) onChanged;

  const WhereForm({
    super.key,
    required this.locations,
    required  this.initialValue,
    required this.onChanged
  });

  @override
  State<StatefulWidget> createState() => _WhereFormState();
}

class _WhereFormState extends State<WhereForm>{
  final user = UserService().current;

  late Location selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    GrantService grantService = context.watch<GrantService>();
    selected = widget.initialValue;
    bool hasAccess = grantService.hasAccessTo(selected);

    return Wrap(
      children: [
        ToggleButtonsFormField<Location>(
          values: widget.locations,
          initialValues: [widget.initialValue],
          itemBuilder: (location) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(location.icon, color: location.color),
                const SizedBox(width: 8),
                Text(tr(context)!.location(location.name))
              ],
            )
          ),
          onPressed: (values) {
            setState(() {
              selected = values.first;
            });
            widget.onChanged.call(values.first);
          }
        ),
        if (!hasAccess) ListTile(
          iconColor: Colors.deepOrange,
          leading: const Icon(Icons.warning),
          title: Text(
            tr(context)!.location_no_access
          )
        )
      ]
    );
  }

}