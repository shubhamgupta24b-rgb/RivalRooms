import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../leave_game.dart';
import 'maths_duel_logic.dart';

/// Standalone port of Two-player-online's MathDuelLogic rules.
class MathsDuelGame extends StatefulWidget {
  const MathsDuelGame({super.key});
  @override
  State<MathsDuelGame> createState() => _MathsDuelGameState();
}

class _MathsDuelGameState extends State<MathsDuelGame> {
  final _logic = MathsDuelLogic();
  Timer? _advanceTimer;

  List<int> get _scores => _logic.scores;
  Set<int> get _locked => _logic.locked;
  int get _questionNo => _logic.questionNo;
  int? get _solvedBy => _logic.solvedBy;
  bool get _between => _logic.between;
  String get _question => _logic.question;
  int get _answer => _logic.answer;
  List<int> get _options => _logic.options;
  bool get _finished => _logic.finished;

  void _choose(int player, int value) {
    final result = _logic.choose(player, value);
    if (result == 'ignored') return;
    setState(() {});
    if (result == 'correct') {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    if (_between && !_finished) {
      _advanceTimer?.cancel();
      _advanceTimer = Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() => _logic.advance());
      });
    }
  }

  void _restart() {
    _advanceTimer?.cancel();
    setState(_logic.restart);
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = _scores[0] >= 7 ? 1 : _scores[1] >= 7 ? 2 : 0;
    return LeaveGameScope(
      confirm: _logic.inProgress,
      child: Scaffold(
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
