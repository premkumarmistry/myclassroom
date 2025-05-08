import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:parikshamadadkendra/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Full registration form test", (WidgetTester tester) async {
    app.main(); // Launches the real app
    await tester.pumpAndSettle();

    // Navigate to registration screen if needed, or directly find text fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(find.byType(TextFormField).at(1), 'testuser@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), '9876543210');
    await tester.enterText(find.byType(TextFormField).at(3), 'TestPassword123');

    // Select dropdowns (optional)
    await tester.tap(find.text('Select Program'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bachelors').last);
    await tester.pumpAndSettle();

    // Tap register button
    await tester.tap(find.text("Register & Verify Email"));
    await tester.pumpAndSettle();

    // Wait and verify
    expect(find.text("Please Verify Your Email"), findsOneWidget);
  });
}
