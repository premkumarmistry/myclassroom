import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // 🔹 Login User & Check Email Verification
  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (!user!.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please verify your email before logging in.")),
        );
        setState(() => isLoading = false);
        return;
      }

      Navigator.pushReplacementNamed(context, '/dashboard');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: SingleChildScrollView( // 🔹 Fixes Overflow Issue
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox( // 🔹 Prevents Overflow
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8, // 🔹 Adapts to screen size
              ),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 80, color: Colors.deepPurple),
                      SizedBox(height: 20),
                      Text("Login to Your Account",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),

                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: loginUser,
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Login"),
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
}
