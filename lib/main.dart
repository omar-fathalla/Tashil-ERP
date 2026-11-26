import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/design/app_localizations.dart';
import 'core/design/color_schemes.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: TashilApp()));
}

class TashilApp extends StatefulWidget {
  const TashilApp({super.key});

  @override
  State<TashilApp> createState() => _TashilAppState();
}

class _TashilAppState extends State<TashilApp> {
  final _colors = TashilColorController();

  @override
  void dispose() {
    _colors.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TashilColorScope(
      controller: _colors,
      builder: (context, themes) => MaterialApp(
        title: 'Tashil ERP',
        debugShowCheckedModeBanner: false,
        theme: themes.light,
        darkTheme: themes.dark,
        // System high-contrast setting (M3: three contrast levels).
        highContrastTheme: themes.highContrastLight,
        highContrastDarkTheme: themes.highContrastDark,
        // Arabic-first UI on the SUNMI device; the `ar` locale makes it RTL.
        locale: TashilLocale.arabic,
        supportedLocales: TashilLocale.supported,
        localizationsDelegates: TashilLocale.delegates,
        home: const HomeScreen(),
      ),
    );
  }
}
