import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'content_view_screen.dart';

class SubjectMaterialScreen extends StatefulWidget {
  final String subjectPath;
  final String subjectName;

  SubjectMaterialScreen({required this.subjectPath, required this.subjectName});

  @override
  _SubjectMaterialScreenState createState() => _SubjectMaterialScreenState();
}

class _SubjectMaterialScreenState extends State<SubjectMaterialScreen> {
  List<String> folders = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchFolders();
  }

  /// **🔹 Fetch Dynamic Folders from Firebase Storage**
  Future<void> fetchFolders() async {
    print("🔍 Fetching folders from: ${widget.subjectPath}");

    try {
      ListResult result = await FirebaseStorage.instance.ref(widget.subjectPath).listAll();

      if (result.prefixes.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "No folders found for this subject.";
        });
      } else {
        setState(() {
          folders = result.prefixes.map((p) => p.name).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to fetch folders: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          "${widget.subjectName} Materials",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,

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
            ? buildShimmerEffect() // ✨ Shimmer while loading
            : errorMessage.isNotEmpty
            ? buildEmptyState(errorMessage)
            : folders.isEmpty
            ? buildEmptyState("No folders found for this subject.")
            : ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContentViewScreen(
                      folderPath: "${widget.subjectPath}/${folders[index]}",
                      title: folders[index].replaceAll("_", " "),
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
              //    color: Colors.white,
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
                    child: Icon(Icons.folder, color: Colors.deepPurple),
                  ),
                  title: Text(
                    folders[index].replaceAll("_", " "),
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
      itemCount: 5,
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

  /// **🚫 Empty State UI**
  Widget buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off, size: 80, color: Colors.grey.shade500),
          SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
