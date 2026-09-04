import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../theme/design_tokens.dart';
import 'bubble_fountain.dart';
import 'charge_ring_painter.dart';
import 'curved_wordmark.dart';
import 'entry_gate_controller.dart';

class EntryGateScreen extends StatefulWidget {
  const EntryGateScreen({super.key});

  @override
  State<EntryGateScreen> createState() => _EntryGateScreenState();
}

class _EntryGateScreenState extends State<EntryGateScreen>
    with TickerProviderStateMixin {
  late final EntryGateController gate;
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  static const _idleSize = 176.0;
  static const _orbSize = 36.0;

  @override
  void initState() {
    super.initState();
    gate = EntryGateController(vsync: this);
  }

  @override
  void dispose() {
    gate.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  bool get _reduceMotion {
    return MediaQuery.disableAnimationsOf(context);
  }

  Future<void> _afterAuth(bool ok) async {
    if (!ok || !mounted) return;
    final app = context.read<AppState>();
    await app.finishOnboarding();
    if (!mounted) return;
    context.go(app.needsProfile ? '/setup' : '/');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return AnimatedBuilder(
      animation: gate,
      builder: (context, _) {
        final iris = gate.irisProgress;
        final buttonSize = _idleSize + (_orbSize - _idleSize) * iris;
        final clipT = Curves.easeInCubic.transform(iris);
        final clipSize = _idleSize * 1.55 * (1 - clipT) + _orbSize * clipT;

        final reveal = gate.revealProgress;
        final align = Alignment.lerp(
          const Alignment(0, 0.18),
          const Alignment(0, -0.88),
          reveal,
        )!;

        return GradientMeshBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final origin = Offset(
                  (align.x + 1) / 2 * constraints.maxWidth,
                  (align.y + 1) / 2 * constraints.maxHeight,
                );
                return Stack(
                  children: [
                    _idleCopy(),
                    if (reveal > 0) _revealed(app),
                    Align(
                      alignment: align,
                      child: _holdCluster(buttonSize, clipSize),
                    ),
                    BubbleFountain(
                      active: gate.inFountain,
                      time: gate.bubbleTime,
                      origin: origin,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _idleCopy() {
    final fade = ((1 - gate.chargeProgress) * (1 - gate.revealProgress))
        .clamp(0.0, 1.0);
    if (fade <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: Opacity(
        opacity: fade,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
          child: Column(
            children: [
              const SizedBox(height: 28),
              const DisplayHeadline('Memories don’t\nbegin in focus.', size: 40),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Mira — a quieter kind of pregnancy care.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.mutedGray),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _holdCluster(double buttonSize, double clipSize) {
    final captionFade = (1 - gate.chargeProgress).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _idleSize + 120,
          height: _idleSize + 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CurvedWordmark(
                text: 'Mira',
                progress: gate.wordmarkProgress,
                iris: gate.irisProgress,
                radius: _idleSize / 2 + 28,
              ),
              ClipOval(
                clipper: _IrisClipper(clipSize),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(buttonSize + 28, buttonSize + 28),
                      painter: ChargeRingPainter(progress: gate.chargeProgress),
                    ),
                    _HoldButton(
                      size: buttonSize,
                      pulsing: gate.unlocked && !gate.holding,
                      onDown: () {},
                      onUp: () {},
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'press & hold to enter',
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) =>
                      gate.holdStart(reduceMotion: _reduceMotion),
                  onPointerUp: (_) => gate.holdEnd(),
                  onPointerCancel: (_) => gate.holdEnd(),
                  child: SizedBox(width: buttonSize + 36, height: buttonSize + 36),
                ),
              ),
            ],
          ),
        ),
        if (captionFade > 0)
          Opacity(
            opacity: captionFade,
            child: Text(
              'press & hold to enter',
              style: AppTypography.caption,
            ),
          ),
      ],
    );
  }

  Widget _revealed(AppState app) {
    Widget item(int i, Widget child) {
      final p = gate.revealItem(i);
      return Opacity(
        opacity: p,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - p)),
          child: child,
        ),
      );
    }

    return IgnorePointer(
      ignoring: !gate.unlocked,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 88, AppSpacing.lg, 32),
        children: [
        item(
          0,
          const DisplayHeadline('Come in quietly.', size: 36),
        ),
        const SizedBox(height: 6),
        item(
          1,
          Text(
            'Care that already knows your week.',
            style: AppTypography.body.copyWith(color: AppColors.mutedGray),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        item(
          2,
          GlassCard(
            child: Column(
              children: [
                _GateField(controller: email, hint: S.t('email', app.lang)),
                const SizedBox(height: AppSpacing.sm),
                _GateField(
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
                    await _afterAuth(ok);
                  },
                ),
                TextButton(
                  onPressed: () => context.push('/forgot'),
                  child: Text(S.t('forgot', app.lang)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        item(
          3,
          PillButton(
            primary: false,
            label: S.t('google', app.lang),
            onTap: () async {
              final ok = await app.signInGoogle();
              await _afterAuth(ok);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        item(
          4,
          PillButton(
            primary: false,
            label: S.t('apple', app.lang),
            onTap: () async {
              final ok = await app.signInApple();
              await _afterAuth(ok);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        item(
          5,
          PillButton(
            primary: false,
            label: S.t('otp', app.lang),
            onTap: () => context.push('/otp'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        item(
          6,
          PillButton(
            primary: false,
            label: S.t('guest', app.lang),
            onTap: () async {
              await app.continueGuest();
              await _afterAuth(true);
            },
          ),
        ),
        item(
          7,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
        ],
      ),
    );
  }
}

class _IrisClipper extends CustomClipper<Rect> {
  _IrisClipper(this.diameter);

  final double diameter;

  @override
  Rect getClip(Size size) {
    final d = diameter.clamp(8.0, size.shortestSide);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: d,
      height: d,
    );
  }

  @override
  bool shouldReclip(covariant _IrisClipper oldClipper) =>
      oldClipper.diameter != diameter;
}

class _HoldButton extends StatefulWidget {
  const _HoldButton({
    required this.size,
    required this.onDown,
    required this.onUp,
    this.pulsing = false,
  });

  final double size;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final bool pulsing;

  @override
  State<_HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<_HoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulsing) pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _HoldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing && !pulse.isAnimating) {
      pulse.repeat(reverse: true);
    } else if (!widget.pulsing) {
      pulse.stop();
      pulse.value = 0.5;
    }
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = LiquidGlass(
      radius: AppRadius.pill,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Container(
            width: math.max(10, widget.size * 0.28),
            height: math.max(10, widget.size * 0.28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.accentRing,
              boxShadow: [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.4),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Listener(
      onPointerDown: (_) => widget.onDown(),
      onPointerUp: (_) => widget.onUp(),
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          final s = widget.pulsing ? 0.96 + 0.08 * pulse.value : 1.0;
          return Transform.scale(scale: s, child: child);
        },
        child: child,
      ),
    );
  }
}

class _GateField extends StatelessWidget {
  const _GateField({
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.caption,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }
}
