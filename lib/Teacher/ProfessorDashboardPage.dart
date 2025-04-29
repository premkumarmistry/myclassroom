import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/HodAdmin/hod_dashboard.dart';
import 'package:parikshamadadkendra/access_modules_pages/AttendanceManagementPage.dart';
import 'package:parikshamadadkendra/access_modules_pages/Feedback.dart';
import 'package:parikshamadadkendra/access_modules_pages/MarksEntryManagementPage.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class ProfessorDashboardPage extends StatefulWidget {
  @override
  _ProfessorDashboardPageState createState() => _ProfessorDashboardPageState();
}

class _ProfessorDashboardPageState extends State<ProfessorDashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _assignedModules = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedModules();
  }

  Future<void> _fetchAssignedModules() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot professorDoc = await _firestore.collection('teachers').doc(user.uid).get();
      setState(() {
        _assignedModules = List<String>.from(professorDoc["modules"] ?? []);
      });
    }
  }

  void _onModuleTap(String module) {
    if (module == "Attendance Management") {
      showToast("Opening Attendance Page...", Colors.green);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Attendancemanagementpage())); // Uncomment when AttendancePage is available
    } else if (module == "Feedback") {
      showToast("Opening Feedback Page...", Colors.green);
      Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage())); // Uncomment when FeedbackPage is available
    }
    else if (module == "Marks Entry") {
      showToast("Opening Marks Entry Page...", Colors.green);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Marksentrymanagementpage())); // Uncomment when FeedbackPage is available
    }
    else {
      showToast("$module clicked!", Colors.blue);
    }
  }

  /// *🔹 Show Toast Message at the top*
  void showToast(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear any previous snackbars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 100, left: 20, right: 20), // Position it at the top
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Assigned Modules Pages"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Mobile Layout
          if (constraints.maxWidth <= 800) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Assigned Modules:", style: Theme.of(context).textTheme.bodyLarge

                  ),
                  SizedBox(height: 10),
                  _assignedModules.isEmpty
                      ? Center(
                    child: Text("No modules assigned.", style: TextStyle(color: Colors.black, fontSize: 18)),
                  )
                      : Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns for mobile
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _assignedModules.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _onModuleTap(_assignedModules[index]),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 10,
                            color: Colors.white,
                            shadowColor: Colors.black26,
                            // Deep purple border using BoxDecoration
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.deepPurple, width: 2), // Deep purple border
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open, size: 50, color: Colors.deepPurple.shade700),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      _assignedModules[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Desktop Layout - Smaller Cards
            double cardWidth = 220; // Smaller card width for desktop
            double cardHeight = 150; // Smaller card height for desktop

            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Assigned Modules:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                  SizedBox(height: 10),
                  _assignedModules.isEmpty
                      ? Center(
                    child: Text("No modules assigned.", style: TextStyle(color: Colors.black, fontSize: 18)),
                  )
                      : Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6, // 3 columns for desktop
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _assignedModules.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _onModuleTap(_assignedModules[index]),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 10,
                            color: Colors.white,
                            shadowColor: Colors.black26,
                            // Deep purple border using BoxDecoration
                            child: Container(
                              width: cardWidth, // Smaller card width for desktop
                              height: cardHeight, // Smaller card height for desktop
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.deepPurple, width: 2), // Deep purple border
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open, size: 50, color: Colors.deepPurple.shade700),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      _assignedModules[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
