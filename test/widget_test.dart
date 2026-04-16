import 'package:flutter_test/flutter_test.dart';

import 'package:gmmx_mobile/main.dart';

void main() {
  testWidgets('GMMX login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const GmmxApp());
    await tester.pumpAndSettle();

    expect(find.text('GMMX'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });
}
