import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ids.dart';
import '../../core/l10n.dart';
import '../../data/content/week_content.dart';
import '../../data/services/sync_service.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../components/glass_studio.dart';
import '../theme/design_tokens.dart';
import 'mind_body_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _scroll = 0;

  int _score(AppState app) {
    final water = (app.todayWaterMl / 2500 * 40).clamp(0, 40);
    final today = dayKey(DateTime.now());
    final moods = app.vitals.where((v) => v.kind == 'mood' && dayKey(v.at) == today);
    final mood = moods.isEmpty ? 18.0 : (moods.first.value / 5 * 30);
    final sleeps = app.vitals.where((v) => v.kind == 'sleep' && dayKey(v.at) == today);
    final sleep = sleeps.isEmpty ? 16.0 : (sleeps.first.value / 8 * 30).clamp(0, 30);
    return (water + mood + sleep).round().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final score = _score(app);
    final week = weekAt(app.currentWeek);
    final named = (app.user?.displayName ?? '').trim().isNotEmpty;
    final name = named ? app.firstName : 'there';
    final initial = named ? app.firstName[0] : 'M';
    final waterSpark = app.vitals
        .where((v) => v.kind == 'water')
        .take(8)
        .map((v) => v.value)
        .toList();
    final syncLabel = switch (app.syncStatus) {
      SyncStatus.offline => S.t('offline', app.lang),
      SyncStatus.syncing => S.t('syncing', app.lang),
      SyncStatus.synced => S.t('synced', app.lang),
    };
    final steps = <(IconData, String, bool)>[
      (Icons.water_drop_outlined, 'Sip', app.ritualDone('sip')),
      (Icons.directions_walk_rounded, 'Walk', app.ritualDone('walk')),
      (Icons.medication_outlined, 'Vitamin', app.ritualDone('vitamin')),
      (Icons.hotel_outlined, 'Rest', app.ritualDone('rest')),
    ];

    return GradientMeshBackground(
      parallax: _scroll,
      child: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n is ScrollUpdateNotification) {
              setState(() => _scroll = n.metrics.pixels);
            }
            return false;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              140,
            ),
            children: [
              StudioHeader(
                initial: initial,
                score: score,
                scoreLabel: 'Care pulse',
                onBell: () => context.push('/care/reminders'),
                onGrid: () => context.go('/more'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Hello, $name', style: AppTypography.body),
              Text(
                'Your week ${app.currentWeek} plan is ready.',
                style: AppTypography.display.copyWith(fontSize: 32, height: 1.12),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.push('/life/journal'),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.82),
                      boxShadow: AppGlass.shadow,
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.ink),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (app.settings.sosActive) ...[
                SolidAlertBanner(
                  title: S.t('sos', app.lang),
                  body: 'Ambulance 108  ·  emergency contacts',
                  onTap: () => context.push('/people/sos'),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              RitualGlassCard(
                dateLabel: DateFormat('d MMM').format(DateTime.now()),
                title: "Today’s routine",
                fruit: week.fruit,
                done: app.ritualDoneCount,
                total: AppState.ritualKeys.length,
                steps: steps,
                health: score / 100,
                onRead: () => context.push('/plan'),
                onStep: (i) => app.completeRitual(AppState.ritualKeys[i]),
              ),
              const SizedBox(height: AppSpacing.md),
              SwipeActionBar(
                label: 'Swipe to log a sip',
                leading: Icons.water_drop_outlined,
                onComplete: () => app.completeRitual('sip'),
              ),
              const SizedBox(height: AppSpacing.md),
              const CareRingsRow(),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(syncLabel, style: AppTypography.caption),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    VitalStatCard(
                      label: S.t('water', app.lang),
                      value: '${app.todayWaterMl.round()}',
                      unit: 'ml',
                      spark: waterSpark.isEmpty ? const [1, 2, 1.5, 3] : waterSpark,
                      badge: 'Today',
                      onTap: () => context.push('/care/water'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    VitalStatCard(
                      label: S.t('medicines', app.lang),
                      value: '${app.medsDueToday.length}',
                      unit: 'due',
                      spark: const [1, 1, 2, 2, 3],
                      badge: app.medsDueToday.isEmpty ? 'Clear' : 'Open',
                      badgeColor: app.medsDueToday.isEmpty
                          ? AppColors.semanticSafe
                          : AppColors.semanticWarn,
                      onTap: () => context.push('/care/meds'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    VitalStatCard(
                      label: S.t('nextVisit', app.lang),
                      value: app.nextVisit == null
                          ? '—'
                          : DateFormat('d').format(app.nextVisit!.at),
                      unit: app.nextVisit == null
                          ? ''
                          : DateFormat('MMM').format(app.nextVisit!.at),
                      spark: const [2, 2, 3, 2],
                      badge: app.nextVisit?.title ?? 'Add',
                      onTap: () => context.push('/care/visits'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
