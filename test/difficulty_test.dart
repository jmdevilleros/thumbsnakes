import 'package:flutter_test/flutter_test.dart';
import 'package:thumbsnakes/managers/difficulty.dart';
import 'package:thumbsnakes/managers/game_rules.dart';
import 'package:thumbsnakes/utils/game_config.dart';

void main() {
  test('speed steps and caps', () {
    expect(Difficulty.speedAt(0), GameConfig.startSpeed);
    expect(
      Difficulty.speedAt(GameConfig.speedIntervalSec - 0.01),
      GameConfig.startSpeed,
    );
    expect(
      Difficulty.speedAt(GameConfig.speedIntervalSec),
      GameConfig.startSpeed + GameConfig.speedIncrement,
    );
    expect(Difficulty.speedAt(100000), GameConfig.maxSpeed);
  });

  test('growths due', () {
    expect(Difficulty.growthsDue(0), 0);
    expect(Difficulty.growthsDue(GameConfig.growthIntervalSec), 1);
    expect(Difficulty.growthsDue(GameConfig.growthIntervalSec * 3.5), 3);
  });

  test('after one growth interval each snake is initialLength + amount', () {
    final s = GameRules.initialState();
    GameRules.grow(s, GameConfig.growthAmount * Difficulty.growthsDue(10));
    GameRules.tick(s);
    expect(s.a.length, GameConfig.initialLength + GameConfig.growthAmount);
    expect(s.b.length, GameConfig.initialLength + GameConfig.growthAmount);
  });
}
