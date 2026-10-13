import '../utils/game_config.dart';

/// Time-based difficulty (RF-005, RF-006). Pure functions of play time.
class Difficulty {
  Difficulty._();

  static double speedAt(
    double t, {
    double start = GameConfig.startSpeed,
    double increment = GameConfig.speedIncrement,
    double interval = GameConfig.speedIntervalSec,
    double max = GameConfig.maxSpeed,
  }) {
    final v = start + (t / interval).floor() * increment;
    return v > max ? max : v;
  }

  /// Number of growth events that should have happened by time [t].
  static int growthsDue(
    double t, {
    double interval = GameConfig.growthIntervalSec,
  }) => (t / interval).floor();
}
