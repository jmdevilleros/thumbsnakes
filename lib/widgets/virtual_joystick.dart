import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/game_config.dart';

/// Fixed, semi-transparent joystick (ADR-007). Purely visual: touch routing
/// lives in GameScreen / InputController. [knob] is the offset from center.
class VirtualJoystick extends StatelessWidget {
  const VirtualJoystick({super.key, required this.knob, required this.tint});

  final Offset knob;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    const r = GameConfig.joystickRadius;
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(r * 2, r * 2),
        painter: _JoystickPainter(knob, tint),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  _JoystickPainter(this.knob, this.tint);
  final Offset knob;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    const r = GameConfig.joystickRadius;
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, r, Paint()..color = AppColors.joystick);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = tint.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // 4-way arrows
    final arrow = Paint()..color = AppColors.joystickKnob;
    for (final d in const [
      Offset(0, -1),
      Offset(0, 1),
      Offset(-1, 0),
      Offset(1, 0),
    ]) {
      canvas.drawCircle(c + d * (r * 0.75), 3, arrow);
    }
    final k = knob.distance > r ? knob / knob.distance * r : knob;
    canvas.drawCircle(
      c + k,
      r * 0.4,
      Paint()..color = tint.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_JoystickPainter old) =>
      old.knob != knob || old.tint != tint;
}
