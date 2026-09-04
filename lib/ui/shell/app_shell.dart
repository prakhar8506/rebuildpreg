import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../state/app_state.dart';
import '../components/components.dart';
import '../components/premium.dart';
import '../theme/design_tokens.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const tabs = ['/', '/week', '/care', '/more'];

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/week')) return 1;
    if (loc.startsWith('/care')) return 2;
    if (loc.startsWith('/more') ||
        loc.startsWith('/baby') ||
        loc.startsWith('/life') ||
        loc.startsWith('/mira') ||
        loc.startsWith('/people') ||
        loc.startsWith('/settings') ||
        loc.startsWith('/doctor') ||
        loc.startsWith('/admin')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final i = _index(context);
    final labels = [
      S.t('home', app.lang),
      S.t('week', app.lang),
      S.t('care', app.lang),
      S.t('more', app.lang),
    ];
    const icons = [
      Icons.home_outlined,
      Icons.auto_awesome_outlined,
      Icons.favorite_outline,
      Icons.grid_view_rounded,
    ];
    const filled = [
      Icons.home_rounded,
      Icons.auto_awesome,
      Icons.favorite,
      Icons.grid_view_rounded,
    ];

    return Scaffold(
      body: Stack(
        children: [
          child,
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 78,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: LiquidGlass(
                        radius: AppRadius.pill,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Row(
                          children: [
                            for (var n = 0; n < 4; n++) ...[
                              if (n == 2) const SizedBox(width: 58),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => context.go(tabs[n]),
                                  behavior: HitTestBehavior.opaque,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        n == i ? filled[n] : icons[n],
                                        size: 22,
                                        color: AppColors.ink,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        labels[n],
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.ink,
                                          fontWeight: n == i
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: GestureDetector(
                        onTap: () => showQuickAdd(context),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.navInk,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.navInk.withValues(alpha: 0.28),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
