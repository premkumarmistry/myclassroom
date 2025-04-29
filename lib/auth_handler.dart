import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parikshamadadkendra/HodAdmin/hod_dashboard.dart';
import 'package:parikshamadadkendra/Teacher/teacher_dashboard.dart';

import 'package:parikshamadadkendra/dashboard_screen.dart'; // Student Dashboard

import 'package:parikshamadadkendra/register_or_login.dart'; // Register/Login Screen
import 'package:parikshamadadkendra/role_selection_screen.dart'; // Role Selection Screen

class AuthHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator())); // 🔄 Loading UI
        }

        User? user = snapshot.data;
        if (user == null) {
          return RegisterOrLoginScreen(); // 🔹 Show Register/Login Options
        }

        return FutureBuilder<String?>(
          future: getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator())); // 🔄 Loading UI
            }

            String? role = roleSnapshot.data;
            bool isEmailVerified = user.emailVerified;

            if (!isEmailVerified) {
              return RoleSelectionScreen(); // 🔹 Force Login if not verified
            }

            switch (role) {
              case "student":
                return DashboardScreen(); // 🔹 Student Dashboard
              case "teacher":
                return TeacherDashboard(); // 🔹 Teacher Dashboard
              case "hod":
                return HodDashboard(); // 🔹 HOD Dashboard
              default:
                return RegisterOrLoginScreen(); // 🔹 Fallback to Register/Login
            }
          },
        );
      },
    );
  }

  /// **🔹 Fetch User Role from Firestore**
  Future<String?> getUserRole(String uid) async {
    try {
      // 🔹 Check in Students Collection
      DocumentSnapshot studentDoc =
      await FirebaseFirestore.instance.collection("students").doc(uid).get();
      if (studentDoc.exists) return "student";

      // 🔹 Check in Teachers Collection
      DocumentSnapshot teacherDoc =
      await FirebaseFirestore.instance.collection("teachers").doc(uid).get();
      if (teacherDoc.exists) return "teacher";

      // 🔹 Check in HODs Collection
      DocumentSnapshot hodDoc =
      await FirebaseFirestore.instance.collection("hods").doc(uid).get();
      if (hodDoc.exists) return "hod";

      return null; // ❌ User Role Not Found
    } catch (e) {
      print("❌ Error fetching user role: $e");
      return null;
    }
  }
}
