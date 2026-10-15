import 'package:flutter/material.dart';
import '../leave_game.dart';
import 'connect_four_logic.dart';

const _p1 = Color(0xFF3B6FA5);
const _p2 = Color(0xFFD96F58);
const _board = Color(0xFF476B4B);
const _ink = Color(0xFF202520);
const _muted = Color(0xFF777A70);

class ConnectFourGame extends StatefulWidget {
  const ConnectFourGame({super.key});
  @override
  State<ConnectFourGame> createState() => _ConnectFourGameState();
}

class _ConnectFourGameState extends State<ConnectFourGame> {
  late ConnectFourLogic game;

  @override
  void initState() {
    super.initState();
    game = ConnectFourLogic();
  }

  void _drop(int column) {
    if (game.drop(column) != null) setState(() {});
  }

  bool _hasSpace(int column) {
    for (var row = 0; row < ConnectFourLogic.rows; row++) {
      if (game.at(column, row) == -1) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final winner = game.winner;
    final done = game.finished;
    final accent = winner == null
        ? (game.turn == 0 ? _p1 : _p2)
        : (winner == 0 ? _p1 : _p2);
    final status = winner != null
        ? 'PLAYER ${winner + 1} WINS'
        : game.isDraw
            ? 'DRAW — BOARD FULL'
            : 'PLAYER ${game.turn + 1} TO MOVE';
    final winning = game.winCells.toSet();

    return LeaveGameScope(
      confirm: game.moves > 0 && !game.finished,
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to games',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Connect Four',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Restart match',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => game.reset()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withValues(alpha: .55), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status, style: TextStyle(
                            color: accent, fontSize: 12,
                            fontWeight: FontWeight.w900, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            winner != null
                                ? 'Four in a row. Well played.'
                                : game.isDraw
                                    ? 'No spaces remain. Start another round.'
                                    : 'Tap a column to drop your disc.',
                            style: const TextStyle(color: _muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(done ? Icons.emoji_events_rounded : Icons.south_rounded,
                        color: accent, size: 23),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _playerCard(
                    'PLAYER 1', 1, game.cells.where((x) => x == 0).length,
                    _p1, !done && game.turn == 0, winner == 0)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('VS', style: TextStyle(
                      color: _muted, fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                  Expanded(child: _playerCard(
                    'PLAYER 2', 2, game.cells.where((x) => x == 1).length,
                    _p2, !done && game.turn == 1, winner == 1)),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: AspectRatio(
                      aspectRatio: ConnectFourLogic.columns / ConnectFourLogic.rows,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _board,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [BoxShadow(
                            color: Color(0x1E202520), blurRadius: 20,
                            offset: Offset(0, 8))],
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: game.cells.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ConnectFourLogic.columns,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemBuilder: (context, index) {
                            final player = game.cells[index];
                            final column = index % ConnectFourLogic.columns;
                            final canDrop = !done && _hasSpace(column);
                            final highlight = winning.contains(index);
                            return Semantics(
                              button: canDrop,
                              label: player < 0
                                  ? 'Empty cell, column ${column + 1}'
                                  : 'Player ${player + 1} disc, column ${column + 1}${highlight ? ', winning disc' : ''}',
                              child: Material(
                                color: const Color(0xFFF5F3EC),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: canDrop ? () => _drop(column) : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: player < 0
                                          ? const Color(0xFFE4E6DD)
                                          : player == 0 ? _p1 : _p2,
                                      border: Border.all(
                                        color: highlight
                                            ? const Color(0xFFFFD166)
                                            : player < 0
                                                ? const Color(0xFFD0D4C8)
                                                : Colors.white,
                                        width: highlight ? 3 : 1.5,
                                      ),
                                    ),
                                    child: player < 0
                                        ? null
                                        : Center(child: Text('${player + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900))),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (done)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () => setState(() => game.reset()),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Play another round'),
                  ),
                )
              else
                const Text(
                  'Connect four discs horizontally, vertically, or diagonally.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

Widget _playerCard(String label, int number, int count, Color color,
    bool active, bool winner) => AnimatedContainer(
  duration: const Duration(milliseconds: 160),
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      color: active || winner ? color : const Color(0xFFE4E2D9),
      width: active || winner ? 1.8 : 1,
    ),
  ),
  child: Row(children: [
    Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: Text('$number', style: const TextStyle(
        color: Colors.white, fontWeight: FontWeight.w900))),
    ),
    const SizedBox(width: 8),
    Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          color: _ink, fontSize: 10, fontWeight: FontWeight.w900)),
        Text(winner ? 'Winner' : active ? 'Your turn' : 'Discs: $count',
          style: TextStyle(
            color: active || winner ? color : _muted,
            fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    )),
  ]),
);
