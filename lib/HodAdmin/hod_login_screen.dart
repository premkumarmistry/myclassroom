import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../ForgotPasswordScreen.dart';
import '../theme.dart';
import 'hod_dashboard.dart';

class HodLoginScreen extends StatefulWidget {
  @override
  _HodLoginScreenState createState() => _HodLoginScreenState();
}

class _HodLoginScreenState extends State<HodLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPasswordVisible = false; // Manage password visibility

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  /// **🔹 Login HOD & Check Verification**
  void loginHod() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all fields!")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔹 Sign In HOD
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed!")));
        return;
      }

      // 🔹 Check Email Verification
      if (!user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please verify your email before logging in!")));
        return;
      }

      // 🔹 Fetch HOD Details from Firestore
      DocumentSnapshot userDoc = await _firestore.collection("hods").doc(user.uid).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not found in HODs database!")));
        return;
      }

      // 🔹 Check if Admin Verified the HOD
      bool isVerified = userDoc["isVerified"] ?? false;
      if (!isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Admin has not verified your account yet!")));
        return;
      }

      // 🔹 Login Success → Navigate to HOD Dashboard
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HodDashboard()));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("HOD Login", style: TextStyle(color: Colors.white, fontSize: 20)),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "HOD Login",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    SizedBox(height: 20),

                    // 🔹 Email Input
                    buildTextField("Email", emailController, isEmail: true),

                    // 🔹 Password Input
                    buildTextField("Password", passwordController, isPassword: true),

                    SizedBox(height: 25),

                    // 🔹 Login Button
                    GestureDetector(
                      onTap: loginHod,
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

                    SizedBox(height: 10),

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
          ),
        ),
      ),
    );
  }

  /// **🔹 Common Text Field Builder**
  Widget buildTextField(String label, TextEditingController controller, {bool isEmail = false, bool isPassword = false}) {
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
