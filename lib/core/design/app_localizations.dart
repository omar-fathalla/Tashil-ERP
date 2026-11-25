import 'package:material_ui/material_ui.dart';

/// Arabic-first locale setup shared by the app and the playground.
///
/// `ar` makes the whole tree RTL and gives Arabic labels to built-in M3
/// widgets (date picker, time picker, text selection menu, …).
abstract final class TashilLocale {
  static const arabic = Locale('ar', 'EG');
  static const supported = [arabic, Locale('en')];

  /// Material + Cupertino + Widgets localizations.
  static const delegates = GlobalMaterialLocalizations.delegates;
}
