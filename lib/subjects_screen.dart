import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'subject_material_screen.dart';
import 'theme.dart';

class SubjectsScreen extends StatefulWidget {
  final String selectedStream;
  final String selectedBranch;
  final String selectedSemester;

  SubjectsScreen({required this.selectedStream, required this.selectedBranch, required this.selectedSemester});

  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List<String> subjects = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    String documentID = "${widget.selectedStream}_${widget.selectedBranch}_${widget.selectedSemester}";
    print("🔍 Fetching subjects from Firestore document: $documentID");

    try {
      DocumentSnapshot subjectDoc = await FirebaseFirestore.instance.collection("subjects").doc(documentID).get();

      if (subjectDoc.exists && subjectDoc.data() != null) {
        var data = subjectDoc.data() as Map<String, dynamic>;
        if (data.containsKey("subjects")) {
          setState(() {
            subjects = List<String>.from(data["subjects"]);
            errorMessage = "";
          });
        } else {
          setState(() {
            errorMessage = "Subjects field is missing in Firestore.";
            subjects = [];
          });
        }
      } else {
        setState(() {
          errorMessage = "No subjects found for this selection.";
          subjects = [];
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch subjects: $e";
        subjects = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Soft background color
      appBar: AppBar(
        title: Text(
          "Subjects - Semester ${widget.selectedSemester}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
          // Soft dark color
        elevation: 2,
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: isLoading
            ? buildShimmerEffect() // ✨ Shimmer Effect while loading
            : errorMessage.isNotEmpty
            ? Center(
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : subjects.isEmpty
            ? Center(
          child: Text(
            "No subjects found.",
            style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectMaterialScreen(
                      subjectPath:
                      "subjects/${subjects[index]}",
                      subjectName: subjects[index],
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
               //   color: Colors.white, // Soft White Card
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800] // Dark grey for dark mode
                      : Colors.white,


                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Icon(Icons.book, color: Colors.deepPurple),
                  ),
                  title: Text(
                    subjects[index],
                    style:  Theme.of(context).textTheme.titleLarge,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// **✨ Shimmer Loading Effect**
  Widget buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5, // Show 5 shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 80,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
