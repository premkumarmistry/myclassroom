import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HodRegistrationScreen extends StatefulWidget {
  @override
  _HodRegistrationScreenState createState() => _HodRegistrationScreenState();
}

class _HodRegistrationScreenState extends State<HodRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? selectedDepartment;
  bool isLoading = false;
  List<String> departments = []; // 🔹 Departments fetched from Firestore
  List<String> assignedDepartments = []; // 🔹 Already registered HODs' departments

  @override
  void initState() {
    super.initState();
    fetchDepartments();
    fetchAssignedDepartments();
  }

  /// **🔹 Fetch Departments from Firestore (Auto-Generated IDs)**
  void fetchDepartments() async {
    QuerySnapshot deptDocs = await _firestore.collection("departments").get();
    setState(() {
      departments = deptDocs.docs.map((doc) => doc["name"] as String).toList();
    });
  }

  /// **🔹 Fetch Already Assigned Departments**
  void fetchAssignedDepartments() async {
    QuerySnapshot hodDocs = await _firestore.collection("hods").get();
    setState(() {
      assignedDepartments = hodDocs.docs.map((doc) => doc["department"] as String).toList();
    });
  }

  /// **🔹 Register HOD & Send Email Verification**
  void registerHod() async {
    if (!_formKey.currentState!.validate()) return;

    if (assignedDepartments.contains(selectedDepartment)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This department already has a HOD assigned.")));
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      await user!.sendEmailVerification(); // Send Verification Email

      await _firestore.collection("hods").doc(user.uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "department": selectedDepartment,
        "uid": user.uid,
        "isVerified": false, // HOD needs verification
      });

      // 🔹 Show BottomSheet Confirmation
      showEmailVerificationBottomSheet();

      // Refresh assigned departments to prevent duplicate registrations
      fetchAssignedDepartments();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }
  /// **🔹 Common Text Field Builder**
  Widget buildTextField(String label, TextEditingController controller, {bool isEmail = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: isEmail
              ? Icon(Icons.email, color: Colors.deepPurple)
              : isPassword
              ? Icon(Icons.lock, color: Colors.deepPurple)
              : Icon(Icons.person, color: Colors.deepPurple),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Enter $label";

          // 🔹 Restrict email to "srict.ac.in" & "upluniversity.ac.in"
          if (isEmail && !(value.endsWith("@srict.ac.in") || value.endsWith("@upluniversity.ac.in"))) {
            return "Use university email (@srict.ac.in or @upluniversity.ac.in)";
          }

          if (isPassword && value.length < 6) return "Password must be at least 6 characters";
          return null;
        },
      ),
    );
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
                  Navigator.pop(context); // Close BottomSheet
                  Navigator.pushReplacementNamed(context, '/login'); // Redirect to Login
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
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("HOD Registration", style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
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
                        "Register as HOD",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 20),

                      buildTextField("Full Name", nameController),
                      buildTextField("University Email", emailController, isEmail: true),
                      buildDropdown("Select Department", departments, selectedDepartment, (val) {
                        setState(() => selectedDepartment = val);
                      }),
                      buildTextField("Password", passwordController, isPassword: true),

                      SizedBox(height: 25),

                      GestureDetector(
                        onTap: registerHod,
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

  Widget buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        value: selectedValue,
        items: items
            .where((dept) => !assignedDepartments.contains(dept)) // Hide assigned departments
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
