import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A stylised, deliberately non-clinical silhouette of the baby that gently
/// morphs across the weeks — bigger-headed and tightly curled early on, plumper
/// and more baby-shaped as the limbs fill in. Drawn entirely in code (no assets,
/// fully offline) and softly animated so it feels alive without pretending to be
/// an ultrasound.
class FetalSilhouette extends StatefulWidget {
  const FetalSilhouette({
    required this.week,
    this.size = 132,
    this.color,
    super.key,
  });

  final int week;
  final double size;
  final Color? color;

  @override
  State<FetalSilhouette> createState() => _FetalSilhouetteState();
}

class _FetalSilhouetteState extends State<FetalSilhouette>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // A slow breathing float: a few pixels of drift and a hair of sway.
          final phase = math.sin(_controller.value * math.pi * 2);
          return Transform.translate(
            offset: Offset(0, phase * 3),
            child: Transform.rotate(
              angle: phase * 0.03,
              child: CustomPaint(
                painter: _SilhouettePainter(week: widget.week, color: color),
                size: Size.square(widget.size),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter({required this.week, required this.color});

  final int week;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final centre = Offset(s / 2, s / 2);
    // 0 at the start of the table, 1 near term. Drives head/body proportion.
    final t = ((week - 5) / 35).clamp(0.0, 1.0);
    // Limbs emerge from ~week 8 and fill out over the following weeks.
    final limbs = ((week - 8) / 12).clamp(0.0, 1.0);

    // A faint womb halo behind the figure.
    canvas.drawCircle(
      centre,
      s * 0.46,
      Paint()..color = color.withValues(alpha: 0.06),
    );

    // Build the curled figure as a union of soft ovals drawn in one pass, so the
    // overlaps melt together instead of showing seams.
    Offset p(double fx, double fy) => centre + Offset(fx * s, fy * s);

    final headR = (0.25 - 0.05 * t) * s;
    final torsoR = (0.16 + 0.07 * t) * s;
    final bumR = (0.10 + 0.06 * t) * s;
    final kneeR = (0.03 + 0.07 * limbs) * s;
    final armR = (0.02 + 0.05 * limbs) * s;

    final figure = Path()..fillType = PathFillType.nonZero;
    figure.addOval(Rect.fromCircle(center: p(-0.07, -0.20), radius: headR));
    figure.addOval(Rect.fromCircle(center: p(0.03, 0.06), radius: torsoR));
    figure.addOval(Rect.fromCircle(center: p(-0.05, 0.24), radius: bumR));
    figure.addOval(Rect.fromCircle(center: p(-0.17, 0.16), radius: kneeR));
    figure.addOval(Rect.fromCircle(center: p(-0.20, -0.02), radius: armR));

    canvas.drawPath(
      figure,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) =>
      old.week != week || old.color != color;
}
