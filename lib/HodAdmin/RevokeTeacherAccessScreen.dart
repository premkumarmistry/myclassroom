import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class RevokeTeacherAccessScreen extends StatefulWidget {
  @override
  _RevokeTeacherAccessScreenState createState() => _RevokeTeacherAccessScreenState();
}

class _RevokeTeacherAccessScreenState extends State<RevokeTeacherAccessScreen> {
  String? hodDepartment;
  List<Map<String, dynamic>> teachers = [];
  Map<String, List<String>> teacherSubjects = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHodDepartment();
  }

  /// **🔹 Fetch HOD's Assigned Department**
  Future<void> fetchHodDepartment() async {
    setState(() => isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot hodDoc = await FirebaseFirestore.instance.collection("hods").doc(user.uid).get();
      if (hodDoc.exists) {
        setState(() {
          hodDepartment = hodDoc["department"];
          fetchTeachers();
        });
      } else {
        showToast("HOD details not found!", Colors.red);
      }
    }

    setState(() => isLoading = false);
  }

  /// **🔹 Fetch Teachers for the HOD’s Department**
  Future<void> fetchTeachers() async {
    if (hodDepartment == null) return;

    setState(() => isLoading = true);

    try {
      QuerySnapshot teacherDocs = await FirebaseFirestore.instance
          .collection("teachers")
          .where("department", isEqualTo: hodDepartment) // 🔹 Filter by HOD's department
          .get();

      if (teacherDocs.docs.isNotEmpty) {
        setState(() {
          teachers = teacherDocs.docs.map((doc) {
            return {
              "name": doc["name"],
              "id": doc.id,
            };
          }).toList();
          fetchSubjectsForTeachers();
        });
      } else {
        setState(() {
          teachers = [];
          teacherSubjects = {};
        });
        showToast("No teachers found in $hodDepartment!", Colors.orange);
      }
    } catch (e) {
      showToast("Error fetching teachers!", Colors.red);
    }

    setState(() => isLoading = false);
  }

  /// **🔹 Fetch Assigned Subjects for Each Teacher**
  Future<void> fetchSubjectsForTeachers() async {
    setState(() => isLoading = true);
    teacherSubjects.clear();
    for (var teacher in teachers) {
      DocumentSnapshot teacherDoc =
      await FirebaseFirestore.instance.collection("teachers").doc(teacher["id"]).get();
      if (teacherDoc.exists) {
        var subjects = teacherDoc["assigned_subjects"] ?? [];
        setState(() {
          teacherSubjects[teacher["id"]] = List<String>.from(subjects);
        });
      }
    }
    setState(() => isLoading = false);
  }

  /// **🔹 Show Confirmation Before Revoking Access**
  void showRevokeConfirmation(String teacherId, String subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Removal"),
        content: Text("Are you sure you want to revoke access for '$subject'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              revokeSubject(teacherId, subject);
            },
            child: Text("Revoke", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// **🔹 Revoke Subject Access from Teacher**
  void revokeSubject(String teacherId, String subject) async {
    try {
      await FirebaseFirestore.instance.collection("teachers").doc(teacherId).update({
        "assigned_subjects": FieldValue.arrayRemove([subject])
      });

      setState(() {
        teacherSubjects[teacherId]?.remove(subject);
      });

      showToast("Access revoked for $subject!", Colors.green);
    } catch (e) {
      showToast("Error revoking access!", Colors.red);
    }
  }

  /// **🔹 Show Toast Message**
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




    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Revoke Teacher Access", style: TextStyle(color: Colors.white, fontSize: 20)),
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
    ]

      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50),
            Text(
              hodDepartment != null
                  ? "Teachers from $hodDepartment Department"
                  : "Fetching department...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),

            SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : teachers.isEmpty
                  ? Center(child: Text("No teachers available in this department"))
                  : ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  String teacherId = teachers[index]["id"];
                  String teacherName = teachers[index]["name"];
                  List<String> subjects = teacherSubjects[teacherId] ?? [];

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacherName,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),

                          subjects.isEmpty
                              ? Text("No assigned subjects", style: TextStyle(color: Colors.red))
                              : Column(
                            children: subjects.map((subject) {
                              return ListTile(
                                title: Text(subject),
                                trailing: IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => showRevokeConfirmation(teacherId, subject),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
