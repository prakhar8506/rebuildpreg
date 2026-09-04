import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../core/week_math.dart';
import '../../data/models/models.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../theme/design_tokens.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const DisplayHeadline('Memories\ndon’t begin\nin focus.', size: 52),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Mira — a quieter kind of pregnancy care.',
                style: AppTypography.body.copyWith(color: AppColors.mutedGray),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final page = PageController();
  int index = 0;

  static const slides = [
    ('The week, written large', 'Not a dashboard. A greeting that already knows your name and your week.'),
    ('Care you can actually read', 'Water, medicines, pressure — solid numbers on quiet glass. Never gradient text.'),
    ('Mira is a person, not a menu', 'Ask from the composer. Emergency stays loud on purpose.'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    await app.finishOnboarding();
                    if (context.mounted) context.go('/auth');
                  },
                  child: Text(S.t('skip', app.lang)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: page,
                  onPageChanged: (v) => setState(() => index = v),
                  itemCount: slides.length,
                  itemBuilder: (_, i) {
                    final s = slides[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        DisplayHeadline(s.$1, size: i == 0 ? 48 : 40),
                        const SizedBox(height: AppSpacing.lg),
                        GlassCard(
                          variant: GlassVariant.stacked,
                          rotation: i.isEven ? -0.04 : 0.03,
                          child: Text(s.$2, style: AppTypography.body),
                        ),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              PillButton(
                label: index == slides.length - 1 ? S.t('continue', app.lang) : 'Next',
                onTap: () async {
                  if (index == slides.length - 1) {
                    await app.finishOnboarding();
                    if (context.mounted) context.go('/auth');
                  } else {
                    page.nextPage(
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.xl),
            DisplayHeadline(S.t('signIn', app.lang), size: 44),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              child: Column(
                children: [
                  _Field(controller: email, hint: S.t('email', app.lang)),
                  const SizedBox(height: AppSpacing.sm),
                  _Field(
                    controller: password,
                    hint: S.t('password', app.lang),
                    obscure: true,
                  ),
                  if (app.lastError != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      app.lastError!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.semanticAlert,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  PillButton(
                    label: busy ? '…' : S.t('continue', app.lang),
                    onTap: () async {
                      setState(() => busy = true);
                      final ok = await app.signInEmail(email.text, password.text);
                      setState(() => busy = false);
                      if (ok && context.mounted) {
                        context.go(app.needsProfile ? '/setup' : '/');
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () => context.push('/forgot'),
                    child: Text(S.t('forgot', app.lang)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PillButton(
              primary: false,
              label: S.t('google', app.lang),
              onTap: () async {
                final ok = await app.signInGoogle();
                if (ok && context.mounted) {
                  context.go(app.needsProfile ? '/setup' : '/');
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            PillButton(
              primary: false,
              label: S.t('apple', app.lang),
              onTap: () async {
                final ok = await app.signInApple();
                if (ok && context.mounted) {
                  context.go(app.needsProfile ? '/setup' : '/');
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            PillButton(
              primary: false,
              label: S.t('otp', app.lang),
              onTap: () => context.push('/otp'),
            ),
            const SizedBox(height: AppSpacing.sm),
            PillButton(
              primary: false,
              label: S.t('guest', app.lang),
              onTap: () async {
                await app.continueGuest();
                if (context.mounted) context.go('/setup');
              },
            ),
            TextButton(
              onPressed: () => context.push('/register'),
              child: Text(S.t('register', app.lang)),
            ),
            TextButton(
              onPressed: () => context.push('/recover'),
              child: Text(S.t('recover', app.lang)),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  UserRole role = UserRole.mother;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GradientMeshBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const DisplayHeadline('Who is this for?', size: 40),
            const SizedBox(height: AppSpacing.lg),
            PillTabBar(
              tabs: [
                S.t('roleMother', app.lang),
                S.t('rolePartner', app.lang),
                S.t('roleFamily', app.lang),
              ],
              index: role == UserRole.mother
                  ? 0
                  : role == UserRole.partner
                      ? 1
                      : 2,
              onChanged: (i) {
                setState(() {
                  role = [UserRole.mother, UserRole.partner, UserRole.family][i];
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Column(
                children: [
                  _Field(controller: name, hint: 'Your name'),
                  const SizedBox(height: AppSpacing.sm),
                  _Field(controller: email, hint: S.t('email', app.lang)),
                  const SizedBox(height: AppSpacing.sm),
                  _Field(
                    controller: password,
                    hint: S.t('password', app.lang),
                    obscure: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PillButton(
                    label: S.t('continue', app.lang),
                    onTap: () async {
                      final ok = await app.register(
                        name: name.text,
                        email: email.text,
                        password: password.text,
                        role: role,
                      );
                      if (ok && context.mounted) {
                        context.go(app.needsProfile ? '/setup' : '/');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              onTap: () => context.push('/auth/pro'),
              child: Text(
                'Doctor or admin portal →',
                style: AppTypography.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProAuthScreen extends StatefulWidget {
  const ProAuthScreen({super.key});

  @override
  State<ProAuthScreen> createState() => _ProAuthScreenState();
}

class _ProAuthScreenState extends State<ProAuthScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool doctor = true;

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
              const DisplayHeadline('Clinic access', size: 40),
              const SizedBox(height: AppSpacing.md),
              PillTabBar(
                tabs: const ['Doctor', 'Admin'],
                index: doctor ? 0 : 1,
                onChanged: (i) => setState(() => doctor = i == 0),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                child: Column(
                  children: [
                    _Field(controller: name, hint: 'Name'),
                    _Field(controller: email, hint: 'Work email'),
                    _Field(controller: password, hint: 'Password', obscure: true),
                    const SizedBox(height: AppSpacing.md),
                    PillButton(
                      label: 'Enter',
                      onTap: () async {
                        await app.register(
                          name: name.text.isEmpty ? 'Clinic' : name.text,
                          email: email.text,
                          password: password.text,
                          role: doctor ? UserRole.doctor : UserRole.admin,
                        );
                        if (context.mounted) {
                          context.go(doctor ? '/doctor' : '/admin');
                        }
                      },
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

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final email = TextEditingController();
  String? note;

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
              const DisplayHeadline('Reset,\nquietly.', size: 44),
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                child: Column(
                  children: [
                    _Field(controller: email, hint: S.t('email', app.lang)),
                    const SizedBox(height: AppSpacing.md),
                    PillButton(
                      label: 'Send reset',
                      onTap: () async {
                        final ok = await app.sendPasswordReset(email.text);
                        setState(() {
                          note = ok
                              ? 'A local reset notice was queued for that inbox.'
                              : app.lastError;
                        });
                      },
                    ),
                    if (note != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(note!, style: AppTypography.caption),
                    ],
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

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final phone = TextEditingController();
  final code = TextEditingController();
  bool sent = false;

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
              const DisplayHeadline('Your number.', size: 44),
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                child: Column(
                  children: [
                    _Field(controller: phone, hint: 'Phone', keyboard: TextInputType.phone),
                    if (sent) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _Field(controller: code, hint: 'Code (123456)', keyboard: TextInputType.number),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    PillButton(
                      label: sent ? 'Verify' : 'Send code',
                      onTap: () async {
                        if (!sent) {
                          await app.sendOtp(phone.text);
                          setState(() => sent = true);
                          return;
                        }
                        final ok = await app.verifyOtp(code.text);
                        if (ok && context.mounted) {
                          context.go(app.needsProfile ? '/setup' : '/');
                        }
                      },
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

class RecoverScreen extends StatefulWidget {
  const RecoverScreen({super.key});

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final email = TextEditingController();

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
              const DisplayHeadline('Find the thread.', size: 42),
              const SizedBox(height: AppSpacing.md),
              Text(
                'If local pregnancy data is gone, we re-read the Firestore-shaped mirror, then let you type dates again.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                child: Column(
                  children: [
                    _Field(controller: email, hint: S.t('email', app.lang)),
                    const SizedBox(height: AppSpacing.md),
                    PillButton(
                      label: S.t('recover', app.lang),
                      onTap: () async {
                        final ok = await app.recoverAccount(email.text);
                        if (ok && context.mounted) {
                          context.go(app.needsProfile ? '/setup' : '/');
                        }
                      },
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

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.editing = false});

  final bool editing;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int step = 0;
  DateTime? lmp;
  DateTime? due;
  int week = 20;
  final doctor = TextEditingController();
  final hospital = TextEditingController();
  String blood = 'O+';

  static const groups = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    final p = context.read<AppState>().profile;
    if (p != null) {
      lmp = p.lmp;
      due = p.dueDate;
      week = p.currentWeek ?? 20;
      doctor.text = p.doctorName;
      hospital.text = p.hospital;
      blood = p.bloodGroup.isEmpty ? 'O+' : p.bloodGroup;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final titles = [
      'When did this begin?',
      'Which week feels true?',
      'Who is walking with you?',
      'A hospital, a blood group.',
    ];
    return GradientMeshBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step ${step + 1} of 4', style: AppTypography.caption),
              const SizedBox(height: AppSpacing.sm),
              DisplayHeadline(titles[step], size: 36),
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: _stepBody(app)),
              PillButton(
                label: step == 3 ? S.t('save', app.lang) : S.t('continue', app.lang),
                onTap: () async {
                  if (step < 3) {
                    setState(() => step++);
                    return;
                  }
                  final uid = app.user!.id;
                  await app.saveProfile(
                    PregnancyProfile(
                      userId: uid,
                      lmp: lmp,
                      dueDate: due ?? (lmp != null ? dueFromLmp(lmp!) : null),
                      currentWeek: week,
                      doctorName: doctor.text,
                      hospital: hospital.text,
                      bloodGroup: blood,
                    ),
                  );
                  if (context.mounted) {
                    context.go(widget.editing ? '/settings' : '/paywall');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBody(AppState app) {
    switch (step) {
      case 0:
        return GlassCard(
          child: Column(
            children: [
              PillButton(
                primary: false,
                label: lmp == null
                    ? 'Last menstrual period'
                    : 'LMP  ${lmp!.day}/${lmp!.month}/${lmp!.year}',
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 300)),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.now().subtract(const Duration(days: 140)),
                  );
                  if (d != null) {
                    setState(() {
                      lmp = d;
                      due = dueFromLmp(d);
                      week = weekFromLmp(d);
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              PillButton(
                primary: false,
                label: due == null
                    ? 'Or pick a due date'
                    : 'Due  ${due!.day}/${due!.month}/${due!.year}',
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 300)),
                    initialDate: DateTime.now().add(const Duration(days: 140)),
                  );
                  if (d != null) {
                    setState(() {
                      due = d;
                      lmp = lmpFromDue(d);
                      week = weekFromDue(d);
                    });
                  }
                },
              ),
            ],
          ),
        );
      case 1:
        return Column(
          children: [
            DisplayHeadline('$week', size: 56),
            Text('of 40', style: AppTypography.caption),
            Slider(
              value: week.toDouble(),
              min: 1,
              max: 40,
              divisions: 39,
              activeColor: AppColors.violet,
              onChanged: (v) => setState(() => week = v.round()),
            ),
          ],
        );
      case 2:
        return GlassCard(
          child: Column(
            children: [
              _Field(controller: doctor, hint: 'Doctor’s name'),
              const SizedBox(height: AppSpacing.sm),
              _Field(controller: hospital, hint: 'Hospital'),
            ],
          ),
        );
      default:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in groups)
              GestureDetector(
                onTap: () => setState(() => blood = g),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: blood == g ? AppGradients.accentRing : null,
                    color: blood == g ? null : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    g,
                    style: AppTypography.body.copyWith(
                      color: blood == g ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
              ),
          ],
        );
    }
  }
}

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

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
              DisplayHeadline(S.t('paywallTitle', app.lang), size: 40),
              const SizedBox(height: AppSpacing.lg),
              Stack(
                children: [
                  Transform.rotate(
                    angle: -0.05,
                    child: GlassCard(
                      variant: GlassVariant.stacked,
                      child: Text(
                        'Free\nWeek tracker, water, journal, SOS.',
                        style: AppTypography.body,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 88),
                    child: Transform.rotate(
                      angle: 0.03,
                      child: GlassCard(
                        variant: GlassVariant.stacked,
                        child: Text(
                          'Premium\nAsk Mira, scans, weekly meal & yoga letters. Local entitlement — no card yet.',
                          style: AppTypography.body,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PillButton(
                label: 'Unlock premium on this device',
                onTap: () async {
                  await app.unlockPremium();
                  if (context.mounted) context.go('/');
                },
              ),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Continue free'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboard,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.caption,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }
}
