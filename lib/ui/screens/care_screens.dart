import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ids.dart';
import '../../data/models/models.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../components/premium.dart';
import '../theme/design_tokens.dart';

class CareHubScreen extends StatelessWidget {
  const CareHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final bp = app.vitals.where((v) => v.kind == 'bp_sys');
    final glu = app.vitals.where((v) => v.kind == 'glucose');
    final wt = app.vitals.where((v) => v.kind == 'weight');
    final sleep = app.vitals.where((v) => v.kind == 'sleep');
    final mood = app.vitals.where((v) => v.kind == 'mood');

    Widget card({
      required String label,
      required String value,
      required String unit,
      required List<double> spark,
      required String route,
      String? badge,
      Color badgeColor = AppColors.semanticSafe,
    }) {
      return VitalStatCard(
        label: label,
        value: value,
        unit: unit,
        spark: spark,
        badge: badge,
        badgeColor: badgeColor,
        onTap: () => context.push(route),
      );
    }

    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            PremiumHeader(
              initial: app.firstName.isEmpty ? 'M' : app.firstName[0],
              dateLabel: DateFormat('EEEE, d MMM').format(DateTime.now()),
            ),
            const SizedBox(height: AppSpacing.sm),
            const DisplayHeadline('Care,\nin numbers', size: 40),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                card(
                  label: 'Water',
                  value: '${app.todayWaterMl.round()}',
                  unit: 'ml',
                  spark: const [1, 2, 2, 3],
                  route: '/care/water',
                ),
                card(
                  label: 'Weight',
                  value: wt.isEmpty ? '—' : wt.first.value.toStringAsFixed(1),
                  unit: 'kg',
                  spark: wt.take(7).map((e) => e.value).toList().reversed.toList(),
                  route: '/care/weight',
                ),
                card(
                  label: 'Blood pressure',
                  value: bp.isEmpty ? '—' : '${bp.first.value.round()}/${(bp.first.extra['dia'] ?? 0)}',
                  unit: 'mmHg',
                  spark: bp.take(7).map((e) => e.value).toList().reversed.toList(),
                  route: '/care/bp',
                  badge: 'Solid ink',
                ),
                card(
                  label: 'Glucose',
                  value: glu.isEmpty ? '—' : glu.first.value.toStringAsFixed(0),
                  unit: 'mg/dL',
                  spark: glu.take(7).map((e) => e.value).toList().reversed.toList(),
                  route: '/care/glucose',
                ),
                card(
                  label: 'Sleep',
                  value: sleep.isEmpty ? '—' : sleep.first.value.toStringAsFixed(1),
                  unit: 'h',
                  spark: sleep.take(7).map((e) => e.value).toList().reversed.toList(),
                  route: '/care/sleep',
                ),
                card(
                  label: 'Mood',
                  value: mood.isEmpty ? '—' : mood.first.value.toStringAsFixed(0),
                  unit: '/5',
                  spark: const [3, 4, 3, 5],
                  route: '/care/mood',
                ),
                card(
                  label: 'Medicines',
                  value: '${app.medicines.length}',
                  unit: 'rx',
                  spark: const [1, 2, 2],
                  route: '/care/meds',
                ),
                card(
                  label: 'Vaccines',
                  value: '${app.vaccines.where((v) => v.done).length}/${app.vaccines.length}',
                  unit: '',
                  spark: const [1, 1, 2],
                  route: '/care/vaccines',
                ),
                card(
                  label: 'Visits',
                  value: '${app.appointments.length}',
                  unit: '',
                  spark: const [1, 2, 1],
                  route: '/care/visits',
                ),
                card(
                  label: 'Calendar',
                  value: '${app.currentWeek}',
                  unit: 'wk',
                  spark: const [2, 3, 4],
                  route: '/care/calendar',
                ),
                card(
                  label: 'Reminders',
                  value: '${app.reminders.length}',
                  unit: '',
                  spark: const [1, 1, 1],
                  route: '/care/reminders',
                ),
                card(
                  label: 'Reports',
                  value: '${app.vitals.length}',
                  unit: 'logs',
                  spark: const [2, 3, 5],
                  route: '/care/reports',
                ),
                card(
                  label: 'Insights',
                  value: '•',
                  unit: '',
                  spark: const [1, 3, 2, 4],
                  route: '/care/insights',
                ),
                card(
                  label: 'Symptoms',
                  value: '${app.vitals.where((v) => v.kind == 'symptom').length}',
                  unit: '',
                  spark: const [1, 2, 1],
                  route: '/care/symptoms',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogScaffold extends StatelessWidget {
  const _LogScaffold({
    required this.title,
    required this.child,
    this.composer,
  });

  final String title;
  final Widget child;
  final Widget? composer;

  @override
  Widget build(BuildContext context) {
    return GradientMeshBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(child: DisplayHeadline(title, size: 32)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 24),
                children: [child],
              ),
            ),
            if (composer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: composer,
              ),
          ],
        ),
      ),
    );
  }
}

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return _LogScaffold(
      title: 'Water',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VitalStatCard(
            label: 'Today',
            value: '${app.todayWaterMl.round()}',
            unit: 'ml',
            spark: app.vitals
                .where((v) => v.kind == 'water')
                .take(8)
                .map((e) => e.value)
                .toList()
                .reversed
                .toList(),
            badge: app.todayWaterMl >= 2000 ? 'Goal' : 'Keep sipping',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            children: [
              for (final ml in [150, 250, 350, 500])
                ActionChip(
                  label: Text('$ml ml'),
                  onPressed: () => app.addVital(kind: 'water', value: ml.toDouble()),
                ),
            ],
          ),
        ],
      ),
      composer: BottomComposerBar(
        hint: 'Custom ml',
        onSend: () {},
        onMic: () async {
          await _customNumber(context, 'Millilitres', (v) {
            app.addVital(kind: 'water', value: v);
          });
        },
      ),
    );
  }
}

