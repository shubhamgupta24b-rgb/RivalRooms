import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/hexa_ring_sort_game.dart';

void main() {
  testWidgets('Hexa Ring Sort exposes its 50-level map and difficulty choices', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HexaRingSortGame()));
    expect(find.text('Hexa Ring Sort'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    await tester.tap(find.byTooltip('Levels'));
    await tester.pumpAndSettle();
    expect(find.text('Level trail'), findsOneWidget);
    expect(find.text('Easy'), findsAtLeastNWidgets(1));
    expect(find.text('Medium'), findsAtLeastNWidgets(1));
    expect(find.text('Hard'), findsAtLeastNWidgets(1));
    expect(find.text('Back to board'), findsOneWidget);
    expect(find.byType(GridView), findsNWidgets(2));
  });
}
