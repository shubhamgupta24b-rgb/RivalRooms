import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const RivalRoomsApp());

const ink = Color(0xFF202520);
const paper = Color(0xFFF5F3EC);
const green = Color(0xFF476B4B);
const coral = Color(0xFFE4775D);
const muted = Color(0xFF777A70);

class RivalRoomsApp extends StatelessWidget {
  const RivalRoomsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RivalRooms', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.light),
      fontFamily: 'Roboto', appBarTheme: const AppBarTheme(backgroundColor: paper, foregroundColor: ink, elevation: 0)),
    home: const HomeScreen(),
  );
}

class GameInfo {
  final String title, subtitle, emoji, category;
  final Color color;
  const GameInfo(this.title,this.subtitle,this.emoji,this.category,this.color);
}
const games = <GameInfo>[
 GameInfo('Memory Match','Find matching pairs','🧠','Quick play',Color(0xFFE9D9A9)),
 GameInfo('Basketball Hoops','Beat your best score','🏀','Quick play',Color(0xFFF1C6A3)),
 GameInfo('Fruit Cut','Slice. Score. Repeat.','🍉','Quick play',Color(0xFFD4E4C8)),
 GameInfo('Guess the Person','Can you read their clues?','🕵️','Party games',Color(0xFFDAD6ED)),
 GameInfo('Connect Four','Four in a row wins','🔴','Board games',Color(0xFFF0D1CB)),
 GameInfo('Battleship','Outsmart your opponent','🚢','Board games',Color(0xFFC9DFE1)),
 GameInfo('Pool','Line up the perfect shot','🎱','Board games',Color(0xFFD1E2CE)),
 GameInfo('Maths Duel','Fast answers, close race','➗','Quick play',Color(0xFFF0D9AA)),
];

