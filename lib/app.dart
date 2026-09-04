import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/models/models.dart';
import 'routing/app_router.dart';
import 'state/app_state.dart';
import 'ui/theme/design_tokens.dart';

class PregApp extends StatefulWidget {
  const PregApp({super.key, required this.state});

  final AppState state;

  @override
  State<PregApp> createState() => _PregAppState();
}

class _PregAppState extends State<PregApp> {
  late final GoRouter router = createRouter(widget.state);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.state,
      child: Consumer<AppState>(
        builder: (context, app, _) {
          return MaterialApp.router(
            title: 'Mira',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            darkTheme: buildAppTheme(dark: true),
            themeMode: app.settings.theme == ThemeModePref.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: router,
            builder: (context, child) {
              ErrorWidget.builder = (details) {
                return Material(
                  color: AppColors.warmWhite,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Something stalled. Close and reopen Mira.\nThis is not a medical alert.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body,
                      ),
                    ),
                  ),
                );
              };
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(app.textScale.clamp(0.9, 1.25)),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
