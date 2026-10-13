import 'package:flutter_test/flutter_test.dart';
import 'package:thumbsnakes/managers/game_rules.dart';
import 'package:thumbsnakes/models/board.dart';
import 'package:thumbsnakes/models/cell.dart';
import 'package:thumbsnakes/models/direction.dart';
import 'package:thumbsnakes/models/snake.dart';
import 'package:thumbsnakes/utils/game_config.dart';

Snake snake(SnakeId id, List<Cell> body, Direction d) =>
    Snake(id: id, body: body, direction: d);

GameState custom(Snake a, Snake b, {int cols = 10, int rows = 10}) =>
    GameState(Board(cols, rows), a, b);

void main() {
  group('initial state', () {
    test('A left quarter, B right quarter, heading up, default length', () {
      final s = GameRules.initialState();
      expect(s.a.length, GameConfig.initialLength);
      expect(s.b.length, GameConfig.initialLength);
      expect(s.a.direction, Direction.up);
      expect(s.a.head.x, lessThan(GameConfig.gridCols ~/ 2));
      expect(s.b.head.x, greaterThanOrEqualTo(GameConfig.gridCols ~/ 2));
      for (final c in [...s.a.body, ...s.b.body]) {
        expect(s.board.isInside(c), isTrue);
      }
      // body trails below the head
      expect(s.a.body[1], Cell(s.a.head.x, s.a.head.y + 1));
    });

    test('first tick does not collide and both move one cell', () {
      final s = GameRules.initialState();
      final ha = s.a.head, hb = s.b.head;
      GameRules.tick(s);
      expect(s.isOver, isFalse);
      expect(s.a.head, Cell(ha.x, ha.y - 1));
      expect(s.b.head, Cell(hb.x, hb.y - 1));
    });
  });

  group('turns', () {
    test('180° turn is ignored', () {
      final s = GameRules.initialState();
      s.a.requestTurn(Direction.down);
      final h = s.a.head;
      GameRules.tick(s);
      expect(s.a.head, Cell(h.x, h.y - 1));
    });

    test('valid turn applies next tick', () {
      final s = GameRules.initialState();
      s.a.requestTurn(Direction.left);
      final h = s.a.head;
      GameRules.tick(s);
      expect(s.a.head, Cell(h.x - 1, h.y));
      expect(s.a.direction, Direction.left);
    });

    test('buffer of 1 keeps the latest valid turn', () {
      final s = GameRules.initialState();
      s.a.requestTurn(Direction.left);
      s.a.requestTurn(Direction.right);
      s.a.requestTurn(Direction.down); // invalid vs up, ignored
      final h = s.a.head;
      GameRules.tick(s);
      expect(s.a.head, Cell(h.x + 1, h.y));
    });
  });

  group('losses', () {
    test('wall', () {
      final s = custom(
        snake(SnakeId.a, [const Cell(0, 5), const Cell(1, 5)], Direction.left),
        snake(SnakeId.b, [const Cell(8, 5), const Cell(8, 6)], Direction.up),
      );
      GameRules.tick(s);
      expect(s.isOver, isTrue);
      expect(s.losses.single.snake, SnakeId.a);
      expect(s.losses.single.cause, LossCause.wall);
    });

    test('self', () {
      // head at (2,2) moving down into its own body at (2,3)
      final a = snake(SnakeId.a, [
        const Cell(2, 2),
        const Cell(3, 2),
        const Cell(3, 3),
        const Cell(2, 3),
        const Cell(1, 3),
      ], Direction.left);
      a.requestTurn(Direction.down);
      final s = custom(
        a,
        snake(SnakeId.b, [const Cell(8, 5), const Cell(8, 6)], Direction.up),
      );
      GameRules.tick(s);
      expect(s.losses.single.cause, LossCause.self);
    });

    test('vacated tail cell is free', () {
      // square loop: head follows its tail
      final a = snake(SnakeId.a, [
        const Cell(2, 2),
        const Cell(3, 2),
        const Cell(3, 3),
        const Cell(2, 3),
      ], Direction.left);
      a.requestTurn(Direction.down);
      final s = custom(
        a,
        snake(SnakeId.b, [const Cell(8, 5), const Cell(8, 6)], Direction.up),
      );
      GameRules.tick(s);
      expect(s.isOver, isFalse);
    });

    test('other body', () {
      final s = custom(
        snake(SnakeId.a, [const Cell(4, 5), const Cell(3, 5)], Direction.right),
        snake(SnakeId.b, [
          const Cell(5, 3),
          const Cell(5, 4),
          const Cell(5, 5),
          const Cell(5, 6),
        ], Direction.up),
      );
      GameRules.tick(s);
      expect(s.losses.single.snake, SnakeId.a);
      expect(s.losses.single.cause, LossCause.other);
    });

    test('head to head on the same cell: both lose', () {
      final s = custom(
        snake(SnakeId.a, [const Cell(3, 5), const Cell(2, 5)], Direction.right),
        snake(SnakeId.b, [const Cell(5, 5), const Cell(6, 5)], Direction.left),
      );
      GameRules.tick(s);
      expect(s.losses.length, 2);
      expect(s.losses.every((l) => l.cause == LossCause.other), isTrue);
    });

    test('heads swapping cells counts as a crash', () {
      final s = custom(
        snake(SnakeId.a, [const Cell(4, 5), const Cell(3, 5)], Direction.right),
        snake(SnakeId.b, [const Cell(5, 5), const Cell(6, 5)], Direction.left),
      );
      GameRules.tick(s);
      expect(s.isOver, isTrue);
    });

    test('no further movement after game over', () {
      final s = custom(
        snake(SnakeId.a, [const Cell(0, 5), const Cell(1, 5)], Direction.left),
        snake(SnakeId.b, [const Cell(8, 5), const Cell(8, 6)], Direction.up),
      );
      GameRules.tick(s);
      final hb = s.b.head;
      GameRules.tick(s);
      expect(s.b.head, hb);
    });
  });
}
