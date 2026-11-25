import 'package:material_ui/material_ui.dart';

import '../../../core/design/tokens.dart';
import 'common.dart';

class InputsSection extends StatefulWidget {
  const InputsSection({super.key});

  @override
  State<InputsSection> createState() => _InputsSectionState();
}

class _InputsSectionState extends State<InputsSection> {
  bool _check = true;
  bool _switch = true;
  String _unit = 'pcs';
  double _slider = 20;
  final Set<String> _filters = {'قليل المخزون'};
  String _choice = 'اليوم';
  DateTime? _date;

  static const _products = [
    'سكر أبيض 1 كجم',
    'زيت عباد الشمس',
    'أرز مصري 5 كجم',
    'شاي ليبتون 100 فتلة',
    'مكرونة 400 جم',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionList([
      SpecSection(
        title: 'حقول النص',
        m3: 'Text fields',
        spec: 'components/text-fields',
        rule:
            'Outlined دايماً. الأرقام والمبالغ بكيبورد رقمي. '
            'رسالة الخطأ تحت الحقل مش في Dialog.',
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'اسم الصنف',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
          ),
          const SizedBox(height: TashilSpacing.md),
          const TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'سعر البيع',
              suffixText: 'ج.م',
              helperText: 'بالجنيه، رقمين عشريين',
            ),
          ),
          const SizedBox(height: TashilSpacing.md),
          const TextField(
            decoration: InputDecoration(
              labelText: 'الباركود',
              errorText: 'الباركود ده مسجّل لصنف تاني',
              suffixIcon: Icon(Icons.qr_code_scanner),
            ),
          ),
          const SizedBox(height: TashilSpacing.md),
          const TextField(
            enabled: false,
            decoration: InputDecoration(labelText: 'رقم الفاتورة (تلقائي)'),
          ),
        ],
      ),
      SpecSection(
        title: 'البحث',
        m3: 'Search bar',
        spec: 'components/search',
        rule: 'شريط البحث فوق قوائم الأصناف، وفيه زرار مسح الباركود.',
        children: [
          SearchAnchor.bar(
            barHintText: 'ابحث بالاسم أو الباركود',
            barTrailing: const [Icon(Icons.qr_code_scanner)],
            suggestionsBuilder: (context, controller) => [
              for (final p in _products.where(
                (p) => p.contains(controller.text),
              ))
                ListTile(title: Text(p), onTap: () => controller.closeView(p)),
            ],
          ),
        ],
      ),
      SpecSection(
        title: 'القائمة المنسدلة',
        m3: 'Menus / DropdownMenu',
        spec: 'components/menus',
        children: [
          DropdownMenu<String>(
            initialSelection: _unit,
            label: const Text('الوحدة'),
            onSelected: (v) => setState(() => _unit = v ?? _unit),
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'pcs', label: 'قطعة'),
              DropdownMenuEntry(value: 'kg', label: 'كيلو'),
              DropdownMenuEntry(value: 'box', label: 'كرتونة'),
            ],
          ),
        ],
      ),
      SpecSection(
        title: 'الشرائح',
        m3: 'Chips',
        spec: 'components/chips',
        rule: 'Filter لتصفية القوائم، Choice لاختيار واحد، Input للعناصر المختارة.',
        children: [
          Demo([
            for (final f in const ['قليل المخزون', 'نفد', 'بدون باركود'])
              FilterChip(
                label: Text(f),
                selected: _filters.contains(f),
                onSelected: (v) =>
                    setState(() => v ? _filters.add(f) : _filters.remove(f)),
              ),
          ]),
          const SizedBox(height: TashilSpacing.sm),
          Demo([
            for (final c in const ['اليوم', 'الأسبوع', 'الشهر'])
              ChoiceChip(
                label: Text(c),
                selected: _choice == c,
                onSelected: (_) => setState(() => _choice = c),
              ),
          ]),
          const SizedBox(height: TashilSpacing.sm),
          Demo([
            InputChip(label: const Text('مشروبات'), onDeleted: () {}),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: const Text('تصنيف'),
              onPressed: () {},
            ),
          ]),
        ],
      ),
      SpecSection(
        title: 'الاختيارات',
        m3: 'Checkbox, Radio, Switch',
        spec: 'components/checkbox',
        children: [
          CheckboxListTile(
            value: _check,
            onChanged: (v) => setState(() => _check = v ?? false),
            title: const Text('طباعة الفاتورة تلقائياً'),
          ),
          SwitchListTile(
            value: _switch,
            onChanged: (v) => setState(() => _switch = v),
            title: const Text('تنبيه عند نفاد المخزون'),
          ),
          RadioGroup<String>(
            groupValue: _unit,
            onChanged: (v) => setState(() => _unit = v ?? _unit),
            child: const Column(
              children: [
                RadioListTile(value: 'pcs', title: Text('قطعة')),
                RadioListTile(value: 'kg', title: Text('كيلو')),
              ],
            ),
          ),
        ],
      ),
      SpecSection(
        title: 'المنزلق',
        m3: 'Slider',
        spec: 'components/sliders',
        children: [
          Slider(
            value: _slider,
            max: 100,
            divisions: 20,
            label: '${_slider.round()}%',
            onChanged: (v) => setState(() => _slider = v),
          ),
        ],
      ),
      SpecSection(
        title: 'التاريخ والوقت',
        m3: 'Date & time pickers',
        spec: 'components/date-pickers',
        rule: 'للتقارير والفلترة. التقويم بيطلع بالعربي من locale.',
        children: [
          Demo([
            OutlinedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(
                _date == null
                    ? 'اختر تاريخ'
                    : '${_date!.year}-${_date!.month}-${_date!.day}',
              ),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                  initialDate: _date ?? DateTime.now(),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: const Text('فترة'),
              onPressed: () => showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('وقت'),
              onPressed: () => showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              ),
            ),
          ]),
        ],
      ),
    ]);
  }
}
