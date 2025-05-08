import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parikshamadadkendra/dashboard_screen.dart';
import 'package:parikshamadadkendra/student_login_screen.dart';
import 'package:provider/provider.dart';

import 'package:parikshamadadkendra/theme.dart';
import 'package:parikshamadadkendra/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Student login with invalid and then valid credentials', (WidgetTester tester) async {
    print("🔵 Initializing Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    print("🟣 Launching Student Login screen...");
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
        child: MaterialApp(
          home: StudentLoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Student Login"), findsWidgets);
    print("✅ Student Login screen loaded.");

    // Step 1: Enter Invalid Credentials
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "210102103013.divy@upluniversity.ac.in");
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "1234567");
    print("🟠 Entered invalid credentials.");

    await tester.testTextInput.receiveAction(TextInputAction.done); // 👈 Closes keyboard
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(SnackBar), findsOneWidget);
    print("❌ Login failed as expected.");

    // Step 2: Enter Valid Credentials
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "");
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "210102103013.divy@srict.in");

    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "");
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "123456");

    await tester.testTextInput.receiveAction(TextInputAction.done); // 👈 Closes keyboard
    await tester.pump(const Duration(seconds: 5)); // ⏳ Wait before tapping login
    print("🟢 Entered valid credentials.");

    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    // ✅ Confirm redirection to StudentDashboardScreen
    expect(find.byKey(Key("dashboardScreen")), findsOneWidget);
    print("🎉 Successfully navigated to StudentDashboardScreen.");
  });
}
