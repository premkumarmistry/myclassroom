import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyTeachersScreen extends StatefulWidget {
  @override
  _VerifyTeachersScreenState createState() => _VerifyTeachersScreenState();
}

class _VerifyTeachersScreenState extends State<VerifyTeachersScreen> {
  String? hodDepartment;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHodDepartment();
  }

  /// **🔹 Fetch HOD's Assigned Department**
  Future<void> fetchHodDepartment() async {
    setState(() => isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot hodDoc = await FirebaseFirestore.instance.collection("hods").doc(user.uid).get();
      if (hodDoc.exists) {
        setState(() {
          hodDepartment = hodDoc["department"];
        });
      }
    }

    setState(() => isLoading = false);
  }

  /// **🔹 Approve Teacher (Set `isVerified = true`)**
  void approveTeacher(String teacherId) async {
    try {
      await FirebaseFirestore.instance.collection("teachers").doc(teacherId).update({"isVerified": true});
      showToast("Teacher approved successfully!", Colors.green);
    } catch (e) {
      showToast("Error approving teacher!", Colors.red);
    }
  }

  /// **🔹 Reject Teacher (Delete Record)**
  void rejectTeacher(String teacherId) async {
    try {
      await FirebaseFirestore.instance.collection("teachers").doc(teacherId).delete();
      showToast("Teacher rejected successfully!", Colors.red);
    } catch (e) {
      showToast("Error rejecting teacher!", Colors.red);
    }
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
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Verify Teachers", style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Pending Teacher Approvals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("teachers")
                    .where("department", isEqualTo: hodDepartment)
                    .where("isVerified", isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  var teachers = snapshot.data!.docs;
                  if (teachers.isEmpty) return Center(child: Text("No pending approvals"));

                  return ListView.builder(
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      var teacher = teachers[index];
                      return buildTeacherCard(teacher);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **🔹 Build Teacher Card**
  Widget buildTeacherCard(QueryDocumentSnapshot teacher) {
    String teacherId = teacher.id;
    String name = teacher["name"];
    String email = teacher["email"];
    String phone = teacher["phone"];
    String department = teacher["department"];

    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            Text("📞 $phone", style: TextStyle(fontSize: 16, color: Colors.black87)),
            Text("📚 Department: $department", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => approveTeacher(teacherId),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Approve",  style: TextStyle(fontSize: 16, color: Colors.white),),
                ),
                ElevatedButton(
                  onPressed: () => rejectTeacher(teacherId),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Reject", style: TextStyle(fontSize: 16, color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
