import 'package:flutter_test/flutter_test.dart';
import 'package:farm_assist/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const FarmAssistApp());
    expect(find.text('Farm Assist'), findsOneWidget);
  });
}