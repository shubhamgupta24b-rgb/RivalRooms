import 'dart:math';

/// Local two-player Maths Duel. First correct answer scores, a wrong answer
/// locks that player out of the current question, and seven points wins.
class MathsDuelLogic {
  MathsDuelLogic({Random? random}) : _rng = random ?? Random() {
    makeQuestion();
  }

  final Random _rng;
  final List<int> scores = [0, 0];
  final Set<int> locked = <int>{};
  int questionNo = 0;
  int? solvedBy;
  bool between = false;
  late String question;
  late int answer;
  late List<int> options;

  bool get finished => scores.any((score) => score >= 7);
  bool get inProgress => !finished && (questionNo > 0 || scores.any((score) => score > 0) || locked.isNotEmpty || between);

  void makeQuestion() {
    final level = questionNo ~/ 3;
    final op = _rng.nextInt(level < 3 ? 2 : 3);
    late int a;
    late int b;
    late String symbol;
    if (op == 0) {
      a = 2 + _rng.nextInt(20 + level * 5);
      b = 2 + _rng.nextInt(20 + level * 5);
      answer = a + b;
      symbol = '+';
    } else if (op == 1) {
      a = 10 + _rng.nextInt(30 + level * 5);
      b = 1 + _rng.nextInt(a - 1);
      answer = a - b;
      symbol = '−';
    } else {
      a = 2 + _rng.nextInt(10);
      b = 2 + _rng.nextInt(10);
      answer = a * b;
      symbol = '×';
    }
    question = '$a $symbol $b = ?';
    final values = <int>{answer};
    while (values.length < 4) {
      final delta = 1 + _rng.nextInt(10);
      final wrong = _rng.nextBool() ? answer + delta : answer - delta;
      if (wrong >= 0) values.add(wrong);
    }
    options = values.toList()..shuffle(_rng);
    locked.clear();
    solvedBy = null;
    between = false;
  }

  /// Returns `correct`, `wrong`, or `ignored`.
  String choose(int player, int value) {
    if (finished || between || player < 0 || player > 1 || locked.contains(player)) return 'ignored';
    if (!options.contains(value)) return 'ignored';
    if (value == answer) {
      scores[player]++;
      solvedBy = player;
      between = true;
      return 'correct';
    }
    locked.add(player);
    if (locked.length == 2) between = true;
    return 'wrong';
  }

  /// Moves to the next question after a solved or fully missed round.
  bool advance() {
    if (!between || finished) return false;
    questionNo++;
    makeQuestion();
    return true;
  }

  void restart() {
    scores.setAll(0, [0, 0]);
    questionNo = 0;
    makeQuestion();
  }
}
