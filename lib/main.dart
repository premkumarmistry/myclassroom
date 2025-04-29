import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parikshamadadkendra/Team/TeamPage.dart';
import 'package:parikshamadadkendra/register_or_login.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';

import 'package:parikshamadadkendra/Choose_login.dart';
import 'package:parikshamadadkendra/Choose_register.dart';
import 'package:parikshamadadkendra/splash_screen.dart';
import 'package:parikshamadadkendra/dashboard_screen.dart';
import 'package:parikshamadadkendra/firebase_options.dart';

import 'auth_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _user;
  bool isEmailVerified = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Check the current user when the app initializes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        if (user != null) {
          _user = user;
          isEmailVerified = user.emailVerified;
        } else {
          _user = null;
          isEmailVerified = false;
        }
        _isLoading = false;  // Stop the loading indicator
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: "MyClassroom",
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,  // Apply dynamic theme
          home: _isLoading
              ? SplashScreen()  // Show SplashScreen while loading
              : _user == null
              ? RegisterOrLoginScreen()  // Redirect to login if no user is found
              : isEmailVerified
              ? AuthHandler()  // Show dashboard if user is logged in and verified
              : ChooseLogin(),  // Ask to verify email if user is logged in but not verified
          routes: {
            '/register': (context) => ChooseRegister(),
            '/dashboard': (context) => DashboardScreen(),
            '/login': (context) => ChooseLogin(),
          },
        );
      },
    );
  }
}
