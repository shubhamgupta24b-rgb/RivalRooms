import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/fruit_cut_arcade_game.dart';

void main() {
  testWidgets('Fruit Cut Arcade shows the slicing arena and power-ups', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: FruitCutArcadeGame()));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('Fruit Cut'), findsOneWidget);
    expect(find.text('DIFFICULTY'), findsOneWidget);
    expect(find.text('SLICED'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('LIVES'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('50 Levels'), findsOneWidget);
    expect(find.byTooltip('Restart'), findsOneWidget);
    expect(find.text('Freeze'), findsOneWidget);
    expect(find.text('Frenzy'), findsOneWidget);
    expect(find.text('Shield'), findsOneWidget);
  });

  testWidgets('Fruit Cut level map provides 50 level slots and difficulties', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: FruitCutArcadeGame()));
    await tester.tap(find.byTooltip('50 Levels'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Fruit trail'), findsOneWidget);
    expect(find.text('EASY'), findsOneWidget);
    expect(find.text('MEDIUM'), findsAtLeastNWidgets(1));
    expect(find.text('HARD'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
