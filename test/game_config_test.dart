import 'package:flutter_test/flutter_test.dart';
import 'package:thumbsnakes/models/direction.dart';
import 'package:thumbsnakes/utils/app_strings.dart';
import 'package:thumbsnakes/utils/game_config.dart';

void inRange(num v, num lo, num hi) =>
    expect(v >= lo && v <= hi, isTrue, reason: '$v not in [$lo, $hi]');

void main() {
  test('defaults match spec §5 and lie within ranges', () {
    expect(GameConfig.gridCols, 32);
    expect(GameConfig.gridRows, 18);
    expect(GameConfig.initialDirection, Direction.up);
    inRange(GameConfig.gridCols, 20, 48);
    inRange(GameConfig.gridRows, 12, 27);
    inRange(GameConfig.initialLength, 2, 10);
    inRange(GameConfig.startSpeed, 2.0, 10.0);
    inRange(GameConfig.speedIncrement, 0.1, 2.0);
    inRange(GameConfig.speedIntervalSec, 5, 60);
    inRange(GameConfig.maxSpeed, 6.0, 20.0);
    inRange(GameConfig.growthIntervalSec, 3, 60);
    inRange(GameConfig.growthAmount, 1, 3);
    inRange(GameConfig.joystickDeadZone, 0.1, 0.5);
    inRange(GameConfig.joystickRadius, 40, 100);
    inRange(GameConfig.inputBufferSize, 1, 2);
    inRange(GameConfig.resumeCountdownSec, 0, 5);
    inRange(GameConfig.gameOverInputDelaySec, 0, 2);
    expect(GameConfig.startSpeed <= GameConfig.maxSpeed, isTrue);
  });

  test('seconds formatting', () {
    expect(AppStrings.seconds(42.34), '42.3s');
    expect(AppStrings.seconds(0), '0.0s');
  });
}
