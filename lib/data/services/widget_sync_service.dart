import 'package:home_widget/home_widget.dart';

/// Keeps the Android home-screen widget in sync with in-app care pulse data.
class WidgetSyncService {
  static const androidName = 'PregCareWidget';

  Future<void> push({
    required String greeting,
    required String weekLabel,
    required String water,
    required String nextVisit,
  }) async {
    try {
      await HomeWidget.saveWidgetData('greeting', greeting);
      await HomeWidget.saveWidgetData('weekLabel', weekLabel);
      await HomeWidget.saveWidgetData('water', water);
      await HomeWidget.saveWidgetData('nextVisit', nextVisit);
      await HomeWidget.updateWidget(androidName: androidName);
    } catch (_) {
      // Widget APIs are no-ops on web / missing native receiver.
    }
  }
}
