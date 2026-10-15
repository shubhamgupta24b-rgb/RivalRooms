import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/games/raja_mantri_chor_sipahi_game.dart';

void main() {
  testWidgets('Raja Mantri Chor Sipahi reveals private roles and reaches guessing phase', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    await tester.pumpWidget(const MaterialApp(home: RajaMantriChorSipahiGame()));

    expect(find.text('Raja Mantri Chor Sipahi'), findsOneWidget);
    expect(find.text('ROUND 1 OF 20'), findsOneWidget);
    expect(find.text('TAP TO REVEAL'), findsOneWidget);

    for (var player = 0; player < 4; player++) {
      await tester.tap(find.text('TAP TO REVEAL'));
      await tester.pump();
      expect(find.text('Keep this secret!'), findsOneWidget);
      await tester.tap(find.text(player == 3 ? 'Everyone has seen their role' : 'Hide role & pass to Player ' + (player + 2).toString()));
      await tester.pump();
    }

    expect(find.textContaining('identify the Chor'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(3));
    await tester.binding.setSurfaceSize(null);
  });
}
