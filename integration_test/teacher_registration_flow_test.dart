import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parikshamadadkendra/Teacher/teacher_registration_screen.dart';
import 'package:provider/provider.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:parikshamadadkendra/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();


  testWidgets('Register teacher with invalid then valid email and verify flow', (WidgetTester tester) async {
    print("🔵 Initializing Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    print("🟣 Launching Teacher Registration screen...");
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
        child: MaterialApp(home: TeacherRegistrationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Register as Teacher"), findsOneWidget);
    print("✅ Teacher Registration screen loaded.");

    await tester.enterText(find.widgetWithText(TextFormField, "Full Name"), "Prof. Tester");
    print("🟢 Name entered.");

    await tester.enterText(find.widgetWithText(TextFormField, "University Email"), "teacher@gmail.com");
    print("🟢 Invalid email entered.");

    await tester.enterText(find.widgetWithText(TextFormField, "Phone Number"), "9998887777");
    print("🟢 Phone entered.");

    // Department selection
    await tester.tap(find.text("Select Department"));
    await tester.pumpAndSettle();
    final deptOption = find.byType(DropdownMenuItem<String>).first;
    await tester.tap(deptOption, warnIfMissed: false);
    await tester.pumpAndSettle();
    print("🟢 Department selected.");

    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "Test@1234");
    print("🟢 Password entered.");

    // First submit with invalid email
    await tester.tap(find.text("Register & Verify Email"));
    await tester.pumpAndSettle();

    // Should show validator error
    expect(find.textContaining("Use university email"), findsOneWidget);
    print("❌ Validator worked. Error shown for gmail.");

    // Clear and enter valid email
    await tester.enterText(find.widgetWithText(TextFormField, "University Email"), "");
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, "University Email"), "");
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, "University Email"), "teacher@upluniversity.ac.in");
    print("🟢 Correct email entered.");

// 🔄 Trigger form to revalidate
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tapAt(Offset(10, 10));
    await tester.pumpAndSettle();

    // Submit again
    await tester.tap(find.text("Register & Verify Email"));
    await tester.pumpAndSettle(Duration(seconds: 5));

    // Expect bottom sheet
    expect(find.text("Please Verify Your Email"), findsOneWidget);
    print("🎉 Email verification bottom sheet shown.");
  });




}
