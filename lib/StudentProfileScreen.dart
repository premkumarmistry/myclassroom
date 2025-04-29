import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfileScreen extends StatefulWidget {
  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String email = "";
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  // 🔹 Fetch Student Details from Firestore
  Future<void> fetchStudentDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot studentDoc =
      await FirebaseFirestore.instance.collection("students").doc(user.uid).get();

      if (studentDoc.exists) {
        setState(() {
          nameController.text = studentDoc["name"] ?? "";
          phoneController.text = studentDoc["phone"] ?? "";
          email = studentDoc["email"] ?? "";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔹 Update Student Details
  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUpdating = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection("students").doc(user.uid).update({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error updating profile: $e"),
        backgroundColor: Colors.red,
      ));
    }

    setState(() => isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Student Profile", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.person, size: 80, color: Colors.deepPurple),
                SizedBox(height: 10),
                Text("Edit Profile",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                SizedBox(height: 15),

                // 🔹 Email (Non-editable)
                buildTextField("Email", email, isEditable: false),

                // 🔹 Editable Name & Phone Fields
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildEditableTextField("Full Name", nameController),
                      buildEditableTextField("Phone Number", phoneController, isPhone: true),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // 🔹 Update Button
                GestureDetector(
                  onTap: isUpdating ? null : updateProfile,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isUpdating
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Update Profile",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **🔹 Non-editable Email Field**
  Widget buildTextField(String label, String value, {bool isEditable = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        enabled: isEditable,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(isEditable ? Icons.edit : Icons.email, color: Colors.deepPurple),
        ),
      ),
    );
  }

  /// **🔹 Editable Name & Phone Fields**
  Widget buildEditableTextField(String label, TextEditingController controller, {bool isPhone = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(isPhone ? Icons.phone : Icons.person_2_rounded, color: Colors.deepPurple),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Enter $label";
          if (isPhone && value.length != 10) return "Enter a valid 10-digit phone number";
          return null;
        },
      ),
    );
  }
}
