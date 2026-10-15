import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/chicken_jump_game.dart';

void main() {
  testWidgets('Chicken Jump shows controls, difficulty and start action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChickenJumpGame()));
    expect(find.text('Chicken Jump'), findsOneWidget);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Ready, chicken?'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    await tester.tap(find.text('Start run'));
    await tester.pump();
    expect(find.text('SCORE'), findsOneWidget);
    await tester.tap(find.byTooltip('Restart'));
    await tester.pump();
  });
}
