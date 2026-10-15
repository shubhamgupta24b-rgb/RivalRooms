import 'dart:math';
import 'package:flutter/material.dart';
import '../leave_game.dart';

const _green = Color(0xFF476B4B);
const _ink = Color(0xFF202520);

class RajaMantriChorSipahiGame extends StatefulWidget {
  const RajaMantriChorSipahiGame({super.key});
  @override
  State<RajaMantriChorSipahiGame> createState() => _RajaMantriChorSipahiGameState();
}

class _RajaMantriChorSipahiGameState extends State<RajaMantriChorSipahiGame> {
  final _random = Random();
  final _scores = List<int>.filled(4, 0);
  late List<int> _roles;
  int _round = 1, _revealIndex = 0;
  int? _caught;
  bool _revealed = false, _guessing = false, _roundComplete = false;

  @override
  void initState() { super.initState(); _deal(); }

  void _deal() {
    _roles = [0, 1, 2, 3]..shuffle(_random);
    _revealIndex = 0; _caught = null; _revealed = false;
    _guessing = false; _roundComplete = false;
  }

  void _hideAndPass() {
    setState(() {
      _revealed = false;
      if (_revealIndex < 3) { _revealIndex++; } else { _guessing = true; }
    });
  }

  void _guess(int player) {
    final chor = _roles.indexOf(2);
    final correct = player == chor;
    setState(() {
      _caught = player;
      _scores[_roles.indexOf(0)] += 1000;
      _scores[_roles.indexOf(1)] += correct ? 500 : 0;
      _scores[chor] += correct ? 0 : 500;
      _scores[_roles.indexOf(3)] -= 300;
      _roundComplete = true;
    });
  }

  void _resetMatch() { _scores.fillRange(0, 4, 0); _round = 1; _deal(); }

  void _nextRound() {
    if (_round < 20) { setState(() { _round++; _deal(); }); return; }
    final high = _scores.reduce(max);
    final winner = _scores.indexOf(high) + 1;
    showDialog<void>(context: context, builder: (c) => AlertDialog(
      title: const Text('20 rounds complete'),
      content: Text('Player ' + winner.toString() + ' wins with ' + high.toString() + ' points.'),
      actions: [TextButton(onPressed: () { Navigator.pop(c); setState(_resetMatch); }, child: const Text('New match'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final role = _roles[_revealIndex];
    final matchFinished = _round == 20 && _roundComplete;
    final inProgress = !matchFinished && (_revealed || _revealIndex > 0 || _guessing || _roundComplete || _round > 1);
    return LeaveGameScope(
      confirm: inProgress,
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Back to games', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.maybePop(context)),
        title: const Text('Raja Mantri Chor Sipahi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: [IconButton(tooltip: 'Restart match', icon: const Icon(Icons.refresh_rounded), onPressed: () => setState(_resetMatch))],
      ),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
        Row(children: [Expanded(child: Text('ROUND ' + _round.toString() + ' OF 20', style: const TextStyle(color: _green, fontWeight: FontWeight.w900, letterSpacing: 1.1))), Text(_round.toString() + ' / 20')]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _round / 20, minHeight: 7, color: _green)),
        const SizedBox(height: 18),
        const Text('Pass the phone. Keep your role secret.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _ink)),
        const SizedBox(height: 6),
        const Text('Four players · one device · 20 rounds', style: TextStyle(color: Color(0xFF777A70))),
        const SizedBox(height: 18),
        if (!_guessing && !_roundComplete) ...[
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(children: [
            Text('PLAYER ' + (_revealIndex + 1).toString(), style: const TextStyle(color: _green, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _revealed = !_revealed),
              child: Container(width: double.infinity, height: 190, decoration: BoxDecoration(color: _revealed ? const Color(0xFFE9D9A9) : _green, borderRadius: BorderRadius.circular(20)),
                child: Center(child: _revealed
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(['👑', '📜', '🕵️', '⚔️'][role], style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(['Raja', 'Mantri', 'Chor', 'Sipahi'][role].toUpperCase(), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: _ink)),
                      const Text('Keep this secret!', style: TextStyle(color: _ink)),
                    ])
                  : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.lock_outline_rounded, size: 42, color: Colors.white),
                      SizedBox(height: 12),
                      Text('TAP TO REVEAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ]))),
            ),
            const SizedBox(height: 12),
            Text(_revealed ? 'Memorise your role, then pass the phone.' : 'Only Player ' + (_revealIndex + 1).toString() + ' should look.'),
          ])),
          const SizedBox(height: 14),
          if (_revealed) FilledButton(onPressed: _hideAndPass, style: FilledButton.styleFrom(backgroundColor: _green, minimumSize: const Size.fromHeight(50)), child: Text(_revealIndex == 3 ? 'Everyone has seen their role' : 'Hide role & pass to Player ' + (_revealIndex + 2).toString())),
        ] else if (_guessing && !_roundComplete) ...[
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sipahi is Player ' + (_roles.indexOf(3) + 1).toString() + ' — identify the Chor', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Choose the player you believe is the Chor. Roles are revealed after your guess.'),
            const SizedBox(height: 14),
            for (var i = 0; i < 4; i++) if (i != _roles.indexOf(3)) Padding(padding: const EdgeInsets.only(bottom: 8), child: OutlinedButton.icon(onPressed: () => _guess(i), icon: const Icon(Icons.person_outline_rounded), label: Text('Player ' + (i + 1).toString()), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)))),
          ])),
        ] else ...[
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ROUND RESULT', style: TextStyle(fontWeight: FontWeight.w900, color: _green, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text('Player ' + (_caught! + 1).toString() + ' was chosen. ' + (_caught == _roles.indexOf(2) ? 'Correct — the Chor was caught!' : 'Wrong — the Chor escaped!'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (var i = 0; i < 4; i++) ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: const Color(0xFFE9D9A9), child: Text((i + 1).toString(), style: const TextStyle(color: _ink, fontWeight: FontWeight.w900))), title: Text('Player ' + (i + 1).toString() + ' · ' + ['Raja', 'Mantri', 'Chor', 'Sipahi'][_roles[i]]), trailing: Text(_scores[i].toString() + ' pts', style: const TextStyle(fontWeight: FontWeight.w900))),
            const Divider(),
            const Text('Raja +1000 · Mantri +500 if correct · Chor +500 if not caught · Sipahi −300', style: TextStyle(fontSize: 12, color: Color(0xFF777A70))),
          ])),
          const SizedBox(height: 14),
          FilledButton(onPressed: _nextRound, style: FilledButton.styleFrom(backgroundColor: _green, minimumSize: const Size.fromHeight(52)), child: Text(_round == 20 ? 'Finish match' : 'Next round')),
        ],
        const SizedBox(height: 20),
        const Text('PASS-AND-PLAY · LOCAL ONLY', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFF777A70), letterSpacing: 1.2, fontWeight: FontWeight.w800)),
      ])),
    ),
    );
  }
}
