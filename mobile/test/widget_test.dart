import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/main.dart';

void main() {
  testWidgets('home shows RivalRooms and main navigation', (tester) async {
    await tester.pumpWidget(const RivalRoomsApp());
    expect(find.text('RivalRooms'), findsOneWidget);
    expect(find.text('Who’s your\nnext rival?'), findsOneWidget);
    expect(find.text('Play online'), findsOneWidget);
  });
}
