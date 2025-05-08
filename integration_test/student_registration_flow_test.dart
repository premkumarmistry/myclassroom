import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:parikshamadadkendra/firebase_options.dart';
import 'package:parikshamadadkendra/StudentRegistrationScreen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Register student with any email and log steps', (WidgetTester tester) async {
    print("🔵 Initializing Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    print("🟣 Launching StudentRegistrationScreen...");
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
        child: MaterialApp(home: StudentRegistrationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // 🔍 Ensure page loaded
    expect(find.text("Register as Student"), findsOneWidget);
    print("✅ Registration screen loaded.");

    // Fill name
    await tester.enterText(find.widgetWithText(TextFormField, "Full Name"), "Test User");
    print("🟢 Name entered.");

    // Fill email (non-upl email)
    await tester.enterText(find.widgetWithText(TextFormField, "University Email"), "test@upluniversity.ac.in");
    print("🟢 Email entered.");

    // Fill phone
    await tester.enterText(find.widgetWithText(TextFormField, "Phone Number"), "9999999999");
    print("🟢 Phone entered.");

    // Fill password
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "Test@1234");
    print("🟢 Password entered.");

    // Scroll to Program Dropdown and select
    final programDropdown = find.text("Select Program");
    await tester.ensureVisible(programDropdown);
    await tester.tap(programDropdown);
    await tester.pumpAndSettle();

    final bachelorsOption = find.text("Bachelors").last;
    await tester.ensureVisible(bachelorsOption);
    await tester.tap(bachelorsOption);
    await tester.pumpAndSettle();
    print("🟢 Program selected.");

    print("🟢 Program selected.");

    await tester.tap(find.text("Select Specialization"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Computer Engg").last);
    await tester.pumpAndSettle();
    print("🟢 Specialization selected.");

    // 🟢 Semester Dropdown
    final semesterDropdown = find.text("Select Semester");
    await tester.ensureVisible(semesterDropdown);
    await tester.tap(semesterDropdown);
    await tester.pumpAndSettle();

    final semesterOption = find.text("1");
    if (semesterOption.evaluate().isNotEmpty) {
      await tester.tap(semesterOption.last);
      await tester.pumpAndSettle();
      print("🟢 Semester selected.");
    } else {
      print("🔴 ERROR: 'Sem 1' not found in dropdown.");
      fail("Semester option 'Sem 1' not found.");
    }


    // Submit the form
    await tester.tap(find.text("Register & Verify Email"));
    await tester.pumpAndSettle(Duration(seconds: 5)); // wait for async

    print("✅ Form submitted.");
    print("✅ Check for email verification bottom sheet.");

    // Verify email bottom sheet appears
    expect(find.text("Please Verify Your Email"), findsOneWidget);
    print("🎉 Email verification bottom sheet shown.");
  });
}
