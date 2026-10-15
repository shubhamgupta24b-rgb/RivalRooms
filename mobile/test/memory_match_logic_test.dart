import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/memory_match_logic.dart';

void main() {
  test('matching pair scores once and a later pair still resolves', () {
    final game = MemoryMatchLogic(['A', 'B', 'A', 'B']);
    expect(game.tap(0), 'flip');
    expect(game.tap(2), 'match');
    expect(game.moves, 1);
    expect(game.matched, {0, 2});
    expect(game.open, isEmpty);
    expect(game.complete, isFalse);

    expect(game.tap(1), 'flip');
    expect(game.tap(3), 'win');
    expect(game.moves, 2);
    expect(game.complete, isTrue);
    expect(game.tap(1), 'ignore');
  });

  test('a mismatch locks the board until it is hidden', () {
    final game = MemoryMatchLogic(['A', 'B', 'A', 'B']);
    expect(game.tap(0), 'flip');
    expect(game.tap(1), 'mismatch');
    expect(game.busy, isTrue);
    expect(game.moves, 1);
    expect(game.tap(2), 'ignore');
    game.hideMismatch();
    expect(game.open, isEmpty);
    expect(game.busy, isFalse);
    expect(game.tap(2), 'flip');
  });

  test('odd or duplicate indexes cannot finish the board early', () {
    final game = MemoryMatchLogic(['A', 'A']);
    expect(game.tap(0), 'flip');
    expect(game.tap(0), 'ignore');
    expect(game.tap(5), 'ignore');
    expect(game.complete, isFalse);
  });
}
