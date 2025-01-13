import 'package:caslf/services/preferences_service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:caslf/widgets/toggle_buttons_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final Map<ThemeMode, IconData> _icons = {
  ThemeMode.system: Icons.auto_mode,
  ThemeMode.light: Icons.wb_sunny_outlined,
  ThemeMode.dark: Icons.dark_mode_outlined
};

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            tr(context)!.screen_appearance_title
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Selector<PreferencesService, ThemeMode>(
                  selector: (_, service) => service.themeMode,
                  builder: (context, value, __) => ToggleButtonsFormField(
                    values: ThemeMode.values,
                    initialValues: [value],
                    itemBuilder: (theme) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(_icons[theme]!),
                          const SizedBox(width: 2),
                          Text(
                              tr(context)!.theme_mode(theme.name)
                          )
                        ],
                      ),
                    ),
                    onPressed: (values) {
                      PreferencesService().themeMode = values.first;
                    },
                  )
                ),
              ],
            ),
          ),
        )
    );
  }
}