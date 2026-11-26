import 'package:material_ui/material_ui.dart' show BuildContext;
import 'package:notiva/l10n/app_localizations.dart' show AppLocalizations;

extension Localization on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
