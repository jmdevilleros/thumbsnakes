import 'dart:ui';

import '../models/direction.dart';
import '../models/snake.dart';
import '../utils/game_config.dart';

/// Touch routing for fixed joysticks (RF-003, ADR-007).
class InputController {
  InputController._();

  /// Left half → snake A, right half → snake B.
  static SnakeId sideFor(double x, double screenWidth) =>
      x < screenWidth / 2 ? SnakeId.a : SnakeId.b;

  /// Fixed joystick center for a side, bottom corners.
  static Offset centerFor(
    SnakeId id,
    Size screen, {
    double radius = GameConfig.joystickRadius,
    double margin = GameConfig.joystickMargin,
  }) {
    final y = screen.height - margin - radius;
    return id == SnakeId.a
        ? Offset(margin + radius, y)
        : Offset(screen.width - margin - radius, y);
  }

  /// Dominant-axis quantization with a dead zone (fraction of [radius]).
  static Direction? quantize(
    Offset delta, {
    double radius = GameConfig.joystickRadius,
    double deadZone = GameConfig.joystickDeadZone,
  }) {
    if (delta.distance < radius * deadZone) return null;
    if (delta.dx.abs() >= delta.dy.abs()) {
      return delta.dx > 0 ? Direction.right : Direction.left;
    }
    return delta.dy > 0 ? Direction.down : Direction.up;
  }
}
