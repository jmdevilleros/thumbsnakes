import 'cell.dart';

/// Rectangular board with perimeter walls (RF-001).
class Board {
  const Board(this.cols, this.rows);
  final int cols;
  final int rows;

  bool isInside(Cell c) => c.x >= 0 && c.y >= 0 && c.x < cols && c.y < rows;
}
