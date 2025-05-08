import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parikshamadadkendra/student_login_screen.dart';
import 'package:provider/provider.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:parikshamadadkendra/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
        child: MaterialApp(home: StudentLoginScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('✅ 1. Invalid login shows SnackBar', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "invalid@email.com");
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "wrongpass");
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('✅ 2. Valid login navigates to dashboard', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "210102103013.divy@srict.in");
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "123456");
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle(Duration(seconds: 5));
    expect(find.byKey(const Key("dashboardScreen")), findsOneWidget);
  });

  testWidgets('✅ 3. Tap View Materials', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "210102103013.divy@srict.in");
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "123456");
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle(Duration(seconds: 5));
    await tester.tap(find.text("View Materials"));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("studentViewMaterialScreen")), findsOneWidget);
  });

  testWidgets('✅ 4. Dropdown selections work', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "210102103013.divy@srict.in");
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "123456");
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle(Duration(seconds: 5));
    await tester.tap(find.text("View Materials"));
    await tester.pumpAndSettle(Duration(seconds: 3));

    await tester.tap(find.byKey(const Key("dropdownStream")));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Bachelors").last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("dropdownBranch")));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Computer Engg").first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("dropdownSemester")));
    await tester.pumpAndSettle();
    await tester.tap(find.text("1").first);
    await tester.pumpAndSettle();

    expect(find.text("Computer Engg"), findsOneWidget);
  });

  testWidgets('✅ 5. Tap Show Subjects and select chapter', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.widgetWithText(TextFormField, "Email"), "210102103013.divy@srict.in");
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), "123456");
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle(Duration(seconds: 5));
    await tester.tap(find.text("View Materials"));
    await tester.pumpAndSettle(Duration(seconds: 3));

    await tester.tap(find.byKey(const Key("dropdownStream")));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Bachelors").last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("dropdownBranch")));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Computer Engg").first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("dropdownSemester")));
    await tester.pumpAndSettle();
    await tester.tap(find.text("1").first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("btnShowSubjects")));
    await tester.pumpAndSettle();

    expect(find.text("Science"), findsOneWidget);
  });

  // ❌ Failing Tests

  testWidgets('❌ 6. Invalid subject not found', (tester) async {
    await pumpApp(tester);
    expect(find.text("Quantum Physics"), findsOneWidget); // should fail
  });

  testWidgets('❌ 7. Show Subjects without selecting dropdowns', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key("btnShowSubjects"))); // no dropdowns selected
    await tester.pumpAndSettle();
    expect(find.text("Science"), findsOneWidget); // should fail
  });

  testWidgets('❌ 8. Tap chapter before opening folder', (tester) async {
    await pumpApp(tester);
    expect(find.text("Chapter 1"), findsOneWidget); // should fail
  });

  testWidgets('❌ 9. Tap file before selecting chapter', (tester) async {
    await pumpApp(tester);
    expect(find.text("Computer Vision_Unit_4.pdf"), findsOneWidget); // should fail
  });

  testWidgets('❌ 10. Tap 3-dot on invalid file', (tester) async {
    await pumpApp(tester);
    final fakeTile = find.ancestor(
      of: find.text("Fake_File.pdf"),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: fakeTile, matching: find.byIcon(Icons.more_vert)),
    ); // should fail
    await tester.pumpAndSettle();
  });
}