import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';

import 'animated_button.dart';

class RegisterOrLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the screen width is larger than a certain value to distinguish between mobile and desktop.
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MyClassroom",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          // Dark mode toggle button
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeData.brightness == Brightness.dark
                  ? Icons.wb_sunny // Sun for Light Mode
                  : Icons.nightlight_round, // Moon for Dark Mode
              color: Colors.white,
            ),
            onPressed: () {
              // Toggle the theme using the provider
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: isDesktop
            ? // Desktop Layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 50),
          child: _buildCardContent(context),
        )
            : // Mobile Layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: _buildCardContent(context),
        ),




      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(

          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 80, color: Colors.deepPurple), // 🎓 Icon
            SizedBox(height: 20),
            Text(
              "Welcome to MyClassroom",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Please Register or Login to Get Started",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 30),
            AnimatedButton(
              text: "Register",
              onPressed: () {
                Navigator.pushNamed(context, '/register'); // Navigate to Register
              },
            ),
            SizedBox(height: 20),
            AnimatedButton(
              text: "Login",
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Navigate to Login
              },
            ),









          ],
        ),
      ),
    );
  }
}
