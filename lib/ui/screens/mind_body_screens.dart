import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../components/aura_loop.dart';
import '../components/components.dart';
import '../components/glass_studio.dart';
import '../theme/design_tokens.dart';
import 'studio_screens.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  int minutes = 5;
  bool running = false;
  DateTime? started;
  Timer? ticker;
  late final AnimationController breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 8000),
  );

  Duration get elapsed =>
      started == null ? Duration.zero : DateTime.now().difference(started!);

  Duration get remaining {
    final total = Duration(minutes: minutes);
    final left = total - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  String _phase(double t) {
    if (t < 0.33) return 'Inhale';
    if (t < 0.5) return 'Hold';
    return 'Exhale';
  }

  void _start() {
    HapticFeedback.mediumImpact();
    ticker?.cancel();
    setState(() {
      running = true;
      started = DateTime.now();
    });
    breath.repeat();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (remaining == Duration.zero) {
        _finish();
        return;
      }
      setState(() {});
    });
  }

  Future<void> _finish() async {
    ticker?.cancel();
    breath.stop();
    final mins = started == null
        ? minutes.toDouble()
        : (elapsed.inSeconds / 60).clamp(1, minutes.toDouble());
    HapticFeedback.heavyImpact();
    await context.read<AppState>().logMind(kind: 'meditate', minutes: mins.toDouble());
    if (!mounted) return;
    setState(() {
      running = false;
      started = null;
    });
  }

  @override
  void dispose() {
    ticker?.cancel();
    breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final mm = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return AuraLoopBackdrop(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 28),
          child: Column(
            children: [
              const StudioBack(),
              const SizedBox(height: AppSpacing.sm),
              Text('SIT WITH', style: AppTypography.caption.copyWith(letterSpacing: 2)),
              AnimatedBuilder(
                animation: breath,
                builder: (context, _) => Text(
                  running ? _phase(breath.value) : 'Stillness',
                  style: AppTypography.display.copyWith(fontSize: 42, fontStyle: FontStyle.italic),
                ),
              ),
              Text(
                running ? '$mm:$ss' : '$minutes min',
                style: AppTypography.title.copyWith(fontSize: 20),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: breath,
                builder: (context, _) {
                  final t = running ? breath.value : 0.2;
                  return Transform.scale(
                    scale: 0.92 + 0.08 * (t < 0.5 ? t * 2 : 2 - t * 2),
                    child: LiquidGlass(
                      radius: AppRadius.pill,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      child: Text(
                        running
                            ? 'The orb is the breath. Stay with it.'
                            : 'Today ${app.todayMindMin.round()} min of quiet',
                        style: AppTypography.body,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              if (!running)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final m in const [3, 5, 10])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => minutes = m);
                          },
                          child: LiquidGlass(
                            radius: AppRadius.pill,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text(
                              '$m min',
                              style: AppTypography.caption.copyWith(
                                color: minutes == m ? AppColors.ink : AppColors.mutedGray,
                                fontWeight: minutes == m ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              PillButton(
                label: running ? 'Close the sit' : 'Begin',
                onTap: running ? _finish : _start,
              ),
              const SizedBox(height: 8),
              Text(
                'A calm practice, not a treatment. Stop if you feel faint or uneasy.',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityStudioScreen extends StatefulWidget {
  const ActivityStudioScreen({super.key});

  @override
  State<ActivityStudioScreen> createState() => _ActivityStudioScreenState();
}

class _ActivityStudioScreenState extends State<ActivityStudioScreen> {
  bool live = false;
  String liveKind = 'walk';
  DateTime? started;
  Timer? ticker;
  String feel = 'right';

  static const kinds = <(String, IconData, String)>[
    ('walk', Icons.directions_walk_rounded, 'Walk'),
    ('stretch', Icons.self_improvement_rounded, 'Stretch'),
    ('yoga', Icons.spa_outlined, 'Prenatal yoga'),
    ('swim', Icons.pool_outlined, 'Swim'),
    ('floor', Icons.favorite_outline, 'Pelvic floor'),
  ];

  Duration get elapsed =>
      started == null ? Duration.zero : DateTime.now().difference(started!);

  void _toggleLive() {
    if (live) {
      final mins = (elapsed.inSeconds / 60).clamp(1, 180).toDouble();
      context.read<AppState>().logMove(note: liveKind, minutes: mins, feel: feel);
      ticker?.cancel();
      HapticFeedback.mediumImpact();
      setState(() {
        live = false;
        started = null;
      });
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      live = true;
      started = DateTime.now();
    });
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final week = app.weekMoveMinutes();
    final logs = app.vitals.where((v) => v.kind == 'move' || v.kind == 'meditate').take(8);
    return AuraLoopBackdrop(
      dim: 0.14,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 40),
          children: [
            const StudioBack(),
            const SizedBox(height: AppSpacing.sm),
            const DisplayHeadline('Mind &\nbody', size: 42),
            Text(
              'Gentle rings. Conversational pace. Not a 10,000-step dare.',
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 28,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RingCol(progress: app.moveRing, label: 'Move', caption: '${app.todayMoveMin.round()}m'),
                  _RingCol(progress: app.mindRing, label: 'Mind', caption: '${app.todayMindMin.round()}m'),
                  _RingCol(progress: app.restRing, label: 'Rest', caption: '${app.todaySleepHr.toStringAsFixed(1)}h'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 26,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(live ? 'Session on' : 'Start a session', style: AppTypography.title.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final k in kinds)
                        GestureDetector(
                          onTap: live
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  setState(() => liveKind = k.$1);
                                },
                          child: LiquidGlass(
                            radius: AppRadius.pill,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(k.$2, size: 14, color: liveKind == k.$1 ? AppColors.ink : AppColors.mutedGray),
                                const SizedBox(width: 6),
                                Text(k.$3, style: AppTypography.caption.copyWith(color: AppColors.ink)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    live
                        ? '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}'
                        : 'Timer stays on this screen. Stop when the body asks.',
                    style: live
                        ? AppTypography.display.copyWith(fontSize: 36)
                        : AppTypography.caption,
                  ),
                  const SizedBox(height: 10),
                  if (live) ...[
                    Text('How did that feel?', style: AppTypography.caption),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (final f in const [('gentle', 'Gentle'), ('right', 'Just right'), ('much', 'A bit much')])
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => feel = f.$1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: LiquidGlass(
                                  radius: 14,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    f.$2,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.caption.copyWith(
                                      color: feel == f.$1 ? AppColors.ink : AppColors.mutedGray,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  PillButton(
                    label: live ? 'Save session' : 'Start ${kinds.firstWhere((k) => k.$1 == liveKind).$3.toLowerCase()}',
                    onTap: _toggleLive,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Quick log', style: AppTypography.caption.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final q in const [
                  ('walk', 10, '10 min walk'),
                  ('stretch', 8, '8 min stretch'),
                  ('yoga', 15, '15 min yoga'),
                  ('meditate', 5, '5 min sit'),
                ])
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (q.$1 == 'meditate') {
                        context.push('/life/meditate');
                        return;
                      }
                      app.logMove(note: q.$1, minutes: q.$2.toDouble());
                    },
                    child: LiquidGlass(
                      radius: AppRadius.pill,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Text(q.$3, style: AppTypography.caption.copyWith(color: AppColors.ink)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 24,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This week', style: AppTypography.title.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < week.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              children: [
                                Container(
                                  height: 8 + (week[i].clamp(0, 40) * 2.2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white.withValues(alpha: 0.55),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('E').format(
                                    DateTime.now().subtract(Duration(days: 6 - i)),
                                  )[0],
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 24,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mental check', style: AppTypography.title.copyWith(fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(
                    app.todayMoodCount == 0
                        ? 'No mood note yet today.'
                        : '${app.todayMoodCount} mood note${app.todayMoodCount == 1 ? '' : 's'} today.',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/life/wellbeing'),
                          child: LiquidGlass(
                            radius: 16,
                            padding: const EdgeInsets.all(12),
                            child: Text('How I feel', style: AppTypography.caption.copyWith(color: AppColors.ink)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/life/meditate'),
                          child: LiquidGlass(
                            radius: 16,
                            padding: const EdgeInsets.all(12),
                            child: Text('Meditate', style: AppTypography.caption.copyWith(color: AppColors.ink)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final log in logs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LiquidGlass(
                  radius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Text(
                        log.kind == 'meditate' ? 'Sit' : log.note,
                        style: AppTypography.title.copyWith(fontSize: 16),
                      ),
                      const Spacer(),
                      Text('${log.value.round()} min', style: AppTypography.caption),
                      const SizedBox(width: 8),
                      Text(DateFormat('h:mm a').format(log.at), style: AppTypography.caption),
                    ],
                  ),
                ),
              ),
            Text(
              'If talking becomes hard, dizziness starts, or something feels sharp — stop and tell a clinician.',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _RingCol extends StatelessWidget {
  const _RingCol({required this.progress, required this.label, required this.caption});

  final double progress;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DonutGauge(progress: progress, label: label, size: 78),
        const SizedBox(height: 6),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.ink)),
        Text(caption, style: AppTypography.caption),
      ],
    );
  }
}

class CareRingsRow extends StatelessWidget {
  const CareRingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GestureDetector(
      onTap: () => context.push('/life/activity'),
      child: LiquidGlass(
        radius: 26,
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        child: Row(
          children: [
            Expanded(child: _RingCol(progress: app.moveRing, label: 'Move', caption: '${app.todayMoveMin.round()}m')),
            Expanded(child: _RingCol(progress: app.mindRing, label: 'Mind', caption: '${app.todayMindMin.round()}m')),
            Expanded(child: _RingCol(progress: app.restRing, label: 'Rest', caption: '${app.todaySleepHr.toStringAsFixed(1)}h')),
          ],
        ),
      ),
    );
  }
}
