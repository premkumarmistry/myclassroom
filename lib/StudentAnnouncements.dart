import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // 📅 For Date Formatting

class StudentAnnouncementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("📡 Fetching Announcements..."); // Debug message
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text("Announcements", style: TextStyle(color: Colors.white),),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("announcements")
            .where("enabled", isEqualTo: true) // 🔹 Fetch only active announcements
            .orderBy("date", descending: true) // 🔹 Show latest first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("⏳ Firestore is still loading announcements...");
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("❌ Firestore Error: ${snapshot.error}");
            return Center(child: Text("Error loading announcements. Please try again later."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("⚠ No announcements found in Firestore.");
            return Center(
                child: Text(
                  "No announcements available",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ));
          }

          var announcements = snapshot.data!.docs;
          print("✅ Announcements Fetched: ${announcements.length}");

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              var announcement = announcements[index];
              print("📢 Title: ${announcement["title"]}");

              return AnnouncementCard(announcement: announcement);
            },
          );
        },
      ),
    );
  }
}

// 🔹 Announcement Card Widget (With Fix for Timestamp Issue)
class AnnouncementCard extends StatelessWidget {
  final QueryDocumentSnapshot announcement;

  AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    String title = announcement["title"];
    String description = announcement["description"];
    Timestamp timestamp = announcement["date"]; // 🔥 Firestore stores as Timestamp
    String formattedDate = DateFormat('dd-MM-yyyy').format(
        timestamp.toDate()); // ✅ Convert Timestamp to String
    String priority = announcement["priority"];
    String? attachmentUrl = announcement["attachment_url"];

    print(
        "📋 Rendering Announcement: $title, Priority: $priority, Date: $formattedDate");

    Color priorityColor = Colors.blue;
    if (priority == "Urgent")
      priorityColor = Colors.red;
    else if (priority == "Event") priorityColor = Colors.green;

    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title with Priority Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(priority,
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            SizedBox(height: 8),

            // 🔹 Description
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 10),

            // 🔹 Date & Attachment (if available)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📅 $formattedDate", // ✅ Correct Date Format
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (attachmentUrl != null && attachmentUrl.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _openAttachment(context, attachmentUrl),
                    icon: Icon(Icons.attachment, size: 18),
                    label: Text("View File", style: TextStyle(fontSize: 14)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openAttachment(BuildContext context, String url) async {
    Uri fileUri = Uri.parse(url);

    if (await canLaunchUrl(fileUri)) {
      await launchUrl(fileUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot open attachment.")),
      );
    }
  }
}