import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/content/guides.dart';
import '../../data/content/week_content.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../theme/design_tokens.dart';

class StudioBack extends StatelessWidget {
  const StudioBack({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/more');
          }
        },
        child: LiquidGlass(
          radius: AppRadius.pill,
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        ),
      ),
    );
  }
}

class TodayPlanScreen extends StatelessWidget {
  const TodayPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final w = weekAt(app.currentWeek);
    final tip = dailyFor(DateTime.now());
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 40),
          children: [
            const StudioBack(),
            const SizedBox(height: AppSpacing.sm),
            const DisplayHeadline('Today’s\nplan', size: 42),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 28,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEEK ${w.week}', style: AppTypography.caption.copyWith(letterSpacing: 1.6)),
                  Text(w.size, style: AppTypography.title.copyWith(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(w.development, style: AppTypography.body),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 28,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tip.title, style: AppTypography.title.copyWith(fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(tip.body, style: AppTypography.body),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 28,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Body', style: AppTypography.title.copyWith(fontSize: 18)),
                  Text(w.body, style: AppTypography.body),
                  const SizedBox(height: 12),
                  Text('Eat', style: AppTypography.title.copyWith(fontSize: 18)),
                  Text(w.nutrition, style: AppTypography.body),
                  const SizedBox(height: 12),
                  Text('Move', style: AppTypography.title.copyWith(fontSize: 18)),
                  Text(w.exercise, style: AppTypography.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreatheScreen extends StatefulWidget {
  const BreatheScreen({super.key});

  @override
  State<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends State<BreatheScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 8000),
  )..repeat();

  String _phase(double t) {
    if (t < 0.33) return 'Inhale';
    if (t < 0.5) return 'Hold';
    return 'Exhale';
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AnimatedBuilder(
            animation: c,
            builder: (context, _) {
              final t = c.value;
              final scale = t < 0.33
                  ? 0.72 + 0.28 * (t / 0.33)
                  : t < 0.5
                      ? 1.0
                      : 1.0 - 0.28 * ((t - 0.5) / 0.5);
              return Column(
                children: [
                  const StudioBack(),
                  const SizedBox(height: AppSpacing.sm),
                  const DisplayHeadline('Breathe\nwith baby', size: 40),
                  const Spacer(),
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 220,
                      height: 220,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.72),
                            AppColors.orchid.withValues(alpha: 0.55),
                            AppColors.sky.withValues(alpha: 0.2),
                          ],
                        ),
                        boxShadow: AppGlass.shadow,
                      ),
                      child: Text(
                        _phase(t),
                        style: AppTypography.display.copyWith(
                          fontSize: 32,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Four seconds in, two of stillness, four out. No score.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class PelvicFloorScreen extends StatefulWidget {
  const PelvicFloorScreen({super.key});

  @override
  State<PelvicFloorScreen> createState() => _PelvicFloorScreenState();
}

class _PelvicFloorScreenState extends State<PelvicFloorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );
  int reps = 0;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    HapticFeedback.mediumImpact();
    await c.forward(from: 0);
    if (!mounted) return;
    setState(() => reps++);
    c.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AnimatedBuilder(
            animation: c,
            builder: (context, _) {
              final lift = c.value < 0.5;
              return Column(
                children: [
                  const StudioBack(),
                  const SizedBox(height: AppSpacing.sm),
                  const DisplayHeadline('Pelvic\nfloor', size: 40),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    lift && c.isAnimating ? 'Lift on the exhale' : 'Fully let go',
                    style: AppTypography.title,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: _RingPainter(c.value),
                      child: Center(
                        child: Text(
                          '$reps / 8',
                          style: AppTypography.display.copyWith(fontSize: 36),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'The release is the half most people skip. Stop if anything feels sharp.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PillButton(
                    label: c.isAnimating ? 'Holding…' : 'Start a set',
                    onTap: c.isAnimating ? () {} : _run,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * t,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = AppColors.violet,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.t != t;
}

class CravingsScreen extends StatefulWidget {
  const CravingsScreen({super.key});

  @override
  State<CravingsScreen> createState() => _CravingsScreenState();
}

class _CravingsScreenState extends State<CravingsScreen> {
  final text = TextEditingController();
  bool aversion = false;

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final logs = app.vitals
        .where((v) => v.kind == 'craving' || v.kind == 'aversion')
        .take(16)
        .toList();
    const chips = ['Citrus', 'Salt', 'Ice', 'Spice', 'Sweet', 'Coffee smell'];
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const StudioBack(),
            const SizedBox(height: AppSpacing.sm),
            const DisplayHeadline('Cravings &\naversions', size: 40),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chip in chips)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      app.addVital(
                        kind: aversion ? 'aversion' : 'craving',
                        value: 1,
                        note: chip,
                      );
                    },
                    child: LiquidGlass(
                      radius: AppRadius.pill,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text(chip, style: AppTypography.caption.copyWith(color: AppColors.ink)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 24,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  TextField(
                    controller: text,
                    decoration: const InputDecoration(
                      hintText: 'Something else…',
                      border: InputBorder.none,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => aversion = !aversion),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        aversion ? 'Logging an aversion' : 'Logging a craving',
                        style: AppTypography.caption,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PillButton(
                    label: 'Save',
                    onTap: () {
                      if (text.text.trim().isEmpty) return;
                      app.addVital(
                        kind: aversion ? 'aversion' : 'craving',
                        value: 1,
                        note: text.text.trim(),
                      );
                      text.clear();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final log in logs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LiquidGlass(
                  radius: 20,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Text(
                        log.kind == 'aversion' ? 'Aversion' : 'Craving',
                        style: AppTypography.caption,
                      ),
                      const Spacer(),
                      Text(log.note, style: AppTypography.body),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BellyTapeScreen extends StatefulWidget {
  const BellyTapeScreen({super.key});

  @override
  State<BellyTapeScreen> createState() => _BellyTapeScreenState();
}

class _BellyTapeScreenState extends State<BellyTapeScreen> {
  final cm = TextEditingController();

  @override
  void dispose() {
    cm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final logs = app.vitals.where((v) => v.kind == 'belly').toList();
    final last = logs.isEmpty ? null : logs.first;
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const StudioBack(),
            const SizedBox(height: AppSpacing.sm),
            const DisplayHeadline('Belly\ntape', size: 42),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 28,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    last == null ? 'No tape yet' : '${last.value.round()} cm',
                    style: AppTypography.display.copyWith(fontSize: 40),
                  ),
                  Text(
                    'Pubic bone to the top of the uterus, once a week after 20. This is a home note, not a growth scan.',
                    style: AppTypography.body,
                  ),
                  TextField(
                    controller: cm,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Centimetres',
                      border: InputBorder.none,
                    ),
                  ),
                  PillButton(
                    label: 'Save tape',
                    onTap: () {
                      final v = double.tryParse(cm.text.trim());
                      if (v == null) return;
                      app.addVital(kind: 'belly', value: v);
                      cm.clear();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final log in logs.take(8))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LiquidGlass(
                  radius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Text('${log.value.round()} cm', style: AppTypography.title.copyWith(fontSize: 16)),
                      const Spacer(),
                      Text(DateFormat('d MMM').format(log.at), style: AppTypography.caption),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FoodSafetyScreen extends StatefulWidget {
  const FoodSafetyScreen({super.key});

  @override
  State<FoodSafetyScreen> createState() => _FoodSafetyScreenState();
}

class _FoodSafetyScreenState extends State<FoodSafetyScreen> {
  String q = '';

  static const items = <(String, String, String)>[
    ('Soft cheese', 'Skip if unpasteurized', 'alert'),
    ('Sushi', 'Cooked is fine; raw is a skip', 'alert'),
    ('Coffee', 'About one small cup', 'warn'),
    ('Papaya', 'Ripe is usually fine; raw green is a skip', 'warn'),
    ('Eggs', 'Fully cooked yolks', 'safe'),
    ('Fish', 'Low-mercury, well cooked', 'safe'),
    ('Deli meat', 'Heat until steaming', 'warn'),
    ('Alcohol', 'Skip', 'alert'),
    ('Herbal teas', 'Ask the clinic — some are not quiet', 'warn'),
    ('Leftovers', 'Reheat thoroughly, once', 'safe'),
  ];

  @override
  Widget build(BuildContext context) {
    final shown = items
        .where((e) => q.isEmpty || e.$1.toLowerCase().contains(q.toLowerCase()))
        .toList();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const StudioBack(),
            const SizedBox(height: AppSpacing.sm),
            const DisplayHeadline('Food\nsafety', size: 42),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 22,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                onChanged: (v) => setState(() => q = v),
                decoration: const InputDecoration(
                  hintText: 'Search a food…',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final item in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LiquidGlass(
                  radius: 20,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.$3 == 'alert'
                              ? AppColors.semanticAlert
                              : item.$3 == 'warn'
                                  ? AppColors.semanticWarn
                                  : AppColors.semanticSafe,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$1, style: AppTypography.title.copyWith(fontSize: 16)),
                            Text(item.$2, style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Text(
              'This is a household guide, not a diet prescription.',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const StudioBack(),
            const SizedBox(height: AppSpacing.sm),
            DisplayHeadline(title, size: 36),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 24,
              padding: const EdgeInsets.all(18),
              child: Text(body, style: AppTypography.body),
            ),
          ],
        ),
      ),
    );
  }
}

const kPrivacyBody =
    'Mira stores your notes, vitals, and photos on this device first. '
    'If you later connect a cloud account, only the records you choose to sync leave the phone. '
    'We do not sell health data. You can export a summary or delete the account from Settings. '
    'Guest sessions stay local.';

const kDisclaimerBody =
    'Mira is a pregnancy companion, not a medical device and not a substitute for antenatal care. '
    'It does not diagnose, treat, or predict complications. '
    'Call your clinician or emergency services for bleeding, fluid leak, severe headache, chest pain, '
    'a sudden drop in baby movement, or anything that feels wrong. In India, ambulance is 108.';

class ExportCareScreen extends StatelessWidget {
  const ExportCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final snap = app.exportSnapshot();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const StudioBack(),
            const SizedBox(height: AppSpacing.sm),
            const DisplayHeadline('Export\ncare', size: 40),
            const SizedBox(height: AppSpacing.md),
            LiquidGlass(
              radius: 24,
              padding: const EdgeInsets.all(18),
              child: Text(snap, style: AppTypography.body),
            ),
            const SizedBox(height: AppSpacing.md),
            PillButton(
              label: 'Share summary',
              onTap: () => SharePlus.instance.share(ShareParams(text: snap)),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> promptAddCheck(BuildContext context, String listId) async {
  final field = TextEditingController();
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(16),
      child: LiquidGlass(
        radius: 28,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: field,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Add an item',
                border: InputBorder.none,
              ),
            ),
            PillButton(label: 'Add', onTap: () => Navigator.pop(ctx, true)),
          ],
        ),
      ),
    ),
  );
  if (ok == true && field.text.trim().isNotEmpty && context.mounted) {
    await context.read<AppState>().addCheck(listId: listId, label: field.text.trim());
  }
  field.dispose();
}

class AddCheckSheet {
  static Future<void> show(BuildContext context, String listId) =>
      promptAddCheck(context, listId);
}
