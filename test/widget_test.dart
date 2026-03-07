import 'package:flutter_test/flutter_test.dart';
import 'package:baseone/main.dart';

void main() {
  testWidgets('App boots', (tester) async {
    await tester.pumpWidget(const BaseOneApp());
    expect(find.text('BaseOne Notes'), findsOneWidget);
  });
}