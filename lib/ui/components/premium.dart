import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../theme/design_tokens.dart';
import 'components.dart';

class PremiumHeader extends StatelessWidget {
  const PremiumHeader({
    super.key,
    required this.initial,
    required this.dateLabel,
    this.trailing,
  });

  final String initial;
  final String dateLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.55),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
          child: Text(
            initial.toUpperCase(),
            style: AppTypography.title.copyWith(fontSize: 16),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  dateLabel,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class SemiGauge extends StatelessWidget {
  const SemiGauge({
    super.key,
    required this.value,
    required this.caption,
    this.max = 100,
  });

  final double value;
  final int max;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      height: 78,
      child: CustomPaint(
        painter: _SemiGaugePainter(
          progress: (value / max).clamp(0.0, 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Column(
            children: [
              Text(
                '${value.round()}/$max',
                style: AppTypography.title.copyWith(fontSize: 15, height: 1),
              ),
              Text(
                caption,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SemiGaugePainter extends CustomPainter {
  _SemiGaugePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    final radius = size.width * 0.46;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = math.pi;
    const sweep = math.pi;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.45);
    canvas.drawArc(rect, start, sweep, false, track);

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: const [AppColors.sky, AppColors.violet, AppColors.orchid],
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep * progress, false, glow);

    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: const [Color(0xFF8EC5FF), AppColors.cornflower, AppColors.violet],
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep * progress, false, core);
  }

  @override
  bool shouldRepaint(covariant _SemiGaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class GlowHeroCard extends StatelessWidget {
  const GlowHeroCard({
    super.key,
    required this.tip,
    this.onTap,
  });

  final String tip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: SizedBox(
          height: 228,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF4E9FF), Color(0xFFD7E8FF), Color(0xFFF8D5E8)],
                  ),
                ),
              ),
              const CustomPaint(painter: _GlowOrbPainter()),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: $tip',
                              style: AppTypography.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrbPainter extends CustomPainter {
  const _GlowOrbPainter();

  @override
  void paint(Canvas canvas, Size size) {
    void orb(Offset c, double r, List<Color> colors) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(colors: colors).createShader(
            Rect.fromCircle(center: c, radius: r),
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    orb(
      Offset(size.width * 0.56, size.height * 0.38),
      size.width * 0.48,
      [
        const Color(0xFF5B7CFA).withValues(alpha: 0.95),
        const Color(0xFF8EC5FF).withValues(alpha: 0.55),
        const Color(0x00B9D4F6),
      ],
    );
    orb(
      Offset(size.width * 0.34, size.height * 0.5),
      size.width * 0.34,
      [
        const Color(0xFFFF8EC8).withValues(alpha: 0.95),
        const Color(0x00FADADD),
      ],
    );
    orb(
      Offset(size.width * 0.62, size.height * 0.22),
      size.width * 0.22,
      [
        Colors.white.withValues(alpha: 0.7),
        const Color(0x00FFFFFF),
      ],
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TwinStatusPills extends StatelessWidget {
  const TwinStatusPills({
    super.key,
    required this.leftIcon,
    required this.leftLabel,
    required this.rightIcon,
    required this.rightTitle,
    required this.rightCaption,
    this.onLeft,
    this.onRight,
  });

  final IconData leftIcon;
  final String leftLabel;
  final IconData rightIcon;
  final String rightTitle;
  final String rightCaption;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onLeft,
            child: LiquidGlass(
              radius: AppRadius.pill,
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cornflower,
                    ),
                    child: Icon(leftIcon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      leftLabel,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onRight,
            child: LiquidGlass(
              radius: AppRadius.pill,
              padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
              child: Row(
                children: [
                  Icon(rightIcon, color: AppColors.ink),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rightTitle,
                          style: AppTypography.title.copyWith(fontSize: 15, height: 1.1),
                        ),
                        Text(rightCaption, style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TickMeter extends StatelessWidget {
  const TickMeter({
    super.key,
    required this.title,
    required this.progress,
    required this.stats,
  });

  final String title;
  final double progress;
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title.copyWith(fontSize: 18)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final s in stats) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.$1,
                      style: AppTypography.display.copyWith(fontSize: 22),
                    ),
                    Text(s.$2, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 54,
          child: CustomPaint(
            painter: _TickPainter(progress.clamp(0.0, 1.0)),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).round()}%',
                style: AppTypography.title.copyWith(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const count = 42;
    final filled = (count * progress).round();
    final gap = size.width / count;
    for (var i = 0; i < count; i++) {
      final x = i * gap + 1;
      final h = 10.0 + (math.sin(i * 0.55) * 0.5 + 0.5) * (size.height - 18);
      final y = (size.height - h) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 2.2, h),
          const Radius.circular(2),
        ),
        Paint()
          ..color = i < filled
              ? AppColors.ink
              : Colors.white.withValues(alpha: 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelect,
  });

  final List<DateTime> days;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (_, i) {
          final d = days[i];
          final on = DateUtils.isSameDay(d, selected);
          return GestureDetector(
            onTap: () => onSelect(d),
            child: Column(
              children: [
                Text(
                  DateFormat('EE').format(d).substring(0, 2),
                  style: AppTypography.caption.copyWith(
                    color: on ? AppColors.ink : AppColors.mutedGray,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('dd').format(d),
                  style: AppTypography.title.copyWith(
                    fontSize: on ? 20 : 16,
                    color: on ? AppColors.ink : AppColors.mutedGray,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MoodOption {
  const MoodOption({
    required this.label,
    required this.icon,
    required this.score,
  });

  final String label;
  final IconData icon;
  final double score;
}

const kMoodArc = <MoodOption>[
  MoodOption(label: 'Tired', icon: Icons.nightlight_outlined, score: 2),
  MoodOption(label: 'Tender', icon: Icons.spa_outlined, score: 3),
  MoodOption(label: 'Calm', icon: Icons.favorite_outline, score: 4),
  MoodOption(label: 'Bright', icon: Icons.wb_sunny_outlined, score: 5),
  MoodOption(label: 'Wobbly', icon: Icons.air_rounded, score: 3),
];

class ArcMoodPicker extends StatelessWidget {
  const ArcMoodPicker({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = 250.0;
        final cx = w / 2;
        final cy = h * 0.72;
        const radius = 118.0;
        return SizedBox(
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MoodArcPainter(progress: index / (kMoodArc.length - 1)),
                ),
              ),
              for (var i = 0; i < kMoodArc.length; i++)
                _moodNode(
                  i,
                  Offset(
                    cx + radius * math.cos(_angle(i)),
                    cy + radius * math.sin(_angle(i)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _angle(int i) {
    const start = -math.pi * 0.95;
    const end = -math.pi * 0.05;
    return start + (end - start) * i / (kMoodArc.length - 1);
  }

  Widget _moodNode(int i, Offset pos) {
    final on = i == index;
    return Positioned(
      left: pos.dx - 28,
      top: pos.dy - 28,
      child: GestureDetector(
        onTap: () => onChanged(i),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? AppColors.cornflower : Colors.white.withValues(alpha: 0.55),
                boxShadow: on
                    ? [
                        BoxShadow(
                          color: AppColors.cornflower.withValues(alpha: 0.45),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
                border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
              ),
              child: Icon(
                kMoodArc[i].icon,
                color: on ? Colors.white : AppColors.ink,
              ),
            ),
            if (on)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  kMoodArc[i].label,
                  style: AppTypography.caption.copyWith(color: AppColors.ink),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MoodArcPainter extends CustomPainter {
  _MoodArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.72);
    final rect = Rect.fromCircle(center: center, radius: 78);
    const start = math.pi * 1.05;
    const sweep = math.pi * 0.9;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawArc(rect, start, sweep, false, track);

    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: const [AppColors.violet, AppColors.orchid, Colors.transparent],
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep * progress.clamp(0.15, 1), false, fill);

    final thumbA = start + sweep * progress.clamp(0.0, 1.0);
    final thumb = Offset(
      center.dx + 78 * math.cos(thumbA),
      center.dy + 78 * math.sin(thumbA),
    );
    canvas.drawCircle(thumb, 13, Paint()..color = Colors.white);
    canvas.drawCircle(
      thumb,
      13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.violet.withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(covariant _MoodArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class StepOrbButton extends StatelessWidget {
  const StepOrbButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.violet.withValues(alpha: 0.55), width: 2),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navInk,
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

Future<void> showQuickAdd(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: LiquidGlass(
          radius: 32,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add to today', style: AppTypography.display.copyWith(fontSize: 28)),
              const SizedBox(height: 16),
              _quick(context, Icons.auto_awesome_outlined, 'Ask Mira', '/mira'),
              _quick(context, Icons.favorite_outline, 'How I feel', '/life/wellbeing'),
              _quick(context, Icons.menu_book_outlined, 'Journal', '/life/journal'),
              _quick(context, Icons.water_drop_outlined, 'Water', '/care/water'),
            ],
          ),
        ),
      );
    },
  );
}

Widget _quick(BuildContext context, IconData icon, String label, String route) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GlassCard(
      variant: GlassVariant.pill,
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.arrow_outward_rounded, size: 16),
        ],
      ),
    ),
  );
}
