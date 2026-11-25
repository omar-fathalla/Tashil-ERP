import 'package:material_ui/material_ui.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/chips.dart';
import '../../../core/design/widgets/date_time_fields.dart';
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
  final Set<String> _row = {'بقالة'};
  String? _category;
  String? _supplier;
  bool _saved = false;
  List<String> _barcodes = ['6221234567890'];
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  DateTime? _invoiceDate = DateTime(2026, 11, 26);
  DateTime? _expiry;
  DateTimeRange? _range;
  TimeOfDay _shiftClose = const TimeOfDay(hour: 23, minute: 0);
  bool _time24 = false;

  static const _products = [
    'سكر أبيض 1 كجم',
    'زيت عباد الشمس',
    'أرز مصري 5 كجم',
    'شاي ليبتون 100 فتلة',
    'مكرونة 400 جم',
  ];

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
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
        title: 'الشرايح: الأنواع الأربعة',
        m3: 'Chips',
        spec: 'components/chips/guidelines',
        rule:
            'Assist لإجراء حسب السياق، Filter للتصفية، Input لحاجة كتبها '
            'المستخدم، Suggestion لاقتراح من النظام. الشرايح دايماً مجموعة، '
            'والنص 20 حرف بالكتير. الخطوة الأساسية (إتمام البيع) زرار مش شريحة.',
        children: [
          Demo([
            ActionChip(
              avatar: const Icon(Icons.print_outlined),
              label: const Text('اطبع'),
              onPressed: () {},
            ),
            FilterChip(
              label: const Text('قليل المخزون'),
              selected: true,
              onSelected: (_) {},
            ),
            InputChip(label: const Text('مشروبات'), onDeleted: () {}),
            ActionChip(label: const Text('سكر'), onPressed: () {}),
          ]),
        ],
      ),
      SpecSection(
        title: 'شرايح الإجراء',
        m3: 'Assist chips',
        spec: 'components/chips/guidelines#assist-chips',
        rule:
            'تحت المحتوى الأساسي، بتبدأ بفعل وأيقونة. ممكن تعرض التقدم '
            'والتأكيد (احفظ ثم اتحفظت). Elevated بس فوق صورة.',
        children: [
          Card.outlined(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(TashilSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم البيع: 245.00 ج.م',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: TashilSpacing.md),
                  Demo([
                    ActionChip(
                      avatar: const Icon(Icons.print_outlined),
                      label: const Text('اطبع الإيصال'),
                      onPressed: () {},
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.share_outlined),
                      label: const Text('ابعت واتساب'),
                      onPressed: () {},
                    ),
                    ActionChip(
                      avatar: Icon(
                        _saved ? Icons.check : Icons.bookmark_add_outlined,
                      ),
                      label: Text(_saved ? 'اتحفظت' : 'احفظ للعميل'),
                      onPressed: () => setState(() => _saved = !_saved),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: TashilSpacing.md),
          Container(
            height: 140,
            alignment: AlignmentDirectional.bottomStart,
            padding: const EdgeInsets.all(TashilSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TashilRadius.medium),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8D6E63), Color(0xFF263238)],
              ),
            ),
            child: Demo([
              ActionChip.elevated(
                avatar: const Icon(Icons.photo_camera_outlined),
                label: const Text('غيّر الصورة'),
                onPressed: () {},
              ),
              ActionChip.elevated(
                avatar: const Icon(Icons.crop),
                label: const Text('قص'),
                onPressed: () {},
              ),
            ]),
          ),
        ],
      ),
      SpecSection(
        title: 'شرايح التصفية',
        m3: 'Filter chips',
        spec: 'components/chips/guidelines#filter-chips',
        rule:
            'علامة صح لما تتختار. المجموعة الواحدة يا اختيار واحد يا متعدد، '
            'مش الاتنين. لو زادت عن صفين تبقى صف واحد بيتسحب. '
            'ممنوع مجموعة فيها اختيار واحد بس. ChoiceChip ممنوع.',
        children: [
          Text('اختيار متعدد', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: TashilSpacing.sm),
          Demo([
            for (final f in const ['قليل المخزون', 'نفد', 'بدون باركود'])
              FilterChip(
                label: Text(f),
                selected: _filters.contains(f),
                onSelected: (v) =>
                    setState(() => v ? _filters.add(f) : _filters.remove(f)),
              ),
          ]),
          const SizedBox(height: TashilSpacing.md),
          Text('اختيار واحد', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: TashilSpacing.sm),
          Demo([
            for (final c in const ['اليوم', 'الأسبوع', 'الشهر'])
              FilterChip(
                label: Text(c),
                selected: _choice == c,
                onSelected: (_) => setState(() => _choice = c),
              ),
          ]),
          const SizedBox(height: TashilSpacing.md),
          Text(
            'بتفتح قائمة (الشريحة كلها بتفتحها)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: TashilSpacing.sm),
          Demo([
            MenuFilterChip<String>(
              label: 'التصنيف',
              value: _category,
              options: const {
                'drinks': 'مشروبات',
                'grocery': 'بقالة',
                'cleaning': 'منظفات',
              },
              onChanged: (v) => setState(() => _category = v),
            ),
            MenuFilterChip<String>(
              label: 'المورد',
              value: _supplier,
              options: const {'a': 'الأهرام', 'b': 'النيل للتوزيع'},
              onChanged: (v) => setState(() => _supplier = v),
            ),
          ]),
          const SizedBox(height: TashilSpacing.md),
          Text(
            'صف واحد بيتسحب بالعرض',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: TashilSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in const [
                  'مشروبات',
                  'بقالة',
                  'منظفات',
                  'ألبان',
                  'حلويات',
                  'مجمدات',
                  'خضار',
                ])
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: TashilSpacing.sm,
                    ),
                    child: FilterChip(
                      label: Text(c),
                      selected: _row.contains(c),
                      onSelected: (v) =>
                          setState(() => v ? _row.add(c) : _row.remove(c)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      SpecSection(
        title: 'شرايح الإدخال',
        m3: 'Input chips',
        spec: 'components/chips/guidelines#input-chips',
        rule:
            'جوه حقل الكتابة. Enter أو فاصلة تعمل شريحة. Backspace مرة '
            'تحدد آخر شريحة، ومرة تانية تمسحها. زرار المسح دايماً في آخر الشريحة.',
        children: [
          InputChipField(
            label: 'باركودات إضافية للصنف',
            hint: 'اكتب الباركود واضغط Enter',
            avatar: Icons.qr_code_2,
            values: _barcodes,
            onChanged: (v) => setState(() => _barcodes = v),
          ),
        ],
      ),
      SpecSection(
        title: 'شرايح الاقتراحات',
        m3: 'Suggestion chips',
        spec: 'components/chips/guidelines#suggestion-chips',
        rule:
            'اقتراحات من النظام (عمليات بحث سابقة، رد سريع). '
            'أسماء أو جمل قصيرة، من غير أيقونة.',
        children: [
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              labelText: 'ابحث عن صنف',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: TashilSpacing.sm),
          Demo([
            for (final q in const ['سكر', 'زيت عباد', 'أرز 5 كجم'])
              ActionChip(label: Text(q), onPressed: () => _search.text = q),
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
        title: 'التاريخ',
        m3: 'Date pickers',
        spec: 'components/date-pickers/guidelines',
        rule:
            'في الفورم: حقل تاريخ يتكتب بالكيبورد وجنبه زرار تقويم. على '
            'SUNMI (شاشة compact) التقويم بيفتح modal، ومن 600dp بيفتح تحت '
            'الحقل (docked). للتواريخ البعيدة زي الصلاحية الكتابة أسرع، '
            'والحقل بيقبل 15/4/2027 وبيقبل الأرقام العربية.',
        children: [
          DateField(
            label: 'تاريخ الفاتورة',
            value: _invoiceDate,
            firstDate: DateTime(2024),
            lastDate: DateTime(2030, 12, 31),
            onChanged: (d) => setState(() => _invoiceDate = d),
          ),
          const SizedBox(height: TashilSpacing.md),
          DateField(
            label: 'تاريخ الصلاحية (docked)',
            value: _expiry,
            docked: true,
            firstDate: DateTime(2024),
            lastDate: DateTime(2035, 12, 31),
            onChanged: (d) => setState(() => _expiry = d),
          ),
        ],
      ),
      SpecSection(
        title: 'فترة تاريخ',
        m3: 'Date range picker',
        spec: 'components/date-pickers/guidelines',
        rule:
            'للتقارير: الفترات الجاهزة (اليوم، الأسبوع، الشهر) ButtonGroup، '
            'و"فترة مخصصة" بتفتح منتقي الفترة بملء الشاشة على الموبايل.',
        children: [
          Demo([
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(
                _range == null
                    ? 'فترة مخصصة'
                    : '${loc.formatShortMonthDay(_range!.start)} – '
                          '${loc.formatShortMonthDay(_range!.end)}',
              ),
              onPressed: () async {
                final r = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030, 12, 31),
                  initialDateRange: _range,
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                );
                if (r != null) setState(() => _range = r);
              },
            ),
          ]),
        ],
      ),
      SpecSection(
        title: 'الوقت',
        m3: 'Time pickers',
        spec: 'components/time-pickers/guidelines',
        rule:
            'Scroll جوه الفورم (يفضل inline). الـ Dial في dialog بس. زرار '
            'الكيبورد لازم يبقى موجود. 12 أو 24 ساعة حسب إعداد الجهاز. لو '
            'الأوقات محددة (كل ربع ساعة) استخدم ButtonGroup أو قائمة.',
        children: [
          Text(
            'موعد قفل الوردية: ${_shiftClose.format(context)}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: TashilSpacing.sm),
          ScrollTimePicker(
            value: _shiftClose,
            use24HourFormat: _time24,
            onChanged: (t) => setState(() => _shiftClose = t),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _time24,
            onChanged: (v) => setState(() => _time24 = v),
            title: const Text('نظام 24 ساعة'),
          ),
          Demo([
            OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('الساعة (Dial)'),
              onPressed: () => showTimePicker(
                context: context,
                initialTime: _shiftClose,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: _time24),
                  child: child!,
                ),
              ),
            ),
          ]),
        ],
      ),
    ]);
  }
}
