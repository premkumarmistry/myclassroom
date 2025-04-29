import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parikshamadadkendra/HodAdmin/hod_login_screen.dart';
import 'package:parikshamadadkendra/Teacher/teacher_login_screen.dart';
import 'package:parikshamadadkendra/student_login_screen.dart';
import 'package:parikshamadadkendra/register_or_login.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart'; // Home Screen
import 'package:provider/provider.dart';
class ChooseLogin extends StatefulWidget {
  @override
  _ChooseLoginState createState() => _ChooseLoginState();
}

class _ChooseLoginState extends State<ChooseLogin> {
  bool studentEnabled = false;
  bool teacherEnabled = false;
  bool hodEnabled = false;
  String studentMessage = "";
  String teacherMessage = "";
  String hodMessage = "";

  @override
  void initState() {
    super.initState();
    fetchLoginStatus();
  }

  /// **🔥 Fetch Login Flags from Firestore**
  Future<void> fetchLoginStatus() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot studentDoc = await firestore.collection("login_control").doc("students").get();
      DocumentSnapshot teacherDoc = await firestore.collection("login_control").doc("teachers").get();
      DocumentSnapshot hodDoc = await firestore.collection("login_control").doc("hods").get();

      setState(() {
        studentEnabled = studentDoc["isEnabled"];
        teacherEnabled = teacherDoc["isEnabled"];
        hodEnabled = hodDoc["isEnabled"];

        studentMessage = studentDoc["message"];
        teacherMessage = teacherDoc["message"];
        hodMessage = hodDoc["message"];
      });
    } catch (e) {
      print("❌ Error fetching login status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Login as", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        actions: [

          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterOrLoginScreen()));
            },
          ),
          // Lightbulb Theme Toggle Button

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildRoleCard(
              context,
              title: "Student",
              imagePath: "assets/student.png",
              isEnabled: studentEnabled,
              message: studentMessage,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StudentLoginScreen())),
            ),
            SizedBox(height: 20),
            buildRoleCard(
              context,
              title: "Teacher",
              imagePath: "assets/professor.png",
              isEnabled: teacherEnabled,
              message: teacherMessage,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherLoginScreen())),
            ),
            SizedBox(height: 20),
            buildRoleCard(
              context,
              title: "HoD",
              imagePath: "assets/hod.png",
              isEnabled: hodEnabled,
              message: hodMessage,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HodLoginScreen())),
            ),
          ],
        ),
      ),
    );
  }

  /// **🔹 Reusable Role Card**
  Widget buildRoleCard(BuildContext context,
      {required String title, required String imagePath, required bool isEnabled, required String message, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: isEnabled ? onTap : () => showDisabledMessage(context, message),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 100,
        decoration: BoxDecoration(
          gradient: isEnabled ? LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]) : LinearGradient(colors: [Colors.grey, Colors.grey.shade400]),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2)],
        ),
        child: Row(
          children: [
            SizedBox(width: 20),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Image.asset(imagePath, width: 50, height: 50),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  /// **⚠ Show Message When Disabled**
  void showDisabledMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
