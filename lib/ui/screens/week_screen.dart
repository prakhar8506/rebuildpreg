import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../components/premium.dart';
import '../theme/design_tokens.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final w = app.weekContent;
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            PremiumHeader(
              initial: app.firstName.isEmpty ? 'M' : app.firstName[0],
              dateLabel: 'Week ${app.viewingWeek} of 40',
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DisplayHeadline('This\nweek', size: 44),
                ),
                SemiGauge(
                  value: app.viewingWeek.toDouble(),
                  max: 40,
                  caption: app.weekContent.fruit,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 40,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final week = i + 1;
                  return GradientRingDateChip(
                    label: '$week',
                    caption: week == app.currentWeek ? 'now' : '',
                    selected: week == app.viewingWeek,
                    onTap: () => app.setViewingWeek(week),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _jump(context, app),
                child: Text(S.t('jumpWeek', app.lang)),
              ),
            ),
            GlassCard(
              variant: GlassVariant.photoOverlay,
              height: 210,
              photo: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.peach,
                      AppColors.orchid.withValues(alpha: 0.85),
                      AppColors.rose,
                    ],
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  PhotoLabelChip('Size of ${w.fruit}'),
                  const SizedBox(height: 8),
                  Text(
                    w.size,
                    style: AppTypography.title.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PillTabBar(
              tabs: const ['Grow', 'Body', 'Avoid'],
              index: tab,
              onChanged: (v) => setState(() => tab = v),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              opaque: true,
              child: Text(
                [w.development, w.body, w.avoid][tab],
                style: AppTypography.body.copyWith(color: AppColors.ink),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('THIS WEEK', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(child: Text('Nutrition  ·  ${w.nutrition}', style: AppTypography.body)),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(child: Text('Movement  ·  ${w.exercise}', style: AppTypography.body)),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(child: Text('Yoga  ·  ${w.yoga}', style: AppTypography.body)),
            const SizedBox(height: AppSpacing.md),
            Text('FAQ', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            for (final faq in w.faqs) ...[
              GlassCard(child: Text(faq, style: AppTypography.body)),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _jump(BuildContext context, AppState app) async {
    var pick = app.viewingWeek;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: GlassCard(
            child: StatefulBuilder(
              builder: (ctx, set) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Jump to week $pick', style: AppTypography.title),
                    Slider(
                      value: pick.toDouble(),
                      min: 1,
                      max: 40,
                      divisions: 39,
                      activeColor: AppColors.violet,
                      onChanged: (v) => set(() => pick = v.round()),
                    ),
                    PillButton(
                      label: 'Go',
                      onTap: () {
                        app.setViewingWeek(pick);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
