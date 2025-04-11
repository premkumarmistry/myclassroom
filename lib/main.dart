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
  late Stream<User?> _authStateChanges;

  @override
  void initState() {
    super.initState();
    _authStateChanges = FirebaseAuth.instance.authStateChanges();
    _checkAuthState();
  }

  void _checkAuthState() async {
    _authStateChanges.listen((User? user) async {
      if (user != null) {
        await user.reload();
        setState(() {
          _user = user;
          isEmailVerified = user.emailVerified;
          _isLoading = false;
        });
      } else {
        setState(() {
          _user = null;
          isEmailVerified = false;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: "Pariksha Madad Kendra",
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,  // Apply dynamic theme
          home: _isLoading
              ? SplashScreen()
              : _user == null
              ? RegisterOrLoginScreen()
              : isEmailVerified
              ? DashboardScreen()
              : ChooseLogin(),
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
