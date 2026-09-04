import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../state/app_state.dart';

extension PregX on BuildContext {
  AppState get app => Provider.of<AppState>(this, listen: false);
  AppState get watchApp => watch<AppState>();
  String tr(String key) => S.t(key, watch<AppState>().lang);
}
