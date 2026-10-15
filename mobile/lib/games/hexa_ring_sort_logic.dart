import 'dart:math';

/// Ring-sort board. A stack is solved only when it is full and one colour.
class HexaRingBoard {
  HexaRingBoard(this.stacks, this.capacity);

  final List<List<int>> stacks;
  final int capacity;

  static bool solvedStack(List<int> stack, int capacity) =>
      stack.length == capacity && stack.isNotEmpty && stack.every((value) => value == stack.first);

  bool get complete => stacks.every((stack) => stack.isEmpty || solvedStack(stack, capacity));

  int topRun(int index) {
    final stack = stacks[index];
    if (stack.isEmpty) return 0;
    final color = stack.last;
    var count = 0;
    for (var i = stack.length - 1; i >= 0 && stack[i] == color; i--) {
      count++;
    }
    return count;
  }

  bool canMove(int from, int to) {
    if (from == to || from < 0 || to < 0 || from >= stacks.length || to >= stacks.length) return false;
    final source = stacks[from];
    final target = stacks[to];
    if (source.isEmpty || target.length >= capacity) return false;
    if (solvedStack(source, capacity) || solvedStack(target, capacity)) return false;
    if (target.isNotEmpty && target.last != source.last) return false;
    return true;
  }

  /// Pours the whole top colour group. Returns how many rings moved.
  int move(int from, int to) {
    if (!canMove(from, to)) return 0;
    final color = stacks[from].last;
    var moved = 0;
    while (stacks[from].isNotEmpty && stacks[from].last == color && stacks[to].length < capacity) {
      stacks[to].add(stacks[from].removeLast());
      moved++;
    }
    return moved;
  }

  List<List<int>> snapshot() => [for (final stack in stacks) List<int>.from(stack)];
}

class HexaLevel {
  HexaLevel({required this.stacks, required this.capacity, required this.solution});

  final List<List<int>> stacks;
  final int capacity;
  final List<List<int>> solution;

  static int capacityFor(int level, int difficulty) =>
      difficulty == 0 || (difficulty == 1 && level < 12) ? 3 : 4;

  static int colorsFor(int level, int difficulty) => min(7, 4 + level ~/ 12 + difficulty);

  /// Builds a level by reversing legal pours, so the stored solution is playable.
  static HexaLevel generate(int level, int difficulty, {Random? random}) {
    final rng = random ?? Random(level * 131 + difficulty * 29 + 999);
    final capacity = capacityFor(level.clamp(1, 50), difficulty.clamp(0, 2));
    final colors = colorsFor(level.clamp(1, 50), difficulty.clamp(0, 2));
    final board = HexaRingBoard([
      for (var color = 0; color < colors; color++) List<int>.filled(capacity, color, growable: true),
      <int>[],
      <int>[],
    ], capacity);
    final backward = <List<int>>[];
    final steps = 14 + level + difficulty * 10;
    List<int>? previous;
    for (var n = 0; n < steps; n++) {
      final blocked = previous;
      final options = _backwardMoves(board).where((move) {
        if (blocked == null) return true;
        return !(move[0] == blocked[1] && move[1] == blocked[0] && move[2] == blocked[2]);
      }).toList();
      if (options.isEmpty) break;
      final move = options[rng.nextInt(options.length)];
      _applyBackward(board, move);
      backward.add(move);
      previous = move;
    }
    return HexaLevel(
      stacks: board.snapshot(),
      capacity: capacity,
      solution: [for (final move in backward.reversed) [move[1], move[0]]],
    );
  }

  static int unlockedAfterClear({required int unlocked, required int level, required bool complete}) {
    if (!complete) return unlocked;
    return max(unlocked, min(50, level + 1));
  }
}

List<List<int>> _backwardMoves(HexaRingBoard board) {
  final moves = <List<int>>[];
  for (var from = 0; from < board.stacks.length; from++) {
    final stack = board.stacks[from];
    if (stack.isEmpty) continue;
    final color = stack.last;
    final run = board.topRun(from);
    final pure = stack.every((value) => value == color);
    final maxCount = pure ? run : run - 1;
    if (maxCount < 1) continue;
    for (var to = 0; to < board.stacks.length; to++) {
      if (to == from) continue;
      final destination = board.stacks[to];
      if (destination.isNotEmpty && destination.last == color) continue;
      final room = board.capacity - destination.length;
      final upper = min(maxCount, room);
      for (var count = 1; count <= upper; count++) {
        final nextLength = destination.length + count;
        final uniform = destination.isEmpty || destination.every((value) => value == color);
        if (nextLength == board.capacity && uniform) continue;
        moves.add([from, to, count]);
      }
    }
  }
  return moves;
}

void _applyBackward(HexaRingBoard board, List<int> move) {
  final color = board.stacks[move[0]].last;
  for (var i = 0; i < move[2]; i++) {
    board.stacks[move[0]].removeLast();
    board.stacks[move[1]].add(color);
  }
}
