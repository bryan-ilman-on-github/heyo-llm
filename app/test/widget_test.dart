import 'package:flutter_test/flutter_test.dart';
import 'package:heyo/main.dart';
import 'package:heyo/shared/providers/settings_provider.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    final settingsProvider = SettingsProvider();
    await tester.pumpWidget(HeyoApp(settingsProvider: settingsProvider));
    expect(find.text('Heyo'), findsOneWidget);
  });
}
