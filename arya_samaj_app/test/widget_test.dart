import 'package:flutter_test/flutter_test.dart';
import 'package:arya_samaj_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AryaSamajApp());
    expect(find.text('आर्य समाज'), findsOneWidget);
  });
}
