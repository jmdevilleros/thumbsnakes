import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thumbsnakes/game/thumbsnakes_game.dart';
import 'package:thumbsnakes/utils/game_config.dart';

/// Substitutes device checkpoints (ADR-010): drives the Flame loop headless.
Future<ThumbsnakesGame> loaded() async {
  final g = ThumbsnakesGame();
  g.onGameResize(Vector2(1600, 800));
  await g.onLoad();
  return g;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'running snakes eventually hit the wall → dying → over, best saved',
    () async {
      final g = await loaded();
      var sawDying = false;
      for (var i = 0; i < 1200 && g.phase.value != GamePhase.over; i++) {
        g.update(1 / 60);
        if (g.phase.value == GamePhase.dying) sawDying = true;
        await Future<void>.delayed(Duration.zero);
      }
      expect(sawDying, isTrue);
      expect(g.phase.value, GamePhase.over);
      expect(g.state.losses, isNotEmpty);
      expect(g.score.elapsed > 0, isTrue);
      expect(g.highScores.best, g.score.elapsed);
      expect(g.lastWasNewBest, isTrue);
    },
  );

  test('pause freezes clock; resume runs countdown first', () async {
    final g = await loaded();
    g.update(0.2);
    g.pause();
    final t = g.score.elapsed;
    g.update(1);
    expect(g.score.elapsed, t);
    g.resume();
    expect(g.phase.value, GamePhase.countdown);
    for (var i = 0; i < 1000 && g.phase.value == GamePhase.countdown; i++) {
      g.update(1 / 60);
    }
    expect(g.score.elapsed, t);
    expect(GameConfig.resumeCountdownSec > 0, isTrue);
    expect(g.phase.value, GamePhase.running);
  });

  test('reset starts a fresh run', () async {
    final g = await loaded();
    g.update(1);
    g.reset();
    expect(g.score.elapsed, 0);
    expect(g.phase.value, GamePhase.running);
    expect(g.state.a.length, GameConfig.initialLength);
  });
}