class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final logs = app.vitals.where((v) => v.kind == 'weight').toList();
    return _LogScaffold(
      title: 'Weight',
      child: Column(
        children: [
          VitalStatCard(
            label: 'Latest',
            value: logs.isEmpty ? '—' : logs.first.value.toStringAsFixed(1),
            unit: 'kg',
            spark: logs.take(10).map((e) => e.value).toList().reversed.toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final log in logs.take(12))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                opaque: true,
                child: Text(
                  '${log.value.toStringAsFixed(1)} kg   ·   ${DateFormat.MMMd().format(log.at)}',
                  style: AppTypography.body.copyWith(color: AppColors.ink),
                ),
              ),
            ),
        ],
      ),
      composer: PillButton(
        label: 'Log weight',
        onTap: () => _customNumber(context, 'Kilograms', (v) {
          app.addVital(kind: 'weight', value: v);
        }),
      ),
    );
  }
}

class BpScreen extends StatelessWidget {
  const BpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final logs = app.vitals.where((v) => v.kind == 'bp_sys').toList();
    return _LogScaffold(
      title: 'Blood pressure',
      child: Column(
        children: [
          VitalStatCard(
            label: 'Latest',
            value: logs.isEmpty
                ? '—'
                : '${logs.first.value.round()}/${logs.first.extra['dia'] ?? '—'}',
            unit: 'mmHg',
            spark: logs.take(8).map((e) => e.value).toList().reversed.toList(),
            badge: 'High contrast',
          ),
          const SizedBox(height: AppSpacing.md),
          for (final log in logs.take(12))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                opaque: true,
                child: Text(
                  '${log.value.round()}/${log.extra['dia']} mmHg   ·   ${DateFormat.MMMd().format(log.at)}',
                  style: AppTypography.title.copyWith(fontSize: 20, color: AppColors.ink),
                ),
              ),
            ),
        ],
      ),
      composer: PillButton(
        label: 'Log reading',
        onTap: () async {
          await _customPair(context, 'Systolic', 'Diastolic', (s, d) {
            app.addVital(kind: 'bp_sys', value: s, extra: {'dia': d.round()});
          });
        },
      ),
    );
  }
}

class GlucoseScreen extends StatelessWidget {
  const GlucoseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final logs = app.vitals.where((v) => v.kind == 'glucose').toList();
    return _LogScaffold(
      title: 'Glucose',
      child: Column(
        children: [
          VitalStatCard(
            label: 'Latest',
            value: logs.isEmpty ? '—' : logs.first.value.toStringAsFixed(0),
            unit: 'mg/dL',
            spark: logs.take(8).map((e) => e.value).toList().reversed.toList(),
          ),
          for (final log in logs.take(12))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: GlassCard(
                opaque: true,
                child: Text(
                  '${log.value.toStringAsFixed(0)} mg/dL   ·   ${DateFormat.MMMd().format(log.at)}',
                  style: AppTypography.body.copyWith(color: AppColors.ink),
                ),
              ),
            ),
        ],
      ),
      composer: PillButton(
        label: 'Log glucose',
        onTap: () => _customNumber(context, 'mg/dL', (v) {
          app.addVital(kind: 'glucose', value: v);
        }),
      ),
    );
  }
}

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final logs = app.vitals.where((v) => v.kind == 'sleep').toList();
    return _LogScaffold(
      title: 'Sleep',
      child: Column(
        children: [
          VitalStatCard(
            label: 'Last night',
            value: logs.isEmpty ? '—' : logs.first.value.toStringAsFixed(1),
            unit: 'hours',
            spark: logs.take(8).map((e) => e.value).toList().reversed.toList(),
          ),
        ],
      ),
      composer: PillButton(
        label: 'Log hours',
        onTap: () => _customNumber(context, 'Hours', (v) {
          app.addVital(kind: 'sleep', value: v);
        }),
      ),
    );
  }
}

