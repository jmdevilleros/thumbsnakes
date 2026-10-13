import 'cell.dart';
import 'direction.dart';

enum SnakeId { a, b }

/// A snake: body (head first), heading, buffered turns and pending growth.
class Snake {
  Snake({
    required this.id,
    required List<Cell> body,
    required this.direction,
    this.bufferSize = 1,
  }) : body = List.of(body);

  final SnakeId id;
  final List<Cell> body;
  Direction direction;
  final int bufferSize;
  final List<Direction> _turns = [];
  int pendingGrowth = 0;

  Cell get head => body.first;
  int get length => body.length;

  /// Queues a turn (RF-003). Repeats and 180° turns relative to the previous
  /// heading are ignored. When the buffer is full the newest turn replaces
  /// the last queued one, so the latest valid request wins.
  void requestTurn(Direction d) {
    final full = _turns.length >= bufferSize;
    final keep = full ? _turns.length - 1 : _turns.length;
    final ref = keep == 0 ? direction : _turns[keep - 1];
    if (d == ref || d == ref.opposite) return;
    if (full) _turns.removeLast();
    _turns.add(d);
  }

  /// Applies the next buffered turn and returns the head cell for this tick.
  Cell nextHead() {
    if (_turns.isNotEmpty) direction = _turns.removeAt(0);
    return head.step(direction);
  }

  /// Moves to [newHead]; the tail stays when growth is pending.
  void advance(Cell newHead) {
    body.insert(0, newHead);
    if (pendingGrowth > 0) {
      pendingGrowth--;
    } else {
      body.removeLast();
    }
  }
}
