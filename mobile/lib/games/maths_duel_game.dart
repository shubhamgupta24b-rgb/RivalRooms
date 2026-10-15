import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standalone port of Two-player-online's MathDuelLogic rules.
class MathsDuelGame extends StatefulWidget {
  const MathsDuelGame({super.key});
  @override
  State<MathsDuelGame> createState() => _MathsDuelGameState();
}

class _MathsDuelGameState extends State<MathsDuelGame> {
  final _rng = Random();
  final _scores = [0, 0];
  final _locked = <int>{};
  Timer? _advanceTimer;
  int _questionNo = 0;
  int? _solvedBy;
  bool _between = false;
  late String _question;
  late int _answer;
  late List<int> _options;

  bool get _finished => _scores.any((score) => score >= 7);

  @override
  void initState() {
    super.initState();
    _makeQuestion();
  }

  void _makeQuestion() {
    final level = _questionNo ~/ 3;
    final op = _rng.nextInt(level < 3 ? 2 : 3);
    late int a, b;
    late String symbol;
    if (op == 0) {
      a = 2 + _rng.nextInt(20 + level * 5);
      b = 2 + _rng.nextInt(20 + level * 5);
      _answer = a + b;
      symbol = '+';
    } else if (op == 1) {
      a = 10 + _rng.nextInt(30 + level * 5);
      b = 1 + _rng.nextInt(a - 1);
      _answer = a - b;
      symbol = '−';
    } else {
      a = 2 + _rng.nextInt(10);
      b = 2 + _rng.nextInt(10);
      _answer = a * b;
      symbol = '×';
    }
    _question = '$a $symbol $b = ?';
    final values = <int>{_answer};
    while (values.length < 4) {
      final delta = 1 + _rng.nextInt(10);
      final wrong = _rng.nextBool() ? _answer + delta : _answer - delta;
      if (wrong >= 0) values.add(wrong);
    }
    _options = values.toList()..shuffle(_rng);
    _locked.clear();
    _solvedBy = null;
    _between = false;
  }

  void _choose(int player, int value) {
    if (_finished || _between || _locked.contains(player)) return;
    setState(() {
      if (value == _answer) {
        _scores[player]++;
        _solvedBy = player;
        _between = true;
        HapticFeedback.lightImpact();
      } else {
        _locked.add(player);
        HapticFeedback.heavyImpact();
        if (_locked.length == 2) _between = true;
      }
    });
    if (_between && !_finished) {
      _advanceTimer?.cancel();
      _advanceTimer = Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _questionNo++;
          _makeQuestion();
        });
      });
    }
  }

  void _restart() {
    _advanceTimer?.cancel();
    setState(() {
      _scores.setAll(0, [0, 0]);
      _questionNo = 0;
      _makeQuestion();
    });
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = _scores[0] >= 7 ? 1 : 2;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Math Duel'),
        actions: [
          IconButton(tooltip: 'Restart', onPressed: _restart, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: SafeArea(
        child: _finished
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('FIRST TO 7'),
                  const SizedBox(height: 12),
                  Text('Player $winner wins!', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text('Player 1: ${_scores[0]}   •   Player 2: ${_scores[1]}'),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: _restart, child: const Text('Play again')),
                ]),
              )
            : Column(children: [
                Expanded(child: RotatedBox(quarterTurns: 2, child: _playerZone(1))),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('P2  ${_scores[1]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('FIRST TO 7  •  Q${_questionNo + 1}', style: const TextStyle(fontSize: 12)),
                    Text('${_scores[0]}  P1', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
                Expanded(child: _playerZone(0)),
              ]),
      ),
    );
  }

  Widget _playerZone(int player) {
    final locked = _locked.contains(player);
    final status = _solvedBy == player
        ? 'Correct! +1'
        : _solvedBy != null
            ? 'Too slow! Answer: $_answer'
            : locked
                ? (_between ? 'Nobody got it! Answer: $_answer' : 'Wrong! Wait for the next question')
                : 'Tap the correct answer first';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: player == 0 ? const Color(0xFFF3E6D6) : const Color(0xFFE0E9DE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Row(children: [
          Text('PLAYER ${player + 1}', style: const TextStyle(fontWeight: FontWeight.w900)),
          const Spacer(),
          Text('${_scores[player]} / 7', style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        const Spacer(),
        FittedBox(
          child: Text(_question, style: const TextStyle(fontSize: 37, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 6),
        Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        const Spacer(),
        Row(children: [
          for (final option in _options)
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: SizedBox(
                height: 55,
                child: FilledButton(
                  onPressed: locked || _between ? null : () => _choose(player, option),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: _between && option == _answer
                        ? const Color(0xFF476B4B)
                        : const Color(0xFF344C45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: FittedBox(child: Text('$option', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                ),
              ),
            )),
        ]),
      ]),
    );
  }
}
