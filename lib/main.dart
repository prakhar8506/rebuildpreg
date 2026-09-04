import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/hive/boxes.dart';
import 'data/repositories/app_repository.dart';
import 'data/services/ai_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/sync_service.dart';
import 'data/services/widget_sync_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    await Boxes.openAll();
  } catch (_) {}

  final repo = AppRepository();
  final notifications = NotificationService();
  try {
    await notifications.init();
  } catch (_) {}

  final state = AppState(
    repo: repo,
    sync: SyncService(repo),
    ai: AiService(),
    notifications: notifications,
    widgetSync: WidgetSyncService(),
  );
  runApp(PregApp(state: state));
  try {
    await state.boot();
  } catch (_) {}
}
