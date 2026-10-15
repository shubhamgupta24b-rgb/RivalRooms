import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../leave_game.dart';

class PoolGame extends StatefulWidget {
  const PoolGame({super.key});
  @override State<PoolGame> createState() => _PoolGameState();
}

class _PoolBall {
  _PoolBall(this.x, this.y, this.color, {this.cue = false});
  double x, y, vx = 0, vy = 0;
  final Color color;
  final bool cue;
  bool pocketed = false;
}

class _PoolGameState extends State<PoolGame> {
  static const _radius = 0.018;
  final List<_PoolBall> _balls = [];
  final List<int> _scores = [0, 0];
  Timer? _timer;
  int _player = 0;
  int _remaining = 15;
  bool _moving = false;
  bool _gameOver = false;
  Offset? _aimPoint;
  Size _size = Size.zero;

  @override
  void initState() { super.initState(); _reset(); }

  void _reset() {
    _timer?.cancel();
    _balls.clear();
    _scores.setAll(0, [0, 0]);
    _player = 0; _remaining = 15; _moving = false; _gameOver = false; _aimPoint = null;
    _balls.add(_PoolBall(.23, .5, Colors.white, cue: true));
    const colors = [Color(0xFFF4C542), Color(0xFF2D68C4), Color(0xFFD94343), Color(0xFF7D4AB5), Color(0xFFF28B36), Color(0xFF278F73), Color(0xFF4D3430), Color(0xFF202020), Color(0xFFE7C94A), Color(0xFF5A8AD8), Color(0xFFEB6C73), Color(0xFFB184D4), Color(0xFFFFB16A), Color(0xFF66B7A2), Color(0xFF6B5149)];
    var k = 0;
    for (var col = 0; col < 5; col++) {
      for (var row = 0; row <= col; row++) {
        final x = .70 + col * .045;
        final y = .5 + (row - col / 2) * .052;
        _balls.add(_PoolBall(x, y, colors[k++]));
      }
    }
    if (mounted) setState(() {});
  }

  bool get _allStopped => _balls.every((b) => b.pocketed || (b.vx.abs() < .001 && b.vy.abs() < .001));

  void _startShot(Offset start, Offset end) {
    if (_moving || _gameOver || _size.isEmpty) return;
    final cue = _balls.first;
    if (cue.pocketed) return;
    final dx = start.dx - end.dx, dy = start.dy - end.dy;
    final distance = sqrt(dx * dx + dy * dy);
    if (distance < 12) return;
    final power = (distance / 180).clamp(.08, .95).toDouble();
    cue.vx = dx / max(1, distance) * power * .035;
    cue.vy = dy / max(1, distance) * power * .035;
    _aimPoint = null;
    _moving = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _step());
    setState(() {});
  }

  void _step() {
    if (!mounted) { _timer?.cancel(); return; }
    var pottedThisShot = false;
    final pocketCenters = [const Offset(.035,.08),const Offset(.5,.065),const Offset(.965,.08),const Offset(.035,.92),const Offset(.5,.935),const Offset(.965,.92)];
    for (final b in _balls) {
      if (b.pocketed) continue;
      b.x += b.vx; b.y += b.vy;
      b.vx *= .985; b.vy *= .985;
      if (b.x < .055 || b.x > .945) { b.x = b.x.clamp(.055,.945).toDouble(); b.vx = -b.vx * .82; }
      if (b.y < .12 || b.y > .88) { b.y = b.y.clamp(.12,.88).toDouble(); b.vy = -b.vy * .82; }
      for (final p in pocketCenters) {
        final dx=b.x-p.dx, dy=b.y-p.dy;
        if (dx*dx+dy*dy < .00115) {
          b.pocketed = true; b.vx=0; b.vy=0;
          if (!b.cue) { _scores[_player]++; _remaining--; pottedThisShot = true; }
          else { b.pocketed=false; b.x=.23; b.y=.5; }
          break;
        }
      }
    }
    for (var i=0;i<_balls.length;i++) {
      final a=_balls[i]; if(a.pocketed) continue;
      for(var j=i+1;j<_balls.length;j++) {
        final b=_balls[j]; if(b.pocketed) continue;
        final dx=b.x-a.x, dy=b.y-a.y, d=sqrt(dx*dx+dy*dy);
        if(d>0 && d<_radius*2) {
          final nx=dx/d, ny=dy/d;
          final rel=(a.vx-b.vx)*nx+(a.vy-b.vy)*ny;
          if(rel>0){a.vx-=rel*nx; a.vy-=rel*ny; b.vx+=rel*nx; b.vy+=rel*ny;}
          final overlap=_radius*2-d;
          a.x-=nx*overlap/2; a.y-=ny*overlap/2; b.x+=nx*overlap/2; b.y+=ny*overlap/2;
        }
      }
    }
    if (_allStopped) {
      _timer?.cancel(); _timer=null; _moving=false;
      if (_remaining<=0) _gameOver=true;
      else if (!pottedThisShot) _player=1-_player;
    }
    setState(() {});
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => LeaveGameScope(
    confirm: !_gameOver && (_scores[0] + _scores[1] > 0 || _moving),
    child: Scaffold(
    backgroundColor: const Color(0xFFF5F3EC),
    appBar: AppBar(
      title: const Text('Pool', style: TextStyle(fontWeight: FontWeight.w900)),
      leading: IconButton(tooltip:'Back', onPressed:()=>Navigator.maybePop(context), icon:const Icon(Icons.arrow_back_rounded)),
      actions:[IconButton(tooltip:'Restart',onPressed:_reset,icon:const Icon(Icons.refresh_rounded))],
    ),
    body: SafeArea(child: Padding(padding:const EdgeInsets.all(14),child:Column(children:[
      Row(children:[
        Expanded(child:_scoreCard('PLAYER 1',_scores[0],_player==0)),
        const SizedBox(width:8),
        Expanded(child:_scoreCard('PLAYER 2',_scores[1],_player==1)),
      ]),
      const SizedBox(height:10),
      Row(children:[
        const Icon(Icons.sports_esports_rounded,size:18,color:Color(0xFF476B4B)),
        const SizedBox(width:6),
        Expanded(child:Text(_gameOver?'Rack cleared — final score':_moving?'Balls moving…': 'Player ${_player+1}: drag back from the cue ball, then release',style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700))),
        Text('$_remaining left',style:const TextStyle(fontWeight:FontWeight.w900)),
      ]),
      const SizedBox(height:10),
      Expanded(child:LayoutBuilder(builder:(context,box){
        _size=Size(box.maxWidth,box.maxHeight);
        return GestureDetector(
          behavior:HitTestBehavior.opaque,
          onPanStart:(d){if(!_moving&&!_gameOver)_aimPoint=d.localPosition;},
          onPanUpdate:(d){if(!_moving&&!_gameOver)setState(()=>_aimPoint=d.localPosition);},
          onPanEnd:(d){final start=Offset(_balls.first.x*_size.width,_balls.first.y*_size.height);final end=_aimPoint;if(end!=null)_startShot(start,end);},
          child:CustomPaint(size:Size.infinite,painter:_PoolPainter(balls:_balls,aim:_aimPoint,size:_size)),
        );
      })),
      const SizedBox(height:8),
      const Text('Local pass-and-play • Pocket a ball to keep your turn',style:TextStyle(color:Color(0xFF777A70),fontSize:11)),
      if(_gameOver) Padding(padding:const EdgeInsets.only(top:8),child:FilledButton.icon(onPressed:_reset,icon:const Icon(Icons.replay_rounded),label:const Text('Play another rack'))),
    ]))),
  ),
  );

  Widget _scoreCard(String label,int score,bool active)=>Container(
    padding:const EdgeInsets.all(12),
    decoration:BoxDecoration(color:active?const Color(0xFFDDE8D8):Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:active?const Color(0xFF476B4B):Colors.transparent,width:2)),
    child:Row(children:[Expanded(child:Text(label,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900))),Text('$score',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900))]),
  );
}

