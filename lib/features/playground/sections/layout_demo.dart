import 'package:material_ui/material_ui.dart';

import '../../../core/design/layout.dart';
import '../../../core/design/money.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/button_group.dart';

/// Preview of the M3 layout scaffold: pick a breakpoint and see the same
/// invoices screen as a scaled-down window of that width.
class LayoutDemo extends StatefulWidget {
  const LayoutDemo({super.key});

  @override
  State<LayoutDemo> createState() => _LayoutDemoState();
}

class _LayoutDemoState extends State<LayoutDemo> {
  static const _widths = {
    TashilBreakpoint.compact: 360.0,
    TashilBreakpoint.medium: 700.0,
    TashilBreakpoint.expanded: 1000.0,
    TashilBreakpoint.large: 1360.0,
    TashilBreakpoint.extraLarge: 1760.0,
  };

  TashilBreakpoint _b = TashilBreakpoint.expanded;
  int? _open = 0;
  bool _contained = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final window = TashilBreakpoint.of(context);
    final b = _b;
    final width = _widths[b]!;
    final panes = switch (b) {
      TashilBreakpoint.compact || TashilBreakpoint.medium => 1,
      TashilBreakpoint.extraLarge => 3,
      _ => 2,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الشاشة دي دلوقتي: ${window.label} '
          '(${MediaQuery.sizeOf(context).width.round()}dp)',
          style: text.labelLarge,
        ),
        const SizedBox(height: TashilSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ButtonGroup<TashilBreakpoint>(
            variant: ButtonGroupVariant.connected,
            items: [
              for (final v in TashilBreakpoint.values)
                ButtonGroupItem(value: v, label: v.label),
            ],
            selected: {b},
            onSelectionChanged: (s) => setState(() => _b = s.first),
          ),
        ),
        const SizedBox(height: TashilSpacing.sm),
        Text(
          'من ${b.minWidth.round()}dp · هامش ${b.margin.round()} · '
          '${panes == 1 ? 'جزء واحد' : '$panes أجزاء، بينهم ${b.spacer.round()}'}'
          '${b.fixedPaneWidth == null ? '' : ' · القايمة ${b.fixedPaneWidth!.round()}dp'}',
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('أجزاء بخلفية (تجميع صريح)'),
          value: _contained,
          onChanged: (v) => setState(() => _contained = v),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(TashilRadius.medium),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(TashilRadius.medium),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(
                width: width,
                height: 460,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(size: Size(width, 460)),
                  child: Material(
                    color: scheme.surface,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: TashilSpacing.lg,
                          ),
                          child: PaneLayout(
                            key: ValueKey(b),
                            breakpoint: b,
                            contained: _contained,
                            showSecond: _open != null,
                            first: _List(
                              selected: _open,
                              onOpen: (i) => setState(() => _open = i),
                            ),
                            second: _open == null
                                ? null
                                : _Detail(
                                    index: _open!,
                                    onBack: b < TashilBreakpoint.expanded
                                        ? () => setState(() => _open = null)
                                        : null,
                                  ),
                            placeholder: const Center(
                              child: Text('اختار فاتورة من القايمة'),
                            ),
                            third: const _Filters(),
                          ),
                        ),
                        PositionedDirectional(
                          end: b.margin,
                          bottom: TashilSpacing.lg,
                          child: AdaptiveFab(
                            breakpoint: b,
                            icon: Icons.add,
                            label: 'فاتورة جديدة',
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _customers = ['محل الأمل', 'سوبر ماركت النور', 'عم سيد', 'بقالة الخير'];

class _List extends StatelessWidget {
  const _List({required this.selected, required this.onOpen});

  final int? selected;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (var i = 0; i < _customers.length; i++)
        ListTile(
          selected: i == selected,
          leading: const Icon(Icons.receipt_long_outlined),
          title: Text(_customers[i]),
          subtitle: Text('فاتورة ${1041 + i}'),
          trailing: Text(Money.format(12550 * (i + 1))),
          onTap: () => onOpen(i),
        ),
    ],
  );
}

class _Detail extends StatelessWidget {
  const _Detail({required this.index, this.onBack});

  final int index;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(TashilSpacing.lg),
      children: [
        Row(
          children: [
            if (onBack != null)
              IconButton(
                tooltip: 'رجوع',
                onPressed: onBack,
                icon: const BackButtonIcon(),
              ),
            Expanded(
              child: Text('فاتورة ${1041 + index}', style: text.headlineSmall),
            ),
          ],
        ),
        const SizedBox(height: TashilSpacing.sm),
        Text(_customers[index], style: text.titleMedium),
        const SizedBox(height: TashilSpacing.md),
        ReadingWidth(
          child: Text(
            'في الشاشات الكبيرة الفاتورة بتفتح جنب القايمة، وفي الموبايل '
            'بتاخد الشاشة كلها وفيه زرار رجوع. السطر مش بيعدّي 60 حرف '
            'عشان يتقري بسهولة.',
            style: text.bodyLarge,
          ),
        ),
        const SizedBox(height: TashilSpacing.md),
        Text(
          'الإجمالي ${Money.format(12550 * (index + 1))}',
          style: text.titleLarge,
        ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(TashilSpacing.lg),
    children: [
      Text('تصفية', style: Theme.of(context).textTheme.titleMedium),
      for (final f in ['مدفوعة', 'آجل', 'مرتجع'])
        CheckboxListTile(
          value: f != 'مرتجع',
          onChanged: (_) {},
          title: Text(f),
        ),
    ],
  );
}
