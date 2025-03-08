import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/Choose_login.dart';
import 'package:parikshamadadkendra/Choose_register.dart';
import 'package:parikshamadadkendra/LoginScreen.dart';
import 'package:parikshamadadkendra/StudentRegistrationScreen.dart';
import 'package:parikshamadadkendra/register_or_login.dart';
import 'package:parikshamadadkendra/role_selection_screen.dart';
import 'package:parikshamadadkendra/splash_screen.dart';

import 'dashboard_screen.dart'; // 🔹 Import Dashboard Screen
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {




  User? _user;
  bool isEmailVerified = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  // 🔹 Check User Authentication & Email Verification
  void _checkAuthState() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await user.reload(); // Refresh user data
        setState(() {
          _user = user;
          isEmailVerified = user.emailVerified;
          _isLoading = false; // Hide splash screen
        });
      } else {
        setState(() {
          _user = null;
          isEmailVerified = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pariksha Madad Kendra",
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      /* _user == null
          ? RegisterOrLoginScreen() // 🔹 Show Register/Login Options
          : isEmailVerified
          ? MainDashboard() // 🔹 Redirect to Dashboard
          : RoleSelectionScreen(), */// 🔹 Force Login if not verified
      routes: {
        '/register': (context) => ChooseRegister(),
        '/dashboard': (context) => DashboardScreen(),
        '/login': (context) => ChooseLogin(),
      },
    );
  }
}


