import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class ManageFoldersScreen extends StatefulWidget {
  final String assignedBranch;
  final List<String> assignedSubjects;

  ManageFoldersScreen({required this.assignedBranch, required this.assignedSubjects});

  @override
  _ManageFoldersScreenState createState() => _ManageFoldersScreenState();
}

class _ManageFoldersScreenState extends State<ManageFoldersScreen> {
  String selectedProgram = "Bachelors";
  String selectedSemester = "1";
  String? selectedSubject;
  String? selectedFolder;

  List<String> folders = [];

  @override
  void initState() {
    super.initState();
    selectedSubject = widget.assignedSubjects.isNotEmpty ? widget.assignedSubjects.first : null;
    if (selectedSubject != null) fetchExistingFolders();
  }

  /// **🔹 Fetch Existing Folders**
  Future<void> fetchExistingFolders() async {
    if (selectedSubject == null) return;
    try {
      ListResult result = await FirebaseStorage.instance.ref(
        "subjects/$selectedSubject/",
      ).listAll();

      setState(() {
        folders = result.prefixes.map((e) => e.name).toList();
        selectedFolder = folders.isNotEmpty ? folders.first : null;
      });
    } catch (e) {
      print("❌ Error fetching folders: $e");
    }
  }

  /// **🔹 Delete Folder (Only if Empty)**
  Future<void> deleteFolder() async {
    if (selectedFolder == null) return;

    bool confirmDelete = await showDeleteConfirmationDialog();
    if (!confirmDelete) return;

    try {
      ListResult folderContents = await FirebaseStorage.instance.ref(
        "subjects/$selectedSubject/$selectedFolder/",
      ).listAll();

      if (folderContents.items.isNotEmpty) {
        showToast("Cannot delete: Folder is not empty!", Colors.red);
        return;
      }

      await FirebaseStorage.instance.ref(
        "subjects/$selectedSubject/$selectedFolder/",
      ).delete();

      showToast("Folder deleted successfully!", Colors.green);

      /// Refresh Folders After Deletion
      fetchExistingFolders();
    } catch (e) {
      showToast("Error deleting folder: $e", Colors.red);
    }
  }

  /// **🔹 Confirmation Dialog Before Deleting**
  Future<bool> showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $selectedFolder?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
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
        title: Text("Manage Folders", style: TextStyle(color: Colors.white)),
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
       //   elevation: 8,
         // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40),
                Text("Delete Study Folders", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),

                SizedBox(height: 20),

                DropdownButtonFormField(
                  value: selectedSubject,
                  items: widget.assignedSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() {
                    selectedSubject = val;
                    fetchExistingFolders();
                  }),
                  decoration: InputDecoration(
                    labelText: "Select Subject",
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

                SizedBox(height: 10),

                DropdownButtonFormField(
                  value: selectedFolder,
                  items: folders.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (val) => setState(() => selectedFolder = val),
                  decoration: InputDecoration(
                    labelText: "Select Folder",
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

                SizedBox(height: 20),





                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text("Delete Folder"),
                  onPressed: deleteFolder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
