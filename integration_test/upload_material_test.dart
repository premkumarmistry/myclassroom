import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:parikshamadadkendra/Teacher/teacher_login_screen.dart';
import 'package:provider/provider.dart';
import 'package:parikshamadadkendra/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Teacher login and upload material flow (UI only)', (tester) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
        child: MaterialApp(home: TeacherLoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // 🔴 Invalid login attempt
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "invalid@email.com");
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "wrongpass");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    // ✅ Valid login
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "210102103029.hiren@srict.in");
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "123456");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: 3));
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Wait for dashboard to load
    expect(find.text("Upload Study Material"), findsOneWidget);
    await tester.tap(find.text("Upload Study Material"));
    await tester.pumpAndSettle();

    // Upload Material screen
    //expect(find.text("Upload Study Materials"), findsOneWidget);

    await tester.tap(find.byKey(Key("dropdownSubject")));
    await tester.pumpAndSettle();
    expect(find.text("Maths"), findsWidgets);
    await tester.tap(find.text("Maths").first);
    await tester.pumpAndSettle();

    // Folder Dropdownawait tester.tap(find.byType(DropdownButtonFormField).at(1));

    await tester.tap(find.byKey(Key("dropdownFolder")));
    await tester.pumpAndSettle();
    expect(find.text("Chapter 1"), findsWidgets);
    await tester.tap(find.text("Chapter 1").first);
    await tester.pumpAndSettle();

    // Tap select file button (just test UI response)
    await tester.tap(find.byKey(Key("btnSelectFiles")));
    await tester.pumpAndSettle();

    // Skip real file picking – just show mock UI
    print("📁 File picker UI triggered (no real file selected in test)");

    // Tap Upload Button
    await tester.tap(find.byKey(Key("uploadButton")));
    await tester.pumpAndSettle();

    print("✅ Upload button tapped, UI flow verified");
  });
}
