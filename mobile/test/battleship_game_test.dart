import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/battleship_game.dart';

void main() {
  testWidgets('Battleship hides fleet between randomized local turns', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: BattleshipGame()));
    expect(find.textContaining('Pass to Player'), findsOneWidget);
    expect(find.text('Reveal my turn'), findsOneWidget);
    await tester.tap(find.text('Reveal my turn'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Target grid'), findsOneWidget);
    expect(find.text('PLAYER 1'), findsOneWidget);
    expect(find.text('PLAYER 2'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('New game'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Target row 1 column 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pass to Player'), findsOneWidget);
    expect(find.text('Reveal my turn'), findsOneWidget);
  });
}
