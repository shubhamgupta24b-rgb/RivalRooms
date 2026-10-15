import 'package:flutter/material.dart';
import 'connect_four_logic.dart';
class ConnectFourGame extends StatefulWidget { const ConnectFourGame({super.key}); @override State<ConnectFourGame> createState()=>_ConnectFourGameState(); }
class _ConnectFourGameState extends State<ConnectFourGame> {
 late ConnectFourLogic game;
 @override void initState(){super.initState();game=ConnectFourLogic();}
 void drop(int c){if(game.drop(c)!=null)setState((){});}
 @override Widget build(BuildContext context){
 const blue=Color(0xFF3267A8),red=Color(0xFFE4775D); final done=game.finished;
 final status=game.winner!=null?'Player ${game.winner!+1} wins':game.isDraw?'Draw':'Player ${game.turn+1} turn';
 return Scaffold(appBar:AppBar(leading:IconButton(tooltip:'Back',icon:const Icon(Icons.arrow_back),onPressed:()=>Navigator.maybePop(context)),title:const Text('Connect Four'),actions:[IconButton(onPressed:()=>setState(()=>game.reset()),icon:const Icon(Icons.refresh))]),body:SafeArea(child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[Text(status,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:12),Expanded(child:Center(child:AspectRatio(aspectRatio:7/6,child:Container(padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:const Color(0xFF31594B),borderRadius:BorderRadius.circular(14)),child:GridView.builder(physics:const NeverScrollableScrollPhysics(),itemCount:42,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7,crossAxisSpacing:4,mainAxisSpacing:4),itemBuilder:(context,i){final p=game.cells[i];return InkWell(onTap:done?null:()=>drop(i%7),child:Container(decoration:BoxDecoration(shape:BoxShape.circle,color:p<0?const Color(0xFF25463B):p==0?blue:red,border:Border.all(color:game.winCells.contains(i)?const Color(0xFFFFD166):Colors.white,width:game.winCells.contains(i)?3:1)),child:p<0?null:Center(child:Text('${p+1}',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900)))));}))))),Text(done?'Round complete':'Tap a column to drop',style:const TextStyle(color:Color(0xFF777A70))),const SizedBox(height:10),FilledButton(onPressed:done?()=>setState(()=>game.reset()):null,child:const Text('Play again'))]))));}
}
