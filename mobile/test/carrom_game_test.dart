import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/carrom_game.dart';
void main(){testWidgets('Carrom screen shows score, instructions and restart',(tester)async{await tester.binding.setSurfaceSize(const Size(800,900));await tester.pumpWidget(const MaterialApp(home:CarromGame()));expect(find.text('Carrom'),findsOneWidget);expect(find.text('PLAYER 1'),findsOneWidget);expect(find.text('PLAYER 2'),findsOneWidget);expect(find.textContaining('Drag back'),findsOneWidget);await tester.tap(find.byTooltip('Restart'));await tester.pump();await tester.binding.setSurfaceSize(null);});}
