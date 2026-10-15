import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/connect_four_logic.dart';
void main() {
 test('discs fall and turns alternate', () {
  final g=ConnectFourLogic(startingPlayer:0);
  expect(g.drop(3),5); expect(g.at(3,5),0); expect(g.turn,1);
  expect(g.drop(3),4); expect(g.at(3,4),1);
 });
 test('rejects invalid and full columns', () {
  final g=ConnectFourLogic(startingPlayer:0);
  expect(g.drop(-1),isNull); expect(g.drop(7),isNull);
  for(var i=0;i<6;i++){expect(g.drop(0),isNotNull);}
  final turn=g.turn,moves=g.moves;
  expect(g.drop(0),isNull); expect(g.turn,turn); expect(g.moves,moves);
 });
 test('detects horizontal, vertical and diagonal wins', () {
  final h=ConnectFourLogic(startingPlayer:0);
  for(final c in [0,0,1,1,2,2,3]){h.drop(c);}
  expect(h.winner,0); expect(h.winCells.length,greaterThanOrEqualTo(4));
  final v=ConnectFourLogic(startingPlayer:0);
  for(var i=0;i<3;i++){v.drop(0);v.drop(1);} v.drop(0);
  expect(v.winner,0);
  final d=ConnectFourLogic(startingPlayer:0);
  for(final c in [0,1,1,2,4,2,2,3,4,3,5,3,3]){d.drop(c);}
  expect(d.winner,0);
 });
 test('stops after win and reset clears the board', () {
  final g=ConnectFourLogic(startingPlayer:0);
  for(final c in [0,0,1,1,2,2,3]){g.drop(c);}
  expect(g.finished,isTrue); expect(g.drop(4),isNull);
  g.reset(startingPlayer:1);
  expect(g.cells.every((v)=>v==-1),isTrue); expect(g.turn,1); expect(g.moves,0);
 });
}
