import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/bike_racing_game.dart';
void main(){testWidgets('Bike Racing has start, score and lane controls',(tester)async{await tester.binding.setSurfaceSize(const Size(800,900));await tester.pumpWidget(const MaterialApp(home:BikeRacingGame()));expect(find.text('Bike Racing'),findsOneWidget);expect(find.text('Ready to ride?'),findsOneWidget);expect(find.text('Start race'),findsOneWidget);expect(find.text('Left'),findsOneWidget);expect(find.text('Right'),findsOneWidget);await tester.tap(find.text('Start race'));await tester.pump();expect(find.text('SCORE'),findsOneWidget);await tester.tap(find.byTooltip('Restart'));await tester.pump();await tester.binding.setSurfaceSize(null);});}
