import 'package:flutter/material.dart';

/// Color tokens from cursor-rebuild-prompt.md Section 1.
class AppColors {
  AppColors._();

  static const Color warmWhite = Color(0xFFFFFBFB);
  static const Color ink = Color(0xFF241C24);
  static const Color mutedGray = Color(0xFF7A7280);

  static const Color rose = Color(0xFFFADADD);
  static const Color orchid = Color(0xFFD4C4F0);
  static const Color peach = Color(0xFFFBC9A6);
  static const Color sky = Color(0xFFB9D4F6);
  static const Color mist = Color(0xFFE6E6FA);

  static const Color magenta = Color(0xFFE84393);
  static const Color violet = Color(0xFF6B7CFF);
  static const Color cornflower = Color(0xFF5B7CFA);
  static const Color amber = Color(0xFFF5B942);
  static const Color navInk = Color(0xFF1A1424);

  static const Color semanticSafe = Color(0xFF2E9E6B);
  static const Color semanticWarn = Color(0xFFE0A32E);
  static const Color semanticAlert = Color(0xFFD64545);

  static const Color opaqueCard = Color(0xFFF8F1F4);
  static const Color nightInk = Color(0xFFF6EEF4);
  static const Color nightMuted = Color(0xFFB8AEB8);
  static const Color nightSurface = Color(0xFF1C141C);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient backgroundMesh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.mist, AppColors.rose, AppColors.sky],
  );

  static const RadialGradient accentRing = RadialGradient(
    colors: [AppColors.magenta, AppColors.violet, AppColors.amber],
  );
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  AppRadius._();
  static const double cardLarge = 28;
  static const double cardSmall = 20;
  static const double pill = 999;
}

class AppGlass {
  AppGlass._();
  static const double blurSigma = 36;
  static const double fillOpacity = 0.16;
  static const double borderOpacity = 0.58;
  static const double sheenOpacity = 0.42;

  /// Slight saturate + lift after blur — the “liquid” refraction trick.
  static const List<double> saturateMatrix = <double>[
    1.18, 0.06, 0.06, 0, 8,
    0.06, 1.18, 0.06, 0, 8,
    0.06, 0.06, 1.18, 0, 8,
    0, 0, 0, 1, 0,
  ];

  static List<BoxShadow> shadow = [
    BoxShadow(
      color: AppColors.violet.withValues(alpha: 0.16),
      blurRadius: 40,
      spreadRadius: -6,
      offset: const Offset(0, 18),
    ),
    BoxShadow(
      color: AppColors.rose.withValues(alpha: 0.12),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}

class AppTypography {
  AppTypography._();

  /// Editorial serif — bundled so the APK does not fetch fonts at runtime.
  static TextStyle display = const TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 48,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    height: 1.08,
    color: AppColors.ink,
  );

  static TextStyle title = const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );

  static TextStyle body = const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.ink,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.mutedGray,
  );
}

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    this.ink = AppColors.ink,
    this.muted = AppColors.mutedGray,
    this.surface = AppColors.warmWhite,
    this.opaqueCard = AppColors.opaqueCard,
  });

  final Color ink;
  final Color muted;
  final Color surface;
  final Color opaqueCard;

  @override
  AppThemeTokens copyWith({
    Color? ink,
    Color? muted,
    Color? surface,
    Color? opaqueCard,
  }) {
    return AppThemeTokens(
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      surface: surface ?? this.surface,
      opaqueCard: opaqueCard ?? this.opaqueCard,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      ink: Color.lerp(ink, other.ink, t) ?? ink,
      muted: Color.lerp(muted, other.muted, t) ?? muted,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      opaqueCard: Color.lerp(opaqueCard, other.opaqueCard, t) ?? opaqueCard,
    );
  }
}

ThemeData buildAppTheme({bool dark = false}) {
  final ink = dark ? AppColors.nightInk : AppColors.ink;
  final muted = dark ? AppColors.nightMuted : AppColors.mutedGray;
  final surface = dark ? AppColors.nightSurface : AppColors.warmWhite;
  final card = dark ? const Color(0xFF2A2028) : AppColors.opaqueCard;

  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: surface,
    textTheme: TextTheme(
      displayLarge: AppTypography.display.copyWith(color: ink),
      titleLarge: AppTypography.title.copyWith(color: ink),
      bodyLarge: AppTypography.body.copyWith(color: ink),
      bodySmall: AppTypography.caption.copyWith(color: muted),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: dark ? Brightness.dark : Brightness.light,
      surface: surface,
    ),
    extensions: [
      AppThemeTokens(ink: ink, muted: muted, surface: surface, opaqueCard: card),
    ],
  );
}

AppThemeTokens tokensOf(BuildContext context) {
  return Theme.of(context).extension<AppThemeTokens>() ?? const AppThemeTokens();
}
