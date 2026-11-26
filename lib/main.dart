import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/design/app_localizations.dart';
import 'core/design/app_theme.dart';
import 'core/design/tokens.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: TashilApp()));
}

class TashilApp extends StatelessWidget {
  const TashilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tashil ERP',
      debugShowCheckedModeBanner: false,
      theme: TashilTheme.light(),
      darkTheme: TashilTheme.dark(),
      // System high-contrast setting (M3: three contrast levels).
      highContrastTheme: TashilTheme.light(contrast: TashilContrast.high),
      highContrastDarkTheme: TashilTheme.dark(contrast: TashilContrast.high),
      // Arabic-first UI on the SUNMI device; the `ar` locale makes it RTL.
      locale: TashilLocale.arabic,
      supportedLocales: TashilLocale.supported,
      localizationsDelegates: TashilLocale.delegates,
      home: const HomeScreen(),
    );
  }
}
