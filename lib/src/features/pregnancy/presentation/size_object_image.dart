import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/size_comparison.dart';

/// The "as big as…" illustration: the bundled OpenMoji image for a comparison
/// object, gently bobbing so it feels playful. If the asset can't be found for
/// any reason it falls back to the plain emoji, so the screen never breaks.
class SizeObjectImage extends StatefulWidget {
  const SizeObjectImage({required this.object, this.size = 72, super.key});

  final ComparisonObject object;
  final double size;

  @override
  State<SizeObjectImage> createState() => _SizeObjectImageState();
}

class _SizeObjectImageState extends State<SizeObjectImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final phase = math.sin(_controller.value * math.pi * 2);
          return Transform.translate(
            offset: Offset(0, phase * 2.5),
            child: Transform.scale(scale: 1 + phase * 0.04, child: child),
          );
        },
        child: Image.asset(
          widget.object.assetPath,
          width: widget.size,
          height: widget.size,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, _, _) => Center(
            child: Text(
              widget.object.emoji,
              style: TextStyle(fontSize: widget.size * 0.78),
            ),
          ),
        ),
      ),
    );
  }
}
