// Renders every playground tab to PNG with the real fonts, light and dark,
// at SUNMI V3 size (360x780 dp @2x). Not part of CI.
//
//     flutter test tool/screenshots --update-goldens
//
// Output: build/playground_shots/<brightness>_<tab>_<page>.png
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tashil_erp/features/playground/playground_screen.dart';
import 'package:tashil_erp/main_playground.dart';

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  final out = '${Directory.current.path}/build/playground_shots';
  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;

  setUpAll(() async {
    await _loadFont('Cairo', 'assets/fonts/cairo/Cairo-Variable.ttf');
    await _loadFont(
      'MaterialIcons',
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
  });

  for (final b in Brightness.values) {
    testWidgets('screenshots ${b.name}', (tester) async {
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);
      tester.view.physicalSize = const Size(720, 1560);
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.platformBrightnessTestValue = b;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await tester.pumpWidget(const PlaygroundApp());
      await _settle(tester);
      for (var i = 0; i < PlaygroundScreen.tabs.length; i++) {
        DefaultTabController.of(tester.element(find.byType(TabBarView).first))
            .animateTo(i);
        await _settle(tester);
        for (var page = 0; page < 3; page++) {
          await expectLater(
            find.byType(PlaygroundApp),
            matchesGoldenFile('$out/${b.name}_${i}_$page.png'),
          );
          await tester.dragFrom(const Offset(180, 600), const Offset(0, -560));
          await _settle(tester);
        }
        await tester.dragFrom(const Offset(180, 300), const Offset(0, 5000));
        await _settle(tester);
      }
    });
  }
}
