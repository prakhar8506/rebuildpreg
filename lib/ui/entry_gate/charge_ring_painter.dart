import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class ChargeRingPainter extends CustomPainter {
  ChargeRingPainter({required this.progress, this.stroke = 7});

  final double progress;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - stroke;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    const start = -math.pi / 2;

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * math.pi,
        colors: const [
          AppColors.orchid,
          AppColors.violet,
          AppColors.magenta,
          AppColors.amber,
          AppColors.orchid,
        ],
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep, false, glow);

    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * math.pi,
        colors: const [
          Color(0xFF7EC8E3),
          AppColors.violet,
          AppColors.magenta,
          AppColors.amber,
          Color(0xFF7EC8E3),
        ],
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep, false, core);
  }

  @override
  bool shouldRepaint(covariant ChargeRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
