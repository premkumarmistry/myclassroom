import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class TeacherRegistrationRobot {
  final WidgetTester tester;
  TeacherRegistrationRobot(this.tester);

  Future<void> verifyPageLoaded() async {
    expect(find.text("Register as Teacher"), findsOneWidget);
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

  Future<void> selectDepartment(String value) async {
    await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, "Select Department"));
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  Future<void> enterPassword(String password) async {
    await tester.enterText(find.widgetWithText(TextFormField, "Password"), password);
  }

  Future<void> tapRegister() async {
    await tester.tap(find.text("Register & Verify Email"));
    await tester.pumpAndSettle();
  }

  Future<void> verifyEmailBottomSheet() async {
    expect(find.text("Please Verify Your Email"), findsOneWidget);
  }
}
