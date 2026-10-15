/// Local Memory Match pair rules. The widget owns flip delays; this owns the board.
class MemoryMatchLogic {
  MemoryMatchLogic(this.cards);

  final List<String> cards;
  final Set<int> open = <int>{};
  final Set<int> matched = <int>{};
  int moves = 0;
  bool busy = false;

  bool get complete => cards.isNotEmpty && matched.length == cards.length;
  bool get inProgress => !complete && (moves > 0 || open.isNotEmpty);

  /// Returns `ignore`, `flip`, `match`, `mismatch`, or `win`.
  String tap(int index) {
    if (busy || index < 0 || index >= cards.length) return 'ignore';
    if (matched.contains(index) || open.contains(index)) return 'ignore';
    open.add(index);
    if (open.length < 2) return 'flip';

    busy = true;
    moves++;
    final pair = open.toList();
    if (cards[pair[0]] != cards[pair[1]]) return 'mismatch';

    matched.addAll(pair);
    open.clear();
    busy = false;
    return complete ? 'win' : 'match';
  }

  void hideMismatch() {
    open.clear();
    busy = false;
  }
}
