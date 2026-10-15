import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

const _ink = Color(0xFF202520);
const _paper = Color(0xFFF5F3EC);
const _green = Color(0xFF476B4B);
const _coral = Color(0xFFE4775D);

enum JumpDifficulty { easy, medium, hard }

class ChickenJumpGame extends StatefulWidget {
  const ChickenJumpGame({super.key});
  @override
  State<ChickenJumpGame> createState() => _ChickenJumpGameState();
}

class _ChickenJumpGameState extends State<ChickenJumpGame> {
  Timer? _timer;
  JumpDifficulty _difficulty = JumpDifficulty.medium;
  double _chickenY = 0;
  double _velocity = 0;
  double _obstacleX = 1.1;
  int _score = 0;
  int _best = 0;
  bool _running = false;
  bool _gameOver = false;
  bool _grounded = true;

  double get _speed => switch (_difficulty) {
    JumpDifficulty.easy => 0.006,
    JumpDifficulty.medium => 0.009,
    JumpDifficulty.hard => 0.012,
  };
  double get _gap => switch (_difficulty) {
    JumpDifficulty.easy => 0.42,
    JumpDifficulty.medium => 0.34,
    JumpDifficulty.hard => 0.27,
  };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _chickenY = 0;
      _velocity = 0;
      _obstacleX = 1.1;
      _score = 0;
      _running = true;
      _gameOver = false;
      _grounded = true;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || !_running) return;
      setState(() {
        _velocity += 0.0015;
        _chickenY += _velocity;
        if (_chickenY >= 0) {
          _chickenY = 0;
          _velocity = 0;
          _grounded = true;
        }
        _obstacleX -= _speed;
        if (_obstacleX < -0.12) {
          _obstacleX = 1.1 + Random().nextDouble() * _gap;
          _score++;
          if (_score > _best) _best = _score;
        }
        if (_obstacleX < -0.01 && _obstacleX > -0.11 && _chickenY > -0.09) {
          _running = false;
          _gameOver = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _jump() {
    if (_gameOver) {
      _start();
      return;
    }
    if (!_running) {
      _start();
      return;
    }
    if (_grounded) {
      setState(() {
        _velocity = -0.035;
        _grounded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficultyName = switch (_difficulty) {
      JumpDifficulty.easy => 'Easy',
      JumpDifficulty.medium => 'Medium',
      JumpDifficulty.hard => 'Hard',
    };
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        foregroundColor: _ink,
        title: const Text('Chicken Jump', style: TextStyle(fontWeight: FontWeight.w900)),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [IconButton(tooltip: 'Restart', onPressed: _start, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(child: _stat('SCORE', '$_score')),
                const SizedBox(width: 10),
                Expanded(child: _stat('BEST', '$_best')),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                DropdownButton<JumpDifficulty>(
                  value: _difficulty,
                  items: const [
                    DropdownMenuItem(value: JumpDifficulty.easy, child: Text('Easy')),
                    DropdownMenuItem(value: JumpDifficulty.medium, child: Text('Medium')),
                    DropdownMenuItem(value: JumpDifficulty.hard, child: Text('Hard')),
                  ],
                  onChanged: _running ? null : (value) {
                    if (value != null) setState(() => _difficulty = value);
                  },
                ),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _jump,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFE6EBDD), borderRadius: BorderRadius.circular(24)),
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(builder: (context, constraints) {
                      final ground = constraints.maxHeight * .78;
                      final chickenBottom = ground + _chickenY * constraints.maxHeight;
                      return Stack(children: [
                        Positioned(left: 0, right: 0, top: ground + 27, child: Container(height: 3, color: _green)),
                        Positioned(left: constraints.maxWidth * .12, bottom: constraints.maxHeight - chickenBottom - 56, child: const Text('🐔', style: TextStyle(fontSize: 48))),
                        Positioned(left: _obstacleX * constraints.maxWidth, top: ground - 28, child: Container(width: 24, height: 31, decoration: BoxDecoration(color: _coral, borderRadius: BorderRadius.circular(8)))),
                        if (!_running)
                          Positioned.fill(child: Container(color: const Color(0xCCF5F3EC), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(_gameOver ? 'Nice run!' : 'Ready, chicken?', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: _ink)),
                            const SizedBox(height: 8),
                            Text(_gameOver ? 'Score: $_score · Tap to try again' : 'Tap anywhere to jump over obstacles', textAlign: TextAlign.center, style: const TextStyle(color: _ink)),
                            const SizedBox(height: 14),
                            FilledButton(onPressed: _start, style: FilledButton.styleFrom(backgroundColor: _green), child: Text(_gameOver ? 'Play again' : 'Start run')),
                          ])))),
                      ]);
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Tap to jump. Stay clear of the blocks and beat your best score.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF777A70), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Text(label, style: const TextStyle(color: Color(0xFF777A70), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
      const Spacer(),
      Text(value, style: const TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w900)),
    ]),
  );
}
