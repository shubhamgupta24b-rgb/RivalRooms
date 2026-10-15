import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/connect_four_logic.dart';
void main(){
 test('disc drops to the lowest free row',(){final g=ConnectFourLogic(startingPlayer:0);expect(g.drop(3),5);expect(g.drop(3),4);});
 test('turn alternates and invalid columns are rejected',(){final g=ConnectFourLogic(startingPlayer:0);g.drop(2);expect(g.turn,1);expect(g.drop(-1),isNull);expect(g.drop(7),isNull);});
 test('horizontal, vertical and diagonal lines win',(){final h=ConnectFourLogic(startingPlayer:0);for(final c in [0,0,1,1,2,2,3]){h.drop(c);}expect(h.winner,0);final v=ConnectFourLogic(startingPlayer:0);for(var i=0;i<3;i++){v.drop(0);v.drop(1);}v.drop(0);expect(v.winner,0);final d=ConnectFourLogic(startingPlayer:0);for(final c in [0,1,1,2,4,2,2,3,4,3,5,3,3]){d.drop(c);}expect(d.winner,0);});
 test('a full column rejects moves and reset clears state',(){final g=ConnectFourLogic(startingPlayer:0);for(var i=0;i<6;i++){g.drop(0);}expect(g.drop(0),isNull);g.reset(startingPlayer:1);expect(g.cells.every((v)=>v==-1),isTrue);expect(g.turn,1);});
}
