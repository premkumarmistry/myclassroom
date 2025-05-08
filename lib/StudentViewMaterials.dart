import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/subjects_screen.dart';
import 'package:provider/provider.dart';
import 'theme.dart';

class Studentviewmaterials extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<Studentviewmaterials> {
  List<String> dropStream = [];
  List<String> dropBranch = [];
  List<String> dropSemester = [];

  String? selectedStream;
  String? selectedBranch;
  String? selectedSemester;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot streamDoc = await firestore.collection("dropdowns").doc("streams").get();
      DocumentSnapshot branchDoc = await firestore.collection("dropdowns").doc("branches").get();
      DocumentSnapshot semesterDoc = await firestore.collection("dropdowns").doc("semesters").get();

      setState(() {
        dropStream = streamDoc.exists ? List<String>.from(streamDoc["list"] ?? []) : [];
        dropBranch = branchDoc.exists ? List<String>.from(branchDoc["list"] ?? []) : [];
        dropSemester = semesterDoc.exists ? List<String>.from(semesterDoc["list"] ?? []) : [];

        selectedStream = dropStream.isNotEmpty ? dropStream[0] : null;
        selectedBranch = dropBranch.isNotEmpty ? dropBranch[0] : null;
        selectedSemester = dropSemester.isNotEmpty ? dropSemester[0] : null;

        isLoading = false;
      });

      print("✅ Streams: $dropStream");
      print("✅ Branches: $dropBranch");
      print("✅ Semesters: $dropSemester");
    } catch (e) {
      print("❌ Error fetching dropdown data: $e");
      setState(() => isLoading = false);
    }
  }

  void showDropdownBottomSheet({
    required String title,
    required List<String> items,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    if (items.isEmpty) {
      showToast("No data found for $title", Colors.red);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 400,
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(items[index], style: TextStyle(fontSize: 18)),
                      trailing: selectedValue == items[index] ? Icon(Icons.check, color: Colors.deepPurple) : null,
                      onTap: () {
                        onSelected(items[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KeyedSubtree(
      key: Key("studentViewMaterialScreen"),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            "View Materials",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Provider.of<ThemeProvider>(context).themeData.brightness == Brightness.dark
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
                color: Colors.white,
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLoading
                      ? Column(
                    children: [
                      CircularProgressIndicator(color: Colors.deepPurple),
                      SizedBox(height: 10),
                      Text("please wait...", style: TextStyle(fontSize: 16)),
                    ],
                  )
                      : Column(
                    children: [
                      buildDropdownCard(
                        "Select Stream",
                        selectedStream,
                        dropStream,
                            (val) => setState(() => selectedStream = val),
                        Key("dropdownStream"),
                      ),
                      buildDropdownCard(
                        "Select Branch",
                        selectedBranch,
                        dropBranch,
                            (val) => setState(() => selectedBranch = val),
                        Key("dropdownBranch"),
                      ),
                      buildDropdownCard(
                        "Select Semester",
                        selectedSemester,
                        dropSemester,
                            (val) => setState(() => selectedSemester = val),
                        Key("dropdownSemester"),
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        key: Key("btnShowSubjects"),
                        onTap: () {
                          if (selectedStream != null &&
                              selectedBranch != null &&
                              selectedSemester != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubjectsScreen(
                                  selectedStream: selectedStream!,
                                  selectedBranch: selectedBranch!,
                                  selectedSemester: selectedSemester!,
                                ),
                              ),
                            );
                          } else {
                            showToast("Please select all fields!", Colors.red);
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient:
                            LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Show Subjects",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownCard(
      String label,
      String? selectedValue,
      List<String> items,
      Function(String) onSelected,
      Key? key,
      ) {
    return GestureDetector(
      key: key,
      onTap: () => showDropdownBottomSheet(
        title: label,
        items: items,
        selectedValue: selectedValue,
        onSelected: onSelected,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(selectedValue ?? label,
                  style: Theme.of(context).textTheme.titleLarge),
              Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }
}
