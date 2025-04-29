import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class AssignTeacherScreen extends StatefulWidget {
  @override
  _AssignTeacherScreenState createState() => _AssignTeacherScreenState();
}

class _AssignTeacherScreenState extends State<AssignTeacherScreen> {
  //List<String> programs = ["Diploma", "Bachelors"];
  String? selectedProgram;
  String? hodDepartment; // Auto-fetched HOD department
  List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];
  String? selectedSemester;
  List<String> subjects = [];
  String? selectedSubject;
  List<String> teachers = [];
  String? selectedTeacher;
  bool isLoading = false;
  List<String> programs = [];

  @override
  void initState() {
    super.initState();
    fetchPrograms();
    fetchHodDepartment();
  }
  /// **🔹 Fetch Programs from Firestore**
  Future<void> fetchPrograms() async {
    setState(() => isLoading = true);

    try {
      // Fetch programs from Firestore
      DocumentSnapshot programsDoc = await FirebaseFirestore.instance.collection('dropdowns').doc('streams').get();

      if (programsDoc.exists) {
        var data = programsDoc.data() as Map<String, dynamic>;
        if (data.containsKey('list')) {
          setState(() {
            programs = List<String>.from(data['list']);
            selectedProgram = programs.isNotEmpty ? programs[0] : null; // Set default selected program
            fetchSubjects(); // Fetch subjects after programs are loaded
          });
        }
      } else {
        showToast("No programs found!", Colors.orange);
      }
    } catch (e) {
      showToast("Error fetching programs!", Colors.red);
    }

    setState(() => isLoading = false);
  }
  /// **🔹 Fetch HOD's Assigned Department**
  Future<void> fetchHodDepartment() async {
    setState(() => isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot hodDoc =
      await FirebaseFirestore.instance.collection("hods").doc(user.uid).get();
      if (hodDoc.exists) {
        setState(() {
          hodDepartment = hodDoc["department"];
          fetchTeachers(); // Fetch teachers after department is set
        });
      }
    }
    setState(() => isLoading = false);
  }

  /// **🔹 Fetch Subjects Based on Selected Program & Semester**
  Future<void> fetchSubjects() async {
    if (selectedProgram == null || selectedSemester == null) return;

    setState(() => isLoading = true);
    String documentID = "${selectedProgram}_${hodDepartment}_${selectedSemester}";

    try {
      DocumentSnapshot subjectDoc =
      await FirebaseFirestore.instance.collection("subjects").doc(documentID).get();

      if (subjectDoc.exists && subjectDoc.data() != null) {
        var data = subjectDoc.data() as Map<String, dynamic>;
        if (data.containsKey("subjects")) {
          setState(() {
            subjects = List<String>.from(data["subjects"]);
            selectedSubject = subjects.isNotEmpty ? subjects[0] : null;
          });
        }
      } else {
        setState(() {
          subjects = [];  // Clear subjects if no subjects are found
          selectedSubject = null;  // Reset selected subject
        });
        showToast("No subjects found for this selection!", Colors.orange);
      }
    } catch (e) {
      showToast("Error fetching subjects!", Colors.red);
    }
    setState(() => isLoading = false);
  }

  /// **🔹 Fetch Teachers from the HOD's Department**
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
          teachers = teacherDocs.docs.map((doc) => doc["name"].toString()).toList();
          selectedTeacher = teachers.isNotEmpty ? teachers[0] : null;
        });
      } else {
        setState(() {
          teachers = [];
          selectedTeacher = null;
        });
        showToast("No teachers found in $hodDepartment!", Colors.orange);
      }
    } catch (e) {
      showToast("Error fetching teachers!", Colors.red);
    }

    setState(() => isLoading = false);
  }

  /// **🔹 Assign Subject to Selected Teacher**
  void assignSubjectToTeacher() async {
    if (selectedTeacher == null || selectedSubject == null) {
      showToast("Please select both Subject and Teacher!", Colors.red);
      return;
    }

    setState(() => isLoading = true);
    try {
      QuerySnapshot teacherQuery = await FirebaseFirestore.instance
          .collection("teachers")
          .where("name", isEqualTo: selectedTeacher)
          .get();

      if (teacherQuery.docs.isEmpty) {
        showToast("Teacher not found!", Colors.red);
        return;
      }

      String teacherDocId = teacherQuery.docs.first.id;
      await FirebaseFirestore.instance.collection("teachers").doc(teacherDocId).update({
        "assigned_subjects": FieldValue.arrayUnion([selectedSubject])
      });

      showToast("Subject assigned successfully!", Colors.green);
    } catch (e) {
      showToast("Error assigning subject!", Colors.red);
    }

    setState(() => isLoading = false);
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
        title: Text("Assign Teacher", style: TextStyle(color: Colors.white, fontSize: 20)),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          //elevation: 8,
         // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              //  SizedBox(height: 20),
                Text(
                  "Assign Subjects to Teachers",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                SizedBox(height: 20),

                buildDropdown("Select Program", programs, selectedProgram, (val) {
                  setState(() {
                    selectedProgram = val;
                    fetchSubjects();
                  });
                }),

                // 🔹 Show HOD's Department (Disabled Field)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    initialValue: hodDepartment ?? "Fetching...",
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Branch (Auto-Fetched)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                buildDropdown("Select Semester", semesters, selectedSemester, (val) {
                  setState(() {
                    selectedSemester = val;
                    fetchSubjects();
                  });
                }),

                buildDropdown("Select Subject", subjects, selectedSubject, (val) {
                  setState(() => selectedSubject = val);
                }),

                buildDropdown("Select Teacher", teachers, selectedTeacher, (val) {
                  setState(() => selectedTeacher = val);
                }),

                SizedBox(height: 20),

                GestureDetector(
                  onTap: assignSubjectToTeacher,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Assign Subject",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **🔹 Common Dropdown Builder**
  Widget buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        value: selectedValue,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
     //   decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),

        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, // Label color based on theme
          ),
        ),
        style: TextStyle(
          fontSize: 14,fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, // Text color based on theme
        ),

      ),
    );
  }
}
