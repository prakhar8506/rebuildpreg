import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/design_tokens.dart';
import 'components.dart';

/// App mesh plus the recorded aura, looped. White in the clip is multiplied
/// away so Mira’s gradient stays the ground and the orb motion sits on top.
class AuraLoopBackdrop extends StatefulWidget {
  const AuraLoopBackdrop({
    super.key,
    required this.child,
    this.dim = 0.08,
  });

  final Widget child;
  final double dim;

  @override
  State<AuraLoopBackdrop> createState() => _AuraLoopBackdropState();
}

class _AuraLoopBackdropState extends State<AuraLoopBackdrop> {
  VideoPlayerController? _player;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final c = VideoPlayerController.asset('assets/motion/meditation_loop.mp4');
    c.initialize().then((_) {
      if (!mounted) {
        c.dispose();
        return;
      }
      c
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      setState(() {
        _player = c;
        _ready = true;
      });
    }).catchError((_) {
      if (mounted) setState(() => _ready = false);
      c.dispose();
    });
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientMeshBackground(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready && _player != null)
            IgnorePointer(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  AppColors.orchid.withValues(alpha: 0.18),
                  BlendMode.softLight,
                ),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFF6EEF4),
                    BlendMode.multiply,
                  ),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _player!.value.size.width,
                      height: _player!.value.size.height,
                      child: VideoPlayer(_player!),
                    ),
                  ),
                ),
              ),
            ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.warmWhite.withValues(alpha: 0.18 + widget.dim),
                    Colors.transparent,
                    AppColors.mist.withValues(alpha: 0.22 + widget.dim),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
