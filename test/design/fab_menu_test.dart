import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tashil_erp/core/design/app_theme.dart';
import 'package:tashil_erp/core/design/motion.dart';
import 'package:tashil_erp/core/design/widgets/fab_menu.dart';

void main() {
  Future<List<String>> pumpMenu(WidgetTester tester) async {
    final pressed = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: TashilTheme.light(),
        home: Scaffold(
          floatingActionButton: FabMenu(
            items: [
              for (final l in ['أ', 'ب', 'ج'])
                FabMenuItem(
                  icon: Icons.add,
                  label: l,
                  onPressed: () => pressed.add(l),
                ),
            ],
          ),
        ),
      ),
    );
    return pressed;
  }

  testWidgets('opens, focuses the close button and closes on item tap', (
    tester,
  ) async {
    final pressed = await pumpMenu(tester);
    expect(find.text('أ'), findsNothing);

    await tester.tap(find.byType(InkWell).last);
    await tester.pumpAndSettle();
    expect(find.text('أ'), findsOneWidget);
    expect(
      tester.getSemantics(find.byTooltip('قائمة الإجراءات')),
      isSemantics(isButton: true, isExpanded: true, hasExpandedState: true),
    );
    final focused = FocusManager.instance.primaryFocus;
    expect(focused?.debugLabel, 'FabMenu toggle');

    // Items are at least 48dp tall.
    expect(tester.getSize(find.text('ب').hitTestable()).height, lessThan(56));
    expect(
      tester
          .getSize(
            find.ancestor(of: find.text('ب'), matching: find.byType(InkWell)),
          )
          .height,
      greaterThanOrEqualTo(48),
    );

    await tester.tap(find.text('ب'));
    await tester.pumpAndSettle();
    expect(pressed, ['ب']);
    expect(find.text('ب'), findsNothing);
  });

  testWidgets('Esc closes the menu', (tester) async {
    await pumpMenu(tester);
    await tester.tap(find.byType(InkWell).last);
    await tester.pumpAndSettle();
    expect(find.text('ج'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('ج'), findsNothing);
  });

  test('spring tokens settle in plausible times', () {
    expect(
      TashilSpring.fastSpatial.duration,
      lessThan(TashilSpring.slowSpatial.duration),
    );
    for (final s in TashilSpring.values) {
      expect(s.duration.inMilliseconds, inInclusiveRange(100, 2000));
      expect(s.curve.transform(1), 1);
    }
  });
}
