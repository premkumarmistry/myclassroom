import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class StudentRegistrationRobot {
  final WidgetTester tester;
  StudentRegistrationRobot(this.tester);


  Future<void> verifyPageLoaded() async {
    expect(find.text("Register as Student"), findsOneWidget);
  }

  Future<void> enterName(String name) async {
    await tester.enterText(find.widgetWithText(TextFormField, "Full Name"), name);
  }

  Future<void> enterEmail(String email) async {
    await tester.enterText(find.widgetWithText(TextFormField, "University Email"), email);
  }

  Future<void> enterPhone(String phone) async {
    await tester.enterText(find.widgetWithText(TextFormField, "Phone Number"), phone);
  }

  Future<void> enterPassword(String password) async {
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), password);
  }

  Future<void> selectProgram(String value) async {
    await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, "Select Program"));
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectSpecialization(String value) async {
    await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, "Select Specialization"));
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectSemester(String value) async {
    await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, "Select Semester"));
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapRegister() async {
    await tester.tap(find.text("Register & Verify Email"));
    await tester.pumpAndSettle();
  }

  Future<void> verifyEmailBottomSheet() async {
    expect(find.text("Please Verify Your Email"), findsOneWidget);
  }
}
