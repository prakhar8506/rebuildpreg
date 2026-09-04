import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class GateBubble {
  GateBubble({
    required this.icon,
    required this.color,
    required this.position,
    required this.velocity,
    required this.size,
    required this.born,
  });

  final IconData icon;
  final Color color;
  Offset position;
  Offset velocity;
  final double size;
  final double born;
}

class BubbleFountain extends StatefulWidget {
  const BubbleFountain({
    super.key,
    required this.active,
    required this.time,
    required this.origin,
  });

  final bool active;
  final double time;
  final Offset origin;

  @override
  State<BubbleFountain> createState() => _BubbleFountainState();
}

class _BubbleFountainState extends State<BubbleFountain> {
  static const _max = 22;
  static const _gravity = 980.0;
  static const _icons = <IconData>[
    Icons.spa_outlined,
    Icons.child_care_outlined,
    Icons.favorite_outline,
    Icons.water_drop_outlined,
    Icons.nightlight_outlined,
    Icons.auto_awesome_outlined,
    Icons.local_florist_outlined,
    Icons.wb_twilight_outlined,
  ];
  static const _colors = [
    AppColors.rose,
    AppColors.orchid,
    AppColors.peach,
    AppColors.magenta,
    AppColors.violet,
    AppColors.amber,
  ];

  final _bubbles = <GateBubble>[];
  final _rng = math.Random(7);
  double _lastSpawn = 0;
  double _lastTime = 0;

  @override
  void didUpdateWidget(covariant BubbleFountain oldWidget) {
    super.didUpdateWidget(oldWidget);
    _step(widget.time);
  }

  void _step(double time) {
    final dt = (time - _lastTime).clamp(0.0, 0.05);
    _lastTime = time;
    if (dt <= 0) return;

    if (widget.active &&
        _bubbles.length < _max &&
        time - _lastSpawn > 0.15) {
      _lastSpawn = time;
      final angle = (_rng.nextDouble() - 0.5) * 0.7;
      _bubbles.add(
        GateBubble(
          icon: _icons[_rng.nextInt(_icons.length)],
          color: _colors[_rng.nextInt(_colors.length)],
          position: widget.origin,
          velocity: Offset(
            math.sin(angle) * (80 + _rng.nextDouble() * 90),
            -(320 + _rng.nextDouble() * 160),
          ),
          size: 28 + _rng.nextDouble() * 18,
          born: time,
        ),
      );
    }

    for (final b in _bubbles) {
      b.velocity = Offset(b.velocity.dx, b.velocity.dy + _gravity * dt);
      b.position += b.velocity * dt;
    }
    _bubbles.removeWhere(
      (b) =>
          b.position.dy > widget.origin.dy + 40 || time - b.born > 3.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          for (final b in _bubbles)
            Positioned(
              left: b.position.dx - b.size / 2,
              top: b.position.dy - b.size / 2,
              child: _BubbleChip(
                icon: b.icon,
                color: b.color,
                size: b.size,
                opacity: (1 -
                        ((b.position.dy - widget.origin.dy + 180) / 260)
                            .clamp(0.0, 1.0))
                    .clamp(0.0, 1.0),
              ),
            ),
        ],
      ),
    );
  }
}

class _BubbleChip extends StatelessWidget {
  const _BubbleChip({
    required this.icon,
    required this.color,
    required this.size,
    required this.opacity,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.85),
              color.withValues(alpha: 0.7),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.46, color: AppColors.ink),
      ),
    );
  }
}
