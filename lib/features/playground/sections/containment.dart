import 'package:material_ui/material_ui.dart';

import '../../../core/design/bidi.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/pos_widgets.dart';
import 'common.dart';

class ContainmentSection extends StatelessWidget {
  const ContainmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget cardBody(String t, String v) => Padding(
      padding: const EdgeInsets.all(TashilSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: text.labelLarge),
          Text(v, style: text.headlineSmall),
        ],
      ),
    );

    return SectionList([
      SpecSection(
        title: 'الكروت',
        m3: 'Cards',
        spec: 'components/cards',
        rule: 'Filled لمؤشرات الداشبورد، Outlined للعناصر القابلة للضغط.',
        children: [
          Row(
            children: [
              Expanded(child: Card(child: cardBody('Elevated', '12 فاتورة'))),
              Expanded(
                child: Card.filled(child: cardBody('Filled', '3,450 ج.م')),
              ),
              Expanded(
                child: Card.outlined(child: cardBody('Outlined', '5 أصناف')),
              ),
            ],
          ),
        ],
      ),
      SpecSection(
        title: 'القوائم',
        m3: 'Lists',
        spec: 'components/lists',
        children: [
          Card.outlined(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('أحمد محمود'),
                  subtitle: Text('رصيد آجل'),
                  trailing: MoneyText(125000),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: const Text('شركة النيل للتوريدات'),
                  subtitle: const Text('آخر توريد من 3 أيام'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                ),
                const Divider(),
                ExpansionTile(
                  leading: Icon(Icons.receipt_long_outlined),
                  title: Text('فاتورة ${Bidi.ltr('SUNMI01-20261125-0042')}'),
                  children: const [
                    ListTile(title: Text('سكر ×2'), trailing: MoneyText(9100)),
                    ListTile(title: Text('شاي ×1'), trailing: MoneyText(6500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      SpecSection(
        title: 'جدول البيانات',
        m3: 'Data table',
        spec: 'components/lists',
        rule:
            'M3 مالوش DataTable رسمي. نستخدمه في التقارير بس، '
            'وعلى الموبايل جوه scroll أفقي.',
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('الصنف')),
                DataColumn(label: Text('الكمية'), numeric: true),
                DataColumn(label: Text('الإجمالي'), numeric: true),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('سكر أبيض')),
                    DataCell(Text('34')),
                    DataCell(MoneyText(154700)),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('زيت عباد')),
                    DataCell(Text('12')),
                    DataCell(MoneyText(102000)),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('أرز مصري')),
                    DataCell(Text('8')),
                    DataCell(MoneyText(76000)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      SpecSection(
        title: 'الشارات',
        m3: 'Badges',
        spec: 'components/badges',
        children: [
          const Demo([
            Badge(child: Icon(Icons.notifications_outlined)),
            Badge(label: Text('7'), child: Icon(Icons.inventory_2_outlined)),
            Badge(label: Text('99+'), child: Icon(Icons.cloud_upload_outlined)),
          ]),
        ],
      ),
      SpecSection(
        title: 'الفواصل',
        m3: 'Dividers',
        spec: 'components/divider',
        children: const [Divider(), SizedBox(height: 8), Divider(indent: 16)],
      ),
    ]);
  }
}
