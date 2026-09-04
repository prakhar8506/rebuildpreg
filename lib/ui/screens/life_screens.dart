import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../data/content/guides.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../components/premium.dart';
import '../theme/design_tokens.dart';

class LifeHubScreen extends StatelessWidget {
  const LifeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Nutrition', '/life/nutrition'),
      ('Food safety', '/life/food'),
      ('Movement', '/life/exercise'),
      ('Activity', '/life/activity'),
      ('Meditate', '/life/meditate'),
      ('Breathe', '/life/breathe'),
      ('Pelvic floor', '/life/floor'),
      ('Cravings', '/life/cravings'),
      ('Belly tape', '/life/belly'),
      ('Shopping', '/life/shop'),
      ('Visit questions', '/life/questions'),
      ('Journal', '/life/journal'),
      ('Memories', '/life/memories'),
      ('Community', '/life/community'),
    ];
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            const DisplayHeadline('Daily life.', size: 42),
            const SizedBox(height: AppSpacing.lg),
            for (final i in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassCard(
                  onTap: () => context.push(i.$2),
                  child: Text(i.$1, style: AppTypography.title.copyWith(fontSize: 22)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key, required this.title, required this.items});

  final String title;
  final List<GuideItem> items;

  @override
  Widget build(BuildContext context) {
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            DisplayHeadline(title, size: 36),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassCard(
                  variant: i.isOdd ? GlassVariant.stacked : GlassVariant.standalone,
                  rotation: i.isOdd ? 0.025 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(items[i].tag.toUpperCase(), style: AppTypography.caption),
                      Text(items[i].title, style: AppTypography.title.copyWith(fontSize: 20)),
                      const SizedBox(height: 8),
                      Text(items[i].body, style: AppTypography.body),
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

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PremiumHeader(
                    initial: app.firstName.isEmpty ? 'M' : app.firstName[0],
                    dateLabel: DateFormat('EEEE, d MMM').format(DateTime.now()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DisplayHeadline("${app.firstName}'s\nJournal", size: 36),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  for (final e in app.journal)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GlassCard(
                        variant: GlassVariant.stacked,
                        rotation: e.voiceNote ? 0.03 : -0.02,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat.yMMMd().format(e.at), style: AppTypography.caption),
                            Text(
                              e.body.isEmpty
                                  ? 'आज की सबसे लंबी जर्नल प्रविष्टि यह जाँच करती है कि शीशे वाला कार्ड हिंदी में भी नहीं कटेगा।'
                                  : e.body,
                              style: AppTypography.body,
                            ),
                            if (e.voiceNote)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: CustomPaint(
                                  size: const Size(double.infinity, 28),
                                  painter: _WavePainter(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: BottomComposerBar(
                controller: text,
                hint: 'A sentence for today…',
                onSend: () {
                  if (text.text.trim().isEmpty) return;
                  app.addJournal(text.text.trim());
                  text.clear();
                },
                onMic: () => app.addJournal('Voice note', voice: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violet
      ..strokeWidth = 2;
    for (var i = 0; i < size.width; i += 6) {
      final h = 6 + (i % 18);
      canvas.drawLine(Offset(i.toDouble(), size.height / 2 - h / 2), Offset(i.toDouble(), size.height / 2 + h / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  int tab = 1;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final kind = ['video', 'photo', 'audio'][tab];
    final items = app.memories.where((m) {
      final okKind = m.kind == kind || (kind == 'photo' && m.kind == 'photo');
      final okQ = query.isEmpty || m.label.toLowerCase().contains(query.toLowerCase());
      return okKind && okQ;
    }).toList();
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: DisplayHeadline('Keep\nthe light.', size: 36),
              ),
              const SizedBox(height: AppSpacing.md),
              PillTabBar(
                tabs: const ['Videos', 'Photos', 'Audio'],
                index: tab,
                onChanged: (v) => setState(() => tab = v),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: InputDecoration(
                  hintText: S.t('search', app.lang),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: items.isEmpty ? 4 : items.length,
                  itemBuilder: (_, i) {
                    final label = items.isEmpty
                        ? ['Week 12', 'First kick', 'Scan day', 'Rain walk'][i]
                        : items[i].label;
                    return GlassCard(
                      variant: GlassVariant.photoOverlay,
                      photo: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.rose,
                              AppColors.orchid,
                              AppColors.peach.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: PhotoLabelChip(label),
                      ),
                    );
                  },
                ),
              ),
              BottomComposerBar(
                hint: 'Add a memory',
                onAttach: () async {
                  final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    await app.addMemory(path: file.path, kind: 'photo', label: 'Today');
                  }
                },
                onSend: () => app.addMemory(path: '', kind: kind, label: 'New'),
                onMic: () => app.addMemory(path: '', kind: 'audio', label: 'Voice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            const DisplayHeadline('Other rooms.', size: 36),
            const SizedBox(height: AppSpacing.md),
            for (final p in app.posts)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassCard(
                  variant: GlassVariant.photoOverlay,
                  height: 180,
                  onTap: () => context.push('/life/community/${p.id}'),
                  photo: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.orchid, AppColors.peach, AppColors.rose],
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      PhotoLabelChip(p.author),
                      const SizedBox(height: 8),
                      Text(
                        p.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            PillButton(
              label: 'Write a post',
              onTap: () => app.addPost('Holding both hope and a snack. Week ${app.currentWeek}.'),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityDetailScreen extends StatelessWidget {
  const CommunityDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final matches = app.posts.where((p) => p.id == id);
    final post = matches.isEmpty ? null : matches.first;
    if (post == null) {
      return const GradientMeshBackground(child: Center(child: Text('Gone')));
    }
    final c = TextEditingController();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            GlassCard(
              variant: GlassVariant.photoOverlay,
              height: 220,
              photo: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.rose, AppColors.orchid]),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  PhotoLabelChip(post.author),
                  Text(post.body, style: AppTypography.body.copyWith(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final comment in post.comments)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Text('${comment['author']}: ${comment['body']}'),
                ),
              ),
            BottomComposerBar(
              controller: c,
              hint: 'A kind reply',
              onSend: () {
                if (c.text.trim().isEmpty) return;
                app.addComment(post, c.text.trim());
                c.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WellbeingScreen extends StatefulWidget {
  const WellbeingScreen({super.key});

  @override
  State<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends State<WellbeingScreen> {
  int moodIndex = 2;
  late DateTime selected;

  @override
  void initState() {
    super.initState();
    selected = DateTime.now();
  }

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
              selected: selected,
              onSelect: (d) => setState(() => selected = d),
            ),
            const SizedBox(height: AppSpacing.lg),
            const DisplayHeadline(
              'How are you\nfeeling today?',
              size: 36,
              italic: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Pick the closest true thing. You can change it later.',
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
                  app.addJournal('Feeling ${m.label.toLowerCase()} today.');
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
