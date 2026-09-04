import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Sequenced 2.9s hold timeline. One controller so reverse stays in sync.
class EntryGateController extends ChangeNotifier {
  EntryGateController({required TickerProvider vsync}) {
    timeline = AnimationController(
      vsync: vsync,
      duration: total,
    )
      ..addListener(notifyListeners)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          unlocked = true;
          if (holding) _bubbleTicker.start();
          notifyListeners();
        }
      });
    _bubbleTicker = vsync.createTicker(_tickBubbles);
  }

  static const charge = Duration(milliseconds: 1200);
  static const wordmark = Duration(milliseconds: 600);
  static const iris = Duration(milliseconds: 500);
  static const reveal = Duration(milliseconds: 600);
  static const total = Duration(milliseconds: 2900);

  static const double _tChargeEnd = 1200 / 2900;
  static const double _tWordEnd = 1800 / 2900;
  static const double _tIrisEnd = 2300 / 2900;

  late final AnimationController timeline;
  late final Ticker _bubbleTicker;

  bool holding = false;
  bool unlocked = false;
  double bubbleTime = 0;

  double get t => timeline.value;

  double get chargeProgress => _interval(0, _tChargeEnd, Curves.easeOut);

  double get wordmarkProgress =>
      _interval(_tChargeEnd, _tWordEnd, Curves.easeOutBack);

  double get irisProgress => _interval(_tWordEnd, _tIrisEnd, Curves.easeInCubic);

  double get revealProgress => _interval(_tIrisEnd, 1, Curves.easeOut);

  bool get inFountain => unlocked && holding;

  double revealItem(int index) {
    final start = _tIrisEnd + (index * 80 / 2900);
    final end = (start + 220 / 2900).clamp(0.0, 1.0);
    return _interval(start, end, Curves.easeOut);
  }

  double _interval(double start, double end, Curve curve) {
    if (end <= start) return t >= start ? 1 : 0;
    if (t <= start) return 0;
    if (t >= end) return 1;
    return curve.transform(((t - start) / (end - start)).clamp(0.0, 1.0));
  }

  void holdStart({bool reduceMotion = false}) {
    holding = true;
    if (reduceMotion) {
      timeline.value = 1;
      unlocked = true;
      _bubbleTicker.start();
      notifyListeners();
      return;
    }
    if (unlocked) {
      _bubbleTicker.start();
      notifyListeners();
      return;
    }
    timeline.forward();
    notifyListeners();
  }

  void holdEnd() {
    holding = false;
    _bubbleTicker.stop();
    if (!unlocked) {
      timeline.reverse();
    }
    notifyListeners();
  }

  void jumpToUnlocked() {
    unlocked = true;
    holding = false;
    timeline.value = 1;
    notifyListeners();
  }

  void _tickBubbles(Duration elapsed) {
    bubbleTime = elapsed.inMilliseconds / 1000.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _bubbleTicker.dispose();
    timeline.dispose();
    super.dispose();
  }
}
