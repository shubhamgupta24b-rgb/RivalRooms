import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/pool_game.dart';

void main() {
  testWidgets('Pool renders a local two-player table and controls', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: PoolGame()));
    expect(find.text('Pool'), findsOneWidget);
    expect(find.text('PLAYER 1'), findsOneWidget);
    expect(find.text('PLAYER 2'), findsOneWidget);
    expect(find.textContaining('drag back from the cue ball'), findsOneWidget);
    expect(find.textContaining('pass-and-play'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Restart'), findsOneWidget);
    expect(find.byType(CustomPaint), findsOneWidget);
  });
}