class SymptomsScreen extends StatelessWidget {
  const SymptomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    const names = ['Nausea', 'Headache', 'Cramp', 'Heartburn', 'Swelling', 'Backache'];
    final logs = app.vitals.where((v) => v.kind == 'symptom').toList();
    return _LogScaffold(
      title: 'Symptoms',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final n in names)
                ActionChip(
                  label: Text(n),
                  onPressed: () => app.addVital(
                    kind: 'symptom',
                    value: 2,
                    note: n,
                    extra: {'name': n, 'severity': 2},
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final log in logs)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                opaque: true,
                child: Text(
                  '${log.note}  ·  severity ${log.value.round()}  ·  ${DateFormat.MMMd().format(log.at)}',
                  style: AppTypography.body.copyWith(color: AppColors.ink),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int moodIndex = 2;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final days = List.generate(
      7,
      (i) => DateTime.now().subtract(Duration(days: 6 - i)),
    );
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            PremiumHeader(
              initial: app.firstName.isEmpty ? 'M' : app.firstName[0],
              dateLabel: "${app.firstName}'s Journal",
            ),
            const SizedBox(height: AppSpacing.md),
            DateStrip(
              days: days,
              selected: DateTime.now(),
              onSelect: (_) {},
            ),
            const SizedBox(height: AppSpacing.lg),
            const DisplayHeadline('How are you\nfeeling today?', size: 36, italic: true),
            const SizedBox(height: 6),
            Text(
              'A quiet check-in. Nothing to perform.',
              style: AppTypography.body.copyWith(color: AppColors.mutedGray),
            ),
            ArcMoodPicker(
              index: moodIndex,
              onChanged: (v) => setState(() => moodIndex = v),
            ),
            Center(
              child: StepOrbButton(
                label: '${moodIndex + 1} of ${kMoodArc.length}',
                onTap: () {
                  final m = kMoodArc[moodIndex];
                  app.addVital(kind: 'mood', value: m.score, note: m.label);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedsScreen extends StatelessWidget {
  const MedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return _LogScaffold(
      title: 'Medicines',
      child: Column(
        children: [
          for (final med in app.medicines)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _TimelineMed(med: med),
            ),
        ],
      ),
      composer: PillButton(
        label: 'Add medicine',
        onTap: () => _addMed(context),
      ),
    );
  }
}

class _TimelineMed extends StatelessWidget {
  const _TimelineMed({required this.med});

  final Medicine med;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.violet,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(width: 2, color: AppColors.orchid.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GlassCard(
              opaque: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name, style: AppTypography.title.copyWith(fontSize: 18, color: AppColors.ink)),
                  Text(med.dosage, style: AppTypography.body.copyWith(color: AppColors.ink)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final t in med.times)
                        GestureDetector(
                          onTap: () => app.toggleDose(med, t),
                          child: PhotoLabelChip(
                            '${t}  ${(med.adherence['${dayKey(DateTime.now())}-$t'] ?? false) ? '✓' : ''}',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VaccinesScreen extends StatelessWidget {
  const VaccinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return _LogScaffold(
      title: 'Vaccines',
      child: Column(
        children: [
          for (final v in app.vaccines)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                opaque: true,
                onTap: () => app.saveVaccine(
                  VaccineItem(
                    id: v.id,
                    userId: v.userId,
                    name: v.name,
                    dueWeek: v.dueWeek,
                    done: !v.done,
                    at: DateTime.now(),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${v.name}\nWeek ${v.dueWeek}',
                        style: AppTypography.body.copyWith(color: AppColors.ink),
                      ),
                    ),
                    Icon(
                      v.done ? Icons.check_circle : Icons.circle_outlined,
                      color: v.done ? AppColors.semanticSafe : AppColors.mutedGray,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VisitsScreen extends StatelessWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return _LogScaffold(
      title: 'Visits',
      child: Column(
        children: [
          for (final a in app.appointments)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                opaque: true,
                child: Text(
                  '${a.title}\n${DateFormat.yMMMd().add_jm().format(a.at)}\n${a.place}',
                  style: AppTypography.body.copyWith(color: AppColors.ink),
                ),
              ),
            ),
        ],
      ),
      composer: PillButton(
        label: 'Add visit',
        onTap: () => _addVisit(context),
      ),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return _LogScaffold(
      title: 'Calendar',
      child: Column(
        children: [
          GlassCard(
            child: Text('Week ${app.currentWeek}  ·  visits, vaccines, and due date on one rail.'),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final a in app.appointments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: Text('${DateFormat.MMMd().format(a.at)}  ·  ${a.title}'),
              ),
            ),
          for (final v in app.vaccines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: Text('Week ${v.dueWeek}  ·  ${v.name}'),
              ),
            ),
        ],
      ),
    );
  }
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return _LogScaffold(
      title: 'Reminders',
      child: Column(
        children: [
          for (final r in app.reminders)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: Text('${r.title}\n${DateFormat.yMMMd().add_jm().format(r.at)}  ·  ${r.kind}'),
              ),
            ),
        ],
      ),
      composer: PillButton(
        label: 'Add reminder',
        onTap: () async {
          await app.saveReminder(
            AppReminder(
              id: newId(),
              userId: app.user!.id,
              title: 'Drink water',
              at: DateTime.now().add(const Duration(hours: 2)),
              kind: 'water',
            ),
          );
        },
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return _LogScaffold(
      title: 'Reports',
      child: Column(
        children: [
          for (final kind in ['water', 'weight', 'bp_sys', 'glucose', 'sleep', 'mood', 'symptom'])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                opaque: true,
                child: Text(
                  '$kind  ·  ${app.vitals.where((v) => v.kind == kind).length} entries',
                  style: AppTypography.body.copyWith(color: AppColors.ink),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final water = app.todayWaterMl;
    return _LogScaffold(
      title: 'Insights',
      child: Column(
        children: [
          VitalStatCard(
            label: 'Hydration trend',
            value: '${water.round()}',
            unit: 'ml today',
            spark: const [800, 1200, 1500, 1800],
            badge: water < 1500 ? 'Low' : 'Steady',
            badgeColor: water < 1500 ? AppColors.semanticWarn : AppColors.semanticSafe,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            opaque: true,
            child: Text(
              'Logged ${app.vitals.length} points, ${app.medicines.length} medicines, ${app.appointments.length} visits. Numbers stay ink-on-card.',
              style: AppTypography.body.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _customNumber(
  BuildContext context,
  String label,
  ValueChanged<double> onSave,
) async {
  final c = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTypography.title),
            TextField(
              controller: c,
              keyboardType: TextInputType.number,
              style: AppTypography.body.copyWith(color: AppColors.ink),
            ),
            PillButton(
              label: 'Save',
              onTap: () {
                final v = double.tryParse(c.text);
                if (v != null) onSave(v);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _customPair(
  BuildContext context,
  String a,
  String b,
  void Function(double, double) onSave,
) async {
  final ca = TextEditingController();
  final cb = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ca, decoration: InputDecoration(hintText: a), keyboardType: TextInputType.number),
            TextField(controller: cb, decoration: InputDecoration(hintText: b), keyboardType: TextInputType.number),
            PillButton(
              label: 'Save',
              onTap: () {
                final s = double.tryParse(ca.text);
                final d = double.tryParse(cb.text);
                if (s != null && d != null) onSave(s, d);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _addMed(BuildContext context) async {
  final name = TextEditingController();
  final dose = TextEditingController(text: '1 tablet');
  final app = context.read<AppState>();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(hintText: 'Medicine name')),
            TextField(controller: dose, decoration: const InputDecoration(hintText: 'Dosage')),
            PillButton(
              label: 'Save',
              onTap: () {
                app.saveMed(
                  Medicine(
                    id: newId(),
                    userId: app.user!.id,
                    name: name.text.isEmpty
                        ? 'Ferrous sulphate with folic acid (longest label check)'
                        : name.text,
                    dosage: dose.text,
                    times: const ['08:00', '20:00'],
                  ),
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _addVisit(BuildContext context) async {
  final app = context.read<AppState>();
  await app.saveAppt(
    Appointment(
      id: newId(),
      userId: app.user!.id,
      title: 'Antenatal visit',
      at: DateTime.now().add(const Duration(days: 7)),
      place: app.profile?.hospital ?? 'Clinic',
    ),
  );
}
