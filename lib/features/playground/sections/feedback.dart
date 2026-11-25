import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/dialogs.dart';
import 'common.dart';

class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionList([
      SpecSection(
        title: 'حوار أساسي',
        m3: 'Basic dialog',
        spec: 'components/dialogs/guidelines',
        rule:
            'للحاجات المهمة اللي بتوقف الشغل بس. عنوان واضح، أزرار نصية، '
            'زرار التأكيد بيقول هيحصل إيه وعلى الطرف (شمال في العربي). '
            'لو المعلومة مش مهمة استخدم Snackbar.',
        children: [
          Demo([
            OutlinedButton(
              onPressed: () => showTashilDialog<void>(
                context: context,
                builder: (c) => AlertDialog(
                  icon: const Icon(Icons.receipt_long_outlined),
                  title: const Text('إلغاء الفاتورة رقم 1042؟'),
                  content: const Text(
                    'هيتعمل مرتجع للمخزون، والفاتورة هتفضل في السجل كملغاة.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('رجوع'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('إلغاء الفاتورة'),
                    ),
                  ],
                ),
              ),
              child: const Text('تأكيد'),
            ),
            OutlinedButton(
              onPressed: () => showTashilDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (c) => AlertDialog(
                  icon: const Icon(Icons.print_disabled_outlined),
                  title: const Text('الطابعة مفيهاش ورق'),
                  content: const Text(
                    'الفاتورة اتحفظت. حط رول ورق جديد واطبعها من السجل.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('حسنًا'),
                    ),
                  ],
                ),
              ),
              child: const Text('إقرار بزرار واحد'),
            ),
            OutlinedButton(
              onPressed: () async {
                final r = await showChoiceDialog<String>(
                  context: context,
                  title: 'سبب المرتجع',
                  confirmLabel: 'تسجيل المرتجع',
                  options: const {
                    'damaged': 'تالف',
                    'expired': 'منتهي الصلاحية',
                    'wrong': 'صنف غلط',
                    'customer': 'العميل غيّر رأيه',
                    'price': 'خطأ في السعر',
                    'duplicate': 'اتسجل مرتين',
                    'other': 'سبب تاني',
                  },
                );
                if (r != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('اتسجل المرتجع')),
                  );
                }
              },
              child: const Text('اختيار من قائمة'),
            ),
          ]),
        ],
      ),
      SpecSection(
        title: 'حوار بملء الشاشة',
        m3: 'Full-screen dialog',
        spec: 'components/dialogs/guidelines#full-screen-dialog',
        rule:
            'لفورم فيه كتابة على الموبايل بس، ومن 600dp يبقى حوار أساسي. '
            'بيفتح من الزرار بـ container transform. أخطاء الحقول تحت '
            'الحقل، وفشل الحفظ بس هو اللي ياخد حوار. لو قفلت وفيه تعديلات '
            'بيسألك تتجاهلها ولا لأ.',
        children: [
          OpenContainer(
            transitionDuration: TashilTransitions.containerTransform(context),
            closedColor: Theme.of(context).colorScheme.primaryContainer,
            closedElevation: 3,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TashilRadius.large),
            ),
            openBuilder: (context, _) => const _NewProductDialog(),
            closedBuilder: (context, open) => InkWell(
              onTap: open,
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TashilSpacing.lg,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: TashilSpacing.sm),
                      Text(
                        'صنف جديد',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: TashilSpacing.sm),
          Text(
            'جرب: احفظ والاسم فاضي، اكتب حاجة واقفل، أو اكتب "فشل" في '
            'الاسم عشان تشوف حوار فشل الحفظ.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
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

/// Full-screen "new product" form used by the dialogs demo.
class _NewProductDialog extends StatefulWidget {
  const _NewProductDialog();

  @override
  State<_NewProductDialog> createState() => _NewProductDialogState();
}

class _NewProductDialogState extends State<_NewProductDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  String? _nameError;
  String? _priceError;
  bool _saving = false;

  bool get _dirty => _name.text.isNotEmpty || _price.text.isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _nameError = _name.text.trim().isEmpty ? 'اكتب اسم الصنف' : null;
      _priceError = double.tryParse(_price.text) == null
          ? 'اكتب السعر بالأرقام، مثلاً 12.50'
          : null;
    });
    if (_nameError != null || _priceError != null) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    if (_name.text.contains('فشل')) {
      await showTashilDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('تعذّر الحفظ'),
          content: const Text(
            'مساحة التخزين على الجهاز خلصت. امسح صور أو ملفات قديمة '
            'وجرب تاني. البيانات اللي كتبتها لسه موجودة.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('اتضاف "${_name.text}"')));
    _name.clear();
    _price.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: 'صنف جديد',
      saveLabel: 'حفظ',
      dirty: _dirty,
      saving: _saving,
      onSave: _save,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            onChanged: (_) => setState(() => _nameError = null),
            decoration: InputDecoration(
              labelText: 'اسم الصنف',
              errorText: _nameError,
            ),
          ),
          const SizedBox(height: TashilSpacing.md),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() => _priceError = null),
            decoration: InputDecoration(
              labelText: 'سعر البيع',
              suffixText: 'ج.م',
              errorText: _priceError,
            ),
          ),
        ],
      ),
    );
  }
}
