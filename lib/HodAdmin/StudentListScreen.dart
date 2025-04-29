import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
class StudentListScreen extends StatefulWidget {
  final String department;
  StudentListScreen(this.department);

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String? selectedProgram;
  String? selectedSemester;
  List<String> programs = [];
  List<String> semesters = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  /// **🔹 Fetch Program & Semester Options from Firestore**
  Future<void> fetchDropdownData() async {
    try {
      DocumentSnapshot programsDoc =
      await FirebaseFirestore.instance.collection("dropdowns").doc("streams").get();
      DocumentSnapshot semestersDoc =
      await FirebaseFirestore.instance.collection("dropdowns").doc("semesters").get();

      setState(() {
        programs = List<String>.from(programsDoc["list"] ?? []);
        semesters = List<String>.from(semestersDoc["list"] ?? []);
      });
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Students in ${widget.department}", style: TextStyle(color: Colors.white, fontSize: 20)),
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
        child: Column(
          children: [
            // 🔹 Program Dropdown
            buildDropdown("Select Program", programs, selectedProgram, (val) {
              setState(() => selectedProgram = val);
            }),

            SizedBox(height: 10),

            // 🔹 Semester Dropdown
            buildDropdown("Select Semester", semesters, selectedSemester, (val) {
              setState(() => selectedSemester = val);
            }),

            SizedBox(height: 20),

            // 🔹 Student List Display
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("students")
                    .where("specialization", isEqualTo: widget.department)
                    .where("program", isEqualTo: selectedProgram ?? "")
                    .where("semester", isEqualTo: selectedSemester ?? "")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  var students = snapshot.data!.docs;
                  if (students.isEmpty) return Center(child: Text("No students found"));

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      var student = students[index];
                      return buildStudentCard(student["name"], student["email"], student["phone"]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **🔹 Student Card UI**
  Widget buildStudentCard(String name, String email, String phone) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withOpacity(0.2),
          child: Icon(Icons.person, color: Colors.deepPurple),
        ),
        title: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: Theme.of(context).textTheme.bodyMedium),
            Text("📞 $phone", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  /// **🔹 Common Dropdown Builder**
  Widget buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField(
      value: selectedValue,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      //decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),


      decoration: InputDecoration(
        labelText: label,

        labelStyle: TextStyle(
          fontSize: 14,fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, // Label color based on theme
        ),
          border: OutlineInputBorder()
      ),
      style: TextStyle(
        fontSize: 14,fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, // Text color based on theme
      ),




    );
  }
}


