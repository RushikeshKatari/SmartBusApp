import 'package:flutter_test/flutter_test.dart';
import 'package:smartbus/main.dart';

void main() {
  testWidgets('SmartBus single login screen renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartBusApp());
    await tester.pumpAndSettle();

    // Verify unified login UI elements
    expect(find.text('SmartBus Login'), findsOneWidget);
    expect(find.text('User ID / Roll Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
  });
}
