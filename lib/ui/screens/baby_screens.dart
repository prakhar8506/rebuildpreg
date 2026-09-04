import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/content/guides.dart';
import '../../data/models/models.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../components/glass_studio.dart';
import '../theme/design_tokens.dart';
import 'studio_screens.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final today = DateTime.now();
    final moods = app.vitals.where((v) => v.kind == 'mood');
    final mood = moods.isEmpty ? null : moods.first;
    final moodWord = mood?.note.isNotEmpty == true ? mood!.note : 'Quiet';
    final moodPct = mood == null ? 48 : (mood.value / 5 * 100).round().clamp(0, 100);
    final named = (app.user?.displayName ?? '').trim().isNotEmpty;
    final tiles = <(IconData, String, String, String)>[
      (Icons.self_improvement_rounded, 'Meditate', 'Aura loop sit', '/life/meditate'),
      (Icons.monitor_heart_outlined, 'Activity', 'Move, mind, rest', '/life/activity'),
      (Icons.air_rounded, 'Breathe', 'Orb with baby', '/life/breathe'),
      (Icons.spa_outlined, 'Pelvic floor', 'Lift, then let go', '/life/floor'),
      (Icons.restaurant_outlined, 'Cravings', 'What you want', '/life/cravings'),
      (Icons.straighten_rounded, 'Belly tape', 'Home fundal note', '/life/belly'),
      (Icons.shopping_bag_outlined, 'Shopping', 'What to gather', '/life/shop'),
      (Icons.quiz_outlined, 'Visit notes', 'Questions to ask', '/life/questions'),
      (Icons.no_food_outlined, 'Food safety', 'What to skip', '/life/food'),
      (Icons.monitor_heart_outlined, 'Kicks', 'Count the quiet', '/baby/kicks'),
      (Icons.document_scanner_outlined, 'Scan', 'Rx or a label', '/mira/scan'),
      (Icons.photo_outlined, 'Memories', 'Bump photos', '/life/memories'),
      (Icons.groups_outlined, 'People', 'Partner and SOS', '/people'),
      (Icons.auto_awesome, 'Ask Mira', 'Chat and plans', '/mira'),
    ];
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            StudioHeader(
              initial: named ? app.firstName[0] : 'M',
              score: moodPct,
              scoreLabel: 'Mood',
              onBell: () => context.push('/care/reminders'),
              onGrid: () => context.push('/settings'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              named ? "${app.firstName}'s studio" : 'Your studio',
              style: AppTypography.display.copyWith(fontSize: 34),
            ),
            const SizedBox(height: AppSpacing.md),
            OrbitalMoodCard(
              mood: moodWord,
              percent: moodPct,
              onTap: () => context.push('/life/wellbeing'),
            ),
            if (app.dueDate != null) ...[
              const SizedBox(height: AppSpacing.md),
              LiveCountdown(due: app.dueDate!),
            ],
            const SizedBox(height: AppSpacing.md),
            SwipeActionBar(
              label: 'Swipe to log water',
              leading: Icons.water_drop_outlined,
              onComplete: () => app.addVital(kind: 'water', value: 250),
            ),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.18,
              children: [
                for (final t in tiles)
                  GlassFeatureTile(
                    icon: t.$1,
                    label: t.$2,
                    caption: t.$3,
                    onTap: () => context.push(t.$4),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (final row in [
              ('Baby & labor', '/baby'),
              ('Daily life', '/life'),
              ('Settings', '/settings'),
              ('Privacy', '/legal/privacy'),
              ('Medical note', '/legal/disclaimer'),
              ('Export care', '/legal/export'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  onTap: () => context.push(row.$2),
                  child: Text(row.$1, style: AppTypography.title.copyWith(fontSize: 18)),
                ),
              ),
            Text(
              DateFormat('EEEE, d MMM').format(today),
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class BabyHubScreen extends StatelessWidget {
  const BabyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Kick counter', '/baby/kicks'),
      ('Contraction timer', '/baby/contractions'),
      ('Hospital bag', '/baby/bag'),
      ('Birth plan', '/baby/plan'),
      ('Baby names', '/baby/names'),
      ('Nursery list', '/baby/nursery'),
    ];
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            const DisplayHeadline('Baby &\nlabor.', size: 42),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final item in items)
                  SizedBox(
                    width: 160,
                    child: GlassCard(
                      onTap: () => context.push(item.$2),
                      child: Text(item.$1, style: AppTypography.title.copyWith(fontSize: 18)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class KickScreen extends StatelessWidget {
  const KickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const DisplayHeadline('Count the quiet.', size: 36),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (app.liveKick == null) {
                    app.startKick();
                  } else {
                    app.tapKick();
                  }
                },
                child: Container(
                  width: 220,
                  height: 220,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.accentRing,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tokensOf(context).opaqueCard,
                    ),
                    child: Text(
                      app.liveKick == null ? 'Start' : '${app.liveKick!.kicks}',
                      style: AppTypography.display.copyWith(fontSize: 42, color: AppColors.ink),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (app.liveKick != null)
                PillButton(label: 'End session', onTap: app.endKick),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                child: Column(
                  children: [
                    for (final s in app.kicks.take(6))
                      Text(
                        '${s.kicks} kicks  ·  ${DateFormat.MMMd().add_jm().format(s.startedAt)}',
                        style: AppTypography.body,
                      ),
                    if (app.kicks.isEmpty) Text('No sessions yet', style: AppTypography.caption),
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

class ContractionScreen extends StatelessWidget {
  const ContractionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const DisplayHeadline('A calm clock.', size: 36),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (app.contractionStarted == null) {
                    app.startContraction();
                  } else {
                    app.endContraction();
                  }
                },
                child: Container(
                  width: 220,
                  height: 220,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.accentRing,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tokensOf(context).opaqueCard,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      app.contractionStarted == null ? 'Tap' : 'Stop',
                      style: AppTypography.display.copyWith(fontSize: 36, color: AppColors.ink),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              GlassCard(
                child: Column(
                  children: [
                    for (final c in app.contractions.take(8))
                      Text(
                        '${c.seconds}s  ·  ${DateFormat.Hm().format(c.startedAt)}',
                        style: AppTypography.body,
                      ),
                    if (app.contractions.isEmpty)
                      Text('Each wave lands here.', style: AppTypography.caption),
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

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key, required this.listId, required this.title});

  final String listId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.checksFor(listId);
    final groups = <String, List<CheckItem>>{};
    for (final i in items) {
      groups.putIfAbsent(i.group, () => []).add(i);
    }
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            DisplayHeadline(title, size: 36),
            const SizedBox(height: AppSpacing.md),
            for (final g in groups.entries) ...[
              Text(g.key.toUpperCase(), style: AppTypography.caption),
              const SizedBox(height: 8),
              GlassCard(
                child: Column(
                  children: [
                    for (final item in g.value)
                      GestureDetector(
                        onTap: () => app.toggleCheck(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  gradient: item.done ? AppGradients.accentRing : null,
                                  border: Border.all(color: AppColors.orchid),
                                ),
                                child: item.done
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(item.label, style: AppTypography.body)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            PillButton(
              label: 'Add item',
              onTap: () => promptAddCheck(context, listId),
            ),
          ],
        ),
      ),
    );
  }
}

class BirthPlanScreen extends StatefulWidget {
  const BirthPlanScreen({super.key});

  @override
  State<BirthPlanScreen> createState() => _BirthPlanScreenState();
}

class _BirthPlanScreenState extends State<BirthPlanScreen> {
  late final place = TextEditingController(text: context.read<AppState>().birthPlan.place);
  late final support = TextEditingController(text: context.read<AppState>().birthPlan.support);
  late final pain = TextEditingController(text: context.read<AppState>().birthPlan.pain);
  late final feeding = TextEditingController(text: context.read<AppState>().birthPlan.feeding);
  late final notes = TextEditingController(text: context.read<AppState>().birthPlan.notes);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const DisplayHeadline('A plan,\nnot a script.', size: 36),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Column(
                children: [
                  TextField(controller: place, decoration: const InputDecoration(hintText: 'Place of birth')),
                  TextField(controller: support, decoration: const InputDecoration(hintText: 'Who is with you')),
                  TextField(controller: pain, decoration: const InputDecoration(hintText: 'Pain preferences')),
                  TextField(controller: feeding, decoration: const InputDecoration(hintText: 'Feeding')),
                  TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(hintText: 'Notes')),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PillButton(
              label: 'Save',
              onTap: () => app.savePlan(
                BirthPlan(
                  userId: app.user!.id,
                  place: place.text,
                  support: support.text,
                  pain: pain.text,
                  feeding: feeding.text,
                  notes: notes.text,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text:
                        'Birth plan for ${app.firstName}\nPlace: ${place.text}\nSupport: ${support.text}\nPain: ${pain.text}\nFeeding: ${feeding.text}\n${notes.text}',
                  ),
                );
              },
              child: const Text('Export / share'),
            ),
          ],
        ),
      ),
    );
  }
}

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  int index = 0;
  List<Map<String, String>> deck = List.from(babyNameSeed);
  String? aiBlock;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final card = deck[index % deck.length];
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const DisplayHeadline('A name\nin the air.', size: 36),
              const Spacer(),
              GestureDetector(
                onHorizontalDragEnd: (d) {
                  setState(() {
                    if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
                      index++;
                    } else {
                      index = (index - 1) < 0 ? deck.length - 1 : index - 1;
                    }
                  });
                },
                child: GlassCard(
                  variant: GlassVariant.stacked,
                  rotation: 0.03,
                  child: SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(card['name']!, style: AppTypography.display.copyWith(fontSize: 40)),
                        Text(card['origin']!, style: AppTypography.caption),
                        Text(card['note']!, style: AppTypography.body),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PillButton(
                label: app.savedNames.contains(card['name']) ? 'Saved' : 'Save this name',
                onTap: () => app.saveName(card['name']!),
              ),
              TextButton(
                onPressed: () async {
                  final out = await app.generatePlan('names');
                  setState(() => aiBlock = out);
                },
                child: const Text('Ask Mira for ideas'),
              ),
              if (aiBlock != null)
                GlassCard(child: Text(aiBlock!, style: AppTypography.body)),
            ],
          ),
        ),
      ),
    );
  }
}
