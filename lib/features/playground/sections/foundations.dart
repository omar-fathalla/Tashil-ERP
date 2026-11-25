import 'package:material_ui/material_ui.dart';

import '../../../core/design/tokens.dart';
import 'common.dart';

class FoundationsSection extends StatelessWidget {
  const FoundationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final sem = TashilSemanticColors.of(context);
    final text = Theme.of(context).textTheme;

    final roles = <(String, Color, Color)>[
      ('primary', s.primary, s.onPrimary),
      ('primaryContainer', s.primaryContainer, s.onPrimaryContainer),
      ('secondary', s.secondary, s.onSecondary),
      ('secondaryContainer', s.secondaryContainer, s.onSecondaryContainer),
      ('tertiary', s.tertiary, s.onTertiary),
      ('tertiaryContainer', s.tertiaryContainer, s.onTertiaryContainer),
      ('error', s.error, s.onError),
      ('errorContainer', s.errorContainer, s.onErrorContainer),
      ('success *', sem.success, sem.onSuccess),
      ('successContainer *', sem.successContainer, sem.onSuccessContainer),
      ('warning *', sem.warning, sem.onWarning),
      ('warningContainer *', sem.warningContainer, sem.onWarningContainer),
      ('surface', s.surface, s.onSurface),
      ('surfaceContainerLow', s.surfaceContainerLow, s.onSurface),
      ('surfaceContainer', s.surfaceContainer, s.onSurface),
      ('surfaceContainerHigh', s.surfaceContainerHigh, s.onSurface),
      ('surfaceContainerHighest', s.surfaceContainerHighest, s.onSurface),
      ('inverseSurface', s.inverseSurface, s.onInverseSurface),
    ];

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
      SpecSection(
        title: 'الألوان',
        spec: 'styles/color/roles',
        rule:
            'كل الألوان من ColorScheme المتولد من لون البذرة. '
            'العناصر بعلامة * امتداد خاص بتسهيل (نجاح/تحذير).',
        children: [
          for (final (name, bg, fg) in roles)
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: TashilSpacing.md),
              alignment: AlignmentDirectional.centerStart,
              color: bg,
              child: Text(
                name,
                style: text.labelLarge?.copyWith(color: fg),
                textDirection: TextDirection.ltr,
              ),
            ),
        ],
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
    ]);
  }
}
