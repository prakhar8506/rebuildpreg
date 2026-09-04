import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/models.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../theme/design_tokens.dart';

class PeopleHubScreen extends StatelessWidget {
  const PeopleHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Partner & family', '/people/invite'),
      ('Emergency SOS', '/people/sos'),
      ('Blood donors', '/people/donors'),
    ];
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            const DisplayHeadline('People\n& safety.', size: 40),
            const SizedBox(height: AppSpacing.lg),
            for (final i in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassCard(
                  onTap: () => context.push(i.$2),
                  child: Text(i.$1, style: AppTypography.title.copyWith(fontSize: 20)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final code = TextEditingController();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const DisplayHeadline('A shared\nglance.', size: 36),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              opaque: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TODAY FOR ${app.firstName.toUpperCase()}', style: AppTypography.caption),
                  Text(
                    'Week ${app.currentWeek}  ·  ${app.todayWaterMl.round()} ml water  ·  ${app.medsDueToday.length} medicines',
                    style: AppTypography.body.copyWith(color: AppColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PillButton(
              label: 'Create partner invite',
              onTap: () async {
                final invite = await app.createInvite('partner');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Code ${invite.code}')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            PillButton(
              primary: false,
              label: 'Create family invite',
              onTap: () => app.createInvite('family'),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final i in app.invites)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  onTap: () => Clipboard.setData(ClipboardData(text: i.code)),
                  child: Text('${i.role}  ·  ${i.code}  ·  ${i.acceptedBy == null ? 'waiting' : 'joined'}'),
                ),
              ),
            GlassCard(
              child: Column(
                children: [
                  TextField(controller: code, decoration: const InputDecoration(hintText: 'Have a code?')),
                  PillButton(
                    label: 'Join',
                    onTap: () => app.acceptInvite(code.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final name = TextEditingController();
    final phone = TextEditingController();
    return Scaffold(
      backgroundColor: AppColors.semanticAlert,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'SOS',
              style: AppTypography.display.copyWith(color: Colors.white, fontSize: 52),
            ),
            Text(
              'No glass. No blur. One loud action.',
              style: AppTypography.body.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.xl),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: InkWell(
                onTap: () => launchUrl(Uri.parse('tel:108')),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Text(
                    'Call ambulance 108',
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(color: AppColors.semanticAlert),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final c in app.contacts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                  child: ListTile(
                    title: Text(c.name, style: AppTypography.body.copyWith(color: AppColors.ink)),
                    subtitle: Text(c.phone, style: AppTypography.caption.copyWith(color: AppColors.ink)),
                    onTap: () => launchUrl(Uri.parse('tel:${c.phone}')),
                  ),
                ),
              ),
            TextField(
              controller: name,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Contact name',
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: phone,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Phone',
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => app.addContact(name.text, phone.text),
              child: const Text('Add contact', style: TextStyle(color: Colors.white)),
            ),
            SwitchListTile(
              title: const Text('Show SOS banner on Home', style: TextStyle(color: Colors.white)),
              value: app.settings.sosActive,
              onChanged: (v) => app.toggleSos(v),
            ),
          ],
        ),
      ),
    );
  }
}

class DonorsScreen extends StatelessWidget {
  const DonorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const DisplayHeadline('Nearby\nblood.', size: 36),
            const SizedBox(height: AppSpacing.md),
            for (final d in app.donors)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  opaque: true,
                  onTap: () => launchUrl(Uri.parse('tel:${d.phone}')),
                  child: Text(
                    '${d.name}  ·  ${d.bloodGroup}\n${d.city}  ·  ${d.phone}',
                    style: AppTypography.body.copyWith(color: AppColors.ink),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DoctorPortalScreen extends StatelessWidget {
  const DoctorPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final mothers = app.allUsers.where((u) => u.role == UserRole.mother || u.role == UserRole.guest);
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            const DisplayHeadline('Patients', size: 40),
            const SizedBox(height: AppSpacing.md),
            for (final m in mothers)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  opaque: true,
                  onTap: () => context.push('/doctor/${m.id}'),
                  child: Text(
                    '${m.displayName}\n${m.email}',
                    style: AppTypography.body.copyWith(color: AppColors.ink),
                  ),
                ),
              ),
            if (mothers.isEmpty)
              const GlassCard(child: Text('No mother records on this device yet.')),
          ],
        ),
      ),
    );
  }
}

class DoctorPatientScreen extends StatelessWidget {
  const DoctorPatientScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.repo.userById(id);
    final profile = app.repo.profileFor(id);
    final vitals = app.repo.vitalsFor(id);
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            DisplayHeadline(user?.displayName ?? 'Patient', size: 36),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              opaque: true,
              child: Text(
                'Week ${profile?.currentWeek ?? '—'}  ·  ${profile?.bloodGroup}\n${profile?.hospital}  ·  ${profile?.doctorName}',
                style: AppTypography.body.copyWith(color: AppColors.ink),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final v in vitals.take(12))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GlassCard(
                  opaque: true,
                  child: Text(
                    '${v.kind}  ${v.value}  ${v.at.toLocal()}',
                    style: AppTypography.body.copyWith(color: AppColors.ink),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 140),
          children: [
            const DisplayHeadline('Admin', size: 40),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              opaque: true,
              child: Text(
                '${app.allUsers.length} accounts  ·  ${app.posts.length} posts  ·  ${app.donors.length} donors',
                style: AppTypography.body.copyWith(color: AppColors.ink),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final u in app.allUsers)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GlassCard(
                  opaque: true,
                  child: Text(
                    '${u.displayName}  ·  ${u.role.name}  ·  ${u.email}',
                    style: AppTypography.body.copyWith(color: AppColors.ink),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
