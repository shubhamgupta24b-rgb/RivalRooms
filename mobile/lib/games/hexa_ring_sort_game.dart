import 'dart:math';
import 'package:flutter/material.dart';
import '../leave_game.dart';
import 'hexa_ring_sort_logic.dart';

class HexaRingSortGame extends StatefulWidget {
  const HexaRingSortGame({super.key});
  @override State<HexaRingSortGame> createState() => _HexaRingSortGameState();
}

class _HexaRingSortGameState extends State<HexaRingSortGame> {
  static const palette = [Color(0xFF36B66A), Color(0xFF35B8D5), Color(0xFF3978D9), Color(0xFFF08A3C), Color(0xFFE65359), Color(0xFFDE6DA8), Color(0xFFE5B93D), Color(0xFF9567C8)];
  int difficulty = 1, level = 1, selected = -1, hints = 2;
  final Map<int,int> unlocked = {0:1,1:1,2:1};
  final List<List<List<int>>> history = [];
  late HexaRingBoard board;
  bool won = false;
  String get mode => ['Easy','Medium','Hard'][difficulty];
  List<List<int>> get stacks => board.stacks;
  int get capacity => board.capacity;

  @override void initState() { super.initState(); _newLevel(); }
  void _newLevel() {
    final generated = HexaLevel.generate(level, difficulty);
    board = HexaRingBoard(generated.stacks.map((stack) => List<int>.from(stack)).toList(), generated.capacity);
    selected=-1; hints=2; won=false; history.clear();
  }
  bool get _complete => board.complete;
  bool _can(int f,int t) => board.canMove(f, t);
  void _tap(int i) {
    if(won)return;
    setState(() {
      if(selected<0) { if(stacks[i].isNotEmpty && !HexaRingBoard.solvedStack(stacks[i], capacity)) selected=i; return; }
      if(selected==i){selected=-1;return;}
      if(!_can(selected,i)){selected=stacks[i].isEmpty?-1:i;return;}
      history.add(board.snapshot());
      board.move(selected, i);
      selected=-1;
      if(_complete){won=true;unlocked[difficulty]=HexaLevel.unlockedAfterClear(unlocked: unlocked[difficulty]??1, level: level, complete: true);}
    });
    if(won) WidgetsBinding.instance.addPostFrameCallback((_) { if(mounted) _winDialog(); });
  }
  void _winDialog(){showDialog<void>(context:context,barrierDismissible:false,builder:(c)=>AlertDialog(title:const Text('Level complete!'),content:Text(level<50?'Level ${level+1} unlocked.':'All 50 $mode levels completed!'),actions:[FilledButton(onPressed:(){Navigator.pop(c);setState((){level=level<50?level+1:1;_newLevel();});},child:Text(level<50?'Next level':'Replay'))]));}
  void _undo(){if(history.isEmpty||won)return;setState((){board=HexaRingBoard(history.removeLast(),capacity);selected=-1;});}
  void _hint(){if(hints<=0||won)return;for(var f=0;f<stacks.length;f++){for(var t=0;t<stacks.length;t++){if(_can(f,t)){setState((){selected=f;hints--;});ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Move a ring from stack ${f+1} to stack ${t+1}.')));return;}}}ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('No useful move found. Try Undo.')));}
  void _changeMode(int v){setState((){difficulty=v;level=min(level,unlocked[v]??1);_newLevel();});}
  void _showLevels() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, refresh) => SizedBox(
          height: MediaQuery.of(ctx).size.height * .72,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Level trail', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: [
                    for (var d = 0; d < 3; d++)
                      ChoiceChip(
                        label: Text(['Easy', 'Medium', 'Hard'][d]),
                        selected: difficulty == d,
                        onSelected: (_) {
                          setState(() { difficulty = d; level = min(level, unlocked[d] ?? 1); _newLevel(); });
                          refresh(() {});
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    itemCount: 50,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 7,
                      mainAxisSpacing: 7,
                    ),
                    itemBuilder: (_, i) {
                      final n = i + 1;
                      final open = n <= (unlocked[difficulty] ?? 1);
                      return FilledButton(
                        onPressed: open ? () {
                          setState(() { level = n; _newLevel(); });
                          Navigator.pop(ctx);
                        } : null,
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: n == level ? const Color(0xFFFFC857) : Colors.white,
                          foregroundColor: const Color(0xFF282036),
                        ),
                        child: Text(open ? '$n' : '🔒'),
                      );
                    },
                  ),
                ),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back to board')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LeaveGameScope(
      confirm: history.isNotEmpty && !won,
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Hexa Ring Sort', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Levels',
            onPressed: _showLevels,
            icon: const Icon(Icons.map_outlined),
          ),
          IconButton(
            tooltip: 'Restart level',
            onPressed: () => setState(_newLevel),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: _stat('LEVEL', '$level / 50')),
                const SizedBox(width: 8),
                Expanded(child: _stat('MOVES', '${history.length}')),
              ]),
              const SizedBox(height: 12),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Easy')),
                  ButtonSegment(value: 1, label: Text('Medium')),
                  ButtonSegment(value: 2, label: Text('Hard')),
                ],
                selected: {difficulty},
                showSelectedIcon: false,
                onSelectionChanged: (s) => _changeMode(s.first),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Sort every ring by colour', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Tap a stack, then a matching stack or an empty one.', style: TextStyle(color: Color(0xFF777A70), fontSize: 12)),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF282036), borderRadius: BorderRadius.circular(24)),
                  child: GridView.builder(
                    itemCount: stacks.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: stacks.length > 8 ? 5 : 4,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 12,
                      childAspectRatio: .72,
                    ),
                    itemBuilder: (context, i) {
                      final stack = stacks[i];
                      final active = selected == i;
                      return GestureDetector(
                        onTap: () => _tap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          transform: Matrix4.translationValues(0, active ? -5 : 0, 0),
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF4A3A5E) : const Color(0xFF342A43),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: active ? const Color(0xFFFFC857) : Colors.white12,
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      for (final color in stack.reversed)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
                                          child: Container(
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: palette[color % palette.length],
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.white54),
                                            ),
                                            child: Center(
                                              child: Text(
                                                ['♣', '◆', '●', 'ϟ', '♥', '♛', '☀', '★'][color % 8],
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 7,
                                margin: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                                decoration: BoxDecoration(color: const Color(0xFFB8B9C4), borderRadius: BorderRadius.circular(5)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _action(Icons.undo_rounded, 'Undo', history.isNotEmpty ? _undo : null)),
                const SizedBox(width: 8),
                Expanded(child: _action(Icons.lightbulb_outline, 'Hint ($hints)', hints > 0 ? _hint : null)),
                const SizedBox(width: 8),
                Expanded(child: _action(Icons.restart_alt, 'Restart', () => setState(_newLevel))),
              ]),
              const SizedBox(height: 8),
              Text('Unlocked: ${unlocked[difficulty] ?? 1} / 50 • $mode', style: const TextStyle(color: Color(0xFF777A70), fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _stat(String a,String b)=>Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:const TextStyle(fontSize:9,letterSpacing:1,color:Color(0xFF777A70),fontWeight:FontWeight.w900)),Text(b,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900))]));
  Widget _action(IconData icon,String label,VoidCallback? fn)=>FilledButton.tonal(onPressed:fn,style:FilledButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:11),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:18),Text(label,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800))]));
}
