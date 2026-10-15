import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/connect_four_logic.dart';

bool _hasRun(ConnectFourLogic game, int player) {
  const directions = [(1, 0), (0, 1), (1, 1), (1, -1)];
  for (var row = 0; row < ConnectFourLogic.rows; row++) {
    for (var column = 0; column < ConnectFourLogic.columns; column++) {
      for (final (dc, dr) in directions) {
        var count = 0;
        var x = column;
        var y = row;
        while (x >= 0 && x < ConnectFourLogic.columns && y >= 0 && y < ConnectFourLogic.rows && game.at(x, y) == player) {
          count++;
          x += dc;
          y += dr;
        }
        if (count >= 4) return true;
      }
    }
  }
  return false;
}

void main() {
  group('Connect Four rules', () {
    test('drops to the lowest open cell and alternates players', () {
      final game = ConnectFourLogic(startingPlayer: 0);
      expect(game.drop(3), 5);
      expect(game.at(3, 5), 0);
      expect(game.turn, 1);
      expect(game.drop(3), 4);
      expect(game.at(3, 4), 1);
      expect(game.turn, 0);
    });

    test('rejects invalid and full columns', () {
      final game = ConnectFourLogic();
      expect(game.drop(-1), isNull);
      expect(game.drop(ConnectFourLogic.columns), isNull);
      for (var row = 0; row < ConnectFourLogic.rows; row++) {
        game.cells[row * ConnectFourLogic.columns] = row.isEven ? 0 : 1;
      }
      expect(game.drop(0), isNull);
    });

    test('detects a horizontal win and locks further moves', () {
      final game = ConnectFourLogic(startingPlayer: 0);
      for (final column in [0, 0, 1, 1, 2, 2, 3]) {
        game.drop(column);
      }
      expect(game.winner, 0);
      expect(game.finished, isTrue);
      expect(game.winCells.length, greaterThanOrEqualTo(4));
      expect(game.drop(4), isNull);
    });

    test('detects a vertical win', () {
      final game = ConnectFourLogic(startingPlayer: 0);
      for (final column in [0, 1, 0, 1, 0, 1, 0]) {
        game.drop(column);
      }
      expect(game.winner, 0);
      expect(game.winCells.length, greaterThanOrEqualTo(4));
    });

    test('detects a rising diagonal win', () {
      final game = ConnectFourLogic(startingPlayer: 0);
      for (final column in [0, 1, 1, 2, 2, 3, 2, 3, 6, 3, 3]) {
        game.drop(column);
      }
      expect(game.winner, 0);
      expect(game.winCells.length, greaterThanOrEqualTo(4));
    });

    test('detects a falling diagonal win', () {
      final game = ConnectFourLogic(startingPlayer: 0);
      for (final column in [6, 5, 5, 4, 4, 3, 4, 3, 0, 3, 3]) {
        game.drop(column);
      }
      expect(game.winner, 0);
      expect(game.winCells.length, greaterThanOrEqualTo(4));
    });

    test('a full board without four in a row is a draw and rejects input', () {
      final game = ConnectFourLogic(startingPlayer: 0);
      const rowsFromTop = [
        [1, 1, 1, 0, 1, 1, 1],
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 1, 0, 1, 1, 1],
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 1, 0, 1, 1, 1],
        [0, 0, 0, 1, 0, 0, 0],
      ];
      for (var row = 0; row < ConnectFourLogic.rows; row++) {
        for (var column = 0; column < ConnectFourLogic.columns; column++) {
          game.cells[row * ConnectFourLogic.columns + column] = rowsFromTop[row][column];
        }
      }
      game.moves = game.cells.length;
      expect(_hasRun(game, 0), isFalse);
      expect(_hasRun(game, 1), isFalse);
      expect(game.isDraw, isTrue);
      expect(game.finished, isTrue);
      expect(game.drop(0), isNull);
      expect(game.winner, isNull);
    });

    test('reset clears the board and win state', () {
      final game = ConnectFourLogic(startingPlayer: 0);
      for (final column in [0, 0, 1, 1, 2, 2, 3]) {
        game.drop(column);
      }
      game.reset(startingPlayer: 1);
      expect(game.winner, isNull);
      expect(game.winCells, isEmpty);
      expect(game.moves, 0);
      expect(game.turn, 1);
      expect(game.cells.every((cell) => cell == -1), isTrue);
    });
  });
}
