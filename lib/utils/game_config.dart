import '../models/direction.dart';

/// All tunable gameplay constants (spec §5). No magic numbers elsewhere.
class GameConfig {
  GameConfig._();

  // Board (RF-001)
  static const int gridCols = 32; // 20–48
  static const int gridRows = 18; // 12–27

  // Snakes (RF-002)
  static const int initialLength = 4; // 2–10
  static const Direction initialDirection = Direction.up;

  // Speed in ticks per second (RF-006)
  static const double startSpeed = 4.0; // 2.0–10.0
  static const double speedIncrement = 0.5; // 0.1–2.0
  static const double speedIntervalSec = 15; // 5–60
  static const double maxSpeed = 12.0; // 6.0–20.0

  // Growth (RF-005)
  static const double growthIntervalSec = 10; // 3–60
  static const int growthAmount = 1; // 1–3

  // Controls (RF-003, ADR-007)
  static const double joystickDeadZone = 0.25; // 0.1–0.5 (fraction of radius)
  static const double joystickRadius = 60; // 40–100 dp
  static const int inputBufferSize = 1; // 1–2

  // Screens (RF-010, RF-011)
  static const double resumeCountdownSec = 3; // 0–5 (0 = none)
  static const double gameOverInputDelaySec = 0.5; // 0–2

  // Layout / feedback (implementation constants, ADR-010)
  static const double hudHeight = 44; // dp reserved above the board
  static const double lossHighlightSec = 0.8; // highlight before Game Over
  static const double joystickMargin = 24; // dp from screen corner
  static const double hudRefreshSec = 0.1; // ≥10 updates/s (RF-008)
}
