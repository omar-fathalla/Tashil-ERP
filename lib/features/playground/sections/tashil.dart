import 'package:material_ui/material_ui.dart';

import '../../../core/design/money.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/pos_widgets.dart';
import '../../../core/design/widgets/receipt_preview.dart';
import 'common.dart';

/// Project-specific composites built only from M3 parts + tokens.
class TashilSection extends StatefulWidget {
  const TashilSection({super.key});

  @override
  State<TashilSection> createState() => _TashilSectionState();
}

class _TashilSectionState extends State<TashilSection> {
  final _cart = <String, (int, double)>{
    'سكر أبيض 1 كجم': (4550, 2),
    'شاي ليبتون 100 فتلة': (6500, 1),
    'جبنة دومتي 500 جم': (3875, 3),
  };
  String _entry = '';

  int get _total => _cart.values.fold(0, (s, v) => s + (v.$1 * v.$2).round());

  void _onKey(KeypadKey k) => setState(() {
    switch (k) {
      case BackspaceKey():
        if (_entry.isNotEmpty) {
          _entry = _entry.substring(0, _entry.length - 1);
        }
      case DigitKey(:final value):
        if (value == '.' && _entry.contains('.')) return;
        if (_entry.contains('.') && _entry.split('.').last.length >= 2) return;
        _entry += value;
    }
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SectionList([
      SpecSection(
        title: 'ProductTile',
        spec: 'components/lists',
        rule: 'صف الصنف في البحث والقوائم: صورة/حرف، اسم، سعر، رصيد، إضافة.',
        children: [
          Card.outlined(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ProductTile(
                  name: 'سكر أبيض 1 كجم',
                  pricePiastres: 4550,
                  stock: 34,
                  minStock: 10,
                  unit: 'قطعة',
                  onTap: () {},
                  onAdd: () {},
                ),
                const Divider(
                  indent: TashilDividerInset.afterThumbnail,
                  endIndent: TashilDividerInset.both,
                ),
                ProductTile(
                  name: 'زيت عباد الشمس 800 مل',
                  pricePiastres: 8500,
                  stock: 4,
                  minStock: 6,
                  unit: 'قطعة',
                  onAdd: () {},
                ),
                const Divider(
                  indent: TashilDividerInset.afterThumbnail,
                  endIndent: TashilDividerInset.both,
                ),
                ProductTile(
                  name: 'لحمة مفرومة',
                  pricePiastres: 42000,
                  stock: 0,
                  minStock: 2,
                  unit: 'كجم',
                  onAdd: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      SpecSection(
        title: 'StockBadge · SyncStatusLabel',
        spec: 'styles/color/roles',
        rule:
            'أخضر = متوفر، برتقالي = تحت الحد الأدنى، أحمر = نفد. '
            'دي حالات للعرض بس، مش شرايح: الشريحة في M3 لازم تتداس.',
        children: const [
          Demo([
            StockBadge(quantity: 50, minStock: 10, unit: 'قطعة'),
            StockBadge(quantity: 3, minStock: 10, unit: 'قطعة'),
            StockBadge(quantity: 0, minStock: 10, unit: 'قطعة'),
            StockBadge(quantity: 1.25, minStock: 2, unit: 'كجم'),
          ]),
          SizedBox(height: TashilSpacing.md),
          Demo([
            SyncStatusLabel(SyncState.synced),
            SyncStatusLabel(SyncState.pending),
            SyncStatusLabel(SyncState.failed),
          ]),
        ],
      ),
      SpecSection(
        title: 'CartLine + CheckoutBar',
        spec: 'components/lists',
        rule: 'اسحب السطر للحذف. زرار الدفع 56dp وأكبر حاجة في الشاشة.',
        children: [
          Card.outlined(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (_cart.isEmpty)
                  const EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'السلة فاضية',
                    message: 'امسح باركود أو ابحث عن صنف',
                  ),
                for (final (i, e) in _cart.entries.indexed) ...[
                  if (i > 0)
                    const Divider(
                      indent: TashilDividerInset.both,
                      endIndent: TashilDividerInset.both,
                    ),
                  CartLine(
                    name: e.key,
                    unitPricePiastres: e.value.$1,
                    quantity: e.value.$2,
                    onQuantityChanged: (q) =>
                        setState(() => _cart[e.key] = (e.value.$1, q)),
                    onRemove: () => setState(() => _cart.remove(e.key)),
                  ),
                ],
                // Full width: the total is a different section.
                const Divider(),
                CheckoutBar(
                  totalPiastres: _total,
                  itemCount: _cart.length,
                  onPay: _cart.isEmpty ? null : () {},
                ),
              ],
            ),
          ),
        ],
      ),
      SpecSection(
        title: 'NumericKeypad',
        spec: 'components/buttons',
        rule:
            'لإدخال المبلغ المدفوع والكميات. الترتيب 7-8-9 فوق دايماً '
            'حتى في RTL، زي أي آلة حاسبة.',
        children: [
          Container(
            padding: const EdgeInsets.all(TashilSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(TashilRadius.large),
            ),
            child: Row(
              children: [
                Text('المدفوع', style: text.titleMedium),
                const Spacer(),
                Text(
                  '${_entry.isEmpty ? '0' : _entry} ${Money.currency}',
                  style: text.headlineMedium,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
          const SizedBox(height: TashilSpacing.sm),
          NumericKeypad(onKey: _onKey),
        ],
      ),
      SpecSection(
        title: 'ReceiptPreview، 58mm',
        spec: 'styles/typography',
        rule:
            'معاينة الإيصال بعرض الطابعة الحقيقي (384 نقطة)، أبيض وأسود '
            'دايماً. نفس الويدجت هيتحول Bitmap للطباعة.',
        children: const [
          Center(
            child: ReceiptPreview(
              storeName: 'سوبر ماركت تسهيل',
              invoiceNo: 'SUNMI01-20261125-0042',
              dateTime: '2026-11-25  14:32',
              lines: [
                ReceiptLine('سكر أبيض 1 كجم', 2, 4550),
                ReceiptLine('شاي ليبتون 100 فتلة', 1, 6500),
                ReceiptLine('جبنة دومتي 500 جم', 3, 3875),
              ],
              discountPiastres: 500,
            ),
          ),
        ],
      ),
      SpecSection(
        title: 'EmptyState',
        spec: 'foundations',
        children: [
          Card.outlined(
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'مفيش أصناف لسه',
              message: 'ابدأ بإضافة أول صنف أو استورد من Excel',
              action: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('صنف جديد'),
              ),
            ),
          ),
        ],
      ),
    ]);
  }
}
