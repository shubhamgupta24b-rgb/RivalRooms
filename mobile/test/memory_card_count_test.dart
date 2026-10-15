import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/main.dart';

void main() {
  testWidgets('Memory Match supports all requested card-count options', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RivalRoomsApp());
    await tester.tap(find.text('Memory Match').first);
    await tester.pumpAndSettle();
    expect(find.text('24 cards'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    for (final count in [8, 12, 16, 20, 24, 28, 32]) {
      expect(find.text('$count cards'), findsOneWidget);
    }
    await tester.tap(find.text('32 cards').last);
    await tester.pumpAndSettle();
    expect(find.text('32 cards'), findsOneWidget);
  });
}
