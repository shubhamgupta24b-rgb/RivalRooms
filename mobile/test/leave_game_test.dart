import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/main.dart';

void main() {
  testWidgets('Back leaves an unstarted Memory Match without confirmation', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RivalRoomsApp());
    await tester.tap(find.text('Memory Match').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Leave this game?'), findsNothing);
    expect(find.text('All games'), findsOneWidget);
  });

  testWidgets('an in-progress Memory Match confirms Back and system Back', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RivalRoomsApp());
    await tester.tap(find.text('All games'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Memory Match'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('✦').first);
    await tester.pump();
    await tester.tap(find.text('✦').first);
    await tester.pump();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Leave this game?'), findsOneWidget);
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(find.text('Memory Match'), findsOneWidget);
    expect(find.text('Leave this game?'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Leave this game?'), findsOneWidget);
    await tester.tap(find.text('Exit game'));
    await tester.pumpAndSettle();
    expect(find.text('Leave this game?'), findsNothing);
    expect(find.text('Choose your next challenge.'), findsOneWidget);
  });
}
