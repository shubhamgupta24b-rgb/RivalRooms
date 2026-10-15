import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class BikeRacingGame extends StatefulWidget {
  const BikeRacingGame({super.key});
  @override State<BikeRacingGame> createState() => _BikeRacingGameState();
}
class _BikeRacingGameState extends State<BikeRacingGame> {
  Timer? _timer;
  final Random _random = Random();
  int _lane = 1, _obstacleLane = 0, _score = 0, _best = 0;
  double _obstacleY = -0.2;
  bool _running = false, _over = false;

  @override void dispose() { _timer?.cancel(); super.dispose(); }

  void _start() {
    _timer?.cancel();
    setState(() { _lane=1; _obstacleLane=_random.nextInt(3); _obstacleY=-.2; _score=0; _running=true; _over=false; });
    _timer=Timer.periodic(const Duration(milliseconds:30), (_) {
      if (!mounted || !_running) return;
      setState(() {
        _obstacleY += .018;
        if (_obstacleY > 1.05) { _obstacleY=-.2; _obstacleLane=_random.nextInt(3); _score++; if(_score>_best)_best=_score; }
        if (_obstacleY > .72 && _obstacleY < .91 && _obstacleLane == _lane) {
          _running=false; _over=true; _timer?.cancel();
        }
      });
    });
  }
  void _move(int direction) {
    if(!_running)return;
    setState(()=>_lane=(_lane+direction).clamp(0,2));
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F3EC),
    appBar: AppBar(title: const Text('Bike Racing',style:TextStyle(fontWeight:FontWeight.w900)),
      leading: IconButton(tooltip:'Back',onPressed:()=>Navigator.maybePop(context),icon:const Icon(Icons.arrow_back_rounded)),
      actions:[IconButton(tooltip:'Restart',onPressed:_start,icon:const Icon(Icons.refresh_rounded))]),
    body: SafeArea(child: Padding(padding:const EdgeInsets.all(16),child:Column(children:[
      Row(children:[Expanded(child:_stat('SCORE',_score)),const SizedBox(width:10),Expanded(child:_stat('BEST',_best))]),
      const SizedBox(height:12),
      Expanded(child:GestureDetector(
        onHorizontalDragUpdate:(d)=>_move(d.delta.dx>0?1:-1),
        child:Container(decoration:BoxDecoration(color:const Color(0xFFDDE7D7),borderRadius:BorderRadius.circular(24)),clipBehavior:Clip.antiAlias,
          child:LayoutBuilder(builder:(context,b){
            final laneWidth=b.maxWidth/3;
            return Stack(children:[
              Positioned.fill(child:Container(color:const Color(0xFF4A504A))),
              for(var lane=1;lane<3;lane++)
                Positioned(left:lane*laneWidth-1,top:0,bottom:0,child:Container(width:2,color:Colors.white30)),
              Positioned(left:_obstacleLane*laneWidth+laneWidth/2-16,top:(_obstacleY+.2)*b.maxHeight*.8,child:const Text('🚧',style:TextStyle(fontSize:32))),
              Positioned(left:_lane*laneWidth+laneWidth/2-19,bottom:34,child:const Text('🏍️',style:TextStyle(fontSize:38))),
              if(!_running) Positioned.fill(child:Container(color:const Color(0xCCF5F3EC),child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
                Text(_over?'Race over!':'Ready to ride?',style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),
                const SizedBox(height:8),Text(_over?'Score: $_score':'Swipe or use the lane buttons'),
                const SizedBox(height:12),FilledButton(onPressed:_start,child:Text(_over?'Race again':'Start race')),
              ])))),
            ];
          }),
        ),
      )),
      const SizedBox(height:12),
      Row(children:[
        Expanded(child:FilledButton.tonalIcon(onPressed:()=>_move(-1),icon:const Icon(Icons.arrow_left_rounded),label:const Text('Left'))),
        const SizedBox(width:12),
        Expanded(child:FilledButton.tonalIcon(onPressed:()=>_move(1),icon:const Icon(Icons.arrow_right_rounded),label:const Text('Right'))),
      ]),
      const SizedBox(height:8),
      const Text('Dodge road barriers and survive as long as you can.',style:TextStyle(color:Color(0xFF777A70),fontSize:12)),
    ]))),
  );

  Widget _stat(String label,int n)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15)),child:Row(children:[Expanded(child:Text(label,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:Color(0xFF777A70)))),Text('$n',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900))]));
}
