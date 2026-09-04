// design_tokens.dart
//
// Starter implementation of the tokens described in
// cursor-rebuild-prompt.md, Section 1. Drop into the new UI folder
// (e.g. lib/ui/theme/design_tokens.dart) and wire buildAppTheme()
// into MaterialApp(theme: ...). Adjust import paths / package name
// to match this project's actual structure — do not change the
// values without updating the reference images' intent.
//
// Requires the `google_fonts` package. If this project doesn't use
// it yet, add it to pubspec.yaml rather than hardcoding font assets.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------------
/// Color tokens
/// ---------------------------------------------------------------------
class AppColors {
  AppColors._();

  // Neutral surfaces
  static const Color warmWhite = Color(0xFFFFFBFB);
  static const Color ink = Color(0xFF241C24);
  static const Color mutedGray = Color(0xFF7A7280);

  // Background mesh gradient stops
  static const Color rose = Color(0xFFF7B8D0);
  static const Color orchid = Color(0xFFC9A6E8);
  static const Color peach = Color(0xFFFBC9A6);

  // Accent gradient stops (selected states, rings, active tabs)
  static const Color magenta = Color(0xFFE84393);
  static const Color violet = Color(0xFF8E5CE8);
  static const Color amber = Color(0xFFF5B942);

  // Semantic — MUST stay solid/saturated, never gradient-filled.
  // See cursor-rebuild-prompt.md Section 6 (clinical legibility).
  static const Color semanticSafe = Color(0xFF2E9E6B);
  static const Color semanticWarn = Color(0xFFE0A32E);
  static const Color semanticAlert = Color(0xFFD64545);
}

/// ---------------------------------------------------------------------
/// Gradient tokens
/// ---------------------------------------------------------------------
class AppGradients {
  AppGradients._();

  /// Full-bleed background behind hero/greeting screens.
  /// Use a mesh/radial blend in the real implementation if the
  /// rendering approach supports it — this linear version is the
  /// minimum acceptable fallback.
  static const LinearGradient backgroundMesh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.rose, AppColors.orchid, AppColors.peach],
  );

  /// Small, concentrated accent — selected date chip, active tab
  /// indicator, avatar ring. Never spread across a whole screen.
  static const RadialGradient accentRing = RadialGradient(
    colors: [AppColors.magenta, AppColors.violet, AppColors.amber],
  );
}

/// ---------------------------------------------------------------------
/// Spacing scale — use these constants, never a raw number in a screen
/// ---------------------------------------------------------------------
class AppSpacing {
  AppSpacing._();
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// ---------------------------------------------------------------------
/// Corner radius scale
/// ---------------------------------------------------------------------
class AppRadius {
  AppRadius._();
  static const double cardLarge = 28;
  static const double cardSmall = 20;
  static const double pill = 999;
}

/// ---------------------------------------------------------------------
/// Glass surface constants (used by the GlassCard component)
/// ---------------------------------------------------------------------
class AppGlass {
  AppGlass._();
  static const double blurSigma = 24;
  static const double fillOpacity = 0.15;
  static const double borderOpacity = 0.25;

  static List<BoxShadow> shadow = [
    BoxShadow(
      color: AppColors.violet.withOpacity(0.18),
      blurRadius: 32,
      spreadRadius: -4,
      offset: const Offset(0, 12),
    ),
  ];
}

/// ---------------------------------------------------------------------
/// Typography — two-family pairing per Section 1.2
/// ---------------------------------------------------------------------
class AppTypography {
  AppTypography._();

  /// Editorial/display font — greetings, week numbers, date headers.
  /// Used sparingly: at most one display headline moment per screen.
  static TextStyle display = GoogleFonts.fraunces(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.05,
    color: AppColors.ink,
  );

  static TextStyle title = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedGray,
  );
}

/// ---------------------------------------------------------------------
/// ThemeExtension — wire into MaterialApp so tokens are reachable via
/// Theme.of(context).extension<AppThemeTokens>()
/// ---------------------------------------------------------------------
@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens();

  @override
  AppThemeTokens copyWith() => const AppThemeTokens();

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    return this;
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.warmWhite,
    textTheme: TextTheme(
      displayLarge: AppTypography.display,
      titleLarge: AppTypography.title,
      bodyLarge: AppTypography.body,
      bodySmall: AppTypography.caption,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      surface: AppColors.warmWhite,
    ),
    extensions: const [AppThemeTokens()],
  );
}
