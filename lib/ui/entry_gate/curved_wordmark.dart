import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class CurvedWordmark extends StatelessWidget {
  const CurvedWordmark({
    super.key,
    required this.text,
    required this.progress,
    required this.iris,
    required this.radius,
  });

  final String text;
  final double progress;
  final double iris;
  final double radius;

  static const _palette = [
    AppColors.magenta,
    AppColors.violet,
    AppColors.amber,
    AppColors.rose,
    AppColors.orchid,
  ];

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 && iris <= 0) return const SizedBox.shrink();
    final chars = text.split('');
    if (chars.isEmpty) return const SizedBox.shrink();

    const startAngle = -math.pi * 0.88;
    const endAngle = -math.pi * 0.12;
    final span = endAngle - startAngle;
    final step = chars.length == 1 ? 0.0 : span / (chars.length - 1);
    final pull = iris;
    final appear = progress;

    return IgnorePointer(
      child: SizedBox(
        width: radius * 2 + 72,
        height: radius * 2 + 72,
        child: Stack(
          children: [
            for (var i = 0; i < chars.length; i++)
              _letter(
                chars[i],
                i,
                chars.length,
                startAngle + step * i,
                appear,
                pull,
              ),
          ],
        ),
      ),
    );
  }

  Widget _letter(
    String ch,
    int i,
    int n,
    double angle,
    double appear,
    double pull,
  ) {
    final stagger = (i * 0.07).clamp(0.0, 0.55);
    final local = (appear - stagger) / (1 - stagger);
    final shown = local.clamp(0.0, 1.0);

    final r = radius * (1 - 0.92 * pull);
    final x = r * math.cos(angle);
    final y = r * math.sin(angle);
    final opacity = (shown * (1 - pull)).clamp(0.0, 1.0);
    final rot = angle + math.pi / 2;

    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(x, y),
        child: Transform.rotate(
          angle: rot * (1 - pull),
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: 0.72 + 0.38 * local,
              child: Text(
                ch,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: _palette[i % _palette.length],
                  shadows: [
                    Shadow(
                      color: _palette[i % _palette.length].withValues(alpha: 0.45),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