class HomeScreen extends StatefulWidget {
 const HomeScreen({super.key});
 @override State<HomeScreen> createState()=>_HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
 int tab=0;
 void openGame(GameInfo game) {
   if(game.title=='Memory Match') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const MemoryGame()));
   } else if (game.title=='Fruit Cut') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const FruitCutGame()));
   } else if (game.title=='Basketball Hoops') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const BasketballGame()));
   } else {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>GamePreview(game:game)));
   }
 }
 @override Widget build(BuildContext context) {
  return Scaffold(
   appBar: AppBar(title: const Row(children:[
    Icon(Icons.sports_esports_rounded,color:green,size:27), SizedBox(width:9),
    Text('RivalRooms',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:-.7)),
   ]), actions:[IconButton(tooltip:'Settings',onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SettingsScreen())),icon:const Icon(Icons.tune_rounded))]),
   body: SafeArea(child: tab==0 ? _home() : tab==1 ? _online() : _library()),
   bottomNavigationBar: NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),
    backgroundColor:Colors.white,destinations:const[
      NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home_rounded),label:'Home'),
      NavigationDestination(icon:Icon(Icons.people_outline),selectedIcon:Icon(Icons.people_rounded),label:'Play online'),
      NavigationDestination(icon:Icon(Icons.grid_view_rounded),label:'All games'),
    ]),
  );
 }
 Widget _home()=>ListView(padding:const EdgeInsets.fromLTRB(20,8,20,28),children:[
  const Text('GOOD GAMES. GREAT COMPANY.',style:TextStyle(fontSize:11,letterSpacing:1.5,fontWeight:FontWeight.w800,color:muted)),
  const SizedBox(height:8),
  const Text('Who’s your\nnext rival?',style:TextStyle(fontSize:38,height:1.05,fontWeight:FontWeight.w900,letterSpacing:-1.7,color:ink)),
  const SizedBox(height:18),
  Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:green,borderRadius:BorderRadius.circular(24)),
   child:Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('MAKE IT A MATCH',style:TextStyle(color:Color(0xFFD8E3D1),fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.4)),
    SizedBox(height:8),Text('Play with friends\nwherever they are.',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:21,height:1.2)),
    SizedBox(height:15),
   ])),Container(width:74,height:84,decoration:BoxDecoration(color:Color(0xFF5D805F),borderRadius:BorderRadius.circular(20)),child:const Center(child:Text('🏆',style:TextStyle(fontSize:42))))]),
  SizedBox(height:0),
  FilledButton.icon(onPressed:()=>setState(()=>tab=1),icon:const Icon(Icons.group_add_rounded),label:const Text('Create or join a room'),style:FilledButton.styleFrom(backgroundColor:coral,foregroundColor:ink,minimumSize:const Size.fromHeight(52),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15)))),
  const SizedBox(height:26),
  _sectionTitle('Pick up and play','See all',()=>setState(()=>tab=2)),
  const SizedBox(height:12),
  SizedBox(height:174,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:3,separatorBuilder:(_,__)=>const SizedBox(width:12),itemBuilder:(c,i){
   final g=games[i];return SizedBox(width:164,child:InkWell(borderRadius:BorderRadius.circular(20),onTap:()=>openGame(g),child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:g.color,borderRadius:BorderRadius.circular(20)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Align(alignment:Alignment.topRight,child:Text(g.emoji,style:const TextStyle(fontSize:39))),
    const Spacer(),Text(g.title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:17,color:ink)),const SizedBox(height:4),Text(g.subtitle,style:const TextStyle(fontSize:11,color:ink)),
   ])));})),
  const SizedBox(height:26),_sectionTitle('Play your way',null,null),const SizedBox(height:12),
  Row(children:[
   Expanded(child:_modeTile('Online','Friends anywhere',Icons.public_rounded,green,()=>setState(()=>tab=1))),
   const SizedBox(width:10),
   Expanded(child:_modeTile('Same room','Pass and play',Icons.phonelink_rounded,coral,()=>setState(()=>tab=2))),
  ]),
  const SizedBox(height:20),
  const Text('More games are on the way.',style:TextStyle(color:muted,fontSize:12)),
 ]);
 Widget _sectionTitle(String title,String? action,VoidCallback? onTap)=>Row(children:[Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:19,letterSpacing:-.4,color:ink))),if(action!=null)TextButton(onPressed:onTap,child:Text(action))]);
 Widget _modeTile(String title,String subtitle,IconData icon,Color color,VoidCallback tap)=>InkWell(onTap:tap,borderRadius:BorderRadius.circular(18),child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:color,size:27),const SizedBox(height:14),Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:16)),const SizedBox(height:3),Text(subtitle,style:const TextStyle(color:muted,fontSize:11))])));
 Widget _online()=>ListView(padding:const EdgeInsets.all(20),children:[
  const Text('Play online',style:TextStyle(fontSize:31,fontWeight:FontWeight.w900,letterSpacing:-1)),
  const SizedBox(height:6),const Text('Bring your friends into the same room.',style:TextStyle(color:muted)),
  const SizedBox(height:22),const _RoomAction(icon:Icons.add_circle_outline,title:'Create a room',detail:'Start a private match',message:'Room creation needs the multiplayer server connection.'),
  const SizedBox(height:12),const _RoomAction(icon:Icons.login_rounded,title:'Join with a code',detail:'Enter a friend’s room code',message:'Room joining needs the multiplayer server connection.'),
  const SizedBox(height:12),const _RoomAction(icon:Icons.bolt_rounded,title:'Quick Play',detail:'Find a game together',message:'Quick Play will be connected when the server is migrated.'),
  const SizedBox(height:20),const Text('Online rooms are not connected in this first Flutter scaffold yet.',style:TextStyle(color:muted,fontSize:12)),
 ]);
 Widget _library()=>ListView(padding:const EdgeInsets.fromLTRB(20,10,20,24),children:[
  const Text('All games',style:TextStyle(fontSize:31,fontWeight:FontWeight.w900,letterSpacing:-1)),
  const SizedBox(height:6),const Text('Choose your next challenge.',style:TextStyle(color:muted)),const SizedBox(height:18),
  for(final g in games) Padding(padding:const EdgeInsets.only(bottom:10),child:InkWell(onTap:()=>openGame(g),borderRadius:BorderRadius.circular(17),child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17)),child:Row(children:[Container(width:54,height:54,decoration:BoxDecoration(color:g.color,borderRadius:BorderRadius.circular(14)),child:Center(child:Text(g.emoji,style:const TextStyle(fontSize:28)))),const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(g.title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15)),const SizedBox(height:3),Text(g.subtitle,style:const TextStyle(color:muted,fontSize:12))])),const Icon(Icons.chevron_right_rounded,color:muted)])))),
 ]);
}

