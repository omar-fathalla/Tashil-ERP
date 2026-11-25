import 'package:material_ui/material_ui.dart';

import '../../../core/design/tokens.dart';
import 'common.dart';

class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key});

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> {
  int _bar = 0;
  int _rail = 0;

  static const _dest = [
    (Icons.point_of_sale_outlined, Icons.point_of_sale, 'البيع'),
    (Icons.inventory_2_outlined, Icons.inventory_2, 'المخزون'),
    (Icons.bar_chart_outlined, Icons.bar_chart, 'التقارير'),
    (Icons.settings_outlined, Icons.settings, 'الإعدادات'),
  ];

  Widget _frame(Widget child, {double height = 200}) => Container(
    height: height,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(TashilRadius.medium),
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return SectionList([
      SpecSection(
        title: 'شريط التنقل السفلي',
        m3: 'Navigation bar',
        spec: 'components/navigation-bar',
        rule:
            'التنقل الرئيسي على SUNMI V3 (شاشة compact). '
            '3 لـ 5 وجهات بس.',
        children: [
          _frame(
            Scaffold(
              body: Center(child: Text(_dest[_bar].$3)),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _bar,
                onDestinationSelected: (i) => setState(() => _bar = i),
                destinations: [
                  for (final (i, s, l) in _dest)
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: l == 'المخزون',
                        label: const Text('3'),
                        child: Icon(i),
                      ),
                      selectedIcon: Icon(s),
                      label: l,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      SpecSection(
        title: 'القضيب الجانبي',
        m3: 'Navigation rail',
        spec: 'components/navigation-rail',
        rule: 'بدل الشريط السفلي لما العرض > 600 (تابلت أو شاشة أفقية).',
        children: [
          _frame(
            Row(
              children: [
                NavigationRail(
                  selectedIndex: _rail,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (i) => setState(() => _rail = i),
                  destinations: [
                    for (final (i, s, l) in _dest.take(3))
                      NavigationRailDestination(
                        icon: Icon(i),
                        selectedIcon: Icon(s),
                        label: Text(l),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: Center(child: Text(_dest[_rail].$3))),
              ],
            ),
            height: 280,
          ),
        ],
      ),
      SpecSection(
        title: 'القائمة الجانبية',
        m3: 'Navigation drawer',
        spec: 'components/navigation-drawer',
        rule: 'للوجهات الثانوية: العملاء، الموردين، المصروفات، الوردية.',
        children: [
          _frame(
            Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('تسهيل')),
                drawer: NavigationDrawer(
                  selectedIndex: 0,
                  onDestinationSelected: (_) => Navigator.pop(context),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(TashilSpacing.page),
                      child: Text('القائمة'),
                    ),
                    NavigationDrawerDestination(
                      icon: Icon(Icons.people_outline),
                      label: Text('العملاء'),
                    ),
                    NavigationDrawerDestination(
                      icon: Icon(Icons.local_shipping_outlined),
                      label: Text('الموردين'),
                    ),
                    NavigationDrawerDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      label: Text('المصروفات'),
                    ),
                  ],
                ),
                body: const Center(child: Text('اضغط ☰ لفتح القائمة')),
              ),
            ),
            height: 240,
          ),
        ],
      ),
      SpecSection(
        title: 'التبويبات',
        m3: 'Tabs',
        spec: 'components/tabs',
        children: [
          _frame(
            const DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'الكل'),
                      Tab(text: 'قليل'),
                      Tab(text: 'نفد'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Center(child: Text('كل الأصناف')),
                        Center(child: Text('قليل المخزون')),
                        Center(child: Text('نفد')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            height: 160,
          ),
        ],
      ),
      SpecSection(
        title: 'شريط التطبيق',
        m3: 'Top app bar',
        spec: 'components/top-app-bar',
        rule: 'Small app bar في الشاشات العادية. العنوان على البداية (يمين).',
        children: [
          _frame(
            Scaffold(
              appBar: AppBar(
                leading: const BackButton(),
                title: const Text('تفاصيل الصنف'),
                actions: [
                  IconButton(
                    tooltip: 'تعديل',
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'المزيد',
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            height: 64,
          ),
        ],
      ),
    ]);
  }
}
