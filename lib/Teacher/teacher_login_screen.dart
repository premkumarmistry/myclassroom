import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../ForgotPasswordScreen.dart';
import '../theme.dart';
import 'teacher_dashboard.dart';

class TeacherLoginScreen extends StatefulWidget {
  @override
  _TeacherLoginScreenState createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false; // Manage password visibility

  /// **🔹 Login & Check Email Verification + isVerified Status**
  void loginTeacher() async {
    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user == null) {
        showToast("Login Failed!", Colors.red);
        return;
      }

      // 🔹 Check if Email is Verified
      if (!user.emailVerified) {
        showToast("Please verify your email before logging in.", Colors.orange);
        await user.sendEmailVerification(); // Resend verification email
        return;
      }

      // 🔹 Check if Teacher is Approved (isVerified = true)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("teachers").doc(user.uid).get();
      if (!userDoc.exists) {
        showToast("User not found in teachers database!", Colors.red);
        return;
      }

      bool isVerified = userDoc["isVerified"] ?? false;
      if (!isVerified) {
        showToast("Your account is pending approval from HOD.", Colors.orange);
        return;
      }

      showToast("Login Successful!", Colors.green);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeacherDashboard()));

    } catch (e) {
      showToast("Login Failed: ${e.toString()}", Colors.red);
    }

    setState(() => isLoading = false);
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
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text("Teacher Login", style: TextStyle(color: Colors.white, fontSize: 20)),
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
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 40), // Move the card upwards
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, size: 60, color: Colors.deepPurple),
                      SizedBox(height: 5),
                      Text(
                        "Teacher Login",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 20),

                      buildTextField("Email", emailController, isEmail: true),
                      buildTextField("Password", passwordController, isPassword: true),

                      SizedBox(height: 20),

                      GestureDetector(
                        onTap: loginTeacher,
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
                              "Login",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: Text(
                          "Don't have an account? Register",
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                        ),
                      ),

                      SizedBox(height: 30),

                      GestureDetector(
                        onTap: () {
                          // Direct navigation to the RegisterScreen without using routes
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordScreen()), // Directly passing the RegisterScreen widget
                          );
                        },
                        child: Text(
                          "Forget Password?",
                          style: TextStyle(fontSize: 16, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **🔹 Common Text Field Builder**
  Widget buildTextField(String label, TextEditingController controller,
      {bool isEmail = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,

        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: isEmail
              ? Icon(Icons.email, color: Colors.deepPurple)
              : isPassword
              ? Icon(Icons.lock, color: Colors.deepPurple)
              : Icon(Icons.person, color: Colors.deepPurple),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
              });
            },
          )
              :null,
        ),
        validator: (value) {
          if (value!.isEmpty) return "Enter $label";
          return null;
        },
      ),
    );
  }
}
