import 'direction.dart';

/// Immutable grid coordinate.
class Cell {
  const Cell(this.x, this.y);
  final int x;
  final int y;

  Cell step(Direction d) => Cell(x + d.dx, y + d.dy);

  @override
  bool operator ==(Object other) =>
      other is Cell && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x,$y)';
}
