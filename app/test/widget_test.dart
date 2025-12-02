import 'package:flutter_test/flutter_test.dart';
import 'package:heyo/main.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const HeyoApp());
    expect(find.text('Heyo'), findsOneWidget);
  });
}
