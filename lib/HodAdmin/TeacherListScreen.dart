import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class TeacherListScreen extends StatelessWidget {
  final String department;
  TeacherListScreen(this.department);

  /// **🔹 Extract Initials for Avatar**
  String getInitials(String name) {
    List<String> nameParts = name.split(" ");
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0]; // First letter of first & last name
    } else {
      return nameParts[0][0]; // Single name case
    }
  }

  /// **🔹 Toggle Access for Teacher**
  void toggleAccess(String teacherId, bool newValue) async {
    try {
      await FirebaseFirestore.instance.collection("teachers").doc(teacherId).update({
        "isVerified": newValue, // 🔹 Enable/Disable Access
      });
      print("✅ Teacher Access Updated: $newValue");
    } catch (e) {
      print("❌ Error updating teacher access: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text("Teachers in $department", style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white)),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("teachers")
            .where("department", isEqualTo: department)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var teachers = snapshot.data!.docs;
          if (teachers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No teachers found in this department",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              var teacher = teachers[index];
              String teacherId = teacher.id;
              String name = teacher["name"];
              String email = teacher["email"];
              String phone = teacher["phone"] ?? "Not Available";
              String department = teacher["department"];
              bool isVerified = teacher["isVerified"] ?? false;
              List<String> assignedSubjects = List<String>.from(teacher["assigned_subjects"] ?? []);

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.deepPurple.shade200,
                            child: Text(
                              getInitials(name),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white // Text color for dark mode
                                  : Colors.deepPurple, // Text color for light mode
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70 // Icon color for dark mode
                                    : Colors.black54, // Icon color for light mode
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white70 // Text color for dark mode
                                        : Colors.black87, // Text color for light mode
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70 // Icon color for dark mode
                                    : Colors.black54, // Icon color for light mode
                              ),
                              SizedBox(width: 5),
                              Text(
                                phone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70 // Text color for dark mode
                                      : Colors.black87, // Text color for light mode
                                ),
                              ),
                            ],


                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            size: 18,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70 // Icon color for dark mode
                                : Colors.black54, // Icon color for light mode
                          )
,                          SizedBox(width: 5),
                          Text(
                            "Department: $department",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70 // Text color for dark mode
                                  : Colors.black87, // Text color for light mode
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.book,
                            size: 18,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70 // Icon color for dark mode
                                : Colors.black54, // Icon color for light mode
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              assignedSubjects.isNotEmpty
                                  ? "Subjects: ${assignedSubjects.join(", ")}"
                                  : "No subjects assigned",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70 // Text color for dark mode
                                    : Colors.black87, // Text color for light mode
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Access: ${isVerified ? "Enabled" : "Disabled"}",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isVerified ? Colors.green : Colors.red),
                          ),
                          Switch(
                            value: isVerified,
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            onChanged: (newValue) {
                              toggleAccess(teacherId, newValue);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
