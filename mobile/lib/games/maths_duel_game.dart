import 'dart:math';
import 'package:flutter/material.dart';

class MathsDuelGame extends StatefulWidget {
  const MathsDuelGame({super.key});
  @override State<MathsDuelGame> createState() => _MathsDuelGameState();
}

class _MathsDuelGameState extends State<MathsDuelGame> {
  final Random rng = Random();
  int round = 1, player = 0, score1 = 0, score2 = 0, a = 3, b = 4, answer = 7;
  String op = '+';
  List<int> options = [];
  bool answered = false, finished = false;
  String feedback = '';
  @override void initState() { super.initState(); _question(); }

  void _question() {
    final kind = rng.nextInt(4);
    if (kind == 0) { a=rng.nextInt(20)+1; b=rng.nextInt(20)+1; op='+'; answer=a+b; }
    else if (kind == 1) { a=rng.nextInt(20)+10; b=rng.nextInt(a); op='−'; answer=a-b; }
    else if (kind == 2) { a=rng.nextInt(12)+2; b=rng.nextInt(10)+2; op='×'; answer=a*b; }
    else { b=rng.nextInt(10)+2; answer=rng.nextInt(12)+2; a=b*answer; op='÷'; }
    final values = <int>{answer};
    while (values.length < 4) { final d=rng.nextInt(11)-5; values.add(max(0,answer+(d==0?3:d))); }
    options=values.toList()..shuffle(rng); answered=false; feedback='';
  }
  void _pick(int value) {
    if(answered || finished)return;
    setState(() { answered=true; if(value==answer){if(player==0){score1++;}else{score2++;}feedback='Correct! +1 point';}else{feedback='Answer: '+answer.toString();} });
  }
  void _next() {
    if(finished){setState((){round=1;player=0;score1=0;score2=0;finished=false;_question();});return;}
    if(round==10 && player==1){setState(()=>finished=true);return;}
    setState(() { if(player==0){player=1;}else{player=0;round++;} _question(); });
  }
  @override Widget build(BuildContext context) {
    final result = score1==score2 ? 'It’s a tie!' : (score1>score2 ? 'Player 1 wins!' : 'Player 2 wins!');
    return Scaffold(
      appBar: AppBar(leading: IconButton(tooltip:'Back',icon:const Icon(Icons.arrow_back_rounded),onPressed:()=>Navigator.maybePop(context)),title:const Text('Maths Duel',style:TextStyle(fontWeight:FontWeight.w900)),actions:[IconButton(tooltip:'Restart',onPressed:()=>setState((){round=1;player=0;score1=0;score2=0;finished=false;_question();}),icon:const Icon(Icons.refresh_rounded))]),
      body: SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:finished
        ? Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Text('DUEL COMPLETE',style:TextStyle(color:Color(0xFF777A70),fontWeight:FontWeight.w900,letterSpacing:1.5)),const SizedBox(height:12),Text(result,style:const TextStyle(fontSize:32,fontWeight:FontWeight.w900)),const SizedBox(height:16),Text('Player 1  '+score1.toString()+' — '+score2.toString()+'  Player 2',style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800)),const SizedBox(height:24),FilledButton(onPressed:_next,child:const Text('Play again'))]))
        : Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Row(children:[Expanded(child:_scoreCard('PLAYER 1',score1,player==0)),const SizedBox(width:10),Expanded(child:_scoreCard('PLAYER 2',score2,player==1))]),const SizedBox(height:20),
          Row(children:[Text('ROUND '+round.toString()+' OF 10',style:const TextStyle(color:Color(0xFF777A70),fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.2)),const Spacer(),Text(player==0?'Player 1’s turn':'Player 2’s turn',style:const TextStyle(fontWeight:FontWeight.w800))]),const SizedBox(height:10),
          Container(padding:const EdgeInsets.symmetric(vertical:30,horizontal:16),decoration:BoxDecoration(color:const Color(0xFFE7DCC7),borderRadius:BorderRadius.circular(24)),child:Column(children:[const Text('SOLVE THIS',style:TextStyle(fontSize:10,color:Color(0xFF777A70),fontWeight:FontWeight.w900,letterSpacing:1.7)),const SizedBox(height:12),Text(a.toString()+' '+op+' '+b.toString()+' = ?',style:const TextStyle(fontSize:42,fontWeight:FontWeight.w900,letterSpacing:-1.4))])),const SizedBox(height:18),
          for(final value in options) Padding(padding:const EdgeInsets.only(bottom:10),child:SizedBox(height:52,child:OutlinedButton(onPressed:answered?null:()=>_pick(value),style:OutlinedButton.styleFrom(backgroundColor:answered&&value==answer?const Color(0xFFD4E4C8):Colors.white,foregroundColor:const Color(0xFF202520),side:BorderSide(color:answered&&value==answer?const Color(0xFF476B4B):Colors.black12),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15))),child:Text(value.toString(),style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900))))),
          const Spacer(),if(feedback.isNotEmpty)Padding(padding:const EdgeInsets.only(bottom:10),child:Text(feedback,textAlign:TextAlign.center,style:const TextStyle(fontWeight:FontWeight.w800))),FilledButton(onPressed:answered?_next:null,style:FilledButton.styleFrom(minimumSize:const Size.fromHeight(52),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15))),child:Text(round==10&&player==1?'Finish duel':player==0?'Pass to Player 2':'Next round')),
        ]))),
    );
  }
  Widget _scoreCard(String label,int score,bool active)=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:active?const Color(0xFFD4E4C8):Colors.white,borderRadius:BorderRadius.circular(17),border:Border.all(color:active?const Color(0xFF476B4B):Colors.black12)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:5),Text(score.toString(),style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900))]));
}
