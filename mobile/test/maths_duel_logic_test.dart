import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/maths_duel_logic.dart';

void main() {
  test('first correct answer scores and locks the question', () {
    final game = MathsDuelLogic();
    final correct = game.answer;
    final wrong = game.options.firstWhere((value) => value != correct);
    expect(game.choose(0, wrong), 'wrong');
    expect(game.locked, {0});
    expect(game.choose(0, correct), 'ignored');
    expect(game.choose(1, correct), 'correct');
    expect(game.scores, [0, 1]);
    expect(game.between, isTrue);
    expect(game.choose(0, correct), 'ignored');
    expect(game.choose(1, wrong), 'ignored');
  });

  test('two wrong answers reveal the miss and advance', () {
    final game = MathsDuelLogic();
    final wrong = game.options.where((value) => value != game.answer).toList();
    expect(game.choose(0, wrong[0]), 'wrong');
    expect(game.between, isFalse);
    expect(game.choose(1, wrong[1]), 'wrong');
    expect(game.between, isTrue);
    expect(game.scores, [0, 0]);
    expect(game.advance(), isTrue);
    expect(game.questionNo, 1);
    expect(game.locked, isEmpty);
    expect(game.between, isFalse);
  });

  test('first player to seven wins and does not advance', () {
    final game = MathsDuelLogic();
    for (var point = 0; point < 7; point++) {
      expect(game.finished, isFalse);
      expect(game.choose(0, game.answer), 'correct');
      if (point < 6) {
        expect(game.advance(), isTrue);
      }
    }
    expect(game.scores[0], 7);
    expect(game.finished, isTrue);
    expect(game.advance(), isFalse);
    expect(game.choose(1, game.answer), 'ignored');
  });

  test('restart clears a finished match', () {
    final game = MathsDuelLogic();
    for (var point = 0; point < 7; point++) {
      game.choose(1, game.answer);
      game.advance();
    }
    game.restart();
    expect(game.finished, isFalse);
    expect(game.scores, [0, 0]);
    expect(game.questionNo, 0);
    expect(game.options, contains(game.answer));
    expect(game.options.toSet(), hasLength(4));
  });
}
