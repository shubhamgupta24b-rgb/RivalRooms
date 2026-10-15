import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'games/hexa_ring_sort_game.dart';
import 'games/maths_duel_game.dart';
import 'games/connect_four_game.dart';
import 'games/candy_match3_game.dart';
import 'games/fruit_cut_arcade_game.dart';
import 'games/pool_game.dart';
import 'games/battleship_game.dart';
import 'games/chicken_jump_game.dart';
import 'games/carrom_game.dart';
import 'games/bike_racing_game.dart';
import 'games/raja_mantri_chor_sipahi_game.dart';

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
 GameInfo('Suika Pop','Merge fruits. Grow the watermelon.','🍒','Quick play',Color(0xFFFFD8BE)),
 GameInfo('Hexa Ring Sort','Sort colourful rings across 50 levels','💠','Puzzle games',Color(0xFFE6D5F2)),
 GameInfo('Guess the Person','Can you read their clues?','🕵️','Party games',Color(0xFFDAD6ED)),
 GameInfo('Connect Four','Four in a row wins','🔴','Board games',Color(0xFFF0D1CB)),
 GameInfo('Battleship','Outsmart your opponent','🚢','Board games',Color(0xFFC9DFE1)),
 GameInfo('Pool','Line up the perfect shot','🎱','Board games',Color(0xFFD1E2CE)),
 GameInfo('Maths Duel','Fast answers, close race','➗','Quick play',Color(0xFFF0D9AA)),
 GameInfo('Candy Match 3','Match fruit, clear levels, use power-ups','🍬','Puzzle games',Color(0xFFE6D5F2)),
 GameInfo('Chicken Jump','Jump over obstacles and beat your best','🐔','Quick play',Color(0xFFF2D9A8)),
 GameInfo('Carrom','Aim your striker and pocket the coins','🟤','Board games',Color(0xFFE7C9A7)),
 GameInfo('Bike Racing','Dodge traffic and beat your best','🏍️','Quick play',Color(0xFFD4E4C8)),
 GameInfo('Raja Mantri Chor Sipahi','Four roles. One clever guess.','👑','Party games',Color(0xFFE9D9A9)),
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
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const FruitCutArcadeGame()));
   } else if (game.title=='Basketball Hoops') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const BasketballGame()));
   } else if (game.title=='Guess the Person') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const GuessPersonGame()));
   } else if (game.title=='Suika Pop') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const SuikaPopGame()));
   } else if (game.title=='Hexa Ring Sort') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const HexaRingSortGame()));
   } else if (game.title=='Maths Duel') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const MathsDuelGame()));
   } else if (game.title=='Candy Match 3') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const CandyMatch3Game()));
   } else if (game.title=='Connect Four') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const ConnectFourGame()));
   } else if (game.title=='Pool') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const PoolGame()));
   } else if (game.title=='Battleship') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const BattleshipGame()));
   } else if (game.title=='Chicken Jump') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const ChickenJumpGame()));
   } else if (game.title=='Carrom') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const CarromGame()));
   } else if (game.title=='Bike Racing') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const BikeRacingGame()));
   } else if (game.title=='Raja Mantri Chor Sipahi') {
     Navigator.push(context,MaterialPageRoute(builder:(_)=>const RajaMantriChorSipahiGame()));
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
 Widget _home() => ListView(
  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
  children: [
    const Text('GOOD GAMES. GREAT COMPANY.', style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w800, color: muted)),
    const SizedBox(height: 8),
    const Text('Who’s your\nnext rival?', style: TextStyle(fontSize: 38, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.7, color: ink)),
    const SizedBox(height: 18),
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(24)),
      child: Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MAKE IT A MATCH', style: TextStyle(color: Color(0xFFD8E3D1), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
          SizedBox(height: 8),
          Text('Play with friends\nwherever they are.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 21, height: 1.2)),
          SizedBox(height: 15),
        ])),
        Container(width: 74, height: 84, decoration: BoxDecoration(color: Color(0xFF5D805F), borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Text('🏆', style: TextStyle(fontSize: 42)))),
      ]),
    ),
    const SizedBox(height: 12),
    FilledButton.icon(
      onPressed: () => setState(() => tab = 1),
      icon: const Icon(Icons.group_add_rounded),
      label: const Text('Create or join a room'),
      style: FilledButton.styleFrom(backgroundColor: coral, foregroundColor: ink, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    ),
    const SizedBox(height: 26),
    _sectionTitle('Pick up and play', 'See all', () => setState(() => tab = 2)),
    const SizedBox(height: 12),
    SizedBox(
      height: 174,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final g = games[i];
          return SizedBox(
            width: 164,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => openGame(g),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: g.color, borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Align(alignment: Alignment.topRight, child: Text(g.emoji, style: const TextStyle(fontSize: 39))),
                  const Spacer(),
                  Text(g.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, height: 1.1, color: ink)),
                  const SizedBox(height: 4),
                  Text(g.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: ink)),
                ]),
              ),
            ),
          );
        },
      ),
    ),
    const SizedBox(height: 26),
    _sectionTitle('Play your way', null, null),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _modeTile('Online', 'Friends anywhere', Icons.public_rounded, green, () => setState(() => tab = 1))),
      const SizedBox(width: 10),
      Expanded(child: _modeTile('Same room', 'Pass and play', Icons.phonelink_rounded, coral, () => setState(() => tab = 2))),
    ]),
    const SizedBox(height: 20),
    const Text('More games are on the way.', style: TextStyle(color: muted, fontSize: 12)),
  ],
 );
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
 int cardCount=24;
 static const symbols=['🍋','🍒','🍇','🍉','🥝','🍊','🍓','🍍','🍑','🍈','🍏','🥥','🫐','🍐','🍌','🍅'];
 void _reset(){final chosen=symbols.take(cardCount~/2).toList();cards=[...chosen,...chosen]..shuffle(Random());open.clear();matched.clear();moves=0;busy=false;}
 Future<void> _tap(int i) async {
  if(busy||matched.contains(i)||open.contains(i))return;
  setState(()=>open.add(i));
  if(open.length==2){setState(()=>moves++);final pair=open.toList();if(cards[pair[0]]==cards[pair[1]]){setState(()=>matched.addAll(pair));await Future<void>.delayed(const Duration(milliseconds:250));if(matched.length==cards.length&&mounted){showDialog<void>(context:context,builder:(c)=>AlertDialog(title:const Text('Perfect match!'),content:Text('You finished in $moves moves.'),actions:[TextButton(onPressed:(){Navigator.pop(c);setState(_reset);},child:const Text('Play again'))]));}}else{busy=true;await Future<void>.delayed(const Duration(milliseconds:700));if(mounted)setState(()=>open.clear());busy=false;}}
 }
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(leading:IconButton(tooltip:'Back',icon:const Icon(Icons.arrow_back_rounded),onPressed:()=>Navigator.maybePop(context)),title:const Text('Memory Match',style:TextStyle(fontWeight:FontWeight.w800)),actions:[IconButton(tooltip:'Restart',onPressed:()=>setState(_reset),icon:const Icon(Icons.refresh_rounded))]),body:SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[Row(children:[const Expanded(child:Text('Find every pair.',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900))),DropdownButton<int>(value:cardCount,underline:const SizedBox.shrink(),items:const [8,12,16,20,24,28,32].map((n)=>DropdownMenuItem(value:n,child:Text('$n cards'))).toList(),onChanged:(n){if(n!=null)setState((){cardCount=n;_reset();});}),const SizedBox(width:8),Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:9),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),child:Text('Moves  $moves',style:const TextStyle(fontWeight:FontWeight.w800)))]),const SizedBox(height:20),Expanded(child:GridView.builder(itemCount:cards.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:.78),itemBuilder:(context,i){final revealed=open.contains(i)||matched.contains(i);return Semantics(button:true,label:revealed?cards[i]:'Hidden card',child:InkWell(onTap:()=>_tap(i),borderRadius:BorderRadius.circular(14),child:AnimatedContainer(duration:const Duration(milliseconds:160),decoration:BoxDecoration(color:revealed?const Color(0xFFE6E9DE):green,borderRadius:BorderRadius.circular(14),border:Border.all(color:matched.contains(i)?green:Colors.transparent,width:2)),child:Center(child:Text(revealed?cards[i]:'✦',style:TextStyle(fontSize:revealed?30:25,color:revealed?ink:Colors.white,fontWeight:FontWeight.w900))))));})),const SizedBox(height:8),Text('${matched.length~/2} of ${cards.length~/2} pairs found',style:const TextStyle(color:muted,fontWeight:FontWeight.w700)),const SizedBox(height:10)]))));
}


