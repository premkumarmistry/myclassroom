import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/HodAdmin/hod_registration_screen.dart';
import 'package:parikshamadadkendra/Teacher/teacher_registration_screen.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';
import 'student_login_screen.dart';
import 'Teacher/teacher_login_screen.dart';
import 'HodAdmin/hod_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(title: Text("Select Your Role"),      backgroundColor: theme.appBarTheme.backgroundColor,

     actions: [

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
       )


     ],


      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentLoginScreen()));
              },
              child: Text("Login as Student"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherLoginScreen()));
              },
              child: Text("Login as Teacher"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HodLoginScreen()));
              },
              child: Text("Login as HOD"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HodRegistrationScreen()));
              },
              child: Text("Register as HOD"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherRegistrationScreen()));
              },
              child: Text("Register as Teacher"),
            ),
          ],
        ),
      ),
    );
  }
}
