import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class GradientMeshBackground extends StatelessWidget {
  const GradientMeshBackground({
    super.key,
    required this.child,
    this.parallax = 0,
  });

  final Widget child;
  final double parallax;

  @override
  Widget build(BuildContext context) {
    final shift = (parallax * 0.08).clamp(-24.0, 24.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: tokensOf(context).surface),
        Transform.translate(
          offset: Offset(0, shift),
          child: const CustomPaint(painter: _MeshPainter(), child: SizedBox.expand()),
        ),
        Material(type: MaterialType.transparency, child: child),
      ],
    );
  }
}

class _MeshPainter extends CustomPainter {
  const _MeshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.mist, AppColors.rose, AppColors.sky, AppColors.peach],
        ).createShader(Offset.zero & size),
    );
    void blob(Alignment a, Color c, double r) {
      final center = a.alongSize(size);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = c
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90),
      );
    }

    blob(const Alignment(-0.75, -0.9), AppColors.rose, size.width * 0.62);
    blob(const Alignment(0.9, -0.35), AppColors.sky, size.width * 0.58);
    blob(const Alignment(-0.35, 0.95), AppColors.peach, size.width * 0.6);
    blob(const Alignment(0.55, 0.15), AppColors.orchid, size.width * 0.42);
    blob(const Alignment(0.1, 0.4), AppColors.violet.withValues(alpha: 0.28), size.width * 0.28);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum GlassVariant { standalone, stacked, photoOverlay, pill }

/// Frosted liquid-glass surface: blur + saturate, lit gradient fill,
/// specular rim. Used by cards, composer, nav, chips.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.height,
    this.opaque = false,
  });

  final Widget child;
  final double? radius;
  final EdgeInsets? padding;
  final double? height;
  final bool opaque;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppRadius.cardLarge;
    final rr = BorderRadius.circular(r);
    return Container(
      height: height,
      decoration: BoxDecoration(borderRadius: rr, boxShadow: AppGlass.shadow),
      child: ClipRRect(
        borderRadius: rr,
        child: BackdropFilter(
          filter: ImageFilter.compose(
            outer: ImageFilter.blur(
              sigmaX: AppGlass.blurSigma,
              sigmaY: AppGlass.blurSigma,
              tileMode: TileMode.clamp,
            ),
            inner: const ColorFilter.matrix(AppGlass.saturateMatrix),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: rr,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: opaque
                    ? [
                        tokensOf(context).opaqueCard.withValues(alpha: 0.94),
                        tokensOf(context).opaqueCard.withValues(alpha: 0.88),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.36),
                        Colors.white.withValues(alpha: AppGlass.fillOpacity),
                      ],
              ),
              border: Border.all(
                width: 1.15,
                color: Colors.white.withValues(alpha: AppGlass.borderOpacity),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _GlassSheenPainter(r)),
                  ),
                ),
                Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSheenPainter extends CustomPainter {
  const _GlassSheenPainter(this.radius);

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final top = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: AppGlass.sheenOpacity),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.55));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.55),
        Radius.circular(radius),
      ),
      top,
    );

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.92),
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.45),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        Radius.circular((radius - 1).clamp(0, radius)),
      ),
      rim,
    );
  }

  @override
  bool shouldRepaint(covariant _GlassSheenPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.variant = GlassVariant.standalone,
    this.padding,
    this.onTap,
    this.opaque = false,
    this.photo,
    this.rotation = 0,
    this.height,
  });

  final Widget child;
  final GlassVariant variant;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool opaque;
  final Widget? photo;
  final double rotation;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = switch (variant) {
      GlassVariant.pill => AppRadius.pill,
      GlassVariant.standalone => AppRadius.cardLarge,
      GlassVariant.stacked || GlassVariant.photoOverlay => AppRadius.cardSmall,
    };

    Widget card;
    if (variant == GlassVariant.photoOverlay) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ?photo,
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.ink.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: padding ?? const EdgeInsets.all(AppSpacing.md),
                child: child,
              ),
            ],
          ),
        ),
      );
    } else {
      card = LiquidGlass(
        radius: radius,
        height: height,
        opaque: opaque,
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      );
    }

    if (variant == GlassVariant.stacked || rotation != 0) {
      card = Transform.rotate(
        angle: rotation == 0 ? -0.03 : rotation,
        child: card,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.scale(scale: value, child: child),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: card,
        ),
      ),
    );
  }
}

