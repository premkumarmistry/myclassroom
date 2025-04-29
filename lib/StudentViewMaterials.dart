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

  /// *🔹 Fetch Dropdown Values from Firestore*
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

      // Debugging prints
      print("✅ Streams: $dropStream");
      print("✅ Branches: $dropBranch");
      print("✅ Semesters: $dropSemester");
    } catch (e) {
      print("❌ Error fetching dropdown data: $e");
      setState(() => isLoading = false);
    }
  }

  /// *🔹 Show BottomSheet for Dropdown Selection*
  void showDropdownBottomSheet(
      {required String title,
        required List<String> items,
        required String? selectedValue,
        required Function(String) onSelected}) {
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

  /// *🔹 Show Toast Message*
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


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          "View Materials",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,

        centerTitle: true,
        actions: [
          /*IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),*/

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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              //  SizedBox(height: 20),
                /*Text(
                  "Welcome to Pariksha Madad Kendra 🎓",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  textAlign: TextAlign.center,
                ),*/
               // SizedBox(height: 20),

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
                    buildDropdownCard("Select Stream", selectedStream, dropStream, (val) {
                      setState(() => selectedStream = val);
                    }),
                    buildDropdownCard("Select Branch", selectedBranch, dropBranch, (val) {
                      setState(() => selectedBranch = val);
                    }),
                    buildDropdownCard("Select Semester", selectedSemester, dropSemester, (val) {
                      setState(() => selectedSemester = val);
                    }),

                    SizedBox(height: 30),

                    GestureDetector(
                      onTap: () {
                        if (selectedStream != null && selectedBranch != null && selectedSemester != null) {
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
                          gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
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
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  /// *🔹 Enhanced Dropdown UI (Card with Tap to Open BottomSheet)*
  Widget buildDropdownCard(String label, String? selectedValue, List<String> items, Function(String) onSelected) {
    return GestureDetector(
      onTap: () => showDropdownBottomSheet(title: label, items: items, selectedValue: selectedValue, onSelected: onSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
         //   color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800] // Dark grey for dark mode
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
              Text(selectedValue ?? label, style:  Theme.of(context).textTheme.titleLarge),
              Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }
}