class _PoolPainter extends CustomPainter {
  _PoolPainter({required this.balls,required this.aim,required this.size});
  final List<_PoolBall> balls; final Offset? aim; final Size size;
  @override void paint(Canvas canvas,Size size) {
    final table=Offset.zero&size;
    canvas.drawRRect(RRect.fromRectAndRadius(table, const Radius.circular(24)),Paint()..color=const Color(0xFF69442E));
    canvas.drawRRect(RRect.fromRectAndRadius(table.deflate(10),const Radius.circular(17)),Paint()..color=const Color(0xFFB78B55));
    canvas.drawRRect(RRect.fromRectAndRadius(table.deflate(22),const Radius.circular(12)),Paint()..color=const Color(0xFF28684E));
    final pocketPaint=Paint()..color=const Color(0xFF171512);
    for(final p in [const Offset(.035,.08),const Offset(.5,.065),const Offset(.965,.08),const Offset(.035,.92),const Offset(.5,.935),const Offset(.965,.92)]) {
      canvas.drawCircle(Offset(p.dx*size.width,p.dy*size.height),min(size.width,size.height)*.025,pocketPaint);
    }
    for(final ball in balls) {
      if(ball.pocketed)continue;
      final p=Offset(ball.x*size.width,ball.y*size.height);
      final r=min(size.width,size.height)*.018;
      canvas.drawCircle(p.translate(1,2),r,Paint()..color=Colors.black26);
      canvas.drawCircle(p,r,Paint()..color=ball.color);
      canvas.drawCircle(p,r,Paint()..color=ball.cue?const Color(0xFFD8D8D8):Colors.white70..style=PaintingStyle.stroke..strokeWidth=1);
      if(!ball.cue){canvas.drawCircle(p,r*.35,Paint()..color=Colors.white);}
    }
    if(aim!=null&&!balls.first.pocketed) {
      final cue=Offset(balls.first.x*size.width,balls.first.y*size.height);
      canvas.drawLine(cue,aim!,Paint()..color=Colors.white.withValues(alpha:.7)..strokeWidth=2..strokeCap=StrokeCap.round);
      canvas.drawCircle(aim!,4,Paint()..color=const Color(0xFFFFC857));
    }
  }
  @override bool shouldRepaint(covariant _PoolPainter old)=>true;
}
