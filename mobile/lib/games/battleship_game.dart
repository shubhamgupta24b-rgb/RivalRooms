import 'dart:math';
import 'package:flutter/material.dart';

class BattleshipGame extends StatefulWidget {
  const BattleshipGame({super.key});
  @override State<BattleshipGame> createState() => _BattleshipGameState();
}

class _Fleet {
  _Fleet(this.cells);
  final List<int> cells;
  final Set<int> hits = {};
  bool get sunk => hits.length == cells.length;
}

class _BattleshipGameState extends State<BattleshipGame> {
  static const int _n = 8;
  static const List<int> _shipSizes = [4, 3, 3, 2, 2];
  final Random _rng = Random();
  late List<List<int>> _boards;
  late List<List<int>> _shots;
  late List<List<_Fleet>> _fleets;
  int _player = 0;
  int _startingPlayer = 0;
  bool _handoff = true;
  bool _finished = false;
  String _lastMessage = 'A random player starts this round.';

  @override
  void initState() { super.initState(); _newGame(); }

  List<_Fleet> _makeFleet() {
    final occupied = <int>{};
    final fleet = <_Fleet>[];
    for (final length in _shipSizes) {
      List<int> cells = [];
      var placed = false;
      for (var attempt = 0; attempt < 500 && !placed; attempt++) {
        final horizontal = _rng.nextBool();
        final row = _rng.nextInt(_n);
        final col = _rng.nextInt(_n);
        if (horizontal ? col + length > _n : row + length > _n) continue;
        cells = List.generate(length, (i) => horizontal ? row * _n + col + i : (row + i) * _n + col);
        if (cells.any(occupied.contains)) continue;
        occupied.addAll(cells);
        fleet.add(_Fleet(cells));
        placed = true;
      }
      if (!placed) return _makeFleet();
    }
    return fleet;
  }

  void _newGame() {
    _fleets = [_makeFleet(), _makeFleet()];
    _boards = List.generate(2, (p) {
      final b = List<int>.filled(_n * _n, 0);
      for (var s = 0; s < _fleets[p].length; s++) {
        for (final cell in _fleets[p][s].cells) b[cell] = s + 1;
      }
      return b;
    });
    _shots = [List<int>.filled(_n * _n, 0), List<int>.filled(_n * _n, 0)];
    _startingPlayer = _rng.nextInt(2);
    _player = _startingPlayer;
    _handoff = true;
    _finished = false;
    _lastMessage = 'Random draw: Player ${_player + 1} starts.';
    setState(() {});
  }

  void _revealTurn() { setState(() => _handoff = false); }

  void _fire(int cell) {
    if (_handoff || _finished || _shots[_player][cell] != 0) return;
    final opponent = 1 - _player;
    final ship = _boards[opponent][cell];
    setState(() {
      _shots[_player][cell] = ship == 0 ? 1 : 2;
      if (ship == 0) {
        _lastMessage = 'Player ${_player + 1}: splash — miss.';
      } else {
        final fleet = _fleets[opponent][ship - 1];
        fleet.hits.add(cell);
        _lastMessage = fleet.sunk
            ? 'Player ${_player + 1} sank a ship!'
            : 'Player ${_player + 1} scored a hit!';
      }
      final allSunk = _fleets[opponent].every((s) => s.sunk);
      if (allSunk) {
        _finished = true;
        _handoff = false;
        _lastMessage = 'Player ${_player + 1} wins the fleet battle!';
      } else {
        _player = opponent;
        _handoff = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F3EC),
    appBar: AppBar(
      title: const Text('Battleship', style: TextStyle(fontWeight: FontWeight.w900)),
      leading: IconButton(tooltip: 'Back', onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_rounded)),
      actions: [IconButton(tooltip: 'New game', onPressed: _newGame, icon: const Icon(Icons.refresh_rounded))],
    ),
    body: SafeArea(
      child: _handoff ? _handoffScreen() : _battleScreen(),
    ),
  );

  Widget _handoffScreen() => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 104, height: 104,
          decoration: BoxDecoration(color: const Color(0xFFC9DFE1), borderRadius: BorderRadius.circular(28)),
          child: const Center(child: Icon(Icons.visibility_off_rounded, size: 52, color: Color(0xFF285D65))),
        ),
        const SizedBox(height: 24),
        Text('Pass to Player ${_player + 1}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        const Text('Fleet positions stay hidden. Hand over the device before revealing the next turn.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF777A70), height: 1.4)),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _revealTurn,
          icon: const Icon(Icons.visibility_rounded),
          label: const Text('Reveal my turn'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ]),
    ),
  );

  Widget _battleScreen() {
    final target = 1 - _player;
    final hitCount = _shots[_player].where((s) => s == 2).length;
    final missCount = _shots[_player].where((s) => s == 1).length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Expanded(child: _score('PLAYER 1', _shots[0].where((s) => s == 2).length, _player == 0)),
          const SizedBox(width: 8),
          Expanded(child: _score('PLAYER 2', _shots[1].where((s) => s == 2).length, _player == 1)),
        ]),
        const SizedBox(height: 18),
        Text(_finished ? 'Fleet destroyed' : 'Player ${_player + 1} • Target grid', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(_finished ? _lastMessage : 'Tap a square to fire at the hidden fleet.', style: const TextStyle(color: Color(0xFF777A70), fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 14),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: const Color(0xFF285D65), borderRadius: BorderRadius.circular(18)),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _n * _n,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _n, crossAxisSpacing: 3, mainAxisSpacing: 3),
                  itemBuilder: (_, cell) {
                    final shot = _shots[_player][cell];
                    return Semantics(
                      button: true,
                      label: 'Target row ${cell ~/ _n + 1} column ${cell % _n + 1}',
                      child: InkWell(
                        onTap: shot == 0 && !_finished ? () => _fire(cell) : null,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: shot == 2 ? const Color(0xFFE4775D) : shot == 1 ? const Color(0xFFB9D3D2) : const Color(0xFFEAF0E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(child: Text(shot == 2 ? '✕' : shot == 1 ? '•' : '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: shot == 2 ? Colors.white : const Color(0xFF285D65)))),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Text('Hits $hitCount  •  Misses $missCount', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
          if (_finished) FilledButton(onPressed: _newGame, child: const Text('Rematch')),
        ]),
        if (!_finished) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Opponent fleet remains hidden • Player ${target + 1} is your target', style: const TextStyle(fontSize: 10, color: Color(0xFF777A70)))),
      ]),
    );
  }

  Widget _score(String label, int hits, bool active) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: active ? const Color(0xFFC9DFE1) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: active ? const Color(0xFF285D65) : Colors.transparent, width: 2)),
    child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),), Text('$hits hits', style: const TextStyle(fontWeight: FontWeight.w900))]),
  );
}
