import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parikshamadadkendra/Choose_login.dart';
import 'package:parikshamadadkendra/ForgotPasswordScreen.dart';
import 'package:parikshamadadkendra/HodAdmin/StudentListScreen.dart';
import 'package:parikshamadadkendra/Teacher/ManageFoldersScreen.dart';
import 'package:parikshamadadkendra/Teacher/RemoveDocumentsScreen.dart';
import 'package:parikshamadadkendra/Teacher/TeacherAnnouncements.dart';
import 'package:parikshamadadkendra/Teacher/UploadMaterialScreen.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'ProfessorDashboardPage.dart';
import 'upload_material_screen.dart'; // Upload Material Functionality

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String teacherEmail = FirebaseAuth.instance.currentUser?.email ?? "";
  String? assignedBranch;
  List<String> assignedSubjects = [];
  String hodName = "HOD";
  String hodDepartment = "Department";
  String greetingMessage = "Welcome!";
  @override
  void initState() {
    super.initState();
    fetchTeacherDetails();
    subscribeToTopic();

  }

  /// **🔹 Fetch Teacher's Assigned Branch & Subjects**
  Future<void> fetchTeacherDetails() async {
    try {
      print("🔍 Fetching details for teacher email: $teacherEmail");

      QuerySnapshot teacherQuery = await FirebaseFirestore.instance
          .collection("teachers")
          .where("email", isEqualTo: teacherEmail)
          .get();

      if (teacherQuery.docs.isNotEmpty) {
        var teacherDoc = teacherQuery.docs.first;
        List<String> subjectsList = List<String>.from(teacherDoc["assigned_subjects"] ?? []);

        setState(() {
          assignedSubjects = subjectsList;
          assignedBranch = teacherDoc["department"] ?? "Unknown Department";
        });

        print("✅ Assigned Subjects: $assignedSubjects");
        print("✅ Assigned Branch: $assignedBranch");
      } else {
        print("❌ No teacher found for email: $teacherEmail");
      }
    } catch (e) {
      print("❌ Error fetching teacher details: $e");
    }
  }
  void subscribeToTopic() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Replace with your topic name
    String topic = "Teacher";

    // Subscribe to the topic
    await messaging.subscribeToTopic(topic);
    showToast("Subscribed to topic: $topic", Colors.green);
  }
  void showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 600, left: 10, right: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    key: Key("teacherDashboardScreen");

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Teacher Dashboard", style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: theme.appBarTheme.backgroundColor,

        centerTitle: true,

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
      body: SingleChildScrollView( // Wrap the body in a SingleChildScrollView to make it scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Upload Study Material


            buildDashboardCard(
              title: "Assigned Modules",
              icon: Icons.view_module_rounded,
              color: Colors.pinkAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>ProfessorDashboardPage() ),
                );
              },
            ),



            SizedBox(height: 20),


            buildDashboardCard(
              title: "Upload Study Material",
              icon: Icons.upload_file,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadMaterialScreen(assignedBranch: assignedBranch, assignedSubjects: assignedSubjects)),
                );
              },
            ),
            SizedBox(height: 20),

            // 🔹 View Enrolled Students
            buildDashboardCard(
              title: "Announcements",
              icon: Icons.announcement_rounded,
              color: Colors.orangeAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeacherAnnouncementScreen()),
                );
              },
            ),
            SizedBox(height: 20),

            // 🔹 View Enrolled Students
            buildDashboardCard(
              title: "View Enrolled Students",
              icon: Icons.people_alt,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentListScreen(assignedBranch!)),
                );
              },
            ),



            SizedBox(height: 20),

            /// **Manage Files Card**
            buildDashboardCard(
              title: "Manage Files",
              icon: Icons.delete_forever,
              color: Colors.redAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RemoveDocumentsScreen(
                      assignedBranch: assignedBranch ?? "Unknown",
                      assignedSubjects: assignedSubjects,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            buildDashboardCard(
              title: "Manage Folders",
              icon: Icons.folder_delete,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageFoldersScreen(
                      assignedBranch: assignedBranch ?? "Unknown",
                      assignedSubjects: assignedSubjects,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            /// **🔹 Logout Card**
            buildDashboardCard(
              title: "Logout",
              icon: Icons.logout,
              color: Colors.redAccent,
              onTap: () => _logout(context),
              /*onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(

                    ),
                  ),
                );
              },*/
            ),




          ],
        ),
      ),
    );
  }
  /// **🔹 Build Dashboard Cards (Like HOD)**
  Widget buildDashboardCard({required String title, required IconData icon, required Color color, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
/// **🔹 Logout Function**
void _logout(BuildContext context) async {
  bool confirmLogout = await _showLogoutConfirmationDialog(context);
  if (confirmLogout) {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ChooseLogin()), // 🔹 Redirect to Choose Login Page
          (route) => false,
    );
  }
}

/// **🔹 Logout Confirmation Dialog**
Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Logout Confirmation"),
      content: Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Logout", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  ) ??
      false;
}