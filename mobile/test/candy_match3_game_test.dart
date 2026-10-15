import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/candy_match3_game.dart';

void main() {
  testWidgets('Candy Match 3 renders a playable board and controls', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CandyMatch3Game()));
    expect(find.text('Candy Match 3'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('MOVES'), findsOneWidget);
    expect(find.text('GOAL'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Levels'), findsOneWidget);
    expect(find.byTooltip('Restart'), findsOneWidget);
    expect(find.text('Hammer'), findsOneWidget);
    expect(find.text('Shuffle'), findsOneWidget);
    expect(find.text('Color bomb'), findsOneWidget);
  });

  testWidgets('level map exposes 50 level slots and difficulty selection', (tester) async {
    await tester.view.setPhysicalSize(const Size(430, 900));
    await tester.view.setDevicePixelRatio(1);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CandyMatch3Game()));
    await tester.tap(find.byTooltip('Levels'));
    await tester.pumpAndSettle();
    expect(find.text('Candy trail'), findsOneWidget);
    expect(find.text('EASY'), findsOneWidget);
    expect(find.text('MEDIUM'), findsOneWidget);
    expect(find.text('HARD'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
