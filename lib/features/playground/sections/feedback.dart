import 'package:material_ui/material_ui.dart';

import '../../../core/design/tokens.dart';
import 'common.dart';

class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionList([
      SpecSection(
        title: 'الحوارات',
        m3: 'Dialogs',
        spec: 'components/dialogs',
        rule:
            'Dialog للتأكيد قبل إجراء مش بيترجع (إلغاء فاتورة، حذف). '
            'الزر الخطر على النهاية.',
        children: [
          Demo([
            OutlinedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (c) => AlertDialog(
                  icon: const Icon(Icons.warning_amber_rounded),
                  title: const Text('إلغاء الفاتورة؟'),
                  content: const Text(
                    'هيتعمل مرتجع للمخزون والفاتورة هتفضل في السجل كملغاة.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('رجوع'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(c).colorScheme.error,
                        foregroundColor: Theme.of(c).colorScheme.onError,
                      ),
                      onPressed: () => Navigator.pop(c),
                      child: const Text('إلغاء الفاتورة'),
                    ),
                  ],
                ),
              ),
              child: const Text('Basic dialog'),
            ),
            OutlinedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (c) => Dialog.fullscreen(
                  child: Scaffold(
                    appBar: AppBar(
                      leading: CloseButton(onPressed: () => Navigator.pop(c)),
                      title: const Text('صنف جديد'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('حفظ'),
                        ),
                      ],
                    ),
                    body: const Padding(
                      padding: EdgeInsets.all(TashilSpacing.page),
                      child: TextField(
                        decoration: InputDecoration(labelText: 'اسم الصنف'),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('Full-screen dialog'),
            ),
          ]),
        ],
      ),
      SpecSection(
        title: 'الورقة السفلية',
        m3: 'Bottom sheet',
        spec: 'components/bottom-sheets',
        rule: 'للخيارات السريعة على الصنف أو السلة (خصم، ملاحظة، حذف).',
        children: [
          OutlinedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (c) => const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.percent),
                    title: Text('خصم على الصنف'),
                  ),
                  ListTile(
                    leading: Icon(Icons.edit_note),
                    title: Text('ملاحظة'),
                  ),
                  ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('حذف من السلة'),
                  ),
                  SizedBox(height: TashilSpacing.lg),
                ],
              ),
            ),
            child: const Text('Modal bottom sheet'),
          ),
        ],
      ),
      SpecSection(
        title: 'الإشعار السريع',
        m3: 'Snackbar',
        spec: 'components/snackbar',
        rule: 'تأكيد إجراء تم + زر تراجع لو ممكن. مش للأخطاء الخطيرة.',
        children: [
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم حذف الصنف من السلة'),
                action: SnackBarAction(label: 'تراجع', onPressed: () {}),
              ),
            ),
            child: const Text('Show snackbar'),
          ),
        ],
      ),
      SpecSection(
        title: 'مؤشرات التقدم',
        m3: 'Progress indicators',
        spec: 'components/progress-indicators',
        children: const [
          LinearProgressIndicator(),
          SizedBox(height: TashilSpacing.md),
          LinearProgressIndicator(value: 0.6),
          SizedBox(height: TashilSpacing.md),
          Demo([
            CircularProgressIndicator(),
            CircularProgressIndicator(value: 0.75),
          ]),
        ],
      ),
      SpecSection(
        title: 'التلميح',
        m3: 'Tooltip',
        spec: 'components/tooltips',
        rule: 'كل IconButton لازم يكون ليه tooltip (وصول + توضيح).',
        children: [
          Demo([
            Tooltip(
              message: 'مزامنة الآن',
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.sync)),
            ),
          ]),
        ],
      ),
      SpecSection(
        title: 'اللافتة',
        m3: 'Banner',
        spec: 'components/banner',
        rule: 'لحالة مستمرة على مستوى الشاشة: الجهاز أوفلاين، الوردية مقفولة.',
        children: [
          MaterialBanner(
            leading: const Icon(Icons.cloud_off_outlined),
            content: const Text(
              'أنت شغال أوفلاين. المبيعات بتتحفظ وهتتزامن أول ما النت يرجع.',
            ),
            actions: [TextButton(onPressed: () {}, child: const Text('تمام'))],
          ),
        ],
      ),
    ]);
  }
}