class GuessPersonGame extends StatefulWidget {
  const GuessPersonGame({super.key});
  @override State<GuessPersonGame> createState() => _GuessPersonGameState();
}
class _GuessPersonGameState extends State<GuessPersonGame> {
  static const people = <({String clue, List<String> options, String answer})>[
    (clue: 'I painted the Mona Lisa and studied anatomy, engineering, and flight.', options: ['Vincent van Gogh', 'Leonardo da Vinci', 'Pablo Picasso', 'Claude Monet'], answer: 'Leonardo da Vinci'),
    (clue: 'I developed the theory of relativity and won the Nobel Prize in Physics.', options: ['Isaac Newton', 'Niels Bohr', 'Albert Einstein', 'Galileo Galilei'], answer: 'Albert Einstein'),
    (clue: 'I wrote the Harry Potter book series.', options: ['J. R. R. Tolkien', 'Jane Austen', 'Agatha Christie', 'J. K. Rowling'], answer: 'J. K. Rowling'),
    (clue: 'I led India’s non-violent independence movement and was known as Mahatma.', options: ['Sardar Patel', 'Jawaharlal Nehru', 'Mahatma Gandhi', 'B. R. Ambedkar'], answer: 'Mahatma Gandhi'),
    (clue: 'I became the first person to walk on the Moon in 1969.', options: ['Buzz Aldrin', 'Yuri Gagarin', 'Neil Armstrong', 'Michael Collins'], answer: 'Neil Armstrong'),
    (clue: 'I am a scientist famous for research on radioactivity and won two Nobel Prizes.', options: ['Rosalind Franklin', 'Marie Curie', 'Ada Lovelace', 'Jane Goodall'], answer: 'Marie Curie'),
  ];
  late ({String clue, List<String> options, String answer}) person;
  String? selected;
  @override void initState() { super.initState(); _newPerson(); }
  void _newPerson() {
    final pool = List.of(people)..removeWhere((p) => p == personOrNull);
    final next = (pool.isEmpty ? people : pool)[Random().nextInt(pool.isEmpty ? people.length : pool.length)];
    setState(() { person = next; selected = null; });
  }
  ({String clue, List<String> options, String answer})? get personOrNull {
    try { return person; } catch (_) { return null; }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: IconButton(tooltip: 'Back', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.maybePop(context)), title: const Text('Guess the Person', style: TextStyle(fontWeight: FontWeight.w800))),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ONE CLUE. ONE ANSWER.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: muted, letterSpacing: 1.3)),
      const SizedBox(height: 16),
      Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFFDAD6ED), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('WHO AM I?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: ink)),
        const SizedBox(height: 12),
        Text(person.clue, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.25, color: ink)),
      ])),
      const SizedBox(height: 22),
      const Text('Pick one person', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      ...person.options.map((option) {
        final correct = option == person.answer;
        final chosen = option == selected;
        final background = selected == null ? Colors.white : correct ? const Color(0xFFD4E4C8) : chosen ? const Color(0xFFF0D1CB) : Colors.white;
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Material(
            color: background,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: selected == null ? () => setState(() => selected = option) : null,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: chosen ? green : const Color(0xFFE4E2D9)),
                ),
                child: Row(children: [
                  Expanded(child: Text(option, style: const TextStyle(fontWeight: FontWeight.w700))),
                  if (selected != null && correct) const Icon(Icons.check_circle_rounded, color: green),
                  if (chosen && !correct) const Icon(Icons.close_rounded, color: coral),
                ]),
              ),
            ),
          ),
        );
      }),
      if (selected != null) ...[
        const SizedBox(height: 4),
        Text(selected == person.answer ? 'That’s right!' : 'Not quite — it was ${person.answer}.', style: TextStyle(fontWeight: FontWeight.w800, color: selected == person.answer ? green : coral)),
        const Spacer(),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: _newPerson, child: const Text('Next person'))),
      ] else
        const Spacer(),
    ]))),
  );
}


