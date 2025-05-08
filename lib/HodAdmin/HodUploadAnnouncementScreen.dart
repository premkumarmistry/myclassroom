import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../theme.dart'; // For date formatting

class HodUploadAnnouncementScreen extends StatefulWidget {
  @override
  _HodUploadAnnouncementScreenState createState() => _HodUploadAnnouncementScreenState();
}

class _HodUploadAnnouncementScreenState extends State<HodUploadAnnouncementScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedPriority = "General";
  String selectedUser = "Student";
  bool isEnabled = true;
  File? selectedFile;
  String? attachmentUrl;
  bool isUploading = false;
  String hodDepartment = "Department";

  @override
  void initState() {
    super.initState();
    fetchHodDetails();
    //setGreetingMessage();
  }
  void fetchHodDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot hodDoc = await FirebaseFirestore.instance.collection(
          "hods").doc(user.uid).get();
      if (hodDoc.exists) {
        setState(() {

         // hodName = hodDoc["name"] ?? "HOD";
          hodDepartment = hodDoc["department"] ?? "Department";
          showToast(hodDepartment, Colors.red);
        });
      }
    }
  }





  /// **🔹 Pick File**
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => selectedFile = File(result.files.single.path!));
    }
  }

  /// **🔹 Upload File to Firebase Storage and Get URL**
  Future<String?> uploadFileToStorage() async {
    if (selectedFile == null) return null; // No file selected

    setState(() => isUploading = true);

    try {
      // 🔹 Format the date for folder structure (YYYY-MM-DD)
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = selectedFile!.path.split('/').last;
      String storagePath = "announcements/$formattedDate/$fileName";

      Reference ref = FirebaseStorage.instance.ref(storagePath);
      UploadTask uploadTask = ref.putFile(selectedFile!);
      TaskSnapshot snapshot = await uploadTask;
      String fileUrl = await snapshot.ref.getDownloadURL();

      return fileUrl;
    } catch (e) {
      showToast("Upload Failed: $e", Colors.red);
      return null;
    } finally {
      setState(() => isUploading = false);
    }
  }

  /// **🔹 Upload Announcement to Firestore (After File Upload)**
  Future<void> uploadAnnouncement() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      showToast("Title & Description are required!", Colors.red);
      return;
    }

    setState(() => isUploading = true);

    String? fileUrl = await uploadFileToStorage(); // Wait for file upload

    try {
      await FirebaseFirestore.instance.collection("announcements").add({
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "date": Timestamp.now(),
        "priority": selectedPriority,
        "attachment_url": fileUrl ?? "", // Save only if file is uploaded
        "enabled": isEnabled,
        "sendto": selectedUser,
        "department" :hodDepartment ,
      });

      // Reset UI after success
      setState(() {
        isUploading = false;
        titleController.clear();
        descriptionController.clear();
        selectedFile = null;
        attachmentUrl = null;
      });

      showToast("Announcement Uploaded Successfully!", Colors.green);
    } catch (e) {
      setState(() => isUploading = false);
      showToast("Error: $e", Colors.red);
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Upload Announcement", style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            //elevation: 10,
            //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 40),
                  Text(
                    "Create New Announcement",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 20),

                  // 🔹 Title Input
                  buildTextField("Title", titleController, Icons.title),

                  // 🔹 Description Input
                  buildTextField("Description", descriptionController, Icons.description, maxLines: 3),
                  //buildUserSelectionDropdown(),
                  // 🔹 Priority Dropdown
                  buildPriorityDropdown(),
                  buildUserSelectionDropdown(),
                  // 🔹 Enable/Disable Switch
                  buildEnableSwitch(),

                  // 🔹 File Upload
                  buildFileUploadSection(),

                  SizedBox(height: 20),

                  // 🔹 Upload Button
                  GestureDetector(
                    onTap: isUploading ? null : uploadAnnouncement,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: isUploading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Upload Announcement",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// **🔹 Common Text Field with Icon**
  Widget buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// **🔹 Priority Dropdown**
  Widget buildPriorityDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        value: selectedPriority,
        items: [
          DropdownMenuItem(value: "Urgent", child: Text("🔴 Urgent", style: TextStyle(color: Colors.red))),
          DropdownMenuItem(value: "General", child: Text("🟡 General", style: TextStyle(color: Colors.orange))),
          DropdownMenuItem(value: "Event", child: Text("🟢 Event", style: TextStyle(color: Colors.green))),
        ],
        onChanged: (val) => setState(() => selectedPriority = val as String),
        decoration: InputDecoration(labelText: "Priority", border: OutlineInputBorder()),
      ),
    );
  }







  /// **🔹 Enable/Disable Toggle**
  Widget buildEnableSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Enable Announcement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Switch(
          value: isEnabled,
          onChanged: (val) => setState(() => isEnabled = val),
          activeColor: Colors.deepPurple,
        ),
      ],
    );
  }



  Widget buildUserSelectionDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedUser,
        items: [
          DropdownMenuItem(value: "Student", child: Text("🎓 Student" ,style: TextStyle(color: Colors.green))),
          DropdownMenuItem(value: "Teacher", child: Text("👩‍🏫 Teacher", style: TextStyle(color: Colors.green))),
        ],
        onChanged: (val) => setState(() => selectedUser = val!),
        decoration: InputDecoration(
          labelText: "Send To",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }




  /// **🔹 File Upload Section**
  Widget buildFileUploadSection() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: pickFile,
          icon: Icon(
            Icons.attach_file,
            color: Colors.white, // Set icon color to white
          ),
          label: Text(
            selectedFile == null ? "Select File" : "File Selected",
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple, // Button background color
          ),
        )


      ],
    );
  }
}
Future<void> saveTokenToFirestore(String token) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('No user is currently signed in.');
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('hods').doc(user.uid).update({
      'targetFcmToken': token,
    });
    print('Token saved successfully!');
  } catch (e) {
    print('Error saving token: $e');
  }
}