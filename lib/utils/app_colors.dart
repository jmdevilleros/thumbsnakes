import 'package:flutter/painting.dart';

/// Palette (spec §4): dark background, faint grid, neon snakes.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0E14);
  static const Color grid = Color(0x1AFFFFFF);
  static const Color border = Color(0xFF3A4556);
  static const Color text = Color(0xFFE6EDF3);

  // Snake A (left) cyan, snake B (right) orange — ADR-007 accepted colors.
  static const Color snakeA = Color(0xFF00BCD4);
  static const Color snakeAHead = Color(0xFF7FF3FF);
  static const Color snakeB = Color(0xFFFF8C1A);
  static const Color snakeBHead = Color(0xFFFFC27A);

  static const Color loss = Color(0xFFFF3B3B);
  static const Color joystick = Color(0x33FFFFFF);
  static const Color joystickKnob = Color(0x66FFFFFF);
}