class SuikaPopGame extends StatefulWidget {
  const SuikaPopGame({super.key});
  @override State<SuikaPopGame> createState() => _SuikaPopGameState();
}
class _SuikaPopGameState extends State<SuikaPopGame> with SingleTickerProviderStateMixin {
  static const names = ['Cherry','Strawberry','Grape','Orange','Persimmon','Apple','Pear','Peach','Pineapple','Melon','Watermelon'];
  static const emojis = ['🍒','🍓','🍇','🍊','🟠','🍎','🍐','🍑','🍍','🍈','🍉'];
  static const colors = [Color(0xFFFF3B5C),Color(0xFFFF5E4D),Color(0xFF9B5DE5),Color(0xFFFF9F1C),Color(0xFFFF7B00),Color(0xFFE63946),Color(0xFFA7C957),Color(0xFFFF85A1),Color(0xFFF4D35E),Color(0xFF52B788),Color(0xFF2D6A4F)];
  static const radii = [13.0,17.0,21.0,25.0,29.0,34.0,39.0,44.0,49.0,55.0,61.0];
  final random = Random();
  final List<_SuikaFruit> fruits = [];
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _width = 320, _height = 440, _aimX = 160;
  int score = 0, best = 0, currentTier = 0, nextTier = 0;
  int shakes = 2, pops = 2, boosts = 2, overflowFrames = 0;
  bool gameOver = false, showAim = true, canDrop = true;
  double _dropCooldown = 0;
  @override void initState() {
    super.initState();
    currentTier = random.nextInt(4); nextTier = random.nextInt(4);
    _ticker = createTicker(_tick)..start();
  }
  void _tick(Duration elapsed) {
    if (_last == Duration.zero) { _last = elapsed; return; }
    final dt = ((elapsed - _last).inMicroseconds / 1000000).clamp(0.0, .04);
    _last = elapsed;
    if (!gameOver) {
      _dropCooldown = max(0, _dropCooldown - dt);
      canDrop = _dropCooldown <= 0;
      for (final f in fruits) {
        f.vy += 620 * dt;
        f.x += f.vx * dt; f.y += f.vy * dt;
        if (f.x - f.r < 4) { f.x = f.r + 4; f.vx = f.vx.abs() * .45; }
        if (f.x + f.r > _width - 4) { f.x = _width - f.r - 4; f.vx = -f.vx.abs() * .45; }
        if (f.y + f.r > _height - 4) { f.y = _height - f.r - 4; f.vy = -f.vy.abs() * .16; f.vx *= .94; }
      }
      for (var pass=0; pass<2; pass++) {
        for (var i=0; i<fruits.length; i++) {
          for (var j=i+1; j<fruits.length; j++) {
            final a=fruits[i], b=fruits[j];
            final dx=b.x-a.x, dy=b.y-a.y, d=sqrt(dx*dx+dy*dy), minD=a.r+b.r;
            if (d >= minD || d == 0) continue;
            if (a.tier == b.tier && a.tier < names.length-1) {
              final tier=a.tier+1, x=(a.x+b.x)/2, y=(a.y+b.y)/2;
              fruits.removeAt(j); fruits.removeAt(i);
              fruits.add(_SuikaFruit(x,y,tier,vy:-150));
              score += (1 << (tier+1));
              best=max(best,score);
              i=-1; break;
            }
            final overlap=minD-d, nx=dx/d, ny=dy/d;
            a.x -= nx*overlap*.5; a.y -= ny*overlap*.5;
            b.x += nx*overlap*.5; b.y += ny*overlap*.5;
            if ((a.vx-b.vx)*nx+(a.vy-b.vy)*ny > 0) {
              final avx=a.vx, avy=a.vy; a.vx=b.vx*.55; a.vy=b.vy*.35; b.vx=avx*.55; b.vy=avy*.35;
            }
          }
        }
      }
      final danger=fruits.any((f)=>f.y-f.r<64 && f.vy.abs()<25);
      overflowFrames = danger ? overflowFrames+1 : max(0,overflowFrames-2);
      if (overflowFrames > 100) gameOver=true;
    }
    if (mounted) setState(() {});
  }
  void _drop() {
    if (gameOver || !canDrop) return;
    final r=radii[currentTier];
    fruits.add(_SuikaFruit(_aimX.clamp(r+4,_width-r-4), 30, currentTier, vy:75, vx:(random.nextDouble()-.5)*12));
    currentTier=nextTier; nextTier=random.nextInt(5); _dropCooldown=.48; canDrop=false;
    setState(() {});
  }
  void _reset() {
    setState(() { fruits.clear(); score=0; overflowFrames=0; gameOver=false; shakes=2; pops=2; boosts=2; currentTier=random.nextInt(4); nextTier=random.nextInt(4); canDrop=true; _dropCooldown=0; });
  }
  void _shake() {
    if (shakes==0 || gameOver) return;
    setState(() { shakes--; for(final f in fruits){f.vy=-180-random.nextDouble()*140;f.vx+=(random.nextDouble()-.5)*180;} });
  }
  void _pop() {
    if (pops==0 || gameOver || fruits.isEmpty) return;
    fruits.sort((a,b)=>a.tier.compareTo(b.tier));
    setState(() { pops--; fruits.removeRange(0,min(2,fruits.length)); });
  }
  void _boost() {
    if (boosts==0 || gameOver || currentTier>=names.length-1) return;
    setState(() { boosts--; currentTier++; });
  }
  @override void dispose(){_ticker.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(leading:IconButton(tooltip:'Back',icon:const Icon(Icons.arrow_back_rounded),onPressed:()=>Navigator.maybePop(context)),title:const Text('Suika Pop',style:TextStyle(fontWeight:FontWeight.w900)),actions:[IconButton(tooltip:'Aim line',onPressed:()=>setState(()=>showAim=!showAim),icon:Icon(showAim?Icons.gps_fixed_rounded:Icons.gps_not_fixed_rounded)),IconButton(tooltip:'Reset',onPressed:_reset,icon:const Icon(Icons.refresh_rounded))]),
    body:SafeArea(child:LayoutBuilder(builder:(context,box){
      _width=box.maxWidth.clamp(260.0,520.0).toDouble(); _height=max(300.0,box.maxHeight-190).toDouble(); _aimX=_aimX.clamp(20,_width-20).toDouble();
      return Padding(padding:const EdgeInsets.fromLTRB(14,4,14,12),child:Column(children:[
        Row(children:[
          Expanded(child:_suikaStat('SCORE','$score')),
          const SizedBox(width:8),Expanded(child:_suikaStat('BEST','$best')),
          const SizedBox(width:8),Expanded(child:Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15)),child:Row(children:[Text(emojis[nextTier],style:const TextStyle(fontSize:25)),const SizedBox(width:6),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('NEXT',style:TextStyle(fontSize:9,color:muted,fontWeight:FontWeight.w900)),Text(names[nextTier],maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800))]))]))),
        ]),
        const SizedBox(height:10),
        Expanded(child:Center(child:AspectRatio(aspectRatio:_width/_height,child:GestureDetector(
          behavior:HitTestBehavior.opaque,
          onTapDown:(d){_aimX=d.localPosition.dx;_drop();},
          onPanUpdate:(d)=>setState(()=>_aimX=d.localPosition.dx.clamp(10,_width-10).toDouble()),
          onPanEnd:(_)=>_drop(),
          child:ClipRRect(borderRadius:BorderRadius.circular(22),child:CustomPaint(
            painter:_SuikaPainter(fruits:fruits,width:_width,height:_height,aimX:_aimX,aimTier:currentTier,showAim:showAim,gameOver:gameOver,overflow:overflowFrames>0),
            child:gameOver?Container(color:const Color(0xAA3B2925),child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('JAR OVERFLOWED',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:23)),const SizedBox(height:6),Text('Score  $score',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w700,fontSize:17)),const SizedBox(height:14),FilledButton(onPressed:_reset,child:const Text('Play again'))]))):null,
          )),
        )))),
        const SizedBox(height:10),
        Row(children:[
          _powerButton('🫨','Shake jar',shakes,_shake),
          const SizedBox(width:8),_powerButton('✨','Berry pop',pops,_pop),
          const SizedBox(width:8),_powerButton('⬆️','Evo boost',boosts,_boost),
        ]),
        const SizedBox(height:8),
        Text('Drop matching fruits to merge them into bigger ones.',style:TextStyle(color:muted,fontSize:12)),
      ]));
    })),
  );
  Widget _suikaStat(String label,String value)=>Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontSize:9,color:muted,fontWeight:FontWeight.w900,letterSpacing:1)),Text(value,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:ink))]));
  Widget _powerButton(String emoji,String title,int count,VoidCallback action)=>Expanded(child:FilledButton.tonal(onPressed:count>0&&!gameOver?action:null,style:FilledButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:10),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))),child:Column(children:[Text(emoji,style:const TextStyle(fontSize:19)),Text(title,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800)),Text('$count left',style:const TextStyle(fontSize:9))])));
}
class _SuikaFruit {
  double x,y,vx,vy; final int tier; late final double r;
  _SuikaFruit(this.x,this.y,this.tier,{this.vx=0,this.vy=0}) { r=_SuikaPopGameState.radii[tier]; }
}
class _SuikaPainter extends CustomPainter {
  final List<_SuikaFruit> fruits; final double width,height,aimX; final int aimTier; final bool showAim,gameOver,overflow;
  _SuikaPainter({required this.fruits,required this.width,required this.height,required this.aimX,required this.aimTier,required this.showAim,required this.gameOver,required this.overflow});
  @override void paint(Canvas canvas,Size size) {
    final rect=Offset.zero & size;
    canvas.drawRect(rect,Paint()..shader=const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xFFFFF8EE),Color(0xFFFFDCC5)]).createShader(rect));
    final danger=Paint()..color=overflow?const Color(0xFFFF4C50):const Color(0x66FF5E62)..strokeWidth=2;
    for(double x=0;x<size.width;x+=12){canvas.drawLine(Offset(x,64),Offset(min(x+6,size.width),64),danger);}
    if(showAim&&!gameOver){final p=Paint()..color=const Color(0x66FF5E62)..strokeWidth=1.5;for(double y=30;y<size.height;y+=12){canvas.drawLine(Offset(aimX,y),Offset(aimX,min(y+5,size.height)),p);} _fruit(canvas,Offset(aimX,30),_SuikaPopGameState.radii[aimTier],aimTier,alpha:.85);}
    for(final f in fruits){_fruit(canvas,Offset(f.x,f.y),f.r,f.tier);}
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0,0,size.width,size.height),const Radius.circular(22)),Paint()..color=Colors.white.withValues(alpha:.5)..style=PaintingStyle.stroke..strokeWidth=5);
  }
  void _fruit(Canvas canvas,Offset center,double r,int tier,{double alpha=1}) {
    canvas.save();canvas.translate(center.dx,center.dy);
    final color=_SuikaPopGameState.colors[tier];
    canvas.drawCircle(Offset(0,2),r,Paint()..color=Colors.black.withValues(alpha:.08*alpha));
    canvas.drawCircle(Offset.zero,r,Paint()..shader=RadialGradient(center:const Alignment(-.35,-.45),radius:1,colors:[Color.lerp(Colors.white,color,.25)!,color]).createShader(Rect.fromCircle(center:Offset.zero,radius:r))..color=Colors.white.withValues(alpha:alpha));
    canvas.drawCircle(Offset.zero,r,Paint()..color=Colors.white.withValues(alpha:.55*alpha)..style=PaintingStyle.stroke..strokeWidth=1.6);
    if(r>=15){final eye=Paint()..color=const Color(0xFF3B1F1E).withValues(alpha:alpha);canvas.drawCircle(Offset(-r*.25,-r*.08),max(1.5,r*.075),eye);canvas.drawCircle(Offset(r*.25,-r*.08),max(1.5,r*.075),eye);final smile=Path()..moveTo(-r*.13,r*.18)..quadraticBezierTo(0,r*.32,r*.13,r*.18);canvas.drawPath(smile,Paint()..color=const Color(0xFF3B1F1E).withValues(alpha:alpha)..style=PaintingStyle.stroke..strokeWidth=max(1,r*.045)..strokeCap=StrokeCap.round);}
    canvas.restore();
  }
  @override bool shouldRepaint(covariant _SuikaPainter old)=>true;
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
