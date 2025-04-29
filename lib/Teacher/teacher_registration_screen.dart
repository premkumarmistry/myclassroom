import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  @override
  _TeacherRegistrationScreenState createState() => _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? selectedDepartment;
  List<String> departments = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  /// **🔹 Fetch Department List from Firestore**
  Future<void> fetchDepartments() async {
    try {
      DocumentSnapshot departmentDoc =
      await FirebaseFirestore.instance.collection("dropdowns").doc("branches").get();

      setState(() {
        departments = List<String>.from(departmentDoc["list"] ?? []);
      });
    } catch (e) {
      print("Error fetching departments: $e");
    }
  }

  /// **🔹 Register Teacher & Send Email Verification**
  void registerTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      await user!.sendEmailVerification(); // Send Verification Email

      await _firestore.collection("teachers").doc(user.uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "department": selectedDepartment,
        "assigned_subjects": [],
        "uid": user.uid,
        "isVerified": false, // Mark as unverified initially
      });

      showEmailVerificationBottomSheet();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  /// **🔹 Show BottomSheet Confirmation**
  void showEmailVerificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 50, color: Colors.deepPurple),
              SizedBox(height: 10),
              Text(
                "Please Verify Your Email",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "A verification email has been sent to your registered email address. Please verify before logging in.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("Back to Login", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Teacher Registration", style: TextStyle(color: Colors.white, fontSize: 20)),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Register as Teacher",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 20),

                      buildTextField("Full Name", nameController),
                      buildTextField("University Email", emailController, isEmail: true),
                      buildTextField("Phone Number", phoneController, isPhone: true),
                      buildDropdown("Select Department", departments, selectedDepartment, (val) {
                        setState(() => selectedDepartment = val);
                      }),
                      buildTextField("Password", passwordController, isPassword: true),

                      SizedBox(height: 25),

                      GestureDetector(
                        onTap: registerTeacher,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              "Register & Verify Email",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// **🔹 Common Text Field Builder**
  Widget buildTextField(String label, TextEditingController controller,
      {bool isEmail = false, bool isPhone = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.phone : isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: isEmail
              ? Icon(Icons.email, color: Colors.deepPurple)
              : isPhone
              ? Icon(Icons.phone, color: Colors.deepPurple)
              : isPassword
              ? Icon(Icons.lock, color: Colors.deepPurple)
              : Icon(Icons.person, color: Colors.deepPurple),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Enter $label";

          if (isEmail &&
              !(value.endsWith("@srict.in") || value.endsWith("@upluniversity.ac.in"))) {
            return "Use university email (@srict.in or @upluniversity.ac.in)";
          }

          if (isPhone && value.length != 10) return "Enter a valid 10-digit phone number";
          if (isPassword && value.length < 6) return "Password must be 6+ characters";
          return null;
        },
      ),
    );
  }

  /// **🔹 Common Dropdown Builder**
  Widget buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        value: selectedValue,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