class _RoomAction extends StatelessWidget {
 final IconData icon; final String title,detail,message;
 const _RoomAction({required this.icon,required this.title,required this.detail,required this.message});
 @override Widget build(BuildContext context)=>InkWell(onTap:()=>showDialog<void>(context:context,builder:(c)=>AlertDialog(title:Text(title),content:Text(message),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Got it'))])),borderRadius:BorderRadius.circular(18),child:Container(padding:const EdgeInsets.all(17),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),child:Row(children:[Icon(icon,color:green,size:28),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:16)),const SizedBox(height:4),Text(detail,style:const TextStyle(color:muted,fontSize:12))])),const Icon(Icons.chevron_right_rounded,color:muted)])));
}

class GamePreview extends StatelessWidget {
 final GameInfo game; const GamePreview({super.key,required this.game});
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(leading:IconButton(tooltip:'Back',icon:const Icon(Icons.arrow_back_rounded),onPressed:()=>Navigator.maybePop(context)),title:Text(game.title)),body:Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Container(width:140,height:140,decoration:BoxDecoration(color:game.color,borderRadius:BorderRadius.circular(36)),child:Center(child:Text(game.emoji,style:const TextStyle(fontSize:72)))),const SizedBox(height:22),Text(game.title,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text(game.subtitle,style:const TextStyle(color:muted)),const SizedBox(height:24),const Text('This game screen is queued for implementation.',textAlign:TextAlign.center,style:TextStyle(color:muted)),const SizedBox(height:18),FilledButton(onPressed:()=>Navigator.pop(context),child:const Text('Back to games'))]))));
}

class MemoryGame extends StatefulWidget { const MemoryGame({super.key}); @override State<MemoryGame> createState()=>_MemoryGameState(); }
class _MemoryGameState extends State<MemoryGame> {
 late List<String> cards; final Set<int> open={}; final Set<int> matched={}; int moves=0; bool busy=false;
 @override void initState(){super.initState();_reset();}
 void _reset(){final symbols=['🍋','🍒','🍇','🍉','🥝','🍊','🍓','🍍'];cards=[...symbols,...symbols]..shuffle(Random());open.clear();matched.clear();moves=0;busy=false;}
 Future<void> _tap(int i) async {
  if(busy||matched.contains(i)||open.contains(i))return;
  setState(()=>open.add(i));
  if(open.length==2){setState(()=>moves++);final pair=open.toList();if(cards[pair[0]]==cards[pair[1]]){setState(()=>matched.addAll(pair));await Future<void>.delayed(const Duration(milliseconds:250));if(matched.length==cards.length&&mounted){showDialog<void>(context:context,builder:(c)=>AlertDialog(title:const Text('Perfect match!'),content:Text('You finished in $moves moves.'),actions:[TextButton(onPressed:(){Navigator.pop(c);setState(_reset);},child:const Text('Play again'))]));}}else{busy=true;await Future<void>.delayed(const Duration(milliseconds:700));if(mounted)setState(()=>open.clear());busy=false;}}
 }
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(leading:IconButton(tooltip:'Back',icon:const Icon(Icons.arrow_back_rounded),onPressed:()=>Navigator.maybePop(context)),title:const Text('Memory Match',style:TextStyle(fontWeight:FontWeight.w800)),actions:[IconButton(tooltip:'Restart',onPressed:()=>setState(_reset),icon:const Icon(Icons.refresh_rounded))]),body:SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[Row(children:[const Expanded(child:Text('Find every pair.',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900))),Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:9),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),child:Text('Moves  $moves',style:const TextStyle(fontWeight:FontWeight.w800)))]),const SizedBox(height:20),Expanded(child:GridView.builder(itemCount:cards.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:.78),itemBuilder:(context,i){final revealed=open.contains(i)||matched.contains(i);return Semantics(button:true,label:revealed?cards[i]:'Hidden card',child:InkWell(onTap:()=>_tap(i),borderRadius:BorderRadius.circular(14),child:AnimatedContainer(duration:const Duration(milliseconds:160),decoration:BoxDecoration(color:revealed?const Color(0xFFE6E9DE):green,borderRadius:BorderRadius.circular(14),border:Border.all(color:matched.contains(i)?green:Colors.transparent,width:2)),child:Center(child:Text(revealed?cards[i]:'✦',style:TextStyle(fontSize:revealed?30:25,color:revealed?ink:Colors.white,fontWeight:FontWeight.w900))))));})),const SizedBox(height:8),Text('${matched.length~/2} of ${cards.length~/2} pairs found',style:const TextStyle(color:muted,fontWeight:FontWeight.w700)),const SizedBox(height:10)]))));
}

