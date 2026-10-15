import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/hexa_ring_sort_logic.dart';

void main() {
  test('every advertised level has a legal solution', () {
    for (var difficulty = 0; difficulty < 3; difficulty++) {
      for (var level = 1; level <= 50; level++) {
        final generated = HexaLevel.generate(level, difficulty);
        final board = HexaRingBoard(
          generated.stacks.map((stack) => List<int>.from(stack)).toList(),
          generated.capacity,
        );
        expect(board.complete, isFalse, reason: 'level $level difficulty $difficulty started solved');
        expect(generated.solution, isNotEmpty);
        for (final step in generated.solution) {
          expect(board.move(step[0], step[1]), greaterThan(0), reason: 'level $level difficulty $difficulty move $step');
        }
        expect(board.complete, isTrue, reason: 'level $level difficulty $difficulty');
      }
    }
  });

  test('illegal moves, undo snapshots, and incomplete boards do not unlock', () {
    final generated = HexaLevel.generate(3, 0);
    final board = HexaRingBoard(
      generated.stacks.map((stack) => List<int>.from(stack)).toList(),
      generated.capacity,
    );
    final before = board.snapshot();
    expect(board.move(0, 0), 0);
    var illegal = 0;
    for (var from = 0; from < board.stacks.length; from++) {
      for (var to = 0; to < board.stacks.length; to++) {
        if (!board.canMove(from, to)) {
          illegal = board.move(from, to);
          expect(illegal, 0);
        }
      }
    }
    expect(board.snapshot(), before);
    final step = generated.solution.first;
    final moved = board.move(step[0], step[1]);
    expect(moved, greaterThan(0));
    final undone = HexaRingBoard(before, board.capacity);
    expect(undone.complete, isFalse);
    expect(HexaLevel.unlockedAfterClear(unlocked: 3, level: 3, complete: false), 3);
    expect(HexaLevel.unlockedAfterClear(unlocked: 3, level: 3, complete: true), 4);
    expect(HexaLevel.unlockedAfterClear(unlocked: 50, level: 50, complete: true), 50);
  });
}
