import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizationExt on Widget {

  AppLocalizations? tr(BuildContext context) => AppLocalizations.of(context);
}

// extension StateFullLocalizationExt on StatefulWidget {
//   AppLocalizations? tr(BuildContext context) => AppLocalizations.of(context);
// }

extension StateLocalizationExt on State {
  AppLocalizations? tr(BuildContext context) => AppLocalizations.of(context);
}

// FIXME to use instead of extensions on Widget and State...
extension CustomContext on BuildContext{
  AppLocalizations get localization => AppLocalizations.of(this)!;
}