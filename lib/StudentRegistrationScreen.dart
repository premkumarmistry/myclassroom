import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';

class StudentRegistrationScreen extends StatefulWidget {
  @override
  _StudentRegistrationScreenState createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  String? selectedProgram;
  String? selectedSpecialization;
  String? selectedSemester;

  List<String> programs = [];
  List<String> specializations = [];
  List<String> semesters = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  /// **🔹 Fetch Dropdown Values from Firestore**
  Future<void> fetchDropdownData() async {
    setState(() => isLoading = true);

    try {
      DocumentSnapshot programsDoc =
      await _firestore.collection("dropdowns").doc("streams").get();
      DocumentSnapshot branchesDoc =
      await _firestore.collection("dropdowns").doc("branches").get();
      DocumentSnapshot semestersDoc =
      await _firestore.collection("dropdowns").doc("semesters").get();

      setState(() {
        programs = List<String>.from(programsDoc["list"] ?? []);
        specializations = List<String>.from(branchesDoc["list"] ?? []);
        semesters = List<String>.from(semestersDoc["list"] ?? []);
      });

    } catch (e) {
      print("Error fetching dropdown data: $e");
    }

    setState(() => isLoading = false);
  }

  /// **🔹 Register User & Show Email Verification BottomSheet**
  void registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      await user!.sendEmailVerification(); // Send Email Verification

      await _firestore.collection('students').doc(user.uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'program': selectedProgram,
        'specialization': selectedSpecialization,
        'semester': selectedSemester,
        'uid': user.uid,
       // 'isVerified': false,
      });

      showEmailVerificationBottomSheet();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => isLoading = false);
  }

  /// **🔹 BottomSheet Dialog for Email Verification**
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
                "An email has been sent to your registered email address. Please check and verify your email before logging in.",
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
        title: Text("Student Registration", style: TextStyle(color: Colors.white, fontSize: 20)),
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
                        "Register as Student",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 20),

                      buildTextField("Full Name", nameController),
                      buildTextField("University Email", emailController, isEmail: true),
                      buildTextField("Phone Number", phoneController, isPhone: true),
                      buildTextField("Password", passwordController, isPassword: true),

                      buildDropdown("Select Program", programs, selectedProgram, (val) {
                        setState(() => selectedProgram = val);
                      }),
                      buildDropdown("Select Specialization", specializations, selectedSpecialization, (val) {
                        setState(() => selectedSpecialization = val);
                      }),
                      buildDropdown("Select Semester", semesters, selectedSemester, (val) {
                        setState(() => selectedSemester = val);
                      }),

                      SizedBox(height: 25),

                      GestureDetector(
                        onTap: registerUser,
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
          prefixIcon: Icon(Icons.text_fields, color: Colors.deepPurple),
        ),
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