class PillTabBar extends StatelessWidget {
  const PillTabBar({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      radius: AppRadius.pill,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.elasticOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: i == index
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.amber.withValues(alpha: 0.7),
                              AppColors.magenta.withValues(alpha: 0.55),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: i == index
                        ? Border.all(color: Colors.white.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: i == index ? Colors.white : tokensOf(context).ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GradientRingDateChip extends StatelessWidget {
  const GradientRingDateChip({
    super.key,
    required this.label,
    required this.caption,
    required this.selected,
    required this.onTap,
    this.dot,
  });

  final String label;
  final String caption;
  final bool selected;
  final VoidCallback onTap;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: selected ? AppGradients.accentRing : null,
              color: selected ? null : Colors.white.withValues(alpha: 0.35),
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? tokensOf(context).opaqueCard
                    : Colors.white.withValues(alpha: 0.28),
              ),
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokensOf(context).ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(caption, style: AppTypography.caption),
          if (dot != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

class BottomComposerBar extends StatelessWidget {
  const BottomComposerBar({
    super.key,
    this.controller,
    this.hint,
    this.onSend,
    this.onMic,
    this.onAttach,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? hint;
  final VoidCallback? onSend;
  final VoidCallback? onMic;
  final VoidCallback? onAttach;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      radius: AppRadius.pill,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onAttach,
            icon: const Icon(Icons.add, color: AppColors.ink),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hint ?? 'Share with Mira…',
                hintStyle: AppTypography.body.copyWith(color: AppColors.mutedGray),
                border: InputBorder.none,
              ),
              style: AppTypography.body,
            ),
          ),
          IconButton(
            onPressed: onMic,
            icon: const Icon(Icons.mic_none_rounded, color: AppColors.ink),
          ),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.accentRing,
                border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayHeadline extends StatelessWidget {
  const DisplayHeadline(
    this.text, {
    super.key,
    this.size = 48,
    this.color,
    this.italic = false,
  });

  final String text;
  final double size;
  final Color? color;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.display.copyWith(
        fontSize: size,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color ?? tokensOf(context).ink,
      ),
    );
  }
}

class VitalStatCard extends StatelessWidget {
  const VitalStatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    this.spark = const [],
    this.badge,
    this.badgeColor = AppColors.semanticSafe,
    this.onTap,
  });

  final String label;
  final String value;
  final String unit;
  final List<double> spark;
  final String? badge;
  final Color badgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opaque: true,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: SizedBox(
        width: 148,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption,
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTypography.title.copyWith(
                      fontSize: 24,
                      height: 1.1,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: AppTypography.caption.copyWith(color: AppColors.ink),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 18,
              width: double.infinity,
              child: CustomPaint(
                painter: _SparkPainter(spark, badgeColor),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  badge!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.points, this.color);

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minV = points.reduce(min);
    final maxV = points.reduce(max);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : maxV - minV;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height - ((points[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.points != points;
}

class PhotoLabelChip extends StatelessWidget {
  const PhotoLabelChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      radius: AppRadius.pill,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: AppColors.ink),
      ),
    );
  }
}

class SyncPill extends StatelessWidget {
  const SyncPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      radius: AppRadius.pill,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(status, style: AppTypography.caption),
    );
  }
}

class SolidAlertBanner extends StatelessWidget {
  const SolidAlertBanner({
    super.key,
    required this.title,
    required this.body,
    this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.semanticAlert,
      borderRadius: BorderRadius.circular(AppRadius.cardSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.emergency, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      body,
                      style: AppTypography.caption.copyWith(color: Colors.white),
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

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: primary
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppGradients.accentRing,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : LiquidGlass(
              radius: AppRadius.pill,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: tokensOf(context).ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
    );
  }
}

class MeshScaffold extends StatelessWidget {
  const MeshScaffold({
    super.key,
    required this.child,
    this.bottom,
    this.parallax = 0,
  });

  final Widget child;
  final Widget? bottom;
  final double parallax;

  @override
  Widget build(BuildContext context) {
    return GradientMeshBackground(
      parallax: parallax,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(child: child),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}