class SettingsScreen extends StatelessWidget { const SettingsScreen({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(leading:IconButton(icon:const Icon(Icons.arrow_back_rounded),onPressed:()=>Navigator.maybePop(context)),title:const Text('Settings')),body:ListView(padding:const EdgeInsets.all(20),children:const[Card(child:ListTile(leading:Icon(Icons.volume_up_outlined),title:Text('Sound'),subtitle:Text('Sound settings will be added with game preferences.'))),Card(child:ListTile(leading:Icon(Icons.privacy_tip_outlined),title:Text('Privacy policy'),subtitle:Text('Privacy information belongs here in Settings.'))),SizedBox(height:14),Text('RivalRooms • Early build',style:TextStyle(color:muted))])); }


class FruitCutGame extends StatefulWidget {
  const FruitCutGame({super.key});
  @override State<FruitCutGame> createState()=>_FruitCutGameState();
}
class _FruitCutGameState extends State<FruitCutGame> {
  final random=Random();
  final fruitPool=['🍉','🍊','🍋','🍓','🥝','🍍'];
  late List<String> fruits;
  int score=0,seconds=30;
  bool running=false,finished=false;
  Timer? timer;
  @override void initState(){super.initState();_newRound();}
  void _newRound(){timer?.cancel();setState((){fruits=List.generate(12,(_)=>fruitPool[random.nextInt(fruitPool.length)]);score=0;seconds=30;running=true;finished=false;});timer=Timer.periodic(const Duration(seconds:1),(t){if(!mounted)return;if(seconds<=1){t.cancel();setState((){seconds=0;running=false;finished=true;});}else{setState(()=>seconds--);}});}
  void _slice(int i){if(!running)return;setState((){score+=10;fruits[i]=fruitPool[random.nextInt(fruitPool.length)];});}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(leading:IconButton(tooltip:'Back',icon:const Icon(Icons.arrow_back_rounded),onPressed:()=>Navigator.maybePop(context)),title:const Text('Fruit Cut',style:TextStyle(fontWeight:FontWeight.w800)),actions:[IconButton(tooltip:'Restart',onPressed:_newRound,icon:const Icon(Icons.refresh_rounded))]),body:SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[
    Row(children:[_scorePill('SCORE',score.toString()),const Spacer(),_scorePill('TIME','${seconds}s')]),
    const SizedBox(height:14),const Align(alignment:Alignment.centerLeft,child:Text('Tap the fruit.',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900,letterSpacing:-.8))),
    const Align(alignment:Alignment.centerLeft,child:Text('Quick taps. Clean cuts. Chase your best.',style:TextStyle(color:muted))),
    const SizedBox(height:18),
    Expanded(child:GridView.builder(itemCount:fruits.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:12,mainAxisSpacing:12),itemBuilder:(context,i)=>Material(color:Colors.white,borderRadius:BorderRadius.circular(24),child:InkWell(onTap:()=>_slice(i),borderRadius:BorderRadius.circular(24),child:Center(child:Text(fruits[i],style:const TextStyle(fontSize:47))))))),
    if(finished)Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFFD4E4C8),borderRadius:BorderRadius.circular(18)),child:Row(children:[Expanded(child:Text('Time! Final score: $score',style:const TextStyle(fontWeight:FontWeight.w900))),FilledButton(onPressed:_newRound,child:const Text('Play again'))]))
  ]))));
}

