import 'dart:math';

/// Deterministic local two-player Connect Four rules.
/// Row zero is the top of the board; moves fall to the lowest empty cell.
class ConnectFourLogic {
  static const columns = 7;
  static const rows = 6;
  final List<int> cells = List<int>.filled(columns * rows, -1);
  int turn;
  int? winner;
  List<int> winCells = const [];
  int moves = 0;

  ConnectFourLogic({int startingPlayer = 0}) : turn = startingPlayer;
  int at(int column, int row) => cells[row * columns + column];
  bool get isDraw => winner == null && moves == cells.length;
  bool get finished => winner != null || isDraw;

  /// Returns the landing row, or null when the move is invalid.
  int? drop(int column) {
    if (finished || column < 0 || column >= columns) return null;
    for (var row = rows - 1; row >= 0; row--) {
      final index = row * columns + column;
      if (cells[index] != -1) continue;
      cells[index] = turn;
      moves++;
      _checkWin(column, row);
      if (!finished) turn = 1 - turn;
      return row;
    }
    return null;
  }

  void _checkWin(int column, int row) {
    for (final (dc, dr) in const [(1, 0), (0, 1), (1, 1), (1, -1)]) {
      final line = <int>[row * columns + column];
      for (final sign in const [1, -1]) {
        var x = column + dc * sign, y = row + dr * sign;
        while (x >= 0 && x < columns && y >= 0 && y < rows && at(x, y) == turn) {
          line.add(y * columns + x);
          x += dc * sign;
          y += dr * sign;
        }
      }
      if (line.length >= 4) {
        winner = turn;
        winCells = line;
        return;
      }
    }
  }

  void reset({int? startingPlayer}) {
    cells.fillRange(0, cells.length, -1);
    turn = startingPlayer ?? Random().nextInt(2);
    winner = null;
    winCells = const [];
    moves = 0;
  }
}
