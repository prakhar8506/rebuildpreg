import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../data/models/models.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../theme/design_tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final key = TextEditingController(text: app.settings.geminiKey);
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            DisplayHeadline(S.t('settings', app.lang), size: 40),
            const SizedBox(height: AppSpacing.lg),
            Text(S.t('theme', app.lang).toUpperCase(), style: AppTypography.caption),
            PillTabBar(
              tabs: const ['Light', 'Dark'],
              index: app.settings.theme == ThemeModePref.dark ? 1 : 0,
              onChanged: (i) => app.updateSettings(
                app.settings.copyWith(theme: i == 1 ? ThemeModePref.dark : ThemeModePref.light),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(S.t('language', app.lang).toUpperCase(), style: AppTypography.caption),
            PillTabBar(
              tabs: const ['English', 'हिन्दी'],
              index: app.lang == 'hi' ? 1 : 0,
              onChanged: (i) => app.updateSettings(
                app.settings.copyWith(language: i == 1 ? 'hi' : 'en'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(S.t('textSize', app.lang).toUpperCase(), style: AppTypography.caption),
            PillTabBar(
              tabs: const ['S', 'M', 'L'],
              index: app.settings.textSize.index,
              onChanged: (i) => app.updateSettings(
                app.settings.copyWith(textSize: TextSizePref.values[i]),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              onTap: () => context.push('/setup?edit=1'),
              child: Text('Edit profile & pregnancy', style: AppTypography.body),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.t('geminiKey', app.lang), style: AppTypography.caption),
                  TextField(
                    controller: key,
                    obscureText: true,
                    onSubmitted: (v) => app.updateSettings(app.settings.copyWith(geminiKey: v)),
                    decoration: const InputDecoration(hintText: 'AIza…'),
                  ),
                  TextButton(
                    onPressed: () => app.updateSettings(app.settings.copyWith(geminiKey: key.text)),
                    child: const Text('Save key'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: () => context.push('/paywall'),
              child: Text(S.t('premium', app.lang)),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: () => context.push('/gallery'),
              child: const Text('Component gallery'),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: () => context.push('/legal/privacy'),
              child: const Text('Privacy'),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: () => context.push('/legal/disclaimer'),
              child: const Text('Medical note'),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: () => context.push('/legal/export'),
              child: const Text('Export care summary'),
            ),
            const SizedBox(height: AppSpacing.lg),
            PillButton(
              primary: false,
              label: S.t('signOut', app.lang),
              onTap: () async {
                await app.signOut();
                if (context.mounted) context.go('/auth');
              },
            ),
            TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(S.t('deleteAccount', app.lang)),
                    content: const Text('This removes local data for this account.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (ok == true) {
                  await app.deleteAccount();
                  if (context.mounted) context.go('/auth');
                }
              },
              child: Text(
                S.t('deleteAccount', app.lang),
                style: AppTypography.body.copyWith(color: AppColors.semanticAlert),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const DisplayHeadline('Pieces.', size: 40),
            const SizedBox(height: AppSpacing.md),
            const GlassCard(child: Text('standalone glass')),
            const SizedBox(height: AppSpacing.md),
            const GlassCard(
              variant: GlassVariant.stacked,
              rotation: -0.04,
              child: Text('stacked glass'),
            ),
            const SizedBox(height: AppSpacing.md),
            const SizedBox(
              height: 140,
              child: GlassCard(
                variant: GlassVariant.photoOverlay,
                photo: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.rose, AppColors.orchid]),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: PhotoLabelChip('chip'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PillTabBar(tabs: const ['One', 'Two', 'Three'], index: 1, onChanged: (_) {}),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                GradientRingDateChip(label: '12', caption: 'now', selected: true, onTap: () {}),
                const SizedBox(width: 12),
                GradientRingDateChip(label: '13', caption: '', selected: false, onTap: () {}),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const VitalStatCard(
              label: 'Glucose',
              value: '94',
              unit: 'mg/dL',
              spark: [80, 90, 88, 94],
              badge: 'Ink',
            ),
            const SizedBox(height: AppSpacing.md),
            const BottomComposerBar(hint: 'Share with Mira…'),
          ],
        ),
      ),
    );
  }
}
