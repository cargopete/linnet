import 'package:flutter/material.dart';

/// The Linnet brand mark: a simple cream songbird with the linnet's signature
/// rosy breast, on a deep-rose field. Drawn in code so it scales crisply and
/// can be reused in-app (onboarding, about) as well as rendered to the app icon.
class LinnetMark extends StatelessWidget {
  const LinnetMark({this.size = 96, super.key});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: LinnetMarkPainter());
}

class LinnetMarkPainter extends CustomPainter {
  // Brand palette.
  static const _roseTop = Color(0xFFC15E79);
  static const _roseBottom = Color(0xFF9C4359);
  static const _cream = Color(0xFFFFF3E9);
  static const _wing = Color(0xFFE7B9C6);
  static const _breast = Color(0xFFE07A5F);
  static const _beak = Color(0xFFE9A94C);
  static const _eye = Color(0xFF5A2233);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset p(double fx, double fy) => Offset(fx * s, fy * s);

    // Background: a soft vertical rose gradient.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_roseTop, _roseBottom],
        ).createShader(Offset.zero & size),
    );

    // Scale the bird up a little and nudge it up so it fills the frame, leaving
    // less empty rose in the top-left.
    final centre = p(0.48, 0.54);
    canvas.save();
    canvas.translate(-0.015 * s, -0.03 * s);
    canvas.translate(centre.dx, centre.dy);
    canvas.scale(1.14);
    canvas.translate(-centre.dx, -centre.dy);

    final cream = Paint()
      ..color = _cream
      ..isAntiAlias = true;

    // Tail: two soft feathers sweeping back-left from the body.
    final tail = Path()
      ..moveTo(p(0.30, 0.52).dx, p(0.30, 0.52).dy)
      ..lineTo(p(0.13, 0.47).dx, p(0.13, 0.47).dy)
      ..lineTo(p(0.20, 0.60).dx, p(0.20, 0.60).dy)
      ..lineTo(p(0.16, 0.66).dx, p(0.16, 0.66).dy)
      ..lineTo(p(0.34, 0.64).dx, p(0.34, 0.64).dy)
      ..close();
    canvas.drawPath(tail, cream);

    // Body + head as a union of two soft ovals, drawn in one pass (no seam).
    final bird = Path()
      ..fillType = PathFillType.nonZero
      ..addOval(Rect.fromCircle(center: p(0.47, 0.57), radius: 0.205 * s))
      ..addOval(Rect.fromCircle(center: p(0.63, 0.41), radius: 0.135 * s));
    canvas.drawPath(bird, cream);

    // Beak: a small amber triangle.
    final beak = Path()
      ..moveTo(p(0.73, 0.38).dx, p(0.73, 0.38).dy)
      ..lineTo(p(0.85, 0.42).dx, p(0.85, 0.42).dy)
      ..lineTo(p(0.73, 0.45).dx, p(0.73, 0.45).dy)
      ..close();
    canvas.drawPath(beak, Paint()..color = _beak);

    // Breast: a warm coral lens on the lower front — the linnet's red breast.
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: p(0.47, 0.57), radius: 0.205 * s)),
    );
    canvas.drawCircle(p(0.62, 0.66), 0.16 * s, Paint()..color = _breast);
    canvas.restore();

    // Folded wing: a soft rose-pink leaf on the body.
    final wing = Path()
      ..moveTo(p(0.34, 0.50).dx, p(0.34, 0.50).dy)
      ..quadraticBezierTo(
        p(0.56, 0.46).dx,
        p(0.46, 0.50).dy,
        p(0.58, 0.58).dx,
        p(0.58, 0.58).dy,
      )
      ..quadraticBezierTo(
        p(0.44, 0.58).dx,
        p(0.40, 0.60).dy,
        p(0.34, 0.50).dx,
        p(0.34, 0.50).dy,
      )
      ..close();
    canvas.drawPath(wing, Paint()..color = _wing);

    // Eye.
    canvas.drawCircle(p(0.655, 0.385), 0.022 * s, Paint()..color = _eye);

    canvas.restore();
  }

  @override
  bool shouldRepaint(LinnetMarkPainter oldDelegate) => false;
}
