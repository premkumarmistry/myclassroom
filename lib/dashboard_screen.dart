import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parikshamadadkendra/StudentAnnouncements.dart';
import 'package:parikshamadadkendra/StudentProfileScreen.dart';
import 'package:parikshamadadkendra/StudentViewMaterials.dart';
import 'package:parikshamadadkendra/choose_login.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final fcm = FirebaseMessaging.instance;










String hodDepartment = "Department";



class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String announcementText = "";
  bool isAnnouncementEnabled = false;

  @override
  void initState() {
    super.initState();

    fetchAnnouncement();
    _getFCMToken();
    //fetchHodDetails();
   subscribeToTopic();

  }

  Future<void> fetchHodDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot hodDoc = await FirebaseFirestore.instance.collection(
          "students").doc(user.uid).get();
      if (hodDoc.exists) {
        setState(() {

          // hodName = hodDoc["name"] ?? "HOD";
          hodDepartment = hodDoc["specialization"] ?? "Department";
          //subscribeToTopic();
        //  showToast(hodDepartment, Colors.red);
        });
      }
    }
  }

  void subscribeToTopic() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Replace with your topic name
    String topic = "Student";

    // Subscribe to the topic
    await messaging.subscribeToTopic(topic);
    showToast("Subscribed to topic: $topic", Colors.green);
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


  Future<void> _getFCMToken() async {
    // Get the FCM token
    String? token = await FirebaseMessaging.instance.getToken();

    // Show the token in a toast


    // Print the token in the console
    print("FCM Token: $token");
  }







  /// 🔹 Fetch Announcement from Firestore
  Future<void> fetchAnnouncement() async {
    try {
      DocumentSnapshot announcementDoc =
      await FirebaseFirestore.instance.collection("config").doc("announcement").get();

      if (announcementDoc.exists) {
        setState(() {
          announcementText = announcementDoc["message"] ?? "";
          isAnnouncementEnabled = announcementDoc["enabled"] ?? false;
        });
      }
    } catch (e) {
      print("❌ Error fetching announcement: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: Key('dashboardScreen'), // 👈 Add this line

      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text("Student Dashboard", style: TextStyle(color: Colors.white, fontSize: 20)),
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
      body: Column(
        children: [
          if (isAnnouncementEnabled && announcementText.isNotEmpty) buildNewsTicker(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  buildDashboardCard(
                    context,
                    title: "View Materials",
                    icon: Icons.menu_book,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Studentviewmaterials()),
                    ),
                  ),


                  SizedBox(height: 20),
                  buildDashboardCard(
                    context,
                    title: "Announcements",
                    icon: Icons.announcement_rounded,
                    color: Colors.orangeAccent,
                    onTap: () => Navigator.push(
                      context,
                     MaterialPageRoute(builder: (context) => StudentAnnouncementsScreen()),
                    ),
                  ),


                  SizedBox(height: 20),
                  buildDashboardCard(
                    context,
                    title: "Profile",
                    icon: Icons.person,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentProfileScreen()),
                    ),
                  ),



                  SizedBox(height: 20),
                  buildDashboardCard(
                    context,
                    title: "Logout",
                    icon: Icons.logout,
                    color: Colors.red,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ChooseLogin()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **🔹 News Ticker for Announcements**
  Widget buildNewsTicker() {
    return Container(
      height: 40,
      color: Colors.red,
      child: Row(
        children: [
          Icon(Icons.campaign, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: MarqueeWidget(text: announcementText),
          ),
        ],
      ),
    );
  }

  /// **🔹 Dashboard Card**
  Widget buildDashboardCard(BuildContext context,
      {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                    style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}

/// **🔹 Marquee Widget for Scrolling Announcements**
class MarqueeWidget extends StatefulWidget {
  final String text;
  MarqueeWidget({required this.text});

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(
        widget.text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
