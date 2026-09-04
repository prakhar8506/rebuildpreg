import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/design_tokens.dart';
import 'components.dart';

class StudioHeader extends StatelessWidget {
  const StudioHeader({
    super.key,
    required this.initial,
    required this.score,
    required this.scoreLabel,
    this.onBell,
    this.onGrid,
  });

  final String initial;
  final int score;
  final String scoreLabel;
  final VoidCallback? onBell;
  final VoidCallback? onGrid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _circle(Text(initial.toUpperCase(), style: AppTypography.title.copyWith(fontSize: 15))),
        const SizedBox(width: 8),
        Text('$score%', style: AppTypography.title.copyWith(fontSize: 16)),
        const SizedBox(width: 8),
        LiquidGlass(
          radius: AppRadius.pill,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(scoreLabel, style: AppTypography.caption.copyWith(color: AppColors.ink)),
        ),
        const Spacer(),
        _iconBtn(Icons.notifications_none_rounded, onBell),
        const SizedBox(width: 8),
        _iconBtn(Icons.apps_rounded, onGrid),
      ],
    );
  }

  Widget _circle(Widget child) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      ),
      child: child,
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.38),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        ),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }
}

class DonutGauge extends StatelessWidget {
  const DonutGauge({
    super.key,
    required this.progress,
    required this.label,
    this.size = 86,
  });

  final double progress;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(progress.clamp(0.0, 1.0)),
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: AppTypography.title.copyWith(fontSize: size * 0.2),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 7;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          colors: const [AppColors.violet, AppColors.orchid, AppColors.sky],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}

class FruitOrb extends StatefulWidget {
  const FruitOrb({super.key, required this.label, this.size = 88});

  final String label;
  final double size;

  @override
  State<FruitOrb> createState() => _FruitOrbState();
}

class _FruitOrbState extends State<FruitOrb> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final s = 0.94 + 0.08 * c.value;
        return Transform.scale(
          scale: s,
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFB9F3C9), Color(0xFF7EC8E3), Color(0xFFC9A6E8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

class RitualGlassCard extends StatelessWidget {
  const RitualGlassCard({
    super.key,
    required this.dateLabel,
    required this.title,
    required this.fruit,
    required this.done,
    required this.total,
    required this.steps,
    required this.health,
    required this.onRead,
    required this.onStep,
  });

  final String dateLabel;
  final String title;
  final String fruit;
  final int done;
  final int total;
  final List<(IconData, String, bool)> steps;
  final double health;
  final VoidCallback onRead;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      radius: 32,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LiquidGlass(
                radius: AppRadius.pill,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 14),
                    const SizedBox(width: 4),
                    Text(dateLabel, style: AppTypography.caption.copyWith(color: AppColors.ink)),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRead,
                child: LiquidGlass(
                  radius: AppRadius.pill,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('Read plan ›', style: AppTypography.caption.copyWith(color: AppColors.ink)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: AppTypography.title.copyWith(fontSize: 22)),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              FruitOrb(label: fruit),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LiquidGlass(
                  radius: 22,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$done/$total Steps', style: AppTypography.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < steps.length; i++)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onStep(i);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: steps[i].$3
                                      ? AppColors.cornflower
                                      : Colors.white.withValues(alpha: 0.45),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                                ),
                                child: Icon(
                                  steps[i].$1,
                                  size: 16,
                                  color: steps[i].$3 ? Colors.white : AppColors.ink,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LiquidGlass(
                  radius: 22,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('Care pulse', style: AppTypography.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 8),
                      DonutGauge(progress: health, label: 'pulse'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrbitalMoodCard extends StatefulWidget {
  const OrbitalMoodCard({
    super.key,
    required this.mood,
    required this.percent,
    this.caption = 'Today I feel',
    this.onTap,
  });

  final String mood;
  final int percent;
  final String caption;
  final VoidCallback? onTap;

  @override
  State<OrbitalMoodCard> createState() => _OrbitalMoodCardState();
}

class _OrbitalMoodCardState extends State<OrbitalMoodCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: LiquidGlass(
        radius: 36,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
        child: SizedBox(
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: spin,
                builder: (context, _) => Transform.rotate(
                  angle: spin.value * math.pi * 2,
                  child: CustomPaint(
                    size: const Size(210, 210),
                    painter: _OrbitalPainter(),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('MOOD', style: AppTypography.caption.copyWith(letterSpacing: 2)),
                  Text(widget.caption, style: AppTypography.body),
                  const SizedBox(height: 6),
                  Text(
                    widget.mood,
                    style: AppTypography.display.copyWith(
                      fontSize: 34,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text('${widget.percent}%', style: AppTypography.body),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbitalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.55);
    for (final r in [48.0, 68.0, 88.0, 104.0]) {
      canvas.drawCircle(c, r, p);
    }
    canvas.drawCircle(c + const Offset(38, 42), 3.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SwipeActionBar extends StatefulWidget {
  const SwipeActionBar({
    super.key,
    required this.label,
    required this.onComplete,
    this.leading,
  });

  final String label;
  final VoidCallback onComplete;
  final IconData? leading;

  @override
  State<SwipeActionBar> createState() => _SwipeActionBarState();
}

class _SwipeActionBarState extends State<SwipeActionBar> {
  double dx = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) => setState(() => dx = (dx + d.delta.dx).clamp(0, 120)),
      onHorizontalDragEnd: (_) {
        if (dx > 72) {
          HapticFeedback.mediumImpact();
          widget.onComplete();
        }
        setState(() => dx = 0);
      },
      child: LiquidGlass(
        radius: AppRadius.pill,
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        child: Row(
          children: [
            Transform.translate(
              offset: Offset(dx * 0.2, 0),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.navInk,
                ),
                child: Icon(widget.leading ?? Icons.auto_awesome, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Text('››', style: TextStyle(fontSize: 18, color: AppColors.mutedGray)),
          ],
        ),
      ),
    );
  }
}

class LiveCountdown extends StatefulWidget {
  const LiveCountdown({super.key, required this.due});

  final DateTime due;

  @override
  State<LiveCountdown> createState() => _LiveCountdownState();
}

class _LiveCountdownState extends State<LiveCountdown> {
  late DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => now = DateTime.now());
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.due.difference(now);
    final days = left.inDays;
    final hours = left.inHours.remainder(24);
    final mins = left.inMinutes.remainder(60);
    return LiquidGlass(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COUNTDOWN', style: AppTypography.caption.copyWith(letterSpacing: 1.4)),
                Text(
                  days >= 0 ? '$days days · ${hours}h ${mins}m' : 'Due date has passed',
                  style: AppTypography.title.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          Text(
            '${widget.due.day} ${_shortMonth(widget.due.month)}',
            style: AppTypography.caption.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class GlassFeatureTile extends StatelessWidget {
  const GlassFeatureTile({
    super.key,
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: LiquidGlass(
        radius: 24,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.ink),
            const SizedBox(height: 10),
            Text(label, style: AppTypography.title.copyWith(fontSize: 16)),
            Text(caption, maxLines: 2, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}

String _shortMonth(int month) {
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return names[(month - 1).clamp(0, 11)];
}
