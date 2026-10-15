import 'package:flutter/material.dart';
import 'connect_four_logic.dart';
class ConnectFourGame extends StatefulWidget { const ConnectFourGame({super.key}); @override State<ConnectFourGame> createState()=>_ConnectFourGameState(); }
class _ConnectFourGameState extends State<ConnectFourGame> {
 late ConnectFourLogic game;
 @override void initState(){super.initState();game=ConnectFourLogic();}
 void drop(int col){if(game.drop(col)!=null)setState((){});}
 @override Widget build(BuildContext context){return Scaffold(appBar:AppBar(leading:IconButton(icon:const Icon(Icons.arrow_back),onPressed:()=>Navigator.maybePop(context)),title:const Text('Connect Four'),actions:[IconButton(icon:const Icon(Icons.refresh),onPressed:()=>setState(()=>game.reset()))]),body:Column(children:[Text(game.winner==null?'Player turn':'Player wins'),Expanded(child:GridView.builder(itemCount:42,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7),itemBuilder:(context,i){final p=game.cells[i];return InkWell(onTap:game.finished?null:()=>drop(i%7),child:Container(margin:const EdgeInsets.all(3),decoration:BoxDecoration(shape:BoxShape.circle,color:p<0?const Color(0xFF31594B):p==0?const Color(0xFF3267A8):const Color(0xFFE4775D)),child:p<0?null:Center(child:Text('${p+1}'))));})),if(game.finished)FilledButton(onPressed:()=>setState(()=>game.reset()),child:const Text('Play again'))]));}
}
