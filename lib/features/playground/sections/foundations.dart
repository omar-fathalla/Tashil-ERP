import 'package:material_ui/material_ui.dart';

import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import 'color_roles_demo.dart';
import 'common.dart';

class FoundationsSection extends StatelessWidget {
  const FoundationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final styles = <(String, TextStyle?)>[
      ('displaySmall', text.displaySmall),
      ('headlineMedium', text.headlineMedium),
      ('headlineSmall', text.headlineSmall),
      ('titleLarge', text.titleLarge),
      ('titleMedium', text.titleMedium),
      ('titleSmall', text.titleSmall),
      ('bodyLarge', text.bodyLarge),
      ('bodyMedium', text.bodyMedium),
      ('bodySmall', text.bodySmall),
      ('labelLarge', text.labelLarge),
      ('labelMedium', text.labelMedium),
      ('labelSmall', text.labelSmall),
    ];

    return SectionList([
      const SpecSection(
        title: 'الألوان',
        m3: 'Color roles · color system',
        spec: 'styles/color/roles',
        rule:
            'كل الألوان أدوار من ColorScheme المتولد من لون البذرة، ومفيش '
            'لون hex في أي شاشة. استخدم كل دور مع الـ on بتاعه بس (ده اللي '
            'بيضمن التباين). الـ container للخلفيات مش للكلام. 3 مستويات '
            'تباين (زرار التباين فوق): عادي، متوسط، عالي، والعالي بيشتغل '
            'لوحده لو الجهاز طالبه. الرقم جنب كل لون هو التباين.',
        children: [ColorRolesDemo()],
      ),
      SpecSection(
        title: 'الخطوط',
        spec: 'styles/typography/type-scale-tokens',
        rule:
            'خط Cairo مضمّن في التطبيق (يشتغل أوفلاين). '
            'استخدم textTheme فقط، ممنوع fontSize يدوي.',
        children: [
          for (final (name, style) in styles)
            Padding(
              padding: const EdgeInsets.only(bottom: TashilSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: text.labelSmall?.copyWith(color: s.primary),
                    textDirection: TextDirection.ltr,
                  ),
                  Text('سكر أبيض 1 كجم — 45.50 ج.م', style: style),
                ],
              ),
            ),
        ],
      ),
      SpecSection(
        title: 'الأشكال',
        m3: 'Corner radius',
        spec: 'styles/shape/corner-radius-scale',
        children: [
          Demo([
            for (final (n, r) in const [
              ('xs 4', TashilRadius.extraSmall),
              ('sm 8', TashilRadius.small),
              ('md 12', TashilRadius.medium),
              ('lg 16', TashilRadius.large),
              ('xl 28', TashilRadius.extraLarge),
            ])
              Container(
                width: 72,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: s.secondaryContainer,
                  borderRadius: BorderRadius.circular(r),
                ),
                child: Text(n, style: text.labelMedium),
              ),
          ]),
        ],
      ),
      SpecSection(
        title: 'المسافات',
        spec: 'foundations/layout/understanding-layout/spacing',
        rule: 'شبكة 4dp. هامش الصفحة 16. أقل مساحة لمس 48.',
        children: [
          for (final (n, v) in const [
            ('xs', TashilSpacing.xs),
            ('sm', TashilSpacing.sm),
            ('md', TashilSpacing.md),
            ('lg', TashilSpacing.lg),
            ('xl', TashilSpacing.xl),
            ('xxl', TashilSpacing.xxl),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: TashilSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text('$n ${v.toInt()}', style: text.labelMedium),
                  ),
                  Container(width: v * 4, height: 12, color: s.primary),
                ],
              ),
            ),
        ],
      ),
      const SpecSection(
        title: 'الحركة',
        m3: 'Motion · springs (M3 Expressive)',
        spec: 'styles/motion/overview',
        rule:
            'كل حركة داخل الشاشة spring من TashilSpring. Spatial للمكان '
            'والحجم والشكل (بيعمل نطّة)، Effects للون والشفافية (من غير '
            'نطّة). الانتقال بين الشاشات Durations + Easing.',
        children: [_MotionDemo()],
      ),
    ]);
  }
}

class _MotionDemo extends StatefulWidget {
  const _MotionDemo();

  @override
  State<_MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<_MotionDemo> {
  bool _on = false;

  static const _spatial = [
    (TashilSpring.fastSpatial, 'fast spatial'),
    (TashilSpring.defaultSpatial, 'default spatial'),
    (TashilSpring.slowSpatial, 'slow spatial'),
    (TashilSpring.standardDefaultSpatial, 'standard default'),
  ];

  static const _effects = [
    (TashilSpring.fastEffects, 'fast effects'),
    (TashilSpring.defaultEffects, 'default effects'),
    (TashilSpring.slowEffects, 'slow effects'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget label(TashilSpring sp, String name) => Text(
      '$name · damping ${sp.dampingRatio} · stiffness '
      '${sp.stiffness.toInt()} · ${sp.duration.inMilliseconds}ms',
      style: text.labelSmall?.copyWith(color: s.onSurfaceVariant),
      textDirection: TextDirection.ltr,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: () => setState(() => _on = !_on),
          icon: const Icon(Icons.play_arrow),
          label: const Text('شغّل الحركة'),
        ),
        const SizedBox(height: TashilSpacing.md),
        for (final (sp, name) in _spatial) ...[
          label(sp, name),
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: TashilSpacing.sm),
            decoration: BoxDecoration(
              color: s.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(TashilRadius.full),
            ),
            child: AnimatedAlign(
              duration: TashilMotion.scaled(context, sp.duration),
              curve: sp.curve,
              alignment: _on
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: s.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: TashilSpacing.sm),
        for (final (sp, name) in _effects) ...[
          label(sp, name),
          AnimatedContainer(
            duration: TashilMotion.scaled(context, sp.duration),
            curve: sp.curve,
            height: 32,
            margin: const EdgeInsets.only(bottom: TashilSpacing.sm),
            decoration: BoxDecoration(
              color: _on ? s.tertiary : s.tertiaryContainer,
              borderRadius: BorderRadius.circular(TashilRadius.small),
            ),
          ),
        ],
      ],
    );
  }
}
