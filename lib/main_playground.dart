import 'package:material_ui/material_ui.dart';

import 'core/design/app_localizations.dart';
import 'core/design/app_theme.dart';
import 'features/playground/playground_screen.dart';

/// Standalone entry point for the component playground, no database needed:
///
///     flutter run -t lib/main_playground.dart
void main() => runApp(const PlaygroundApp());

class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tashil · Material 3',
    debugShowCheckedModeBanner: false,
    theme: TashilTheme.light(),
    darkTheme: TashilTheme.dark(),
    locale: TashilLocale.arabic,
    supportedLocales: TashilLocale.supported,
    localizationsDelegates: TashilLocale.delegates,
    home: const PlaygroundScreen(),
  );
}
