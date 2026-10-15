import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const _fruitColors = [Color(0xFF2ECC71), Color(0xFFFF9F1C), Color(0xFFE63946), Color(0xFFF4D35E), Color(0xFF9B5DE5), Color(0xFFFF758F)];
const _fruitEmoji = ['🍉', '🍊', '🍎', '🍋', '🫐', '🍑'];

class FruitCutArcadeGame extends StatefulWidget {
  const FruitCutArcadeGame({super.key});
  @override State<FruitCutArcadeGame> createState() => _FruitCutArcadeGameState();
}
class _FruitArcadeItem {
  _FruitArcadeItem(this.x,this.y,this.vx,this.vy,this.r,this.type,{this.bomb=false});
  double x,y,vx,vy,r,angle=0;
  int type;
  bool bomb,sliced=false;
}
class _FruitParticle {
  _FruitParticle(this.x,this.y,this.vx,this.vy,this.color);
  double x,y,vx,vy,life=1;
  Color color;
}
class _FruitCutArcadeGameState extends State<FruitCutArcadeGame> with WidgetsBindingObserver {
  final _rng=Random();
  final Map<String,int> _unlocked={'EASY':1,'MEDIUM':1,'HARD':1};
  final List<_FruitArcadeItem> _fruits=[];
  final List<_FruitParticle> _particles=[];
  final List<Offset> _trail=[];
  late final Ticker _ticker;
  Duration? _last;
  String _diff='MEDIUM';
  int _level=1,_score=0,_sliced=0,_target=12,_lives=3,_freeze=2,_frenzy=2,_shield=2,_frames=0;
  double _w=360,_h=500,_freezeTime=0,_trailTime=0;
  bool _running=true,_ended=false,_shieldOn=false,_frenzyOn=false,_mapOpen=false;

