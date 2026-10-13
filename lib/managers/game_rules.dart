import '../models/board.dart';
import '../models/cell.dart';
import '../models/direction.dart';
import '../models/snake.dart';
import '../utils/game_config.dart';

enum LossCause { wall, self, other }

class Loss {
  const Loss(this.snake, this.cause, this.cell);
  final SnakeId snake;
  final LossCause cause;
  final Cell cell;
}

/// Full logical state of a run. Pure: no Flame / Flutter.
class GameState {
  GameState(this.board, this.a, this.b);
  final Board board;
  final Snake a;
  final Snake b;
  List<Loss> losses = const [];
  bool get isOver => losses.isNotEmpty;

  Snake snake(SnakeId id) => id == SnakeId.a ? a : b;
}

class GameRules {
  GameRules._();

  /// RF-002: A in the left quarter, B in the right quarter, both heading
  /// [direction], body trailing behind the head, centered vertically.
  static GameState initialState({
    int cols = GameConfig.gridCols,
    int rows = GameConfig.gridRows,
    int length = GameConfig.initialLength,
    Direction direction = GameConfig.initialDirection,
    int bufferSize = GameConfig.inputBufferSize,
  }) {
    Snake make(SnakeId id, int x) {
      final head = Cell(
        x - direction.dx * (length ~/ 2),
        rows ~/ 2 - direction.dy * (length ~/ 2),
      );
      final back = direction.opposite;
      final body = [
        for (var i = 0; i < length; i++)
          Cell(head.x + back.dx * i, head.y + back.dy * i),
      ];
      return Snake(
        id: id,
        body: body,
        direction: direction,
        bufferSize: bufferSize,
      );
    }

    return GameState(
      Board(cols, rows),
      make(SnakeId.a, cols ~/ 4),
      make(SnakeId.b, cols - 1 - cols ~/ 4),
    );
  }

  /// Adds growth to both snakes (RF-005).
  static void grow(GameState s, int amount) {
    s.a.pendingGrowth += amount;
    s.b.pendingGrowth += amount;
  }

  /// One simultaneous tick (RF-002, RF-004). Both new heads are computed
  /// first, both snakes move, then collisions are evaluated on the result
  /// (a tail cell vacated this tick is therefore free).
  static void tick(GameState s) {
    if (s.isOver) return;
    final headA = s.a.nextHead();
    final headB = s.b.nextHead();
    s.a.advance(headA);
    s.b.advance(headB);

    final losses = <Loss>[];
    void check(Snake me, Snake other) {
      final h = me.head;
      if (!s.board.isInside(h)) {
        losses.add(Loss(me.id, LossCause.wall, h));
      } else if (me.body.skip(1).contains(h)) {
        losses.add(Loss(me.id, LossCause.self, h));
      } else if (other.body.contains(h)) {
        losses.add(Loss(me.id, LossCause.other, h));
      }
    }

    check(s.a, s.b);
    check(s.b, s.a);
    s.losses = losses;
  }
}
