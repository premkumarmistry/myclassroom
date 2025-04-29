import 'dart:typed_data';
import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class UploadMaterialScreen extends StatefulWidget {
  final String? assignedBranch;
  final List<String> assignedSubjects;

  UploadMaterialScreen({required this.assignedBranch, required this.assignedSubjects});

  @override
  _UploadMaterialScreenState createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  String selectedProgram = "Bachelors";
  String selectedSemester = "1";
  String? selectedSubject;
  String? selectedFolder;
  List<String> folders = [];

  List<Uint8List>? selectedFileBytesList;
  List<File>? selectedFiles;
  List<String>? fileNames;
  bool isUploading = false;
  TextEditingController folderController = TextEditingController();
 // late Future<List<String>> programs;
  List<String> programs = ["Bachelors", "Diploma"];
  //late List<String> programs ;
  List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];

  @override
  void initState() {
    super.initState();
    selectedSubject = widget.assignedSubjects.isNotEmpty ? widget.assignedSubjects.first : null;
    fetchExistingFolders();
    //programs = fetchPrograms();

  }
  Future<List<String>> fetchPrograms() async {
    List<String> programList = [];

    // Fetch data from Firestore
    var snapshot = await FirebaseFirestore.instance
        .collection('dropdowns')
        .doc('branches')
        .get();

    var data = snapshot.data();
    if (data != null && data['list'] != null) {
      programList = List<String>.from(data['list']);
    }
    return programList;
  }

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
  Future<void> createNewFolder() async {
    String folderName = folderController.text.trim();

    if (folderName.isEmpty || folders.contains(folderName)) {
      showToast("Folder name already exists or is empty!", Colors.orange);
      return;
    }

    try {
      String folderPath =
          "subjects/$selectedSubject/$folderName/.keep";

      // 🔹 Upload a dummy empty file to create the folder
      await FirebaseStorage.instance.ref(folderPath).putData(Uint8List(0));

      setState(() {
        folders.add(folderName);
        selectedFolder = folderName;
      });

      showToast("Folder '$folderName' created successfully!", Colors.green);
    } catch (e) {
      showToast("Error creating folder: $e", Colors.red);
    }

    folderController.clear();
    Navigator.pop(context); // Close dialog
  }


  /// **🔹 Show Folder Creation Dialog**
  void showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create New Folder"),
        content: TextField(
          controller: folderController,
          decoration: InputDecoration(labelText: "Enter Folder Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(onPressed: createNewFolder, child: Text("Create")),
        ],
      ),
    );
  }

  /// **🔹 Pick Multiple Files**
  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        fileNames = result.files.map((file) => file.name).toList();

        if (kIsWeb) {
          selectedFileBytesList = result.files.map((file) => file.bytes!).toList();
          selectedFiles = null;
        } else {
          selectedFiles = result.files.map((file) => File(file.path!)).toList();
          selectedFileBytesList = null;
        }
      });
      showToast("${fileNames!.length} files selected!", Colors.blue);
    } else {
      showToast("No files selected!", Colors.red);
    }
  }

  /// **🔹 Upload Multiple Files & Refresh UI**
  Future<void> uploadFiles() async {
    if (selectedSubject == null) {
      showToast("Please select a subject!", Colors.red);
      return;
    }

    if (selectedFolder == null || selectedFolder!.isEmpty) {
      showToast("Please select a folder!", Colors.red);
      return;
    }

    if (fileNames == null || fileNames!.isEmpty) {
      showToast("Please select files!", Colors.red);
      return;
    }

    setState(() => isUploading = true);

    try {
      for (int i = 0; i < fileNames!.length; i++) {
        String fullPath =
            "subjects/$selectedSubject/$selectedFolder/${fileNames![i]}";

        final ref = FirebaseStorage.instance.ref(fullPath);
        UploadTask uploadTask;

        if (kIsWeb) {
          uploadTask = ref.putData(selectedFileBytesList![i]);
        } else {
          uploadTask = ref.putFile(selectedFiles![i]);
        }

        await uploadTask;
      }

      showToast("All files uploaded successfully!", Colors.green);

      /// **🔹 Refresh UI After Upload**
      setState(() {
        fileNames = null; // Clear selected files
        selectedFileBytesList = null;
        selectedFiles = null;
        fetchExistingFolders(); // Refresh folders
      });

    } catch (e) {
      showToast("Upload failed! $e", Colors.red);
    } finally {
      setState(() => isUploading = false);
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
        title: Text("Upload Material", style: TextStyle(color: Colors.white, fontSize: 20)),
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
      body:
      SingleChildScrollView(
        child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          //elevation: 8,
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40),
                Text("Upload Study Materials", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),

                SizedBox(height: 20),

                DropdownButtonFormField(
                  value: selectedSubject,
                  items: widget.assignedSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSubject = val;
                      selectedFolder = null; // Reset selected folder when subject changes
                      fetchExistingFolders();  // Refresh folders for the new subject
                    });
                  },
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

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
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
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: showCreateFolderDialog,
                      child: Icon(Icons.create_new_folder, color: Colors.white),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: Icon(Icons.folder_open),
                  label: Text("Select Files"),
                  onPressed: pickFiles,
                ),

                if (fileNames != null && fileNames!.isNotEmpty)
                  Container(
                    height: 120,
                    child: ListView(
                      children: fileNames!.map((name) => ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text(name, style: TextStyle(fontSize: 14)),
                      )).toList(),
                    ),
                  ),

                SizedBox(height: 10),

                ElevatedButton.icon(
                  icon: Icon(Icons.upload),
                  label: isUploading ? CircularProgressIndicator(color: Colors.white) : Text("Upload Files"),
                  onPressed: uploadFiles,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}