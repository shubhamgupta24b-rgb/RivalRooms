import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('online play reports a missing server instead of opening a local game', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const RivalRoomsApp());
    await tester.tap(find.text('Play online'));
    await tester.pumpAndSettle();
    expect(find.text('Server address'), findsOneWidget);
    expect(find.text('Create a room'), findsOneWidget);
    await tester.tap(find.text('Create a room'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the server address, then try again.'), findsOneWidget);
    expect(find.text('Find every pair.'), findsNothing);
    expect(find.byType(MemoryGame), findsNothing);
  });
}
