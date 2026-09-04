import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../theme/design_tokens.dart';

class MiraChatScreen extends StatefulWidget {
  const MiraChatScreen({super.key});

  @override
  State<MiraChatScreen> createState() => _MiraChatScreenState();
}

class _MiraChatScreenState extends State<MiraChatScreen> {
  final text = TextEditingController();
  final chips = [
    'How am I feeling today',
    'Is this symptom normal',
    'What should I eat this week',
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Expanded(child: DisplayHeadline('Ask Mira', size: 32)),
                  IconButton(
                    onPressed: () => context.push('/mira/symptoms'),
                    icon: const Icon(Icons.health_and_safety_outlined),
                  ),
                  IconButton(
                    onPressed: () => context.push('/mira/plans'),
                    icon: const Icon(Icons.auto_awesome),
                  ),
                  IconButton(
                    onPressed: () => context.push('/mira/lab'),
                    icon: const Icon(Icons.biotech_outlined),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  for (final c in chips)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => app.sendMira(c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(c, style: AppTypography.caption.copyWith(color: AppColors.ink)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  for (final m in app.chat)
                    Align(
                      alignment: m.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            opaque: m.role == 'model',
                            child: Text(
                              m.text,
                              style: AppTypography.body.copyWith(color: AppColors.ink),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (app.aiBusy) const Text('Mira is thinking…'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: BottomComposerBar(
                controller: text,
                hint: S.t('composerHint', app.lang),
                onSend: () {
                  if (text.text.trim().isEmpty) return;
                  app.sendMira(text.text.trim());
                  text.clear();
                },
                onAttach: () => context.push('/mira/scan'),
                onMic: () => app.sendMira('Voice note: I feel a little off today.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiraPlansScreen extends StatefulWidget {
  const MiraPlansScreen({super.key});

  @override
  State<MiraPlansScreen> createState() => _MiraPlansScreenState();
}

class _MiraPlansScreenState extends State<MiraPlansScreen> {
  final page = PageController();
  String meal = '';
  String yoga = '';
  String summary = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final cards = [
      ('Meal plan', meal.isEmpty ? 'Tap generate for a week of plates.' : meal),
      ('Yoga / wellness', yoga.isEmpty ? 'A gentle plan for this week.' : yoga),
      ('Weekly letter', summary.isEmpty ? 'Mira will read your logs and write back.' : summary),
    ];
    return GradientMeshBackground(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DisplayHeadline('Saved\ninsights.', size: 36),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: page,
                itemCount: 3,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: GlassCard(
                    variant: GlassVariant.stacked,
                    rotation: i == 1 ? 0.03 : -0.03,
                    child: ListView(
                      children: [
                        Text(cards[i].$1, style: AppTypography.title),
                        const SizedBox(height: 12),
                        Text(cards[i].$2, style: AppTypography.body),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: PillButton(
                label: app.aiBusy ? 'Writing…' : 'Generate this card',
                onTap: () async {
                  final i = page.page?.round() ?? 0;
                  final kind = ['meal', 'yoga', 'summary'][i];
                  final out = await app.generatePlan(kind);
                  setState(() {
                    if (i == 0) meal = out;
                    if (i == 1) yoga = out;
                    if (i == 2) summary = out;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SymptomCheckerScreen extends StatelessWidget {
  const SymptomCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DisplayHeadline('Is this\nordinary?', size: 40),
              const SizedBox(height: AppSpacing.md),
              Text('One question at a time. Mira is not a doctor.', style: AppTypography.body),
              const SizedBox(height: AppSpacing.lg),
              for (final s in ['Nausea that comes and goes', 'A new headache with spots', 'Baby is quieter today'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    onTap: () {
                      app.sendMira('Is this symptom normal: $s');
                      context.push('/mira');
                    },
                    child: Text(s),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.kind});

  final String kind;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? path;
  String? result;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  DisplayHeadline(widget.kind == 'lab' ? 'Lab light' : 'A paper, held still.', size: 32),
                  const Spacer(),
                  PillButton(
                    primary: false,
                    label: 'Open camera',
                    onTap: () async {
                      final file = await ImagePicker().pickImage(source: ImageSource.camera);
                      path = file?.path;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  PillButton(
                    label: 'Read this',
                    onTap: () async {
                      final out = await app.generatePlan(
                        widget.kind == 'lab'
                            ? 'Interpret a typical antenatal lab panel in plain language. Flag anything that would need a clinician.'
                            : 'Parse a typical prenatal vitamin prescription into name, dose, timing.',
                      );
                      await app.saveScan(kind: widget.kind, summary: out, imagePath: path);
                      setState(() => result = out);
                    },
                  ),
                ],
              ),
            ),
            if (result != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: GlassCard(
                    child: SizedBox(
                      height: 220,
                      child: ListView(children: [Text(result!, style: AppTypography.body)]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
