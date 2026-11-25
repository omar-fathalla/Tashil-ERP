import 'package:material_ui/material_ui.dart';

import 'common.dart';

enum _Pay { cash, card, credit }

class ActionsSection extends StatefulWidget {
  const ActionsSection({super.key});

  @override
  State<ActionsSection> createState() => _ActionsSectionState();
}

class _ActionsSectionState extends State<ActionsSection> {
  Set<_Pay> _pay = {_Pay.cash};
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    void tap() {}
    return SectionList([
      SpecSection(
        title: 'الأزرار',
        m3: 'Common buttons',
        spec: 'components/buttons',
        rule:
            'زر Filled واحد بس لكل شاشة للإجراء الأساسي (دفع، حفظ). '
            'Tonal للثانوي، Outlined للبديل، Text للإلغاء.',
        children: [
          Demo([
            FilledButton(onPressed: tap, child: const Text('Filled')),
            FilledButton.tonal(onPressed: tap, child: const Text('Tonal')),
            ElevatedButton(onPressed: tap, child: const Text('Elevated')),
            OutlinedButton(onPressed: tap, child: const Text('Outlined')),
            TextButton(onPressed: tap, child: const Text('Text')),
          ]),
          const SizedBox(height: 8),
          Demo([
            FilledButton.icon(
              onPressed: tap,
              icon: const Icon(Icons.save_outlined),
              label: const Text('حفظ'),
            ),
            OutlinedButton.icon(
              onPressed: tap,
              icon: const Icon(Icons.print_outlined),
              label: const Text('طباعة'),
            ),
            const FilledButton(onPressed: null, child: Text('معطّل')),
          ]),
        ],
      ),
      SpecSection(
        title: 'أزرار الأيقونات',
        m3: 'Icon buttons',
        spec: 'components/icon-buttons',
        children: [
          Demo([
            IconButton(
              tooltip: 'Standard',
              onPressed: tap,
              icon: const Icon(Icons.qr_code_scanner),
            ),
            IconButton.filled(
              tooltip: 'Filled',
              onPressed: tap,
              icon: const Icon(Icons.qr_code_scanner),
            ),
            IconButton.filledTonal(
              tooltip: 'Tonal',
              onPressed: tap,
              icon: const Icon(Icons.qr_code_scanner),
            ),
            IconButton.outlined(
              tooltip: 'Outlined',
              onPressed: tap,
              icon: const Icon(Icons.qr_code_scanner),
            ),
            IconButton(
              tooltip: 'Toggle',
              isSelected: _fav,
              onPressed: () => setState(() => _fav = !_fav),
              icon: const Icon(Icons.star_outline),
              selectedIcon: const Icon(Icons.star),
            ),
          ]),
        ],
      ),
      SpecSection(
        title: 'الزر العائم',
        m3: 'FAB',
        spec: 'components/floating-action-button',
        rule: 'FAB للإجراء الأهم في الشاشة: مسح باركود أو إضافة صنف.',
        children: [
          Demo([
            FloatingActionButton.small(
              heroTag: 'fab-s',
              onPressed: tap,
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              heroTag: 'fab-m',
              onPressed: tap,
              child: const Icon(Icons.qr_code_scanner),
            ),
            FloatingActionButton.large(
              heroTag: 'fab-l',
              onPressed: tap,
              child: const Icon(Icons.qr_code_scanner),
            ),
            FloatingActionButton.extended(
              heroTag: 'fab-e',
              onPressed: tap,
              icon: const Icon(Icons.add),
              label: const Text('صنف جديد'),
            ),
          ]),
        ],
      ),
      SpecSection(
        title: 'الأزرار المقسّمة',
        m3: 'Segmented button',
        spec: 'components/segmented-buttons',
        rule: 'لاختيار من 2 لـ 5 بدائل، زي طريقة الدفع.',
        children: [
          SegmentedButton<_Pay>(
            segments: const [
              ButtonSegment(
                value: _Pay.cash,
                label: Text('كاش'),
                icon: Icon(Icons.payments_outlined),
              ),
              ButtonSegment(
                value: _Pay.card,
                label: Text('فيزا'),
                icon: Icon(Icons.credit_card),
              ),
              ButtonSegment(
                value: _Pay.credit,
                label: Text('آجل'),
                icon: Icon(Icons.schedule),
              ),
            ],
            selected: _pay,
            onSelectionChanged: (v) => setState(() => _pay = v),
          ),
        ],
      ),
    ]);
  }
}