  @override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);_reset();_ticker=Ticker(_tick)..start();}
  @override void didChangeAppLifecycleState(AppLifecycleState s){if(s==AppLifecycleState.paused||s==AppLifecycleState.inactive){_running=false;}else if(!_ended&&!_mapOpen){_running=true;}}
  void _reset(){_fruits.clear();_particles.clear();_trail.clear();_score=0;_sliced=0;_target=12+((_level-1)~/5)*2;_lives=3;_freeze=2;_frenzy=2;_shield=2;_frames=0;_freezeTime=0;_trailTime=0;_shieldOn=false;_frenzyOn=false;_ended=false;_running=true;if(mounted)setState((){});}
  void _tick(Duration now){if(_last==null){_last=now;return;}final dt=((now-_last!).inMicroseconds/1000000).clamp(0.0,.04).toDouble();_last=now;if(!_running||_ended||!mounted)return;setState((){
    if(_freezeTime>0)_freezeTime=max(0.0,_freezeTime-dt).toDouble();
    _trailTime=max(0.0,_trailTime-dt).toDouble();if(_trailTime==0)_trail.clear();
    if(_freezeTime==0){_frames++;final interval=max(22,54-_level~/2+(_diff=='EASY'?8:_diff=='HARD'?-8:0));if(_frames>=interval){_frames=0;_spawn(_frenzyOn?4:null);_frenzyOn=false;}
      for(final f in _fruits){f.x+=f.vx*dt*60;f.y+=f.vy*dt*60;f.vy+=.19*dt*60;f.angle+=f.vx*.004;}
    }
    for(final p in _particles){p.x+=p.vx*dt*60;p.y+=p.vy*dt*60;p.vy+=.12*dt*60;p.life-=dt*1.5;}
    _particles.removeWhere((p)=>p.life<=0);
    for(final f in List<_FruitArcadeItem>.from(_fruits)){if(f.y>_h+f.r+20){_fruits.remove(f);if(!f.bomb&&!_shieldOn){_lives--;if(_lives<=0){_finish(false);break;}}}}
  });}
  void _spawn([int? countOverride]){final count=countOverride??(_rng.nextInt(_diff=='EASY'?2:_diff=='HARD'?4:3)+1);final chance=_diff=='EASY'?.08:_diff=='MEDIUM'?.16:.23;for(var i=0;i<count;i++){final bomb=countOverride==null&&_level>=2&&_rng.nextDouble()<chance;final type=_rng.nextInt(_fruitColors.length);final r=bomb?24.0:24+_rng.nextDouble()*8;final x=r+_rng.nextDouble()*max(1.0,_w-r*2).toDouble();_fruits.add(_FruitArcadeItem(x,_h+r+5,(_rng.nextDouble()-.5)*(_diff=='HARD'?5.5:4.2),-(8.2+_rng.nextDouble()*3)*(1+_level*.008),r,type,bomb:bomb));}}
  void _down(Offset p){if(!_running||_ended)return;_trail..clear()..add(p);_trailTime=.2;}
  void _move(Offset p){if(!_running||_ended||_trail.isEmpty)return;final a=_trail.last;_trail.add(p);if(_trail.length>12)_trail.removeAt(0);_trailTime=.18;_cut(a,p);}
  void _cut(Offset a,Offset b){var hits=0;for(final f in List<_FruitArcadeItem>.from(_fruits.reversed)){final dx=b.dx-a.dx,dy=b.dy-a.dy,len=dx*dx+dy*dy;final t=len==0?0.0:(((f.x-a.dx)*dx+(f.y-a.dy)*dy)/len).clamp(0.0,1.0).toDouble();final dist=Offset(f.x-(a.dx+t*dx),f.y-(a.dy+t*dy)).distance;if(dist>f.r+8)continue;_fruits.remove(f);hits++;if(f.bomb){if(_shieldOn){_shieldOn=false;_toast('Shield blocked the bomb');}else{_finish(false,bomb:true);return;}}else{_sliced++;_score+=10+_level*2;for(var i=0;i<12;i++){final a=_rng.nextDouble()*pi*2,s=1.2+_rng.nextDouble()*4;_particles.add(_FruitParticle(f.x,f.y,cos(a)*s,sin(a)*s,_fruitColors[f.type]));}if(_sliced>=_target){_finish(true);return;}}}if(hits>1)_score+=hits*15;}
  void _toast(String s){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s),duration:const Duration(milliseconds:1100)));}
  void _finish(bool won,{bool bomb=false}){if(_ended)return;_ended=true;_running=false;if(won&&_level>=(_unlocked[_diff]??1)&&_level<50)_unlocked[_diff]=_level+1;WidgetsBinding.instance.addPostFrameCallback((_){if(!mounted)return;showDialog<void>(context:context,barrierDismissible:false,builder:(ctx)=>AlertDialog(title:Text(won?(_level==50?'Fruit Master! 🍉':'Level '+_level.toString()+' complete! 🍉'):bomb?'Bomb sliced! 💥':'Out of lives 💔'),content:Text(won?'Sliced '+_sliced.toString()+' fruit. Score: '+_score.toString(): 'Sliced '+_sliced.toString()+' / '+_target.toString()+'. Score: '+_score.toString()),actions:[TextButton(onPressed:(){Navigator.pop(ctx);setState((){if(won&&_level<50)_level++;_reset();});},child:Text(won?(_level<50?'Next level':'Replay level'):'Try again')),TextButton(onPressed:(){Navigator.pop(ctx);Navigator.maybePop(context);},child:const Text('Exit'))]));});}
  void _useFreeze(){if(_freeze<=0||_ended)return;setState((){_freeze--;_freezeTime=3.5;});_toast('Freeze active');}
  void _useFrenzy(){if(_frenzy<=0||_ended)return;setState((){_frenzy--;_frenzyOn=true;_spawn(4);});_toast('Frenzy wave');}
  void _useShield(){if(_shield<=0||_shieldOn||_ended)return;setState((){_shield--;_shieldOn=true;});_toast('Shield active');}
  void _openMap(){_running=false;_mapOpen=true;showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:const Color(0xFFF7F4EC),builder:(ctx)=>StatefulBuilder(builder:(ctx,refresh)=>SizedBox(height:MediaQuery.of(ctx).size.height*.72,child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
    const Text('Fruit trail',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900)),
    Wrap(spacing:5,children:['EASY','MEDIUM','HARD'].map((d)=>ChoiceChip(label:Text(d),selected:_diff==d,onSelected:(_){setState((){_diff=d;_level=_unlocked[d]??1;});refresh((){});})).toList()),
    Expanded(child:GridView.builder(itemCount:50,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:5,crossAxisSpacing:7,mainAxisSpacing:7),itemBuilder:(_,i){final n=i+1,open=n<=(_unlocked[_diff]??1);return FilledButton(onPressed:open?(){Navigator.pop(ctx);setState((){_level=n;_mapOpen=false;_reset();});}:null,style:FilledButton.styleFrom(backgroundColor:n==_level?const Color(0xFFFFC226):Colors.white,foregroundColor:const Color(0xFF26143B),padding:EdgeInsets.zero),child:Text(open?n.toString():'🔒'));})),
    TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Back to dojo'))
  ]))))).whenComplete((){_mapOpen=false;if(mounted&&!_ended)setState(()=>_running=true);});}
  @override void dispose(){WidgetsBinding.instance.removeObserver(this);_ticker.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFFF5F3EC),appBar:AppBar(backgroundColor:const Color(0xFFF5F3EC),foregroundColor:const Color(0xFF202520),leading:IconButton(tooltip:'Back',onPressed:()=>Navigator.maybePop(context),icon:const Icon(Icons.arrow_back_rounded)),title:const Text('Fruit Cut',style:TextStyle(fontWeight:FontWeight.w900)),actions:[IconButton(tooltip:'50 Levels',onPressed:_openMap,icon:const Icon(Icons.map_outlined)),IconButton(tooltip:'Restart',onPressed:()=>setState(_reset),icon:const Icon(Icons.refresh_rounded))]),body:SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(12,4,12,12),child:Column(children:[
    Row(children:[_stat('DIFFICULTY',_diff,tap:(){final d=['EASY','MEDIUM','HARD'];setState((){_diff=d[(d.indexOf(_diff)+1)%3];_level=_unlocked[_diff]??1;_reset();});}),const SizedBox(width:6),_stat('LEVEL',_level.toString())]),
    const SizedBox(height:6),Row(children:[_stat('SLICED',_sliced.toString()+' / '+_target.toString()),const SizedBox(width:6),_stat('SCORE',_score.toString()),const SizedBox(width:6),_stat('LIVES',(_shieldOn?'🛡️ ':'')+List.filled(max(0,_lives),'❤️').join())]),
    const SizedBox(height:7),ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:(_sliced/_target).clamp(0.0,1.0),minHeight:8,backgroundColor:const Color(0xFFE3DED2),color:const Color(0xFF476B4B))),
    const SizedBox(height:8),Expanded(child:LayoutBuilder(builder:(ctx,box){_w=box.maxWidth;_h=box.maxHeight;return ClipRRect(borderRadius:BorderRadius.circular(22),child:DecoratedBox(decoration:const BoxDecoration(gradient:RadialGradient(colors:[Color(0xFF3B2059),Color(0xFF221036)])),child:GestureDetector(behavior:HitTestBehavior.opaque,onPanStart:(d)=>_down(d.localPosition),onPanUpdate:(d)=>_move(d.localPosition),onPanEnd:(_)=>_trailTime=.12,child:CustomPaint(size:Size.infinite,painter:_FruitArenaPainter(fruits:_fruits,particles:_particles,trail:_trail,frozen:_freezeTime>0,shield:_shieldOn))))})),
    const SizedBox(height:9),Row(children:[_power('❄️','Freeze',_freeze,_freeze<=0||_ended,_useFreeze),const SizedBox(width:6),_power('🍉','Frenzy',_frenzy,_frenzy<=0||_ended,_useFrenzy),const SizedBox(width:6),_power('🛡️','Shield',_shield,_shield<=0||_shieldOn||_ended,_useShield)]),
    const SizedBox(height:3),const Text('Swipe through fruit. Avoid bombs. Don’t let too many fruits fall.',style:TextStyle(fontSize:10,color:Color(0xFF777A70),fontWeight:FontWeight.w600))
  ]))));
  Widget _stat(String l,String v,{VoidCallback? tap})=>Expanded(child:Material(color:Colors.white,borderRadius:BorderRadius.circular(12),child:InkWell(onTap:tap,borderRadius:BorderRadius.circular(12),child:Padding(padding:const EdgeInsets.symmetric(vertical:8,horizontal:4),child:Column(children:[Text(l,style:const TextStyle(fontSize:9,color:Color(0xFF777A70),fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(v,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12,color:Color(0xFF202520)))])))));
  Widget _power(String icon,String label,int count,bool disabled,VoidCallback tap)=>Expanded(child:FilledButton.tonal(onPressed:disabled?null:tap,style:FilledButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:7),backgroundColor:const Color(0xFFFFE7A4),foregroundColor:const Color(0xFF26143B),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(13))),child:Column(children:[Text(icon,style:const TextStyle(fontSize:21)),Text(label,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800)),Text(count.toString()+' left',style:const TextStyle(fontSize:10))])));
}
class _FruitArenaPainter extends CustomPainter {
  _FruitArenaPainter({required this.fruits,required this.particles,required this.trail,required this.frozen,required this.shield});
  final List<_FruitArcadeItem> fruits; final List<_FruitParticle> particles; final List<Offset> trail; final bool frozen,shield;
  @override void paint(Canvas canvas,Size size){
    final grid=Paint()..color=Colors.white.withValues(alpha:.035);
    for(var i=0;i<7;i++){canvas.drawLine(Offset(size.width*i/6,0),Offset(size.width*i/6,size.height),grid);}
    for(var i=0;i<9;i++){canvas.drawLine(Offset(0,size.height*i/8),Offset(size.width,size.height*i/8),grid);}
    for(final p in particles){canvas.drawCircle(Offset(p.x,p.y),2+3*p.life,Paint()..color=p.color.withValues(alpha:p.life.clamp(0.0,1.0)));}
    for(final f in fruits){canvas.save();canvas.translate(f.x,f.y);canvas.rotate(f.angle);final r=f.r;
      if(f.bomb){canvas.drawCircle(Offset.zero,r,Paint()..shader=const RadialGradient(colors:[Color(0xFF555555),Color(0xFF171717)]).createShader(Rect.fromCircle(center:Offset.zero,radius:r)));canvas.drawCircle(Offset.zero,r,Paint()..color=const Color(0xFFFF4757)..style=PaintingStyle.stroke..strokeWidth=2);canvas.drawLine(Offset(r*.2,-r*.8),Offset(r*.55,-r*1.1),Paint()..color=const Color(0xFFFFC226)..strokeWidth=4..strokeCap=StrokeCap.round);final t=TextPainter(text:const TextSpan(text:'✕',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),textDirection:TextDirection.ltr)..layout();t.paint(canvas,Offset(-t.width/2,-t.height/2));}
      else{final color=_fruitColors[f.type];canvas.drawCircle(Offset(1,3),r+1,Paint()..color=Colors.black.withValues(alpha:.25));canvas.drawCircle(Offset.zero,r,Paint()..shader=RadialGradient(center:const Alignment(-.35,-.45),colors:[Color.lerp(Colors.white,color,.25)!,color,Color.lerp(color,Colors.black,.25)!]).createShader(Rect.fromCircle(center:Offset.zero,radius:r)));canvas.drawCircle(Offset.zero,r,Paint()..color=Colors.white.withValues(alpha:.55)..style=PaintingStyle.stroke..strokeWidth=1.4);final t=TextPainter(text:TextSpan(text:_fruitEmoji[f.type],style:const TextStyle(fontSize:19)),textDirection:TextDirection.ltr)..layout();t.paint(canvas,Offset(-t.width/2,-t.height/2));}
      canvas.restore();
    }
    if(trail.length>1){final path=Path()..moveTo(trail.first.dx,trail.first.dy);for(final p in trail.skip(1)){path.lineTo(p.dx,p.dy);}canvas.drawPath(path,Paint()..color=const Color(0xFFB9F7FF).withValues(alpha:.9)..strokeWidth:5..strokeCap=StrokeCap.round..style=PaintingStyle.stroke);canvas.drawPath(path,Paint()..color=Colors.white.withValues(alpha:.75)..strokeWidth=1.8..strokeCap=StrokeCap.round..style=PaintingStyle.stroke);}
    if(frozen){canvas.drawRect(Offset.zero&size,Paint()..color=const Color(0xFF18DCFF).withValues(alpha:.12));final t=TextPainter(text:const TextSpan(text:'❄ FREEZE',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w900)),textDirection:TextDirection.ltr)..layout();t.paint(canvas,Offset((size.width-t.width)/2,16));}
    if(shield){canvas.drawCircle(Offset(size.width/2,size.height-28),17,Paint()..color=const Color(0xFF18DCFF).withValues(alpha:.2));}
  }
  @override bool shouldRepaint(covariant _FruitArenaPainter old)=>true;
}
