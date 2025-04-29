import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class RemoveDocumentsScreen extends StatefulWidget {
  final String assignedBranch;
  final List<String> assignedSubjects;

  RemoveDocumentsScreen({required this.assignedBranch, required this.assignedSubjects});

  @override
  _RemoveDocumentsScreenState createState() => _RemoveDocumentsScreenState();
}

class _RemoveDocumentsScreenState extends State<RemoveDocumentsScreen> {
  String selectedProgram = "Bachelors";
  String selectedSemester = "1";
  String? selectedSubject;
  String? selectedFolder;
  String? selectedFile;

  List<String> folders = [];
  List<String> files = [];

  @override
  void initState() {
    super.initState();
    selectedSubject = widget.assignedSubjects.isNotEmpty ? widget.assignedSubjects.first : null;
    if (selectedSubject != null) fetchExistingFolders();
  }

  /// **🔹 Fetch Folders**
  Future<void> fetchExistingFolders() async {
    if (selectedSubject == null) return;
    try {
      ListResult result = await FirebaseStorage.instance.ref(
        "subjects/$selectedSubject/",
      ).listAll();

      setState(() {
        folders = result.prefixes.map((e) => e.name).toList();
        selectedFolder = folders.isNotEmpty ? folders.first : null;
        if (selectedFolder != null) fetchFiles();
      });
    } catch (e) {
      print("❌ Error fetching folders: $e");
    }
  }

  /// **🔹 Fetch Files Inside Folder**
  Future<void> fetchFiles() async {
    if (selectedFolder == null) return;
    try {
      ListResult result = await FirebaseStorage.instance.ref(
        "subjects/$selectedSubject/$selectedFolder/",
      ).listAll();

      setState(() {
        files = result.items.map((e) => e.name).toList();
        selectedFile = files.isNotEmpty ? files.first : null;
      });
    } catch (e) {
      print("❌ Error fetching files: $e");
    }
  }

  /// **🔹 Delete File**
  Future<void> deleteFile() async {
    if (selectedFile == null || selectedFolder == null) return;

    bool confirmDelete = await showDeleteConfirmationDialog();
    if (!confirmDelete) return;

    try {
      String filePath =
          "subjects/$selectedSubject/$selectedFolder/$selectedFile";

      await FirebaseStorage.instance.ref(filePath).delete();

      showToast("File deleted successfully!", Colors.green);

      /// Refresh Files After Deletion
      fetchFiles();
    } catch (e) {
      showToast("Error deleting file: $e", Colors.red);
    }
  }

  /// **🔹 Confirmation Dialog Before Deleting**
  Future<bool> showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $selectedFile?"),
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
        title: Text("Manage Files", style: TextStyle(color: Colors.white)),
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

        //  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40),

                Text("Delete Study Materials", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),

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
                  onChanged: (val) => setState(() {
                    selectedFolder = val;
                    fetchFiles();
                  }),
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

                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, // Ensures dropdown takes full width
                  child: DropdownButtonFormField<String>(
                    isExpanded: true, // ✅ Prevents overflow
                    value: selectedFile != null && files.contains(selectedFile) ? selectedFile : null,
                    items: files.toSet().map((file) {
                      return DropdownMenuItem<String>(
                        value: file,
                        child: Text(
                          file,
                          overflow: TextOverflow.ellipsis, // ✅ Truncate long names with ...
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedFile = val),
                    decoration: InputDecoration(

                      labelText: "Select File",
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
                ),

                SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text("Delete File"),
                  onPressed: deleteFile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
