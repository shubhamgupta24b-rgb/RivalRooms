import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/chicken_jump_game.dart';

void main() {
  testWidgets('Chicken Jump shows controls, difficulty and start action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChickenJumpGame()));
    expect(find.text('Chicken Jump'), findsOneWidget);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<JumpDifficulty>));
    await tester.pumpAndSettle();
    expect(find.text('Easy'), findsWidgets);
    expect(find.text('Hard'), findsWidgets);
    await tester.tap(find.text('Medium').last);
    await tester.pumpAndSettle();
    expect(find.text('Ready, chicken?'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    await tester.tap(find.text('Start run'));
    await tester.pump();
    expect(find.text('SCORE'), findsOneWidget);
    await tester.tap(find.byTooltip('Restart'));
    await tester.pump();
  });
}