Widget _scorePill(String label,String value)=>Container(padding:const EdgeInsets.symmetric(horizontal:17,vertical:11),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontSize:10,color:muted,fontWeight:FontWeight.w800,letterSpacing:1)),const SizedBox(height:3),Text(value,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900))]));

class BasketballGame extends StatefulWidget {
 const BasketballGame({super.key});
 @override State<BasketballGame> createState()=>_BasketballGameState();
}
class _BasketballGameState extends State<BasketballGame>{
 int score=0,seconds=30,streak=0;bool running=false,finished=false;Timer? timer;
 void _start(){timer?.cancel();setState((){score=0;seconds=30;streak=0;running=true;finished=false;});timer=Timer.periodic(const Duration(seconds:1),(t){if(!mounted)return;if(seconds<=1){t.cancel();setState((){seconds=0;running=false;finished=true;});}else{setState(()=>seconds--);}});}
 void _shoot(){if(!running)return;setState((){streak++;score+=streak%3==0?3:2;});}
 @override void initState(){super.initState();_start();}
 @override void dispose(){timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(leading:IconButton(tooltip:'Back',icon:const Icon(Icons.arrow_back_rounded),onPressed:()=>Navigator.maybePop(context)),title:const Text('Basketball Hoops',style:TextStyle(fontWeight:FontWeight.w800)),actions:[IconButton(tooltip:'Restart',onPressed:_start,icon:const Icon(Icons.refresh_rounded))]),body:SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[
  Row(children:[_scorePill('POINTS',score.toString()),const Spacer(),_scorePill('TIME','${seconds}s')]),
  const SizedBox(height:18),const Align(alignment:Alignment.centerLeft,child:Text('Find your rhythm.',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900,letterSpacing:-.8))),
  const Align(alignment:Alignment.centerLeft,child:Text('Tap SHOOT to sink the next basket.',style:TextStyle(color:muted))),
  const SizedBox(height:20),
  Expanded(child:Container(width:double.infinity,decoration:BoxDecoration(color:const Color(0xFFE7D7BD),borderRadius:BorderRadius.circular(26)),child:Stack(alignment:Alignment.center,children:[
   Positioned(top:28,child:Container(width:142,height:94,decoration:BoxDecoration(border:Border.all(color:const Color(0xFFB55E39),width:7),borderRadius:BorderRadius.circular(10)))),
   Positioned(top:116,child:Container(width:95,height:10,decoration:BoxDecoration(color:coral,borderRadius:BorderRadius.circular(6)))),
   Positioned(bottom:40,child:Container(width:200,height:100,decoration:BoxDecoration(border:Border.all(color:Colors.white.withValues(alpha:.75),width:3),borderRadius:const BorderRadius.vertical(top:Radius.circular(100))))),
   const Positioned(bottom:68,child:Text('🏀',style:TextStyle(fontSize:76))),
  ]))),
  const SizedBox(height:18),
  SizedBox(width:double.infinity,height:58,child:FilledButton.icon(onPressed:running?_shoot:_start,icon:const Icon(Icons.sports_basketball_rounded),label:Text(finished?'PLAY AGAIN':'SHOOT',style:const TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.3)),style:FilledButton.styleFrom(backgroundColor:coral,foregroundColor:ink,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(17))))),
  if(finished)Padding(padding:const EdgeInsets.only(top:12),child:Text('Final score: $score',style:const TextStyle(fontWeight:FontWeight.w800))),
 ]))));
}
