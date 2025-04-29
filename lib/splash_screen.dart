import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // For responsive UI
import 'package:parikshamadadkendra/auth_handler.dart';
import 'package:parikshamadadkendra/dashboard_screen.dart';
import 'main.dart'; // Import the main screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthHandler()), // Navigate to main.dart
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit( // Initialize ScreenUtil for responsive UI
      designSize: Size(375, 812), // Base design size
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.deepPurple, // Set background color
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 200.h),
                Image.asset(
                  'assets/img.png', // Your splash logo
                  width: 300.w, // Responsive width
                  height: 300.h, // Responsive height
                ),
                SizedBox(height: 20.h),
                SizedBox(height: 250.h),
                Text(
                  "All Right Reserved",
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
