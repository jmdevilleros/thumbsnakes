import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:thumbsnakes/managers/input_controller.dart';
import 'package:thumbsnakes/models/direction.dart';
import 'package:thumbsnakes/models/snake.dart';
import 'package:thumbsnakes/utils/game_config.dart';

void main() {
  const r = GameConfig.joystickRadius;
  test('dead zone returns null', () {
    expect(
      InputController.quantize(
        Offset(r * GameConfig.joystickDeadZone * 0.9, 0),
      ),
      isNull,
    );
  });
  test('dominant axis', () {
    expect(InputController.quantize(const Offset(40, 10)), Direction.right);
    expect(InputController.quantize(const Offset(-40, 30)), Direction.left);
    expect(InputController.quantize(const Offset(10, -40)), Direction.up);
    expect(InputController.quantize(const Offset(-5, 50)), Direction.down);
  });
  test('halves route to their snake', () {
    expect(InputController.sideFor(10, 800), SnakeId.a);
    expect(InputController.sideFor(399, 800), SnakeId.a);
    expect(InputController.sideFor(400, 800), SnakeId.b);
    expect(InputController.sideFor(790, 800), SnakeId.b);
  });
  test('fixed centers in bottom corners', () {
    const size = Size(800, 400);
    final a = InputController.centerFor(SnakeId.a, size);
    final b = InputController.centerFor(SnakeId.b, size);
    expect(a.dx, lessThan(400));
    expect(b.dx, greaterThan(400));
    expect(a.dy, b.dy);
    expect(a.dy, greaterThan(200));
  });
}
