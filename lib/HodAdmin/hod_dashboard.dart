import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parikshamadadkendra/Choose_login.dart';
import 'package:parikshamadadkendra/HodAdmin/HodUploadAnnouncementScreen.dart';
import 'package:parikshamadadkendra/HodAdmin/ManageAnnouncementsScreen.dart';
import 'package:parikshamadadkendra/HodAdmin/RevokeTeacherAccessScreen.dart';
import 'package:parikshamadadkendra/HodAdmin/StudentListScreen.dart';
import 'package:parikshamadadkendra/HodAdmin/TeacherListScreen.dart';
import 'package:parikshamadadkendra/HodAdmin/VerifyTeachersScreen.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'AssignModulesPage.dart';
import 'RevokeModulesPage.dart';
import 'assign_teacher_screen.dart';


class HodDashboard extends StatefulWidget {
  @override
  _HodDashboardState createState() => _HodDashboardState();
}

class _HodDashboardState extends State<HodDashboard> {
  String hodName = "HOD";
  String hodDepartment = "Department";
  String greetingMessage = "Welcome!";
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    fetchHodDetails();
    setGreetingMessage();
    _getFCMToken();
    subscribeToTopic();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show a snackbar or dialog
        showForegroundNotification(message.notification!.title, message.notification!.body);
      }
    });
  }
  void showForegroundNotification(String? title, String? body) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title\n$body'),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.blue,
      ),
    );
  }


  Future<void> _getFCMToken() async {
    // Get the FCM token
    String? token = await FirebaseMessaging.instance.getToken();

    // Show the token in a toast


    // Print the token in the console
    print("FCM Token: $token");


    saveTokenToFirestore(token!);
  }








  /// **🔹 Fetch HOD Details (Name & Department)**
  void fetchHodDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot hodDoc = await FirebaseFirestore.instance.collection(
          "hods").doc(user.uid).get();
      if (hodDoc.exists) {
        setState(() {
          hodName = hodDoc["name"] ?? "HOD";
          hodDepartment = hodDoc["department"] ?? "Department";
        });
      }
    }
  }

  /// **🔹 Set Greeting Message Based on Time**
  void setGreetingMessage() {
    int hour = DateTime
        .now()
        .hour;
    if (hour >= 5 && hour < 12) {
      greetingMessage = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greetingMessage = "Good Afternoon";
    } else {
      greetingMessage = "Good Evening";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("HOD Dashboard",
            style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,


        actions: [
          IconButton(
            icon: Icon(
              Provider
                  .of<ThemeProvider>(context)
                  .themeData
                  .brightness == Brightness.dark
                  ? Icons.wb_sunny // Sun for Light Mode
                  : Icons.nightlight_round, // Moon for Dark Mode
              color: Colors.white,
            ),
            onPressed: () {
              // Toggle the theme using the provider
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Call logout function on press
          ),
        ],

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Greeting Message
            Text(
              "$greetingMessage, $hodName!",
              style: Theme.of(context).textTheme.titleLarge,

            ),
            Text(
              "Department: $hodDepartment",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 20),

            // 🔹 Action Cards
            Expanded(
              child: ListView(
                children: [
                  buildDashboardCard(
                    title: "Assign Subjects to Teachers",
                    icon: Icons.assignment_ind,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AssignTeacherScreen()));
                    },
                  ),
                  SizedBox(height: 20),
                  buildDashboardCard(
                    title: "Assign Modules",
                    icon: Icons.view_module_rounded,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AssignModulesPage()));
                    },
                  ),
                  SizedBox(height: 20),

                  /// **🔹 Logout Card**
                  buildDashboardCard(
                      title: "Create Announcement",
                      icon: Icons.announcement_rounded,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                HodUploadAnnouncementScreen()));
                      }
                  ),
                  SizedBox(height: 20),
                  buildDashboardCard(
                    title: "Verify Teachers",
                    icon: Icons.verified_user,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => VerifyTeachersScreen()));
                    },
                  ),
                  SizedBox(height: 20),
                  buildDashboardCard(
                    title: "Revoke Teacher Access",
                    icon: Icons.remove_circle_outline,
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => RevokeTeacherAccessScreen()));
                    },
                  ),


                  SizedBox(height: 20),
                  buildDashboardCard(
                    title: "Revoke Modules",
                    icon: Icons.view_module_rounded,
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => RevokeModulesPage()));
                    },
                  ),

                  SizedBox(height: 20),

                  /// **🔹 Logout Card**
                  buildDashboardCard(
                      title: "Manage Announcements",
                      icon: Icons.announcement_rounded,
                      color: Colors.lightBlueAccent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ManageAnnouncementsScreen()));
                      }
                  ),
                  SizedBox(height: 20),
                  buildDashboardCard(
                    title: "View List of Students",
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              StudentListScreen(hodDepartment)));
                    },
                  ),
                  SizedBox(height: 20),
                  buildDashboardCard(
                    title: "View List of Teachers",
                    icon: Icons.school,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              TeacherListScreen(hodDepartment)));
                    },
                  ),









                  SizedBox(height: 20),

                  /// **🔹 Logout Card**
                  buildDashboardCard(
                    title: "Logout",
                    icon: Icons.logout,
                    color: Colors.redAccent,
                    onTap: () => _logout(context),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **🔹 Card Builder for Dashboard Options**
  Widget buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required Function() onTap,
  }) {
    final theme = Theme.of(context); // Get the current theme

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white // White text for dark mode
                        : Colors.black, // Black text for light mode
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
/// **🔹 Logout Function**
void _logout(BuildContext context) async {
  bool confirmLogout = await _showLogoutConfirmationDialog(context);
  if (confirmLogout) {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ChooseLogin()), // 🔹 Redirect to Choose Login Page
          (route) => false,
    );
  }
}

/// **🔹 Logout Confirmation Dialog**
Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Logout Confirmation"),
      content: Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Logout", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  ) ??
      false;
}

// Function to save the FCM token in Firestore
Future<void> saveTokenToFirestore(String token) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('No user is currently signed in.');
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('hods').doc(user.uid).update({
      'fcm': token,
    });
    print('Token saved successfully!');
  } catch (e) {
    print('Error saving token: $e');
  }
}
void subscribeToTopic() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Replace with your topic name
  String topic = "Student";

  // Subscribe to the topic
  await messaging.subscribeToTopic(topic);
  print("Subscribed to topic: $topic");
}