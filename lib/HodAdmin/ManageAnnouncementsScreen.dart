import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme.dart'; // For date formatting

class ManageAnnouncementsScreen extends StatefulWidget {
  @override
  _ManageAnnouncementsScreenState createState() => _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends State<ManageAnnouncementsScreen> {
  bool isLoading = true;
  List<DocumentSnapshot> announcements = [];

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  /// **🔹 Fetch All Announcements**
  Future<void> fetchAnnouncements() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("announcements")
          .orderBy("date", descending: true)
          .get();

      setState(() {
        announcements = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching announcements: $e");
      setState(() => isLoading = false);
    }
  }

  /// **🔹 Edit Announcement**
  Future<void> editAnnouncement(String docId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection("announcements").doc(docId).update(data);
      showToast("Announcement updated successfully!", Colors.green);
      fetchAnnouncements();
    } catch (e) {
      showToast("Failed to update announcement!", Colors.red);
    }
  }

  /// **🔹 Remove Only the Attachment (Keep Announcement)**
  Future<void> removeAttachment(String docId, String attachmentUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(attachmentUrl).delete();
      await FirebaseFirestore.instance.collection("announcements").doc(docId).update({"attachment_url": null});

      showToast("Attachment removed successfully!", Colors.green);
      fetchAnnouncements();
    } catch (e) {
      showToast("Failed to remove attachment!", Colors.red);
    }
  }

  /// **🔹 Upload & Replace Attachment**
  Future<void> replaceAttachment(String docId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      String newFilePath = "announcements/$docId/$fileName";

      try {
        UploadTask uploadTask = FirebaseStorage.instance.ref(newFilePath).putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;
        String newFileUrl = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection("announcements").doc(docId).update({"attachment_url": newFileUrl});

        showToast("Attachment replaced successfully!", Colors.green);
        fetchAnnouncements();
      } catch (e) {
        showToast("Failed to upload new attachment!", Colors.red);
      }
    }
  }
  void showEditDialog(DocumentSnapshot announcement) {
    String docId = announcement.id;
    TextEditingController titleController = TextEditingController(text: announcement["title"]);
    TextEditingController descriptionController = TextEditingController(text: announcement["description"]);
    String priority = announcement["priority"];
    bool enabled = announcement["enabled"];
    String? attachmentUrl = announcement["attachment_url"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Edit Announcement",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// **Title Field**
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title, color: Colors.deepPurple),
                      ),
                    ),
                    SizedBox(height: 15),

                    /// **Description Field**
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Description",

                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description, color: Colors.deepPurple),
                      ),
                    ),
                    SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: priority,
                      onChanged: (val) => setState(() => priority = val!),
                      items: ["Urgent", "General", "Event"].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                type == "Urgent"
                                    ? Icons.warning
                                    : type == "General"
                                    ? Icons.info
                                    : Icons.event,
                                color: type == "Urgent"
                                    ? Colors.red
                                    : type == "General"
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                              SizedBox(width: 10),
                              Text(
                                type,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white // Text color for dark mode
                                      : Colors.black, // Text color for light mode
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: "Priority",
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white // Label text color for dark mode
                              : Colors.black, // Label text color for light mode
                        ),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.flag,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white // Icon color for dark mode
                              : Colors.deepPurple, // Icon color for light mode
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    /// **Enable/Disable Toggle**
                    SwitchListTile(
                      title: Text("Enable Announcement", style: TextStyle(fontSize: 16)),
                      activeColor: Colors.green,
                      value: enabled,
                      onChanged: (val) {
                        setState(() => enabled = val);
                      },
                    ),
                    SizedBox(height: 10),

                    /// **Attachment Handling**
                    if (attachmentUrl != null)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(Icons.attach_file, color: Colors.deepPurple),
                          title: Text(attachmentUrl.split('/').last, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  Navigator.pop(context);
                                  removeAttachment(docId, attachmentUrl);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.upload_file, color: Colors.green),
                                onPressed: () {
                                  Navigator.pop(context);
                                  replaceAttachment(docId);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 20),

                    /// **Update Button**
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          editAnnouncement(docId, {
                            "title": titleController.text,
                            "description": descriptionController.text,
                            "priority": priority,
                            "enabled": enabled, // ✅ Save updated value
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text("Update Announcement", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// **🔹 Show Toast Message**
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
      backgroundColor: theme.scaffoldBackgroundColor,      appBar: AppBar(
        title: Text("Manage Announcement", style: TextStyle(color: Colors.white)),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          var announcement = announcements[index];
          String docId = announcement.id;
          String title = announcement["title"];
          String description = announcement["description"];
          String priority = announcement["priority"];
          bool enabled = announcement["enabled"];
          String? attachmentUrl = announcement["attachment_url"];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Icon(Icons.campaign, color: priorityColor(priority), size: 30),
              title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white // Text color for dark mode
                          : Colors.black, // Text color for light mode
                    ),
                  ),
                  SizedBox(height: 5),
                  Text("Priority: $priority", style: TextStyle(color: priorityColor(priority))),
                  SizedBox(height: 5),
                  Text("Enabled: ${enabled ? 'Yes' : 'No'}", style: TextStyle(color: enabled ? Colors.green : Colors.red)),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => showEditDialog(announcement),
              ),
            ),
          );
        },
      ),
    );
  }

  /// **🔹 Priority Color Helper**
  Color priorityColor(String priority) {
    switch (priority) {
      case "Urgent":
        return Colors.red;
      case "General":
        return Colors.orange;
      case "Event":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
