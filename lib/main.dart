import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/design/app_localizations.dart';
import 'core/design/app_theme.dart';
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
      // Arabic-first UI on the SUNMI device; the `ar` locale makes it RTL.
      locale: TashilLocale.arabic,
      supportedLocales: TashilLocale.supported,
      localizationsDelegates: TashilLocale.delegates,
      home: const HomeScreen(),
    );
  }
}
