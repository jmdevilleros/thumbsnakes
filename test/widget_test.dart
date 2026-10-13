import 'package:flutter_test/flutter_test.dart';
import 'package:thumbsnakes/main.dart';

void main() {
  testWidgets('App shell builds', (tester) async {
    await tester.pumpWidget(const ThumbsnakesApp());
    expect(find.byType(ThumbsnakesApp), findsOneWidget);
  });
}
