import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../leave_game.dart';

class CarromGame extends StatefulWidget {
  const CarromGame({super.key});
  @override
  State<CarromGame> createState() => _CarromGameState();
}

class _CarromGameState extends State<CarromGame> {
  final List<Offset> coins = [];
  int p1 = 0, p2 = 0, turn = 0;
  Offset striker = const Offset(.5, .82);
  Offset? drag;
  String status = 'Pull back from your striker, then release to shoot.';

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    coins
      ..clear()
      ..addAll([
        const Offset(.5, .5),
        const Offset(.5, .455),
        const Offset(.54, .478),
        const Offset(.54, .522),
        const Offset(.5, .545),
        const Offset(.46, .522),
        const Offset(.46, .478),
        const Offset(.5, .41),
        const Offset(.58, .455),
        const Offset(.58, .545),
        const Offset(.5, .59),
        const Offset(.42, .545),
        const Offset(.42, .455),
      ]);
    p1 = 0;
    p2 = 0;
    turn = 0;
    striker = const Offset(.5, .82);
    drag = null;
    status = 'Pull back from your striker, then release to shoot.';
  }

  void shoot(Offset end) {
    final dx = striker.dx - end.dx, dy = striker.dy - end.dy;
    if (math.sqrt(dx * dx + dy * dy) < .02) {
      setState(() => status = 'Pull back a little farther.');
      return;
    }
    final target = Offset((striker.dx + dx * 1.5).clamp(.12, .88).toDouble(), (striker.dy + dy * 1.5).clamp(.12, .88).toDouble());
    var pocketed = 0;
    for (var i = coins.length - 1; i >= 0; i--) {
      if ((coins[i] - target).distance < .09) {
        coins.removeAt(i);
        pocketed++;
      }
    }
    setState(() {
      if (turn % 2 == 0) {
        p1 += pocketed;
      } else {
        p2 += pocketed;
      }
      turn++;
      striker = Offset(.5, turn % 2 == 0 ? 0.82 : 0.18);
      status = pocketed > 0 ? 'Pocketed $pocketed coin(s)!' : 'Player ${turn % 2 + 1}, your turn.';
      if (coins.isEmpty) status = 'Board cleared! Restart for another game.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LeaveGameScope(
      confirm: turn > 0 && coins.isNotEmpty,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3EC),
        appBar: AppBar(
          title: const Text('Carrom', style: TextStyle(fontWeight: FontWeight.w900)),
          leading: IconButton(tooltip: 'Back', onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_rounded)),
          actions: [IconButton(tooltip: 'Restart', onPressed: () => setState(reset), icon: const Icon(Icons.refresh_rounded))],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                Expanded(child: score('PLAYER 1', p1)),
                const SizedBox(width: 10),
                Expanded(child: score('PLAYER 2', p2)),
              ]),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return GestureDetector(
                        onPanStart: (details) => drag = Offset(details.localPosition.dx / constraints.maxWidth, details.localPosition.dy / constraints.maxHeight),
                        onPanUpdate: (details) => setState(() => drag = Offset(details.localPosition.dx / constraints.maxWidth, details.localPosition.dy / constraints.maxHeight)),
                        onPanEnd: (_) {
                          final end = drag ?? striker;
                          drag = null;
                          shoot(end);
                        },
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _CarromPainter(coins: coins, striker: striker, drag: drag),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(status, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Drag back from the striker and release to aim your shot.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF777A70), fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget score(String label, int n) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
          Text(n.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        ]),
      );
}

class _CarromPainter extends CustomPainter {
  _CarromPainter({required this.coins, required this.striker, required this.drag});
  final List<Offset> coins;
  final Offset striker;
  final Offset? drag;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(18)), Paint()..color = const Color(0xFFB97843));
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(17), const Radius.circular(10)), Paint()..color = const Color(0xFFF4E6C8));
    for (final x in [.13, .87]) {
      for (final y in [.13, .87]) {
        canvas.drawCircle(Offset(size.width * x, size.height * y), size.width * .045, Paint()..color = const Color(0xFF202520));
      }
    }
    for (final y in [.18, .82]) {
      canvas.drawLine(Offset(size.width * .18, size.height * y), Offset(size.width * .82, size.height * y), Paint()..color = const Color(0xFFB97843)..strokeWidth = 2);
    }
    for (var i = 0; i < coins.length; i++) {
      final point = Offset(coins[i].dx * size.width, coins[i].dy * size.height);
      canvas.drawCircle(point, size.width * .021, Paint()..color = i == 0 ? const Color(0xFFB9433D) : (i.isEven ? const Color(0xFF202520) : Colors.white));
    }
    final strikerPoint = Offset(striker.dx * size.width, striker.dy * size.height);
    canvas.drawCircle(strikerPoint, size.width * .034, Paint()..color = const Color(0xFF476B4B));
    if (drag != null) {
      canvas.drawLine(strikerPoint, Offset(drag!.dx * size.width, drag!.dy * size.height), Paint()..color = const Color(0xFF476B4B)..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(covariant _CarromPainter oldDelegate) => true;
}
